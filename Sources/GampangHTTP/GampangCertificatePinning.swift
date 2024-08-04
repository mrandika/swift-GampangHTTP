//
//  GampangCertificatePinning.swift
//  
//
//  Created by Andika on 04/08/24.
//

import Foundation
import Security

/// A class that implements certificate pinning for URLSession.
public class GampangCertificatePinning: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [Data]
    
    /// Initializes a new GampangCertificatePinning instance.
    ///
    /// - Parameter pinnedCertificates: An array of Data objects representing the pinned certificates.
    public init(pinnedCertificates: [Data]) {
        self.pinnedCertificates = pinnedCertificates
    }
    
    /// Implements the URLSessionDelegate method to handle SSL/TLS challenge.
    ///
    /// This method verifies the server's certificate against the pinned certificates.
    ///
    /// - Parameters:
    ///   - session: The session containing the challenge.
    ///   - challenge: The authentication challenge.
    ///   - completionHandler: The completion handler to call with the result of the challenge.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let trustResult = SecTrustEvaluateWithError(serverTrust, nil)
        
        guard trustResult else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        for certificate in certificates {
            let serverCertificateData = SecCertificateCopyData(certificate) as Data
            
            if pinnedCertificates.contains(serverCertificateData) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
