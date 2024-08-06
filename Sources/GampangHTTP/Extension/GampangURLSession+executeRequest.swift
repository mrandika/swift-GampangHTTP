//
//  GampangURLSession+executeRequest.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

extension GampangURLSession {
    public static func executeRequest(_ request: URLRequest) async throws -> Result<GampangURLDataResponse, GampangClientError> {
        return try await GampangURLSession(request: request).execute
    }
}
