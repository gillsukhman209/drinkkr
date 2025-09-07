//
//  DebugTimeManager.swift
//  Sobbr
//
//  Debug time manipulation for testing milestones and notifications
//

import Foundation
import UIKit

#if DEBUG
class DebugTimeManager: ObservableObject {
    static let shared = DebugTimeManager()
    
    @Published var debugTimeOffset: TimeInterval = 0
    private var lastSystemTime: Date = Date()
    
    private init() {
        // Monitor for significant system time changes
        NotificationCenter.default.addObserver(
            forName: UIApplication.significantTimeChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("⏰ SYSTEM TIME CHANGED - Resetting debug time and milestones")
            self.debugTimeOffset = 0 // Reset debug time to use real system time
            UserDefaults.standard.removeObject(forKey: "lastCelebratedMilestone")
            UserDefaults.standard.removeObject(forKey: "debugLastCelebratedMilestone")
            
            // Force update of all views
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        // Also monitor when app becomes active (in case time changed while backgrounded)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.detectSystemTimeChange()
        }
    }
    
    private func detectSystemTimeChange() {
        let now = Date()
        let timeDifference = abs(now.timeIntervalSince(lastSystemTime))
        
        // If more than 5 minutes passed unexpectedly, likely a time change
        if timeDifference > 300 && debugTimeOffset == 0 {
            print("⏰ Detected possible system time change (diff: \(timeDifference)s)")
            UserDefaults.standard.removeObject(forKey: "lastCelebratedMilestone")
            UserDefaults.standard.removeObject(forKey: "debugLastCelebratedMilestone")
        }
        
        lastSystemTime = now
    }
    
    /// Get the current time adjusted for debug offset
    func getCurrentTime() -> Date {
        return Date().addingTimeInterval(debugTimeOffset)
    }
    
    /// Set debug time to a specific date
    func setDebugTime(to date: Date) {
        debugTimeOffset = date.timeIntervalSince(Date())
    }
    
    /// Add time to current debug time
    func addTime(days: Int = 0, hours: Int = 0, minutes: Int = 0) {
        let additionalOffset = TimeInterval(days * 24 * 3600 + hours * 3600 + minutes * 60)
        debugTimeOffset += additionalOffset
    }
    
    /// Reset to real time
    func resetToRealTime() {
        debugTimeOffset = 0
    }
    
    /// Check if we're in debug time mode
    var isDebugMode: Bool {
        return debugTimeOffset != 0
    }
}

// Extension to Date for easy debug time access
extension Date {
    static var debugAdjusted: Date {
        return DebugTimeManager.shared.getCurrentTime()
    }
}
#endif