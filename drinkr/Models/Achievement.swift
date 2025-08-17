import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var title: String
    var achievementDescription: String
    var icon: String
    var category: AchievementCategory
    var requiredValue: Int
    var currentValue: Int
    var dateEarned: Date?
    var isUnlocked: Bool
    
    init(
        title: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        requiredValue: Int,
        currentValue: Int = 0,
        dateEarned: Date? = nil,
        isUnlocked: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.achievementDescription = description
        self.icon = icon
        self.category = category
        self.requiredValue = requiredValue
        self.currentValue = currentValue
        self.dateEarned = dateEarned
        self.isUnlocked = isUnlocked
    }
    
    func checkProgress(_ value: Int) {
        currentValue = value
        if currentValue >= requiredValue && !isUnlocked {
            unlock()
        }
    }
    
    func unlock() {
        isUnlocked = true
        dateEarned = Date()
    }
    
    var progress: Double {
        return min(Double(currentValue) / Double(requiredValue), 1.0)
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case streak = "Streak"
    case milestone = "Milestone"
    case savings = "Savings"
    case health = "Health"
    case community = "Community"
    case meditation = "Meditation"
}

struct AchievementManager {
    static func getDefaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Day", description: "Complete your first day sober", icon: "star.fill", category: .milestone, requiredValue: 1),
            Achievement(title: "Week Warrior", description: "Stay sober for 7 days", icon: "calendar", category: .streak, requiredValue: 7),
            Achievement(title: "Two Weeks Strong", description: "Reach 14 days sober", icon: "bolt.fill", category: .streak, requiredValue: 14),
            Achievement(title: "Monthly Master", description: "Complete 30 days sober", icon: "crown.fill", category: .streak, requiredValue: 30),
            Achievement(title: "90 Day Champion", description: "Reach 90 days milestone", icon: "trophy.fill", category: .milestone, requiredValue: 90),
            Achievement(title: "Centurion", description: "100 days of sobriety", icon: "flame.fill", category: .milestone, requiredValue: 100),
            Achievement(title: "Year of Freedom", description: "365 days alcohol-free", icon: "star.circle.fill", category: .milestone, requiredValue: 365),
            
            Achievement(title: "Penny Saved", description: "Save $100 from not drinking", icon: "dollarsign.circle.fill", category: .savings, requiredValue: 100),
            Achievement(title: "Big Saver", description: "Save $500", icon: "banknote.fill", category: .savings, requiredValue: 500),
            Achievement(title: "Grand Saved", description: "Save $1000", icon: "creditcard.fill", category: .savings, requiredValue: 1000),
            
            Achievement(title: "Calorie Cutter", description: "Save 1000 calories", icon: "flame.fill", category: .health, requiredValue: 1000),
            Achievement(title: "Health Hero", description: "Save 10000 calories", icon: "heart.fill", category: .health, requiredValue: 10000),
            
            Achievement(title: "Meditation Beginner", description: "Complete 5 meditation sessions", icon: "leaf.fill", category: .meditation, requiredValue: 5),
            Achievement(title: "Mindful Master", description: "Complete 30 meditation sessions", icon: "brain.head.profile", category: .meditation, requiredValue: 30),
            
            Achievement(title: "Pledge Keeper", description: "Complete 7 daily pledges", icon: "hand.raised.fill", category: .community, requiredValue: 7),
            Achievement(title: "Committed", description: "30 consecutive daily pledges", icon: "checkmark.seal.fill", category: .community, requiredValue: 30)
        ]
    }
}