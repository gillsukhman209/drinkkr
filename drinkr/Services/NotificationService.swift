import Foundation
import UserNotifications
import UIKit

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }
    
    func scheduleCheckInNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today? Remember, you're stronger than any craving. 💪"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 24 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "daily-checkin-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Check-in notification scheduled for 24 hours from now")
            }
        }
    }
    
    func scheduleMilestoneNotification(for milestone: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Milestone Achievement! 🎉"
        content.body = "Congratulations! You've reached \(milestone) days sober. You're doing amazing!"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 1 minute from now (for testing purposes)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "milestone-\(milestone)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling milestone notification: \(error)")
            } else {
                print("Milestone notification scheduled")
            }
        }
    }
    
    func scheduleDailyReminderNotification(at hour: Int, minute: Int) {
        // Cancel existing daily reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Take a moment to reflect on your sobriety journey. You've got this! 🌟"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            } else {
                print("Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func cancelCheckInNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let checkInIds = requests.filter { $0.identifier.hasPrefix("daily-checkin") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: checkInIds)
        }
    }
    
    func getPendingNotificationCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
}