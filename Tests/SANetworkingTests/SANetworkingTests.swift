import XCTest
import Combine

@testable import SANetworking

final class SANetworkingTests: XCTestCase {
    var reachability = ReachabilityMock()
    var api = ApiMock()
    var urlRequest = URLRequest(url: URL(string: "www.google/com")!)

    private var cancellables = Set<AnyCancellable>()

    func test_unreachable() {
        let api = ApiClient(reachability: reachability)

        api.make(urlRequest)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error as! ApiError, .offline)
                case .finished:
                    XCTFail()
                }
            } receiveValue: { data in
            }
            .store(in: &cancellables)
    }

    func test_encoding() {
        api.jsonStatus = encodedData

        testType()
            .sink { completion in
                switch completion {
                case .failure:
                    XCTFail()
                case .finished:
                    return
                    /// receive value
                }
            } receiveValue: { response in
                XCTAssertEqual(response.status, "OK")
            }
            .store(in: &cancellables)
    }

    func test_wrongEncoding() {
        api.jsonStatus = errorData

        testType()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .decodable)
                case .finished:
                    XCTFail()
                    /// receive value
                }
            } receiveValue: { response in
            }
            .store(in: &cancellables)

    }

    private func testType() -> AnyPublisher<He, ApiError> {
        let service = NetworkServiceImpls(api: api)

        return service.makeEncodable(urlRequest)
            .eraseToAnyPublisher()
    }

    private var encodedData: String {
        """
    { "status" : "OK" }
    """
    }

    private var errorData: String {
        """
    { "someOtherData" : "OK" }
    """
    }
}

struct He: Codable {
    let status: String
}

struct ReachabilityMock: NetworkReachability {
    var networkAvailableMan = false

    func networkAvailable() -> Bool {
        return networkAvailableMan
    }
}

struct ApiMock: ApiRequest {
    var jsonStatus: String = ""

    func make(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        return Just(jsonStatus.data(using: .utf8)!)
            .mapError({ err in
                err
            })
            .eraseToAnyPublisher()
    }
}
