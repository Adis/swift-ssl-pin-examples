//
//  DetailViewController+CustomPolicyManager.swift
//  SSL-Pinning
//
//  Created by Adis on 09.12.2020..
//  Copyright © 2020 Adis. All rights reserved.
//

import Foundation
import Alamofire

extension DetailViewController {
    func requestWithCustomPolicyManager() {
        guard let urlString = endpointTextfield.text,
              let url = URL(string: urlString) else {
            showResult(success: false)
            return
        }

        
    }
}
