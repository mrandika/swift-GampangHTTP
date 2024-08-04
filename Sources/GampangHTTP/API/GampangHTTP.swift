//
//  GampangHTTP.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

/// A high-level HTTP client for making network requests.
public struct GampangHTTP {
    /// Makes a network request and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be executed.
    ///   - resultType: The type to decode the response into.
    /// - Returns: The decoded response of type T.
    /// - Throws: A GampangError if the request fails or if decoding fails.
    public static func request<T: Decodable>(
        with request: URLRequest,
        of resultType: T.Type
    ) async throws -> T {
        let client = GampangHTTPClient()
        
        do {
            return try await client.request(with: request, of: resultType)
        } catch let error as GampangHTTPError {
            throw GampangClientError.httpError(error)
        } catch {
            throw GampangClientError.decodingError(error)
        }
    }
}
