//
//  File.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

public struct GampangURLRequest {
    let url: String
    let method: HTTPMethod
    let body: [String: Any]?
    let data: Data?
    let queryItems: [URLQueryItem]
    let headers: [(field: HTTPHeaderField, value: String)]?

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

    var build: URLRequest {
        get throws {
            var urlComponents = URLComponents(string: url)

            if !queryItems.isEmpty {
                urlComponents?.queryItems = queryItems
            }

            guard let url = urlComponents?.url else {
                throw URLError.invalid
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue

            if let body = body {
                urlRequest.httpBody = body
                    .map { key, value in
                        "\(key)=\(value)"
                    }
                    .joined(separator: "&")
                    .data(using: .utf8)
            }

            if let data = data {
                urlRequest.httpBody = data
            }

            if let headers = headers {
                for header in headers {
                    urlRequest.setValue(header.value, forHTTPHeaderField: header.field.rawValue)
                }
            }

            return urlRequest
        }
    }
}
