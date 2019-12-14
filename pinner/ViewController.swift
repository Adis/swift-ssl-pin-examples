//
//  ViewController.swift
//  pinner
//
//  Created by Adis on 15/09/2017.
//  Copyright © 2017 Infinum. All rights reserved.
//

import UIKit

import Alamofire

class ViewController: UIViewController {
    
    var sessionManager = SessionManager()
    let customSessionDelegate = CustomSessionDelegate()
    
    @IBOutlet weak var resultLabel: UILabel!

    let domain = "https://www.stackoverflow.com"
    let shortDomain = "stackoverflow.com"
    let certificateURL = Bundle.main.url(forResource: "so", withExtension: "crt")

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions -
    
    fileprivate func showResult(success: Bool) {
        if success {
            resultLabel.textColor = UIColor(red:0.00, green:0.75, blue:0.00, alpha:1.0)
            resultLabel.text = "🚀 Success"
        } else {
            resultLabel.textColor = .black
            resultLabel.text = "🚫 Request failed"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.resultLabel.text = ""
        }
    }
    
    @IBAction func testWithNoPin() {
        Alamofire.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }
    
    @IBAction func testWithAlamofireDefaultPin() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            shortDomain: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
        sessionManager = SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(
                policies: serverTrustPolicies
            )
        )
        
        sessionManager.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }
    
    @IBAction func testWithCustomPolicyManager() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            shortDomain: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
        sessionManager = SessionManager(
            serverTrustPolicyManager: CustomServerTrustPolicyManager(
                policies: serverTrustPolicies
            )
        )
        
        sessionManager.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }
    
    @IBAction func testWithNSURLSessionPin() {
        let url = URL(string: domain)! // Pardon my assumption
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                self.showResult(success: response != nil)
            }
        })
        task.resume()
    }
    
    @IBAction func testWithCustomSessionDelegate() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            shortDomain: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]

        sessionManager = SessionManager(
            delegate: customSessionDelegate, // Feeding our own session delegate
            serverTrustPolicyManager: CustomServerTrustPolicyManager(
                policies: serverTrustPolicies
            )
        )
        
        sessionManager.request(domain).response { response in
            self.showResult(success: response.response != nil)
        }
    }

}

extension ViewController: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            // This case will probably get handled by ATS, but still...
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Compare the server certificate with our own stored
//        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
//            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
//
//            if pinnedCertificates().contains(serverCertificateData) {
//                completionHandler(.useCredential, URLCredential(trust: trust))
//                return
//            }
//        }
        
        // Or, compare the public keys
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0), let serverCertificateKey = publicKey(for: serverCertificate) {
            if pinnedKeys().contains(serverCertificateKey) {
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    fileprivate func pinnedCertificates() -> [Data] {
        var certificates: [Data] = []
        
        if let pinnedCertificateURL = certificateURL {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL)
                certificates.append(pinnedCertificateData)
            } catch (_) {
                // Handle error
            }
        }
        
        return certificates
    }
    
    fileprivate func pinnedKeys() -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        if let pinnedCertificateURL = certificateURL {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL) as CFData
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
                    publicKeys.append(key)
                }
            } catch (_) {
                // Handle error
            }
        }
        
        return publicKeys
    }
    
    // Implementation from Alamofire
    fileprivate func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
    
}

