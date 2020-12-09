//
//  ListViewController.swift
//  SSL-Pinning
//
//  Created by Adis on 30/08/2020.
//  Copyright © 2020 Adis. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Method list"
    }

    @IBAction private func _showAlamofirePin() {
        _showDetailViewController(method: .alamofire)
    }

    @IBAction private func _showCustomPolicyPin() {
        _showDetailViewController(method: .customPolicyManager)
    }

    @IBAction private func _showURLSessionPin() {
        _showDetailViewController(method: .NSURLSession)
    }

    private func _showDetailViewController(method: PinMethod) {
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
        navigationController?.pushViewController(detailViewController!, animated: true)
    }

}
