//
//  GampangRetryPolicy.swift
//  
//
//  Created by Andika on 04/08/24.
//

import Foundation

/// A protocol defining the retry policy for failed requests.
public protocol GampangRetryPolicy {
    /// Determines whether a request should be retried and provides a delay if applicable.
    ///
    /// - Parameters:
    ///   - error: The error that occurred during the request.
    ///   - attempt: The current attempt number.
    /// - Returns: The delay before the next retry attempt, or nil if no retry should be attempted.
    func shouldRetry(error: Error, attempt: Int) -> TimeInterval?
    
    /// Modifies a request for a retry attempt.
    ///
    /// - Parameters:
    ///   - request: The original URLRequest.
    ///   - attempt: The current attempt number.
    /// - Returns: A modified URLRequest for the retry attempt.
    func modifyRequest(_ request: URLRequest, attempt: Int) -> URLRequest
}

/// A default implementation of the GampangRetryPolicy.
public struct GampangDefaultRetryPolicy: GampangRetryPolicy {
    private let maxAttempts: Int
    private let baseDelay: TimeInterval
    
    /// Initializes a new GampangDefaultRetryPolicy.
    ///
    /// - Parameters:
    ///   - maxAttempts: The maximum number of retry attempts. Defaults to 3.
    ///   - baseDelay: The base delay between retries, in seconds. Defaults to 1.0.
    public init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
    }
    
    /// Implements the shouldRetry method of GampangRetryPolicy.
    public func shouldRetry(error: Error, attempt: Int) -> TimeInterval? {
        guard attempt < maxAttempts else { return nil }
        return baseDelay * pow(2.0, Double(attempt - 1))
    }
    
    /// Implements the modifyRequest method of GampangRetryPolicy.
    public func modifyRequest(_ request: URLRequest, attempt: Int) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("\(attempt)", forHTTPHeaderField: "X-Retry-Attempt")
        return modifiedRequest
    }
}
