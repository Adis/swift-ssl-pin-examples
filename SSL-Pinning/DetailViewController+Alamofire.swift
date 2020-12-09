//
//  DetailViewController+Alamofire.swift
//  SSL-Pinning
//
//  Created by Adis on 09.12.2020..
//  Copyright © 2020 Adis. All rights reserved.
//

import Foundation
import Alamofire

extension DetailViewController {
    func requestWithAlamofire(pinning: Bool) {
        guard let urlString = endpointTextfield.text,
              let url = URL(string: urlString) else {
            showResult(success: false)
            return
        }

        if pinning {
            // This is where the pinning happens, you choose how to handle specific domains individually.
            // You could use PinnedCertificatesTrustEvaluator() as well, check
            // https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#security
            // for additional documentation.
            let evaluators: [String: ServerTrustEvaluating] = [
                "stackoverflow.com": PublicKeysTrustEvaluator()
            ]

            let manager = ServerTrustManager(evaluators: evaluators)

            session = Session(serverTrustManager: manager)
        } else {
            session = Session()
        }

        session!
            .request(url, method: .get)
            .validate()
            .response(completionHandler: { [weak self] response in
                switch response.result {
                case .success:
                    self?.showResult(success: true)
                case .failure(let error):
                    switch error {
                    case .serverTrustEvaluationFailed(let reason):
                        // The reason here is a place where you might fine-tune your
                        // error handling and possibly deduce if it's an actualy MITM
                        // or just another error, like certificate issue.
                        //
                        // In this case, this will show `noRequiredEvaluator` if you try
                        // testing against a domain not in the evaluators list which is
                        // the closest I'm willing to setting up a MITM. In production,
                        // it will most likely be one of the other evaluation errors.
                        print(reason)

                        self?.showResult(success: false, pinError: true)
                    default:
                        self?.showResult(success: false)
                    }
                }
            })
    }
}
