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
        let userInfo = response.notification.request.content.userInfo
        
        print("📱 [APPSTATEMANAGER] Notification tapped with identifier: \(identifier)")
        print("📱 [APPSTATEMANAGER] User info: \(userInfo)")
        
        if identifier.hasPrefix("daily-checkin") {
            DispatchQueue.main.async {
                print("✅ Showing check-in modal")
                self.showCheckInModal = true
            }
        } else if identifier == "retention_free_trial" {
            print("🎯 [APPSTATEMANAGER] Retention notification tapped!")
            
            // Handle retention notification
            if let notificationType = userInfo["type"] as? String, notificationType == "retention_free_trial" {
                if let placement = userInfo["placement"] as? String {
                    print("🚀 [APPSTATEMANAGER] Found placement: \(placement) - presenting Superwall")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("📍 [APPSTATEMANAGER] About to call SuperwallManager.presentPlacement(\(placement))")
                        SuperwallManager.shared.presentPlacement(placement)
                        print("✅ [APPSTATEMANAGER] Called SuperwallManager.presentPlacement(\(placement))")
                    }
                } else {
                    print("❌ [APPSTATEMANAGER] No placement found in userInfo")
                }
            } else {
                print("❌ [APPSTATEMANAGER] Invalid retention notification type")
            }
        }
        
        completionHandler()
    }
}