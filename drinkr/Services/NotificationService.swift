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
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Notification permission error: \(error)")
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    print("✅ Notifications authorized")
                case .denied:
                    print("❌ Notifications denied")
                case .notDetermined:
                    print("⚠️ Notifications not determined")
                case .provisional:
                    print("⚠️ Notifications provisional")
                case .ephemeral:
                    print("⚠️ Notifications ephemeral")
                @unknown default:
                    print("❓ Unknown notification status")
                }
                
                print("Alert setting: \(settings.alertSetting)")
                print("Sound setting: \(settings.soundSetting)")
                print("Badge setting: \(settings.badgeSetting)")
            }
        }
    }
    
    func scheduleCheckInNotification(for date: Date = Date().addingTimeInterval(24 * 60 * 60)) {
        // First check if we have permission
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("❌ Cannot schedule notification - permission not granted")
                return
            }
            
            DispatchQueue.main.async {
                let content = UNMutableNotificationContent()
                content.title = "Daily Check-In"
                content.body = "How are you feeling today? Remember, you're stronger than any craving. 💪"
                content.sound = .default
                content.badge = 1
                
                // Calculate time interval from now to the selected date
                let timeInterval = date.timeIntervalSince(Date())
                
                // Don't schedule if the date is in the past
                guard timeInterval > 0 else {
                    print("❌ Cannot schedule notification for past date")
                    return
                }
                
                print("⏰ Scheduling notification for \(timeInterval) seconds from now")
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                
                let identifier = "daily-checkin-\(Date().timeIntervalSince1970)"
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                print("📅 Creating notification with identifier: \(identifier)")
                
                UNUserNotificationCenter.current().add(request) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ Error scheduling notification: \(error)")
                        } else {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            formatter.timeStyle = .short
                            print("✅ Check-in notification scheduled for \(formatter.string(from: date))")
                            
                            // Verify the notification was added
                            self.getPendingNotificationCount { count in
                                print("📱 Total pending notifications: \(count)")
                            }
                        }
                    }
                }
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
    
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test to verify notifications are working! 🎉"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling test notification: \(error)")
                } else {
                    print("✅ Test notification scheduled for 5 seconds from now")
                }
            }
        }
    }
}