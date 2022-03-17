//
//  Copyright © 2021. All rights reserved.
//
//
// .------..------..------..------..------..------..------..------..------.
// |P.--. ||E.--. ||T.--. ||I.--. ||Q.--. ||L.--. ||O.--. ||U.--. ||S.--. |
// | :/\: || (\/) || :/\: || (\/) || (\/) || :/\: || :/\: || (\/) || :/\: |
// | (__) || :\/: || (__) || :\/: || :\/: || (__) || :\/: || :\/: || :\/: |
// | '--'P|| '--'E|| '--'T|| '--'I|| '--'Q|| '--'L|| '--'O|| '--'U|| '--'S|
// `------'`------'`------'`------'`------'`------'`------'`------'`------'
//

import Foundation
import Combine
import Network

public protocol ApiRequest {
    func make(_ request: URLRequest) -> AnyPublisher<Data, Error>
}

public enum ApiError: Error {
    case generic
    case unauthorized
    case offline
}

public struct ApiClient: ApiRequest {

    private let reachability: NetworkReachability = NetworkReachabilityImpl()

    public init() { }

    public func make(_ request: URLRequest) -> AnyPublisher<Data, Error> {

        guard reachability.networkAvailable() else {
            return Fail(error: ApiError.offline)
                .eraseToAnyPublisher()
        }

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                try handleResponse(data: data, response: response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func handleResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.generic
        }

        if 200..<300 ~= httpResponse.statusCode {
            return data
        } else {
            if httpResponse.statusCode == 401 {
                throw ApiError.unauthorized
            } else {
                throw ApiError.generic
            }
        }
    }
}

protocol NetworkReachability {
    func networkAvailable() -> Bool
}

final class NetworkReachabilityImpl: NetworkReachability {
    var pathMonitor: NWPathMonitor

    private var isConnected = true

    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }

        pathMonitor.start(queue: DispatchQueue.global(qos: .background))
    }

    func networkAvailable() -> Bool {
        isConnected
    }
}
