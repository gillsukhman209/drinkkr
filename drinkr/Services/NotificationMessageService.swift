import Foundation

// MARK: - Notification Message Templates

struct NotificationMessageService {
    static let shared = NotificationMessageService()
    private init() {}
    
    // MARK: - Phase 1: Daily Check-In Messages
    
    func getDailyCheckInMessage(userName: String, daysSober: Int, weeklySpending: String) -> (title: String, body: String) {
        let savings = calculateMonthlySavings(from: weeklySpending)
        
        let messages = [
            (
                title: "Good morning, \(userName)! ☀️",
                body: "Day \(daysSober) without alcohol. Your brain is \(daysSober) days clearer, and you're \(savings) richer this month ✨"
            ),
            (
                title: "\(userName), it's your check-in time 💪",
                body: "Remember: you chose growth over guilt today. Day \(daysSober) of proving you can do hard things!"
            ),
            (
                title: "Daily victory check-in! 🏆",
                body: "Hey \(userName), \(daysSober) days ago you made a promise to yourself. Today you're keeping it. That's strength."
            ),
            (
                title: "\(userName), your sober self is calling 📞",
                body: "Day \(daysSober): Still choosing clarity over chaos. Your future self is grateful for today's choices ❤️"
            ),
            (
                title: "Check-in time, champion! 🌟",
                body: "\(userName), \(daysSober) days of freedom. You're not just avoiding alcohol, you're embracing life 🌈"
            )
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Phase 2: Craving Crusher Messages
    
    func getCravingCrusherMessage(userName: String, triggers: [String], afterFeeling: String, daysSober: Int) -> (title: String, body: String) {
        
        // Generic craving messages if no specific trigger data
        let genericMessages = [
            (
                title: "Craving alert, \(userName)! 🚨",
                body: "Remember: you told us alcohol makes you feel '\(afterFeeling)'. Your sober brain is trying to protect you ❤️"
            ),
            (
                title: "Plot twist time! 💫",
                body: "Hey \(userName), that craving? It's actually your brain rewiring itself for happiness. Day \(daysSober) of building new pathways ✨"
            ),
            (
                title: "\(userName), pause and breathe 🌬️",
                body: "This feeling will pass. You've survived \(daysSober) days without alcohol. You're stronger than any craving 💪"
            )
        ]
        
        // Trigger-specific messages
        var triggerMessages: [(String, String)] = []
        
        if triggers.contains("Stress from work") {
            triggerMessages.append((
                "Work stress hitting different? 💼",
                "\(userName), you used to drink away work stress. Day \(daysSober) of handling it like the champion you are ⭐"
            ))
        }
        
        if triggers.contains("Loneliness") {
            triggerMessages.append((
                "Feeling lonely, \(userName)? 🫂",
                "Alcohol never fixed loneliness, it just postponed it. Day \(daysSober) of finding real connection - starting with yourself ❤️"
            ))
        }
        
        if triggers.contains("Boredom") {
            triggerMessages.append((
                "Boredom trying to trick you? 🎭",
                "\(userName), remember: alcohol didn't make life interesting, it made you forget how boring you felt. Day \(daysSober) of real engagement ✨"
            ))
        }
        
        if triggers.contains("Social pressure") {
            triggerMessages.append((
                "Social pressure incoming! 👥",
                "Hey \(userName), peer pressure at day \(daysSober)? You're not missing out, you're standing out. That takes courage 🦁"
            ))
        }
        
        let allMessages = triggerMessages + genericMessages
        return allMessages.randomElement() ?? genericMessages[0]
    }
    
    // MARK: - Helper Methods
    
    private func calculateMonthlySavings(from spending: String) -> String {
        switch spending {
        case "$0-20": return "$40-80"
        case "$20-50": return "$80-200"  
        case "$50-100": return "$200-400"
        case "$100+": return "$400+"
        default: return "$0"
        }
    }
    
    // MARK: - Message Scheduling Helpers
    
    func getRandomCravingCrusherTimes() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        var times: [Date] = []
        
        // Generate 2-3 random times throughout the day
        let timeSlots = [
            (10, 0),  // 10 AM
            (2, 30),  // 2:30 PM  
            (7, 15)   // 7:15 PM
        ]
        
        for (hour, minute) in timeSlots.shuffled().prefix(Int.random(in: 2...3)) {
            if let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) {
                times.append(time)
            }
        }
        
        return times
    }
}