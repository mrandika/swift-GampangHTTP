//
//  GampangURLDataResponse.swift
//
//
//  Created by Andika on 03/08/24.
//

import Foundation

public struct GampangURLDataResponse {
    let data: Data
    let response: HTTPURLResponse
    
    public init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
}
