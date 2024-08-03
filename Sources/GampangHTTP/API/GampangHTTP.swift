//
//  GampangHTTP.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

public struct GampangHTTP {
    public static func request<T: Decodable>(
        with request: URLRequest, of result: T.Type
    ) async throws -> T {
        var response: T
        
        let result = try await GampangURLSession.hit(request)
        
        switch result {
        case .success(let success):
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: success.data)

            response = result
        case .failure(let failure):
            throw failure
        }
        
        return response
    }
}
