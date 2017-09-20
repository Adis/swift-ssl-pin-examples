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
        // You can change the hostname here to force a failure
        if host == "infinum.co" {
            return .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            )
        } else {
            return .customEvaluation({ (_, _) -> Bool in
                return false
            })
        }
    }

}

