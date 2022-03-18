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

public enum NetworkRequestType: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

final public class EndpointBuilder {
    private let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    /// Use this method if there are parameters that needs to be sent
    public func request<T: Encodable>(for path: String,
                                      method: NetworkRequestType,
                                      isAuthorized: Bool,
                                      parameters: T) -> URLRequest {
        var urlRequest = makeUrlRequest(for: path, method: method, isAuthorized: isAuthorized)
        urlRequest.httpBody = try? JSONEncoder().encode(parameters)

        return urlRequest
    }

    /// Use this method for sending a request without parameters
    public func request(for path: String,
                        method: NetworkRequestType,
                        isAuthorized: Bool) -> URLRequest {
        makeUrlRequest(for: path, method: method, isAuthorized: isAuthorized)
    }

}

private extension EndpointBuilder {

    private func makeUrlRequest(for path: String,
                        method: NetworkRequestType,
                        isAuthorized: Bool) -> URLRequest {
        var urlRequest = URLRequest(url: endpoint(path: path))
        urlRequest.httpMethod = method.rawValue

        urlRequest.allHTTPHeaderFields = isAuthorized ? authorizedHeaders() : baseHeaders()

        return urlRequest
    }

    private func endpoint(path: String, isSecure: Bool = true) -> URL {
        var components = URLComponents()

        components.scheme = isSecure ? "https" : "http"
        components.host = baseURL
        components.path = path

        return components.url!
    }

    private func baseHeaders() -> [String: String] {
        var dict = ["content-type": "application/json"]
        dict["user-agent"] = "os: iOS"
        return dict
    }

    private func authorizedHeaders() -> [String: String] {
        var headers = baseHeaders()
        headers["Authorization"] = "Bearer token"

        return headers
    }
}


