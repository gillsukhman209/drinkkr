//
//  DebugLogger.swift
//  Sobbr
//
//  Safe debug logging that only prints in DEBUG builds
//

import Foundation

struct DebugLogger {
    static func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
    
    static func error(_ message: String) {
        #if DEBUG
        print("❌ \(message)")
        #endif
    }
    
    static func success(_ message: String) {
        #if DEBUG
        print("✅ \(message)")
        #endif
    }
    
    static func warning(_ message: String) {
        #if DEBUG
        print("⚠️ \(message)")
        #endif
    }
    
    static func info(_ message: String) {
        #if DEBUG
        print("ℹ️ \(message)")
        #endif
    }
}