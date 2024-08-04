//
//  GampangHTTPError.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

/// Custom error type for HTTP-related errors.
public enum GampangHTTPError: Error {
    case redirection(code: Int)
    case clientError(code: Int)
    case serverError(code: Int)
    case unknown(code: Int)
}
