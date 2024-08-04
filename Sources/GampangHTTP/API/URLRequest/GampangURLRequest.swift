//
//  File.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

/// Represents a URL request with customizable components.
public struct GampangURLRequest {
    /// The base URL string for the request.
    let url: String
    /// The HTTP method for the request.
    let method: HTTPMethod
    /// The body of the request as key-value pairs.
    let body: [String: Any]?
    /// Raw data to be sent in the request body.
    let data: Data?
    /// Query items to be appended to the URL.
    let queryItems: [URLQueryItem]
    /// Custom headers for the request.
    let headers: [(field: HTTPHeaderField, value: String)]?

    /// Initializes a new GampangURLRequest.
    public init(
        url: String,
        method: HTTPMethod,
        body: [String: Any]? = nil,
        data: Data? = nil,
        queryItems: [URLQueryItem] = [],
        headers: [(field: HTTPHeaderField, value: String)]? = nil
    ) {
        self.url = url
        self.method = method
        self.body = body
        self.data = data
        self.queryItems = queryItems
        self.headers = headers
    }

    /// Builds and returns a URLRequest based on the configured properties.
    var urlRequest: URLRequest {
        get throws {
            var urlComponents = URLComponents(string: url)
            urlComponents?.queryItems = queryItems.isEmpty ? nil : queryItems

            guard let url = urlComponents?.url else {
                throw URLError.badUrl
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue

            if let body = body {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } else if let data = data {
                urlRequest.httpBody = data
            }

            headers?.forEach { header in
                urlRequest.setValue(header.value, forHTTPHeaderField: header.field.rawValue)
            }

            return urlRequest
        }
    }
}
