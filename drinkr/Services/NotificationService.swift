import Foundation
import UserNotifications
import UIKit

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private let messageService = NotificationMessageService.shared
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                #if DEBUG
                if granted {
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Notification permission error: \(error)")
                } else {
                    print("❌ Notification permission denied")
                }
                #endif
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            #if DEBUG
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
            #endif
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
    
    // MARK: - Phase 1: Daily Check-In Notifications
    
    func schedulePersonalizedDailyCheckIn(
        userName: String,
        checkInTime: Date,
        daysSober: Int,
        weeklySpending: String
    ) {
        // Check permission first
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("❌ Cannot schedule daily check-in - notification permission not authorized: \(settings.authorizationStatus)")
                return
            }
            
            DispatchQueue.main.async {
                print("🔧 Scheduling daily check-in for user: \(userName.isEmpty ? "[EMPTY NAME]" : userName)")
                
                // Cancel existing daily check-ins
                self.cancelDailyCheckInNotifications()
                
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: checkInTime)
                let minute = calendar.component(.minute, from: checkInTime)
                
                let message = self.messageService.getDailyCheckInMessage(
                    userName: userName,
                    daysSober: daysSober,
                    weeklySpending: weeklySpending
                )
                
                let content = UNMutableNotificationContent()
                content.title = message.title
                content.body = message.body
                content.sound = .default
                content.badge = 1
                content.categoryIdentifier = "DAILY_CHECKIN"
                
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let request = UNNotificationRequest(
                    identifier: "daily-checkin-personalized",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ Error scheduling personalized daily check-in: \(error)")
                        } else {
                            print("✅ Personalized daily check-in scheduled for \(hour):\(String(format: "%02d", minute))")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Phase 2: Craving Crusher Notifications
    
    func scheduleCravingCrusherNotifications(
        userName: String,
        triggers: [String],
        afterFeeling: String,
        daysSober: Int
    ) {
        // Cancel existing craving crushers
        cancelCravingCrusherNotifications()
        
        let times = messageService.getRandomCravingCrusherTimes()
        
        for (index, time) in times.enumerated() {
            let message = messageService.getCravingCrusherMessage(
                userName: userName,
                triggers: triggers,
                afterFeeling: afterFeeling,
                daysSober: daysSober
            )
            
            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default
            content.badge = 1
            content.categoryIdentifier = "CRAVING_CRUSHER"
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: time)
            let minute = calendar.component(.minute, from: time)
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "craving-crusher-\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error scheduling craving crusher \(index): \(error)")
                    } else {
                        print("✅ Craving crusher \(index) scheduled for \(hour):\(String(format: "%02d", minute))")
                    }
                }
            }
        }
    }
    
    // MARK: - Phase 3: Milestone Celebration Notifications
    
    func scheduleMilestoneNotification(
        userName: String,
        milestone: Int,
        moneySaved: String,
        hoursReclaimed: Int
    ) {
        let message = messageService.getMilestoneMessage(
            userName: userName,
            milestone: milestone,
            moneySaved: moneySaved,
            hoursReclaimed: hoursReclaimed
        )
        
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MILESTONE_CELEBRATION"
        
        // Schedule for 10 seconds from now for immediate celebration
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "milestone-\(milestone)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling milestone \(milestone) notification: \(error)")
                } else {
                    print("🎉 Milestone \(milestone) notification scheduled!")
                }
            }
        }
    }
    
    // MARK: - Phase 4: Savage Motivation Notifications
    
    func scheduleSavageMotivationNotifications(
        userName: String,
        losses: [String],
        afterFeeling: String,
        daysSober: Int
    ) {
        // Cancel existing savage motivation notifications
        cancelSavageMotivationNotifications()
        
        // Tuesday 11 AM
        scheduleSavageMotivation(
            userName: userName,
            losses: losses,
            afterFeeling: afterFeeling,
            daysSober: daysSober,
            weekday: 3, // Tuesday
            hour: 11,
            identifier: "savage-tuesday"
        )
        
        // Friday 9 PM
        scheduleSavageMotivation(
            userName: userName,
            losses: losses,
            afterFeeling: afterFeeling,
            daysSober: daysSober,
            weekday: 6, // Friday
            hour: 21,
            identifier: "savage-friday"
        )
    }
    
    private func scheduleSavageMotivation(
        userName: String,
        losses: [String],
        afterFeeling: String,
        daysSober: Int,
        weekday: Int,
        hour: Int,
        identifier: String
    ) {
        let message = messageService.getSavageMotivationMessage(
            userName: userName,
            losses: losses,
            afterFeeling: afterFeeling,
            daysSober: daysSober
        )
        
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SAVAGE_MOTIVATION"
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling savage motivation \(identifier): \(error)")
                } else {
                    print("💪 Savage motivation \(identifier) scheduled!")
                }
            }
        }
    }
    
    // MARK: - Phase 5: Fear Crusher Notifications
    
    func scheduleFearCrusherNotification(
        userName: String,
        biggestFear: String,
        daysSober: Int
    ) {
        // Cancel existing fear crusher
        cancelFearCrusherNotifications()
        
        let message = messageService.getFearCrusherMessage(
            userName: userName,
            biggestFear: biggestFear,
            daysSober: daysSober
        )
        
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "FEAR_CRUSHER"
        
        // Sunday 8 PM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "fear-crusher-sunday",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling fear crusher: \(error)")
                } else {
                    print("🦁 Fear crusher scheduled for Sunday 8 PM!")
                }
            }
        }
    }
    
    // MARK: - Phase 6: Wisdom Drop Notifications
    
    func scheduleWisdomDropNotification() {
        // Cancel existing wisdom drops
        cancelWisdomDropNotifications()
        
        let message = messageService.getWisdomDropMessage()
        
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "WISDOM_DROP"
        
        // Random time between 10 AM and 8 PM
        let randomHour = Int.random(in: 10...20)
        let randomMinute = Int.random(in: 0...59)
        
        var dateComponents = DateComponents()
        dateComponents.hour = randomHour
        dateComponents.minute = randomMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "wisdom-drop-daily",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling wisdom drop: \(error)")
                } else {
                    print("✨ Wisdom drop scheduled for \(randomHour):\(String(format: "%02d", randomMinute))!")
                }
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
    
    func cancelDailyCheckInNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-checkin-personalized"])
    }
    
    func cancelCravingCrusherNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let crusherIds = requests.filter { $0.identifier.hasPrefix("craving-crusher") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: crusherIds)
        }
    }
    
    func cancelSavageMotivationNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["savage-tuesday", "savage-friday"])
    }
    
    func cancelFearCrusherNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["fear-crusher-sunday"])
    }
    
    func cancelWisdomDropNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["wisdom-drop-daily"])
    }
    
    func cancelMilestoneNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let milestoneIds = requests.filter { $0.identifier.hasPrefix("milestone-") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: milestoneIds)
        }
    }
    
    func getPendingNotificationCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
    
    /// Logs current notification permission status
    func logNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("\n🔐 NOTIFICATION PERMISSION STATUS")
                print("═══════════════════════════════════════")
                print("Authorization Status: \(settings.authorizationStatus)")
                print("Alert Setting: \(settings.alertSetting)")
                print("Sound Setting: \(settings.soundSetting)")
                print("Badge Setting: \(settings.badgeSetting)")
                print("Notification Center Setting: \(settings.notificationCenterSetting)")
                print("Lock Screen Setting: \(settings.lockScreenSetting)")
                print("═══════════════════════════════════════\n")
            }
        }
    }
    
    /// Logs all pending notifications with their scheduled times for testing
    func logAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                print("\n🔔 PENDING NOTIFICATIONS DEBUG LOG")
                print("═══════════════════════════════════════")
                print("Total pending notifications: \(requests.count)")
                
                if requests.isEmpty {
                    print("❌ No notifications scheduled")
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                for (index, request) in requests.enumerated() {
                    print("\n[\(index + 1)] \(request.identifier)")
                    print("   Title: \(request.content.title)")
                    print("   Body: \(request.content.body)")
                    
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        if let nextTriggerDate = trigger.nextTriggerDate() {
                            print("   📅 Next trigger: \(dateFormatter.string(from: nextTriggerDate))")
                            
                            // Show how long until next trigger
                            let timeInterval = nextTriggerDate.timeIntervalSince(Date())
                            let hours = Int(timeInterval) / 3600
                            let minutes = (Int(timeInterval) % 3600) / 60
                            print("   ⏰ Time until trigger: \(hours)h \(minutes)m")
                        }
                        
                        // Show the date components for recurring notifications
                        let components = trigger.dateComponents
                        var scheduleInfo = "   📋 Schedule: "
                        
                        if let weekday = components.weekday {
                            let weekdayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                            scheduleInfo += weekdayNames[weekday] + " "
                        }
                        
                        if let hour = components.hour, let minute = components.minute {
                            scheduleInfo += String(format: "%02d:%02d", hour, minute)
                        }
                        
                        scheduleInfo += " (repeats: \(trigger.repeats))"
                        print(scheduleInfo)
                        
                    } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        let triggerDate = Date().addingTimeInterval(trigger.timeInterval)
                        print("   📅 Will trigger: \(dateFormatter.string(from: triggerDate))")
                        print("   ⏰ Time interval: \(trigger.timeInterval) seconds")
                        print("   🔄 Repeats: \(trigger.repeats)")
                    }
                }
                
                print("═══════════════════════════════════════")
                print("💡 To test: Change your device time to match a trigger time\n")
            }
        }
    }
}
