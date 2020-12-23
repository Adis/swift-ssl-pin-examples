//
//  DetailViewController+URLSessionDelegate.swift
//  SSL-Pinning
//
//  Created by Adis on 23.12.2020..
//  Copyright © 2020 Adis. All rights reserved.
//

import Foundation

extension DetailViewController {
    func requestWithURLSessionDelegate(pinning: Bool) {
        guard let urlString = endpointTextfield.text,
              let url = URL(string: urlString) else {
            showResult(success: false)
            return
        }

        /// When not pinning, we simply skip setting our own delegate		
        let session = URLSession(configuration: .default, delegate: pinning ? self : nil, delegateQueue: nil)

        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                if response != nil { self?.showResult(success: true) }
            }
        })

        task.resume()
    }
}

extension DetailViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            // This case will probably get handled by ATS, but still...
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

          /// Compare the server certificate with our own stored
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
            } else {
                /// Failing here means that the public key of the server does not match the stored one. This can
                /// either indicate a MITM attack, or that the backend certificate and the private key changed,
                /// most likely due to expiration.
                completionHandler(.cancelAuthenticationChallenge, nil)
                showResult(success: false, pinError: true)
                return
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
        showResult(success: false)
    }

    private func pinnedCertificates() -> [Data] {
        var certificates: [Data] = []

        if let pinnedCertificateURL = Bundle.main.url(forResource: "stackoverflow", withExtension: "cer") {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL)
                certificates.append(pinnedCertificateData)
            } catch {
                // Handle error
            }
        }

        return certificates
    }

    private func pinnedKeys() -> [SecKey] {
        var publicKeys: [SecKey] = []

        if let pinnedCertificateURL = Bundle.main.url(forResource: "stackoverflow", withExtension: "cer") {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL) as CFData
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
                    publicKeys.append(key)
                }
            } catch {
                // Handle error
            }
        }

        return publicKeys
    }

    /// Implementation from Alamofire
    private func publicKey(for certificate: SecCertificate) -> SecKey? {
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
