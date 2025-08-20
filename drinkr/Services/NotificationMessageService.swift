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
    
    // MARK: - Phase 3: Milestone Celebration Messages
    
    func getMilestoneMessage(userName: String, milestone: Int, moneySaved: String, hoursReclaimed: Int) -> (title: String, body: String) {
        switch milestone {
        case 1:
            return (
                "🎉 FIRST 24 HOURS COMPLETE! 🎉",
                "\(userName), you did it! One full day without alcohol. Your body is already thanking you. This is just the beginning 💪"
            )
        case 3:
            return (
                "🔥 72 HOURS STRONG! 🔥",
                "\(userName), 3 days down! Your liver is celebrating, your brain is clearing, and you're proving you can do this 🌟"
            )
        case 7:
            return (
                "🏆 ONE WEEK CHAMPION! 🏆",
                "\(userName), 7 days sober! You've saved \(moneySaved) and reclaimed \(hoursReclaimed) hours. Screenshot this victory 📸"
            )
        case 14:
            return (
                "💎 TWO WEEKS OF FREEDOM! 💎",
                "\(userName), 14 days! Your sleep is improving, anxiety decreasing, and you're \(moneySaved) richer. Keep going! 🚀"
            )
        case 30:
            return (
                "🚨 MONTH 1 COMPLETE! 🚨",
                "\(userName), 30 DAYS SOBER! You've saved \(moneySaved) and reclaimed \(hoursReclaimed) hours of your life. This is HUGE! 🎊"
            )
        case 60:
            return (
                "⭐ TWO MONTHS STRONG! ⭐",
                "\(userName), 60 days of choosing yourself! \(moneySaved) saved, \(hoursReclaimed) hours reclaimed. You're unstoppable 💫"
            )
        case 90:
            return (
                "🌟 90 DAYS - NEW YOU! 🌟",
                "\(userName), THREE MONTHS SOBER! Your brain has literally rewired itself. \(moneySaved) saved. Screenshot this transformation 📱"
            )
        case 180:
            return (
                "🎯 HALF A YEAR HERO! 🎯",
                "\(userName), 6 MONTHS! From rock bottom to rock solid. \(moneySaved) saved, \(hoursReclaimed) hours of real life lived 🏔️"
            )
        case 365:
            return (
                "👑 ONE YEAR LEGEND! 👑",
                "\(userName), 365 DAYS SOBER! You've saved \(moneySaved) and gained a whole new life. Screenshot this moment forever 🎆"
            )
        default:
            let years = milestone / 365
            if years > 1 {
                return (
                    "🌈 \(years) YEARS OF FREEDOM! 🌈",
                    "\(userName), \(years) YEARS SOBER! You're not just surviving, you're THRIVING. An inspiration to everyone 🦋"
                )
            } else {
                return (
                    "🎊 DAY \(milestone) MILESTONE! 🎊",
                    "\(userName), \(milestone) days of strength! Every day is a victory worth celebrating 🌟"
                )
            }
        }
    }
    
    // MARK: - Phase 4: Savage Motivation Messages
    
    func getSavageMotivationMessage(userName: String, losses: [String], afterFeeling: String, daysSober: Int) -> (title: String, body: String) {
        let messages = [
            (
                "Reality Check Saturday 🔥",
                "\(userName), you used to lose entire weekends to hangovers. It's Saturday 10 AM and you're FREE. Past you could never 🌅"
            ),
            (
                "Friday Night Truth Bomb 💣",
                "Remember when Friday meant blacking out? \(userName), it's Friday night and you're actually living. Day \(daysSober) of real life 🎯"
            ),
            (
                "Brutal Honesty Hour 💪",
                "\(userName), \(daysSober) days ago you felt '\(afterFeeling)' after drinking. Now? You wake up proud. That's growth 📈"
            ),
            (
                "Tuesday Reality Check ⚡",
                "Hey \(userName), remember losing \(losses.first ?? "everything") to alcohol? Day \(daysSober) of getting it all back 💎"
            ),
            (
                "Wake Up Call 📢",
                "\(userName), you're \(daysSober) days into proving everyone wrong who said you couldn't do it. Including yourself 🦁"
            ),
            (
                "Savage Truth Time 🎯",
                "Plot twist: The 'fun' you thought you were having was just borrowed happiness. Day \(daysSober) of the real thing ✨"
            )
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Phase 5: Fear Crusher Messages
    
    func getFearCrusherMessage(userName: String, biggestFear: String, daysSober: Int) -> (title: String, body: String) {
        switch biggestFear.lowercased() {
        case let fear where fear.contains("boring") || fear.contains("life will be boring"):
            return (
                "Sunday Fear Check: Boredom 🎭",
                "\(userName), you feared life would be boring without alcohol. Plot twist: You've had \(daysSober) days of authentic joy. Boring was the blackouts 🎉"
            )
        case let fear where fear.contains("friends") || fear.contains("lose my friends"):
            return (
                "Sunday Fear Check: Friends 👥",
                "You feared losing friends, \(userName). Truth: Real friends celebrate your \(daysSober) days of growth. The rest? Just drinking buddies 🤷‍♀️"
            )
        case let fear where fear.contains("stress") || fear.contains("handle stress"):
            return (
                "Sunday Fear Check: Stress 🧘",
                "\(userName), you thought you couldn't handle stress without alcohol. \(daysSober) days later, you're handling EVERYTHING. Alcohol was the stress 💪"
            )
        case let fear where fear.contains("fail") || fear.contains("disappoint"):
            return (
                "Sunday Fear Check: Failure 🏆",
                "Afraid of failing? \(userName), you're \(daysSober) days into the hardest thing you've ever done. That's not failure, that's heroic 🦸‍♀️"
            )
        case let fear where fear.contains("withdrawal") || fear.contains("symptoms"):
            return (
                "Sunday Fear Check: Withdrawal ⚡",
                "\(userName), you feared withdrawal symptoms. You survived them ALL and here you are, \(daysSober) days stronger. You're unstoppable 🚀"
            )
        case let fear where fear.contains("who i am") || fear.contains("identity"):
            return (
                "Sunday Fear Check: Identity 🦋",
                "You feared not knowing who you are without alcohol. \(userName), after \(daysSober) days, you're meeting the REAL you. And they're amazing 🌟"
            )
        default:
            return (
                "Sunday Fear Check 🎯",
                "\(userName), remember your biggest fear about quitting? \(daysSober) days later, you're living proof that fear was lying to you 💫"
            )
        }
    }
    
    // MARK: - Phase 6: Wisdom Drop Messages
    
    func getWisdomDropMessage() -> (title: String, body: String) {
        let wisdomMessages = [
            (
                "Daily Wisdom 🌟",
                "You're not 'giving up' alcohol. You're choosing everything it took away: clarity, money, time, self-respect, real happiness ✨"
            ),
            (
                "Truth Moment 💭",
                "The version of you that needed alcohol to cope was doing their best with what they knew. Today's version knows better 📖"
            ),
            (
                "Perspective Shift 🔄",
                "Alcohol promised to solve your problems. Instead, it became one. Sobriety isn't the hard part - drinking was 💡"
            ),
            (
                "Today's Insight 🧠",
                "You didn't have a drinking problem. You had a problem that drinking temporarily silenced. Now you're healing the real issue 🌱"
            ),
            (
                "Wisdom Wednesday ✨",
                "Rock bottom became the solid foundation on which you rebuilt your life. Sometimes you need to fall to learn how to fly 🦅"
            ),
            (
                "Daily Reframe 🎨",
                "FOMO about not drinking? The only thing you're missing out on is hangovers, regret, and borrowed happiness. That's JOMO - Joy of Missing Out 🎉"
            ),
            (
                "Truth Drop 💎",
                "Sobriety didn't open the gates of heaven and let you in. It opened the gates of hell and let you out 🔓"
            ),
            (
                "Philosophical Friday 🤔",
                "The opposite of addiction isn't sobriety. It's connection. Every sober day, you're reconnecting with yourself and others 🤝"
            ),
            (
                "Mindset Medicine 💊",
                "You're not broken and in need of fixing. You're healing and in need of time. There's a profound difference 🕰️"
            ),
            (
                "Reality Check ☄️",
                "One day you'll tell your story of how you overcame what you went through, and it will be someone else's survival guide 📚"
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