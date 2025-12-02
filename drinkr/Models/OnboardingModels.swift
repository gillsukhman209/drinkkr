import Foundation
import SwiftUI

// MARK: - Onboarding Data Models

struct OnboardingUserProfile: Codable {
    // Emotional data
    var quittingReason: String = ""
    var lifeImpacts: [String] = []
    var symptoms: [String] = []
    var losses: [String] = []
    var triggers: [String] = []
    var afterFeeling: String = ""
    var biggestFear: String = ""
    var previousAttempts: String = ""
    
    // Personal data
    var userName: String = ""
    var age: Int = 0
    var fastFoodFrequency: String = ""
    var mealsPerWeek: String = ""
    var weeklySpending: String = ""
    var hoursLostWeekly: String = ""
    
    // Goals & Commitment
    var selectedGoals: [String] = []
    var quitDate: Date = Date()
    var checkInTime: Date = Date()
    
    // Calculated values
    var estimatedMonthlySavings: Double {
        let weeklyAmount = weeklySpendingAmount
        return weeklyAmount * 4.33 // Average weeks per month
    }
    
    var weeklySpendingAmount: Double {
        switch weeklySpending {
        case "$0-20": return 10
        case "$20-50": return 35
        case "$50-100": return 75
        case "$100+": return 150
        default: return 0
        }
    }
    
    var mealsPerWeekInt: Int {
        switch mealsPerWeek {
        case "1-2 meals": return 2
        case "3-4 meals": return 4
        case "5-6 meals": return 6
        case "7+ meals": return 8
        default: return 3
        }
    }
    
    var hoursLostWeeklyInt: Int {
        switch hoursLostWeekly {
        case "1-2 hours": return 2
        case "3-5 hours": return 4
        case "5-10 hours": return 8
        case "10+ hours": return 12
        default: return 3
        }
    }
}

// MARK: - Question Models

enum OnboardingQuestionType {
    case singleChoice
    case multipleChoice
    case info
}

struct OnboardingQuestion {
    let id: String
    let title: String
    let subtitle: String?
    let type: OnboardingQuestionType
    let options: [OnboardingOption]
    let allowsMultiple: Bool
    let icon: String?
}

struct OnboardingOption: Identifiable, Equatable, Hashable {
    let id = UUID()
    let text: String
    let icon: String?
    let color: Color?
    
    static func == (lhs: OnboardingOption, rhs: OnboardingOption) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Onboarding Pages

enum OnboardingPage: CaseIterable {
    case welcome
    case intro1
    case intro2
    case intro3
    case whyHere          // Q1
    case lifeImpact       // Q2
    case symptoms         // Q3
    case losses           // Q4
    case triggers         // Q5
    case afterFeeling     // Q6
    case biggestFear      // Q7
    case previousAttempts // Q8
    case name             // Q9 - Name collection
    case eatingPattern  // Q10 - Now Eating Pattern
    case cost             // Q11
    case motivation
    case goals
    case commitment
    case complete
    
    var progress: Double {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self) else { return 0 }
        return Double(index + 1) / Double(allCases.count)
    }
    
    var pageNumber: Int {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self) else { return 0 }
        return index + 1
    }
    
    var isQuestion: Bool {
        switch self {
        case .whyHere, .lifeImpact, .symptoms, .losses, .triggers,
             .afterFeeling, .biggestFear, .previousAttempts, .name,
             .eatingPattern, .cost, .goals:
            return true
        default:
            return false
        }
    }
}

// MARK: - Welcome Content

struct WelcomeContent {
    let title: String
    let subtitle: String
    let imageName: String
    let gradientColors: [Color]
}

// MARK: - Goal Model

struct OnboardingGoal: Identifiable, Equatable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    static func == (lhs: OnboardingGoal, rhs: OnboardingGoal) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Predefined Questions

