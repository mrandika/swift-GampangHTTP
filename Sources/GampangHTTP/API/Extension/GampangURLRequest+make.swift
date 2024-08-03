//
//  GampangURLRequest.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

extension GampangURLRequest {
    public static func make(
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
        ).build
    }
}
