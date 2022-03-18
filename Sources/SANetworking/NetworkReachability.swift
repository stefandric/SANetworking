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
