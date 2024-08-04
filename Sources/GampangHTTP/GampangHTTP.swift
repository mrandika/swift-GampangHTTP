//
//  GampangHTTP.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

/// A high-level HTTP client for making network requests.
public struct GampangHTTP {
    private let session: URLSession
    private let cache: URLCache?
    private let logger: GampangLogger
    private let retryPolicy: GampangRetryPolicy
    private let certificatePinning: GampangCertificatePinning?
    
    /// Initializes a new GampangHTTP instance with customizable components.
    ///
    /// - Parameters:
    ///   - session: The URLSession to use for network requests. Defaults to a custom configured session.
    ///   - cache: The URLCache to use for caching responses. If nil, caching is disabled. Defaults to a custom configured cache.
    ///   - logger: The logger to use for logging operations. Defaults to GampangConsoleLogger.
    ///   - retryPolicy: The retry policy to use for failed requests. Defaults to GampangDefaultRetryPolicy.
    ///   - pinnedCertificates: An array of certificate data for certificate pinning. If nil, certificate pinning is disabled. Defaults to nil.
    public init(
        session: URLSession? = nil,
        cache: URLCache? = URLCache(memoryCapacity: 10_000_000, diskCapacity: 100_000_000, diskPath: "gampang_http_response_cache"),
        logger: GampangLogger = GampangConsoleLogger(),
        retryPolicy: GampangRetryPolicy = GampangDefaultRetryPolicy(),
        pinnedCertificates: [Data]? = nil
    ) {
        self.cache = cache
        self.logger = logger
        self.retryPolicy = retryPolicy
        
        if let pinnedCertificates = pinnedCertificates {
            self.certificatePinning = GampangCertificatePinning(pinnedCertificates: pinnedCertificates)
        } else {
            self.certificatePinning = nil
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = self.cache
        
        if let session = session {
            self.session = session
        } else {
            if let certPinning = self.certificatePinning {
                self.session = URLSession(configuration: configuration, delegate: certPinning, delegateQueue: nil)
            } else {
                self.session = URLSession(configuration: configuration)
            }
        }
    }
    
    /// Performs an HTTP request and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be executed.
    ///   - resultType: The type to decode the response into.
    /// - Returns: The decoded response of type T.
    /// - Throws: A GampangClientError if the request fails, decoding fails, or the request is cancelled.
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
                        throw GampangClientError.httpError(.unknown(code: -1))
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
        if let cache = cache, let cachedResponse = cache.cachedResponse(for: request) {
            logger.log("Using cached response for \(request.url?.absoluteString ?? "")")
            return (cachedResponse.data, cachedResponse.response)
        }
        
        let (data, response) = try await session.data(for: request)
        
        if let cache = cache,
           let httpResponse = response as? HTTPURLResponse,
           (200...299).contains(httpResponse.statusCode) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        
        return (data, response)
    }
}
