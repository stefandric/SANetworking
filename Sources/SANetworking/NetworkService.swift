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

protocol NetworkService {
    func makeEncodable<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, ApiError>
}

public struct NetworkServiceImpls: NetworkService {

    private let apiService: ApiRequest

    public init(api: ApiRequest) {
        self.apiService = api
    }


    public func makeEncodable<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, ApiError> {
        apiService.make(request)
            .tryMap { data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }
            .mapError { error -> ApiError in
                if let error = error as? ApiError {
                    return error
                }

                return .decodable
            }
            .eraseToAnyPublisher()
    }
}
