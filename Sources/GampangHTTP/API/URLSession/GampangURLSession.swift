//
//  File.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

public struct GampangURLSession {
    let request: URLRequest

    public init(request: URLRequest) {
        self.request = request
    }

    var start: Result<GampangURLDataResponse, HTTPError> {
        get async throws {
            let (data, apiResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = apiResponse as? HTTPURLResponse else {
                return .failure(HTTPError.unknown(code: 0))
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 200...299: return .success(GampangURLDataResponse(data: data, response: httpResponse))
            case 300...399: return .failure(HTTPError.clientError(code: statusCode))
            case 400...499: return .failure(HTTPError.clientError(code: statusCode))
            case 500...599: return .failure(HTTPError.serverError(code: statusCode))
            default: return .failure(HTTPError.unknown(code: statusCode))
            }
        }
    }
}
