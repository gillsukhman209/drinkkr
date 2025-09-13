//
//  RetentionNotificationManager.swift
//  drinkr
//
//  Created by Assistant on 2025
//

import Foundation
import UserNotifications

class RetentionNotificationManager: ObservableObject {
    static let shared = RetentionNotificationManager()
    
    private let notificationService = NotificationService.shared
    
    // MARK: - Constants
    private let retentionNotificationDelay: TimeInterval = 5 * 60 // 5 minutes
    private let retentionNotificationId = "retention_free_trial"
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Schedule a retention notification 5 minutes after paywall dismissal
    func scheduleRetentionNotification(userName: String) {
        print("📱 Scheduling retention notification for \(userName) in 5 minutes")
        
        // Clear any existing retention notifications first
        cancelRetentionNotification()
        
        // Create personalized message
        let message = createPersonalizedMessage(userName: userName)
        
        // Schedule the notification
        let content = UNMutableNotificationContent()
        content.title = "🚨 DON'T GIVE UP! 💎 FREE TRIAL INSIDE 🚨"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "RETENTION_CATEGORY"
        content.badge = NSNumber(value: 1)
        
        // Add user info to handle deep link
        content.userInfo = [
            "type": "retention_free_trial",
            "placement": SuperwallManager.Placements.yearlyFreeTrial,
            "userName": userName
        ]
        
        // Create trigger for 5 minutes from now
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: retentionNotificationDelay,
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: retentionNotificationId,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule retention notification: \(error)")
            } else {
                print("✅ Retention notification scheduled for \(userName)")
                
                // Mark that retention notification was scheduled
                UserDefaults.standard.set(true, forKey: "retentionNotificationScheduled")
                UserDefaults.standard.set(Date(), forKey: "retentionNotificationScheduledDate")
            }
        }
    }
    
    /// Cancel any pending retention notifications
    func cancelRetentionNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [retentionNotificationId]
        )
        
        UserDefaults.standard.removeObject(forKey: "retentionNotificationScheduled")
        UserDefaults.standard.removeObject(forKey: "retentionNotificationScheduledDate")
        
        print("🗑️ Cancelled pending retention notifications")
    }
    
    /// Check if user has already received a retention notification
    func hasReceivedRetentionNotification() -> Bool {
        return UserDefaults.standard.bool(forKey: "retentionNotificationScheduled")
    }
    
    /// Handle when user subscribes (cancel retention notifications)
    func userDidSubscribe() {
        print("✅ User subscribed - cancelling retention notifications")
        cancelRetentionNotification()
        
        // Mark that user converted so we don't show retention notifications again
        UserDefaults.standard.set(true, forKey: "userDidConvert")
    }
    
    /// Check if user has already converted (subscribed)
    func userHasConverted() -> Bool {
        return UserDefaults.standard.bool(forKey: "userDidConvert")
    }
    
    // MARK: - Private Methods
    
    /// Create personalized retention message
    private func createPersonalizedMessage(userName: String) -> String {
        let messages = [
            "🚨 \(userName), we didn't give up on you! 💰 Get 3 days FREE - LAST CHANCE to change your life! 🚨",
            "💎 \(userName), your recovery matters! 🎁 FREE 3-DAY TRIAL - No credit card, no strings attached! 💎",
            "⚡ \(userName), we're STILL here for you! 🔥 3 days FREE to RECLAIM your life - Don't miss out! ⚡",
            "💥 \(userName), don't let alcohol WIN! 🎯 Your FREE 3-day trial is waiting - TAP NOW! 💥",
            "🌟 \(userName), recovery IS possible! 💪 Get 3 days FREE to PROVE it to yourself - Limited time! 🌟",
            "🚀 \(userName), this is YOUR moment! 💰 3 days FREE access - Your future self will THANK YOU! 🚀",
            "🔔 \(userName), FINAL OFFER! 🎁 Free 3-day trial - Everything you need to BEAT alcohol! 🔔"
        ]
        
        // Return a random message for variety
        return messages.randomElement() ?? messages[0]
    }
    
    /// Load user name from onboarding data
    func getUserNameForRetention() -> String {
        // Try to get name from onboarding profile
        if let profileData = UserDefaults.standard.data(forKey: "onboardingUserProfile"),
           let profile = try? JSONDecoder().decode(OnboardingUserProfile.self, from: profileData),
           !profile.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return profile.userName
        }
        
        // Fallback to generic name
        return "Friend"
    }
    
    /// Setup notification categories for interactive notifications
    func setupNotificationCategories() {
        let retentionCategory = UNNotificationCategory(
            identifier: "RETENTION_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([retentionCategory])
    }
}

// MARK: - Integration Helper

extension RetentionNotificationManager {
    
    /// Called when paywall is dismissed without purchase
    func handlePaywallDismissed(placement: String) {
        print("💔 Paywall dismissed for placement: \(placement)")
        
        // Don't send if user already converted or already has retention notification
        guard !userHasConverted() && !hasReceivedRetentionNotification() else {
            print("ℹ️ Skipping retention - user already converted or notification already sent")
            return
        }
        
        print("✅ Eligible for retention notification - scheduling for placement: \(placement)")
        
        // Get user name and schedule retention notification
        let userName = getUserNameForRetention()
        scheduleRetentionNotification(userName: userName)
    }
}