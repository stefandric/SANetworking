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

import Network

public protocol NetworkReachability {
    func networkAvailable() -> Bool
}

public final class NetworkReachabilityImpl: NetworkReachability {
    var pathMonitor: NWPathMonitor

    private var isConnected = true

    public init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }

        pathMonitor.start(queue: DispatchQueue.global(qos: .background))
    }

    public func networkAvailable() -> Bool {
        isConnected
    }
}
