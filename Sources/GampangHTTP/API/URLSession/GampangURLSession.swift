//
//  File.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

/// Represents a URL session for making network requests.
public struct GampangURLSession {
    /// The URLRequest to be executed.
    let request: URLRequest

    /// Initializes a new GampangURLSession with the given request.
    public init(request: URLRequest) {
        self.request = request
    }

    /// Executes the request and returns the result.
    var execute: Result<GampangURLDataResponse, GampangClientError> {
        get async throws {
            let (data, apiResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = apiResponse as? HTTPURLResponse else {
                return .failure(.castError(.failed))
            }
            
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200...299:
                return .success(GampangURLDataResponse(data: data, response: httpResponse))
            case 300...399:
                return .failure(.httpError(.redirection(code: statusCode)))
            case 400...499:
                return .failure(.httpError(.clientError(code: statusCode)))
            case 500...599:
                return .failure(.httpError(.serverError(code: statusCode)))
            default:
                return .failure(.httpError(.unknown(code: statusCode)))
            }
        }
    }
}
