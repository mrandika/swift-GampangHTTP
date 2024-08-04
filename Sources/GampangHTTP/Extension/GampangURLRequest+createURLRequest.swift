//
//  GampangURLRequest+createURLRequest.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

extension GampangURLRequest {
    /// Creates a URLRequest from the given parameters.
    ///
    /// - Parameters:
    ///   - url: The URL string for the request.
    ///   - method: The HTTP method.
    ///   - body: The request body as key-value pairs.
    ///   - data: Raw data for the request body.
    ///   - queryItems: Query items to be appended to the URL.
    ///   - headers: Custom headers for the request.
    /// - Returns: A URLRequest configured with the given parameters.
    /// - Throws: An error if the URL is invalid or if there's an issue creating the request.
    public static func createURLRequest(
        _ url: String,
        method: HTTPMethod,
        body: [String: Any]? = nil,
        data: Data? = nil,
        queryItems: [URLQueryItem] = [],
        headers: [(field: HTTPHeaderField, value: String)]? = nil
    ) throws -> URLRequest {
        return try GampangURLRequest(
            url: url,
            method: method,
            body: body,
            data: data,
            queryItems: queryItems,
            headers: headers
        ).urlRequest
    }
}
