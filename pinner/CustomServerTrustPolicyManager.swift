//
//  CustomServerTrustPolicyManager.swift
//  pinner
//
//  Created by Adis on 19/09/2017.
//  Copyright © 2017 Infinum. All rights reserved.
//

import UIKit
import Alamofire

class CustomServerTrustPolicyManager: ServerTrustPolicyManager {

    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        // Check if we have a policy already defined, otherwise just kill the connection
        if let policy = super.serverTrustPolicy(forHost: host) {
            print(policy)
            return policy
        } else {
            return .customEvaluation({ (_, _) -> Bool in
                return false
            })
        }
    }

}
