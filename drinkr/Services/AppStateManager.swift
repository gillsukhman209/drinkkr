import Foundation
import SwiftUI
import UserNotifications

class AppStateManager: NSObject, ObservableObject {
    static let shared = AppStateManager()
    
    @Published var showCheckInModal = false
    
    private override init() {
        super.init()
        setupNotificationHandling()
    }
    
    func setupNotificationHandling() {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppStateManager: UNUserNotificationCenterDelegate {
    // This method is called when a notification is delivered while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // This method is called when the user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        
        print("📱 Notification tapped with identifier: \(identifier)")
        
        if identifier.hasPrefix("daily-checkin") {
            DispatchQueue.main.async {
                print("✅ Showing check-in modal")
                self.showCheckInModal = true
            }
        }
        
        completionHandler()
    }
}