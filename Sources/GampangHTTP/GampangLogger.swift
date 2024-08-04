//
//  GampangLogger.swift
//  
//
//  Created by Andika on 04/08/24.
//

import Foundation

/// A protocol defining the interface for logging in the GampangHTTP framework.
public protocol GampangLogger {
    /// Logs a message.
    ///
    /// - Parameter message: The message to be logged.
    func log(_ message: String)
}

/// A simple console logger implementing the GampangLogger protocol.
public struct GampangConsoleLogger: GampangLogger {
    /// Initializes a new GampangConsoleLogger.
    public init() {}
    
    /// Logs a message to the console.
    ///
    /// - Parameter message: The message to be logged.
    public func log(_ message: String) {
        debugPrint("[GampangHTTP] \(message)")
    }
}
