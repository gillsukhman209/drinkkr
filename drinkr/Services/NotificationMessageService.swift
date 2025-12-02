import Foundation
import SwiftData

// MARK: - Notification Message Templates

struct NotificationMessageService {
    static let shared = NotificationMessageService()
    private init() {}
    
    // MARK: - Phase 1: Daily Check-In Messages
    
    func getDailyCheckInMessage(userName: String, daysSober: Int, weeklySpending: String) -> (title: String, body: String) {
        let savings = calculateMonthlySavings(from: weeklySpending)
        
        // Calculate current days sober dynamically from the actual quit date
        let currentDaysSober = getCurrentDaysSober()
        
        let messages = [
            (
                title: "Good morning, \(userName)! ☀️",
                body: "Your body is thanking you, and you're \(savings) richer this month ✨"
            ),
            (
                title: "\(userName), check-in time! 🥗",
                body: "Remember: you chose health over convenience today. Keep proving you can do hard things!"
            ),
            (
                title: "Daily victory check-in! 🏆",
                body: "Hey \(userName), you made a promise to your body. Today you're keeping it. That's strength."
            ),
            (
                title: "\(userName), your healthy self is calling 📞",
                body: "Still choosing nourishment over junk. Your future self is grateful for today's choices ❤️"
            ),
            (
                title: "Check-in time, champion! 🌟",
                body: "\(userName), you're not just avoiding fast food, you're embracing vitality 🌈"
            )
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Phase 2: Craving Crusher Messages
    
    func getCravingCrusherMessage(userName: String, triggers: [String], afterFeeling: String, daysSober: Int) -> (title: String, body: String) {
        
        // Calculate current days sober dynamically from the actual quit date
        let currentDaysSober = getCurrentDaysSober()
        
        // Generic craving messages if no specific trigger data
        let genericMessages = [
            (
                title: "Craving alert, \(userName)! 🚨",
                body: "Remember: you told us fast food makes you feel '\(afterFeeling)'. Your body deserves better fuel ❤️"
            ),
            (
                title: "Plot twist time! 💫",
                body: "Hey \(userName), that craving? It's actually your taste buds resetting. Day \(currentDaysSober) of building new habits ✨"
            ),
            (
                title: "\(userName), pause and drink water 💧",
                body: "This hunger might just be thirst. You've survived \(currentDaysSober) days without the drive-thru. You're stronger than any craving 💪"
            )
        ]
        
        // Trigger-specific messages
        var triggerMessages: [(String, String)] = []
        
        if triggers.contains("Stress/Anxiety") {
            triggerMessages.append((
                "Stressed out? 🧘",
                "\(userName), you used to eat your stress. Now you're handling it like the champion you are. Breathe. ⭐"
            ))
        }
        
        if triggers.contains("Convenience/Time") {
            triggerMessages.append((
                "In a rush, \(userName)? 🏃",
                "Fast food is quick, but feeling sluggish lasts all day. Grab a healthy snack instead! 🍎"
            ))
        }
        
        if triggers.contains("Boredom") {
            triggerMessages.append((
                "Boredom trying to trick you? 🎭",
                "\(userName), remember: food is fuel, not entertainment. Go for a walk or call a friend! ✨"
            ))
        }
        
        if triggers.contains("Advertisements") {
            triggerMessages.append((
                "Don't let the ads win! 📺",
                "Hey \(userName), that burger looks good in the ad, but remember how it makes you feel? You're smarter than their marketing 🦁"
            ))
        }
        
        let allMessages = triggerMessages + genericMessages
        return allMessages.randomElement() ?? genericMessages[0]
    }
    
    // MARK: - Phase 3: Milestone Celebration Messages
    
    func getMilestoneMessage(userName: String, milestone: Int, moneySaved: String, hoursReclaimed: Int) -> (title: String, body: String) {
        switch milestone {
        case 1:
            return (
                "🎉 FIRST 24 HOURS COMPLETE! 🎉",
                "\(userName), you did it! One full day without fast food. Your digestion is already improving. This is just the beginning 💪"
            )
        case 3:
            return (
                "🔥 72 HOURS STRONG! 🔥",
                "\(userName), 3 days down! Your energy is stabilizing, and you're proving you can do this 🌟"
            )
        case 7:
            return (
                "🏆 ONE WEEK CHAMPION! 🏆",
                "\(userName), 7 days clean! You've saved \(moneySaved) and avoided so much grease and salt. Screenshot this victory 📸"
            )
        case 14:
            return (
                "💎 TWO WEEKS OF FREEDOM! 💎",
                "\(userName), 14 days! Your skin might be clearing up, and you're \(moneySaved) richer. Keep going! 🚀"
            )
        case 30:
            return (
                "🚨 MONTH 1 COMPLETE! 🚨",
                "\(userName), 30 DAYS FAST FOOD FREE! You've saved \(moneySaved) and your body feels amazing. This is HUGE! 🎊"
            )
        case 60:
            return (
                "⭐ TWO MONTHS STRONG! ⭐",
                "\(userName), 60 days of choosing health! \(moneySaved) saved. You're unstoppable 💫"
            )
        case 90:
            return (
                "🌟 90 DAYS - NEW YOU! 🌟",
                "\(userName), THREE MONTHS CLEAN! Your taste buds have changed. \(moneySaved) saved. Screenshot this transformation 📱"
            )
        case 180:
            return (
                "🎯 HALF A YEAR HERO! 🎯",
                "\(userName), 6 MONTHS! From drive-thrus to home cooking. \(moneySaved) saved. You're living the healthy life 🥗"
            )
        case 365:
            return (
                "👑 ONE YEAR LEGEND! 👑",
                "\(userName), 365 DAYS FREE! You've saved \(moneySaved) and gained a whole new level of health. Screenshot this moment forever 🎆"
            )
        default:
            let years = milestone / 365
            if years > 1 {
                return (
                    "🌈 \(years) YEARS OF HEALTH! 🌈",
                    "\(userName), \(years) YEARS FREE! You're not just surviving, you're THRIVING. An inspiration to everyone 🦋"
                )
            } else {
                return (
                    "🎊 DAY \(milestone) MILESTONE! 🎊",
                    "\(userName), \(milestone) days of strength! Every healthy meal is a victory worth celebrating 🌟"
                )
            }
        }
    }
    
    // MARK: - Phase 4: Savage Motivation Messages
    
    func getSavageMotivationMessage(userName: String, losses: [String], afterFeeling: String, daysSober: Int) -> (title: String, body: String) {
        // Calculate current days sober dynamically from the actual quit date
        let currentDaysSober = getCurrentDaysSober()
        
        let messages = [
            (
                "Reality Check Saturday 🔥",
                "\(userName), you used to feel sluggish all weekend. It's Saturday 10 AM and you have ENERGY. Past you could never 🌅"
            ),
            (
                "Friday Night Truth Bomb 💣",
                "Remember when Friday meant a greasy bag of regret? \(userName), it's Friday night and you're fueling your body right. This is real self-care 🎯"
            ),
            (
                "Brutal Honesty Hour 💪",
                "\(userName), you used to feel '\(afterFeeling)' after eating junk. Now? You wake up light. That's growth 📈"
            ),
            (
                "Tuesday Reality Check ⚡",
                "Hey \(userName), remember losing \(losses.first ?? "confidence") to bad food habits? You're getting it all back 💎"
            ),
            (
                "Wake Up Call 📢",
                "\(userName), you're proving everyone wrong who said you couldn't eat healthy. Including yourself 🦁"
            ),
            (
                "Savage Truth Time 🎯",
                "Plot twist: The 'treat' you thought you were having was just poisoning your energy. Real food is the real treat ✨"
            )
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Phase 5: Fear Crusher Messages
    
    func getFearCrusherMessage(userName: String, biggestFear: String, daysSober: Int) -> (title: String, body: String) {
        // Calculate current days sober dynamically from the actual quit date
        let currentDaysSober = getCurrentDaysSober()
        
        switch biggestFear.lowercased() {
        case let fear where fear.contains("hungry") || fear.contains("starving"):
            return (
                "Fear Check: Hunger 🍎",
                "\(userName), you feared being hungry. Plot twist: You're actually NOURISHED now. Empty calories were the lie 🎉"
            )
        case let fear where fear.contains("cooking") || fear.contains("hard"):
            return (
                "Fear Check: Cooking 🍳",
                "You feared cooking was too hard, \(userName). Look at you now, mastering your meals. You're a chef in the making! 👨‍🍳"
            )
        case let fear where fear.contains("tastes bad") || fear.contains("bland"):
            return (
                "Fear Check: Taste 👅",
                "\(userName), you thought healthy food was boring. Now you know what REAL food tastes like. Grease was just masking the flavor 💪"
            )
        case let fear where fear.contains("fail") || fear.contains("disappoint"):
            return (
                "Fear Check: Failure 🏆",
                "Afraid of failing? \(userName), you're making healthy choices every day. That's not failure, that's victory 🦸‍♀️"
            )
        case let fear where fear.contains("social") || fear.contains("awkward"):
            return (
                "Fear Check: Social 🥗",
                "\(userName), you feared social eating. You're showing everyone that health is cool. You're a trendsetter 🚀"
            )
        case let fear where fear.contains("afford") || fear.contains("expensive"):
            return (
                "Fear Check: Money 💰",
                "You feared healthy food was expensive. \(userName), look at your savings from skipping the drive-thru! 🌟"
            )
        default:
            return (
                "Fear Check 🎯",
                "\(userName), remember your biggest fear about quitting? You're living proof that fear was lying to you 💫"
            )
        }
    }
    
    // MARK: - Phase 6: Wisdom Drop Messages
    
    func getWisdomDropMessage() -> (title: String, body: String) {
        let wisdomMessages = [
            (
                "Daily Wisdom 🌟",
                "You're not 'giving up' fast food. You're choosing everything it took away: energy, money, clear skin, self-respect ✨"
            ),
            (
                "Truth Moment 💭",
                "The version of you that needed junk food to cope was doing their best. Today's version knows better fuel 📖"
            ),
            (
                "Perspective Shift 🔄",
                "Fast food promised convenience. Instead, it stole your energy. Cooking isn't the hard part - feeling sick was 💡"
            ),
            (
                "Today's Insight 🧠",
                "You didn't have a hunger problem. You had an emotional need that food temporarily silenced. Now you're nourishing the real you 🌱"
            ),
            (
                "Wisdom Wednesday ✨",
                "Your body is a temple, not a trash can. Treat it with the respect it deserves 🦅"
            ),
            (
                "Daily Reframe 🎨",
                "FOMO about that burger? The only thing you're missing out on is bloating, lethargy, and regret. That's JOMO - Joy of Missing Out 🎉"
            ),
            (
                "Truth Drop 💎",
                "Healthy eating didn't just change your body. It changed your mind. You're thinking clearer now 🔓"
            ),
            (
                "Philosophical Friday 🤔",
                "The opposite of addiction isn't dieting. It's nourishment. Every healthy meal is an act of self-love 🤝"
            ),
            (
                "Mindset Medicine 💊",
                "You're not deprived. You're empowered. There's a profound difference 🕰️"
            ),
            (
                "Reality Check ☄️",
                "One day you'll look back and realize that putting down the junk food was the moment your life truly leveled up 📚"
            )
        ]
        
        return wisdomMessages.randomElement() ?? wisdomMessages[0]
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
            (11, 30), // 11:30 AM (Lunch craving)
            (17, 0),  // 5:00 PM (Dinner craving)
            (21, 0)   // 9:00 PM (Late night snack)
        ]
        
        for (hour, minute) in timeSlots.shuffled().prefix(Int.random(in: 2...3)) {
            if let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) {
                times.append(time)
            }
        }
        
        return times
    }
    
    // MARK: - Dynamic Day Calculation Helper
    
    private func getCurrentDaysSober() -> Int {
        // Get quit date and last relapse date from UserDefaults (accessible from notifications)
        let quitDate = UserDefaults.standard.object(forKey: "sobrietyQuitDate") as? Date ?? Date()
        let lastRelapseDate = UserDefaults.standard.object(forKey: "lastRelapseDate") as? Date
        
        let calendar = Calendar.current
        
        // Use debug time if available, otherwise use real time
        #if DEBUG
        let currentTime = DebugTimeManager.shared.isDebugMode ? 
            DebugTimeManager.shared.getCurrentTime() : Date()
        #else
        let currentTime = Date()
        #endif
        
        let today = calendar.startOfDay(for: currentTime)
        
        if let lastRelapse = lastRelapseDate {
            let daysSinceRelapse = calendar.dateComponents([.day], from: lastRelapse, to: today).day ?? 0
            return max(daysSinceRelapse, 0)
        } else {
            let quitDay = calendar.startOfDay(for: quitDate)
            let daysSinceQuit = calendar.dateComponents([.day], from: quitDay, to: today).day ?? 0
            return max(daysSinceQuit, 0)
        }
    }
}