struct OnboardingQuestions {
    static let whyHere = OnboardingQuestion(
        id: "whyHere",
        title: "Why are you here today?",
        subtitle: "This helps us understand your journey",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "I want to quit completely", icon: "flag.fill", color: .green),
            OnboardingOption(text: "I need to eat healthier", icon: "leaf.fill", color: .orange),
            OnboardingOption(text: "Doctor recommended it", icon: "stethoscope", color: .blue),
            OnboardingOption(text: "I'm just exploring", icon: "magnifyingglass", color: .purple),
            OnboardingOption(text: "I feel out of control", icon: "exclamationmark.triangle.fill", color: .red)
        ],
        allowsMultiple: false,
        icon: "questionmark.circle.fill"
    )
    
    static let lifeImpact = OnboardingQuestion(
        id: "lifeImpact",
        title: "How is fast food affecting your life?",
        subtitle: "Select all that apply",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Gaining weight", icon: "scalemass.fill", color: .red),
            OnboardingOption(text: "Low energy/fatigue", icon: "bolt.slash.fill", color: .blue),
            OnboardingOption(text: "Digestive issues", icon: "cross.case.fill", color: .green),
            OnboardingOption(text: "Wasting money", icon: "dollarsign.circle.fill", color: .yellow),
            OnboardingOption(text: "Feeling guilty", icon: "person.fill.xmark", color: .purple),
            OnboardingOption(text: "Skin problems", icon: "face.dashed", color: .indigo),
            OnboardingOption(text: "Poor sleep quality", icon: "moon.zzz.fill", color: .orange),
            OnboardingOption(text: "Health concerns", icon: "heart.text.square.fill", color: .pink)
        ],
        allowsMultiple: true,
        icon: "exclamationmark.triangle.fill"
    )
    
    static let symptoms = OnboardingQuestion(
        id: "symptoms",
        title: "What symptoms do you experience?",
        subtitle: "Your health matters - select all that apply",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Bloating", icon: nil, color: nil),
            OnboardingOption(text: "Sluggishness", icon: nil, color: nil),
            OnboardingOption(text: "Brain fog", icon: nil, color: nil),
            OnboardingOption(text: "Cravings", icon: nil, color: nil),
            OnboardingOption(text: "Heartburn/Reflux", icon: nil, color: nil),
            OnboardingOption(text: "Mood swings", icon: nil, color: nil),
            OnboardingOption(text: "Acne/Skin issues", icon: nil, color: nil),
            OnboardingOption(text: "Joint pain", icon: nil, color: nil)
        ],
        allowsMultiple: true,
        icon: "stethoscope"
    )
    
    static let losses = OnboardingQuestion(
        id: "losses",
        title: "What has fast food cost you?",
        subtitle: "It's okay to acknowledge the impact",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Physical fitness", icon: "figure.run", color: .red),
            OnboardingOption(text: "Self-confidence", icon: "person.fill.questionmark", color: .orange),
            OnboardingOption(text: "Money and savings", icon: "dollarsign.circle.fill", color: .yellow),
            OnboardingOption(text: "Energy for hobbies", icon: "battery.25", color: .purple),
            OnboardingOption(text: "Long-term health", icon: "heart.text.square.fill", color: .green),
            OnboardingOption(text: "Mental clarity", icon: "brain.head.profile", color: .blue),
            OnboardingOption(text: "Comfort in clothes", icon: "tshirt.fill", color: .pink),
            OnboardingOption(text: "Personal goals", icon: "target", color: .cyan)
        ],
        allowsMultiple: true,
        icon: "exclamationmark.triangle.fill"
    )
    
    static let triggers = OnboardingQuestion(
        id: "triggers",
        title: "What triggers your cravings?",
        subtitle: "Understanding your triggers is key",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Stress/Anxiety", icon: "brain.head.profile", color: .red),
            OnboardingOption(text: "Convenience/Time", icon: "clock.fill", color: .orange),
            OnboardingOption(text: "Boredom", icon: "zzz", color: .blue),
            OnboardingOption(text: "Late night hunger", icon: "moon.stars.fill", color: .purple),
            OnboardingOption(text: "Social gatherings", icon: "person.3.fill", color: .yellow),
            OnboardingOption(text: "Advertisements", icon: "tv.fill", color: .red),
            OnboardingOption(text: "Sadness/Comfort", icon: "cloud.rain.fill", color: .gray),
            OnboardingOption(text: "Habit/Routine", icon: "repeat.circle.fill", color: .green),
            OnboardingOption(text: "Passing a drive-thru", icon: "car.fill", color: .pink)
        ],
        allowsMultiple: true,
        icon: "exclamationmark.triangle.fill"
    )
    
    static let afterFeeling = OnboardingQuestion(
        id: "afterFeeling",
        title: "How do you feel after eating fast food?",
        subtitle: "Be honest with yourself",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "Bloated and heavy", icon: nil, color: nil),
            OnboardingOption(text: "Guilty and ashamed", icon: nil, color: nil),
            OnboardingOption(text: "Tired and lethargic", icon: nil, color: nil),
            OnboardingOption(text: "Physically sick", icon: nil, color: nil),
            OnboardingOption(text: "Disappointed", icon: nil, color: nil),
            OnboardingOption(text: "Satisfied briefly, then bad", icon: nil, color: nil)
        ],
        allowsMultiple: false,
        icon: "heart.slash.fill"
    )
    
    static let biggestFear = OnboardingQuestion(
        id: "biggestFear",
        title: "What's your biggest fear about quitting?",
        subtitle: "These fears are normal",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "I'll be hungry all the time", icon: nil, color: nil),
            OnboardingOption(text: "Cooking is too hard/time consuming", icon: nil, color: nil),
            OnboardingOption(text: "Healthy food tastes bad", icon: nil, color: nil),
            OnboardingOption(text: "I'll fail again", icon: nil, color: nil),
            OnboardingOption(text: "Social situations will be awkward", icon: nil, color: nil),
            OnboardingOption(text: "I can't afford healthy food", icon: nil, color: nil)
        ],
        allowsMultiple: false,
        icon: "exclamationmark.shield.fill"
    )
    
    static let previousAttempts = OnboardingQuestion(
        id: "previousAttempts",
        title: "Have you tried to quit before?",
        subtitle: "Every attempt is a lesson learned",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "Never tried", icon: nil, color: nil),
            OnboardingOption(text: "Once or twice", icon: nil, color: nil),
            OnboardingOption(text: "Several times", icon: nil, color: nil),
            OnboardingOption(text: "Many times", icon: nil, color: nil),
            OnboardingOption(text: "I'm always on and off", icon: nil, color: nil)
        ],
        allowsMultiple: false,
        icon: "clock.arrow.circlepath"
    )
    
    
    static let fastFoodFrequencyOptions = [
        OnboardingOption(text: "Daily", icon: "calendar.circle.fill", color: .red),
        OnboardingOption(text: "Few times a week", icon: "calendar.badge.clock", color: .orange),
        OnboardingOption(text: "Weekly", icon: "calendar", color: .yellow),
        OnboardingOption(text: "Occasionally", icon: "calendar.badge.plus", color: .green)
    ]
    
    static let mealsPerWeekOptions = [
        OnboardingOption(text: "1-2 meals", icon: "1.circle.fill", color: .green),
        OnboardingOption(text: "3-4 meals", icon: "3.circle.fill", color: .yellow),
        OnboardingOption(text: "5-6 meals", icon: "5.circle.fill", color: .orange),
        OnboardingOption(text: "7+ meals", icon: "plus.circle.fill", color: .red)
    ]
    
    
    static let weeklySpendingOptions = [
        OnboardingOption(text: "$0-20", icon: "dollarsign.circle", color: .green),
        OnboardingOption(text: "$20-50", icon: "dollarsign.circle.fill", color: .yellow),
        OnboardingOption(text: "$50-100", icon: "banknote.fill", color: .orange),
        OnboardingOption(text: "$100+", icon: "creditcard.fill", color: .red)
    ]
    
    static let hoursLostOptions = [
        OnboardingOption(text: "1-2 hours", icon: "clock", color: .green),
        OnboardingOption(text: "3-5 hours", icon: "clock.fill", color: .yellow),
        OnboardingOption(text: "5-10 hours", icon: "timer", color: .orange),
        OnboardingOption(text: "10+ hours", icon: "alarm.fill", color: .red)
    ]

    static let goals = [
        OnboardingGoal(icon: "🧠", title: "Clear mind", description: "Better focus and mental clarity", color: .blue),
        OnboardingGoal(icon: "❤️", title: "Self Love", description: "Treating my body right", color: .red),
        OnboardingGoal(icon: "💪", title: "Get fit", description: "Improve physical fitness", color: .green),
        OnboardingGoal(icon: "😴", title: "Sleep better", description: "Peaceful, restful nights", color: .indigo),
        OnboardingGoal(icon: "💰", title: "Save money", description: "Financial freedom", color: .yellow),
        OnboardingGoal(icon: "⚡️", title: "More Energy", description: "No more food comas", color: .orange),
        OnboardingGoal(icon: "😊", title: "Feel good", description: "Confidence and happiness", color: .pink),
        OnboardingGoal(icon: "🍳", title: "Cook more", description: "Learn to make healthy meals", color: .purple)
    ]
}