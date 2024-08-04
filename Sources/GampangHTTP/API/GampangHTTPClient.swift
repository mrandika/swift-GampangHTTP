//
//  GampangHTTPClient.swift
//  
//
//  Created by Andika on 04/08/24.
//

import Foundation

/// A configurable HTTP client for making network requests with advanced features.
public class GampangHTTPClient {
    private var session: URLSession
    private let cache: URLCache
    private let logger: GampangLogger
    private let retryPolicy: GampangRetryPolicy
    private let certificatePinning: GampangCertificatePinning?
        
    /// Initializes a new GampangHTTPClient with customizable components.
    ///
    /// - Parameters:
    ///   - session: The URLSession to use for network requests. Defaults to URLSession.shared.
    ///   - cache: The URLCache to use for caching responses. Defaults to URLCache.shared.
    ///   - logger: The logger to use for logging operations. Defaults to GampangConsoleLogger.
    ///   - retryPolicy: The retry policy to use for failed requests. Defaults to GampangDefaultRetryPolicy.
    ///   - pinnedCertificates: An optional array of certificate data for certificate pinning.
    public init(
        session: URLSession = .shared,
        cache: URLCache = .shared,
        logger: GampangLogger = GampangConsoleLogger(),
        retryPolicy: GampangRetryPolicy = GampangDefaultRetryPolicy(),
        pinnedCertificates: [Data]? = nil
    ) {
        self.session = session
        self.cache = cache
        self.logger = logger
        self.retryPolicy = retryPolicy
        
        if let pinnedCertificates = pinnedCertificates {
            self.certificatePinning = GampangCertificatePinning(pinnedCertificates: pinnedCertificates)
            let configuration = URLSessionConfiguration.default
            self.session = URLSession(configuration: configuration, delegate: self.certificatePinning, delegateQueue: nil)
        } else {
            self.certificatePinning = nil
        }
    }
    
    /// Performs an HTTP request and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be executed.
    ///   - resultType: The type to decode the response into.
    /// - Returns: The decoded response of type T.
    /// - Throws: An error if the request fails, decoding fails, or the request is cancelled.
    public func request<T: Decodable>(
        with request: URLRequest,
        of resultType: T.Type
    ) async throws -> T {
        var currentRequest = request
        var attempt = 0
        
        return try await withTaskCancellationHandler {
            while true {
                do {
                    let (data, response) = try await executeRequest(currentRequest)
                    logger.log("Response received for \(currentRequest.url?.absoluteString ?? "")")
                    
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    if Task.isCancelled {
                        throw GampangClientError.cancelled
                    }
                    
                    attempt += 1
                    if let retryDelay = retryPolicy.shouldRetry(error: error, attempt: attempt) {
                        logger.log("Retrying request after \(retryDelay) seconds")
                        try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                        currentRequest = retryPolicy.modifyRequest(currentRequest, attempt: attempt)
                    } else {
                        throw error
                    }
                }
            }
        } onCancel: {
            logger.log("Request cancelled: \(request.url?.absoluteString ?? "")")
        }
    }
    
    /// Executes a URLRequest, handling caching and logging.
    ///
    /// - Parameter request: The URLRequest to be executed.
    /// - Returns: A tuple containing the response data and URLResponse.
    /// - Throws: An error if the request fails.
    private func executeRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        if let cachedResponse = cache.cachedResponse(for: request) {
            logger.log("Using cached response for \(request.url?.absoluteString ?? "")")
            return (cachedResponse.data, cachedResponse.response)
        }
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           (200...299).contains(httpResponse.statusCode) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        
        return (data, response)
    }
}
