//
//  Copyright © 2022 stefandric. All rights reserved.
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

public protocol ApiRequest {
    func make(_ request: URLRequest) -> AnyPublisher<Data, Error>
}

public enum ApiError: Error {
    case generic
    case unauthorized
    case offline
    case decodable
}

public struct ApiClient: ApiRequest {

    private let reachability: NetworkReachability

    public init(reachability: NetworkReachability) {
        self.reachability = reachability
    }

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
            /// Handle case when data is actually descriptive error
            if httpResponse.statusCode == 401 {
                throw ApiError.unauthorized
            } else {
                throw ApiError.generic
            }
        }
    }
}
