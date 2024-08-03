//
//  File.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

public enum HTTPError: Error {
    case redirection(code: Int)
    case clientError(code: Int)
    case serverError(code: Int)
    case unknown(code: Int)
}
