//
//  Error+GampangClientError.swift
//
//
//  Created by Andika on 04/08/24.
//

import Foundation

/// Custom error type for GampangHTTP operations.
public enum GampangClientError: Error {
    case httpError(GampangHTTPError)
    case castError(GampangCastError)
    case decodingError(Error)
    case cancelled
}
