//
//  File.swift
//  
//
//  Created by Andika on 03/08/24.
//

import Foundation

extension GampangURLSession {
    public static func hit(_ request: URLRequest) async throws -> Result<GampangURLDataResponse, HTTPError> {
        return try await GampangURLSession(request: request).start
    }
}
