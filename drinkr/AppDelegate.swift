//
//  AppDelegate.swift
//  drinkr
//
//  Created by Assistant on 2025
//

import UIKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🚀 AppDelegate: didFinishLaunchingWithOptions called")
        
        // Set up Quick Action for 3-day free trial
        setupQuickActions(application)
        
        // Check if launched from Quick Action
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            print("🎯 App launched from Quick Action: \(shortcutItem.type)")
            // Handle the launch
            _ = self.application(application, performActionFor: shortcutItem) { _ in }
        }
        
        // Check if launched from notification
        if let notificationResponse = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            print("🔔 App launched from notification: \(notificationResponse)")
            handleNotificationDeepLink(notificationResponse)
        }
        
        // Set up notification categories
        RetentionNotificationManager.shared.setupNotificationCategories()
        
        // Set notification delegate for handling taps
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    private func setupQuickActions(_ application: UIApplication) {
        // Create the 3-Day Free Trial quick action
        let freeTrialAction = UIApplicationShortcutItem(
            type: "com.gill.Sobbr.freetrial",
            localizedTitle: "Get 3 Days Free",
            localizedSubtitle: "Try premium features",
            icon: UIApplicationShortcutIcon(systemImageName: "gift.fill"),
            userInfo: ["action": "free_trial" as NSSecureCoding]
        )
        
        // Set the quick action
        application.shortcutItems = [freeTrialAction]
        
        print("✅ Quick Action configured: 3-Day Free Trial")
    }
    
    // Handle quick action selection
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        print("🔍 Quick Action triggered: \(shortcutItem.type)")
        
        if shortcutItem.type == "com.gill.Sobbr.freetrial" {
            // Set flags to trigger Superwall placement when app becomes active
            UserDefaults.standard.set(true, forKey: "shouldShowFreeTrialFromQuickAction")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "quickActionTimestamp")
            print("🎁 3-Day Free Trial quick action triggered - flag set!")
            print("💾 UserDefaults flag: \(UserDefaults.standard.bool(forKey: "shouldShowFreeTrialFromQuickAction"))")
            completionHandler(true)
        } else {
            print("❌ Unknown quick action type: \(shortcutItem.type)")
            completionHandler(false)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 AppDelegate: applicationDidBecomeActive called")
        
        // Check if we should show free trial from quick action
        let shouldShow = UserDefaults.standard.bool(forKey: "shouldShowFreeTrialFromQuickAction")
        print("🔍 Should show free trial: \(shouldShow)")
        
        if shouldShow {
            let timestamp = UserDefaults.standard.double(forKey: "quickActionTimestamp")
            let timeSince = Date().timeIntervalSince1970 - timestamp
            print("⏰ Time since quick action: \(timeSince) seconds")
            
            UserDefaults.standard.removeObject(forKey: "shouldShowFreeTrialFromQuickAction")
            UserDefaults.standard.removeObject(forKey: "quickActionTimestamp")
            
            print("🚀 About to present free trial paywall...")
            
            // Present the Superwall placement immediately - no delay needed since debug button works
            DispatchQueue.main.async {
                self.presentFreeTrialPaywall()
            }
        } else {
            print("ℹ️ No Quick Action flag set")
        }
    }
    
    private func presentFreeTrialPaywall() {
        print("🎁 AppDelegate: Presenting free trial paywall")
        print("🔍 SuperwallManager initialized: \(SuperwallManager.shared.isInitialized)")
        
        // Since the debug button works, just call the same method directly
        SuperwallManager.shared.presentPlacement("yearly_free_trial")
        
        print("✅ AppDelegate: Called presentPlacement for yearly_free_trial")
    }
    
    // MARK: - Notification Deep Link Handling
    
    private func handleNotificationDeepLink(_ userInfo: [AnyHashable: Any]) {
        print("🔗 Handling notification deep link: \(userInfo)")
        
        guard let notificationType = userInfo["type"] as? String else {
            print("❌ No notification type found")
            return
        }
        
        switch notificationType {
        case "retention_free_trial":
            if let placement = userInfo["placement"] as? String {
                print("🎯 Retention notification tapped - presenting placement: \(placement)")
                
                // Delay to ensure app is fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    SuperwallManager.shared.presentPlacement(placement)
                }
            }
        default:
            print("❌ Unknown notification type: \(notificationType)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle notification tap when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("🔔 Notification tapped: \(response.notification.request.identifier)")
        print("📱 User info: \(response.notification.request.content.userInfo)")
        
        // Handle the deep link
        handleNotificationDeepLink(response.notification.request.content.userInfo)
        
        completionHandler()
    }
    
    // Handle notification presentation when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("🔔 Notification received while app in foreground: \(notification.request.identifier)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}