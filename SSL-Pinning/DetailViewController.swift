//
//  DetailViewController.swift
//  SSL-Pinning
//
//  Created by Adis on 30/08/2020.
//  Copyright © 2020 Adis. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {

    @IBOutlet var pinEnabledSwitch: UISwitch!
    @IBOutlet var endpointTextfield: UITextField!
    @IBOutlet var resultLabel: UILabel!

    var method: PinMethod = .alamofire
    var session: Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        endpointTextfield.text = "https://stackoverflow.com/"
    }

    @IBAction private func testPin() {
        switch method {
        case .alamofire:
            requestWithAlamofire(pinning: pinEnabledSwitch.isOn)
        default:
            showResult(success: false)
        }
    }

    func showResult(success: Bool, pinError: Bool = false) {
        if success {
            resultLabel.textColor = UIColor(red:0.00, green:0.75, blue:0.00, alpha:1.0)
            resultLabel.text = "🚀 Success"
        } else {
            resultLabel.textColor = .white
            if pinError {
                resultLabel.text = "✅ Request failed successfully"
            } else {
                resultLabel.text = "🚫 Request failed"
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.resultLabel.text = ""
        }
    }
}
