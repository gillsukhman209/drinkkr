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
    
    // Practical data
    var age: String = ""
    var gender: String = ""
    var relationshipStatus: String = ""
    var drinkingFrequency: String = ""
    var drinksPerSession: String = ""
    var preferredDrink: String = ""
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
    
    var drinksPerSessionInt: Int {
        switch drinksPerSession {
        case "1-2 drinks": return 2
        case "3-4 drinks": return 4
        case "5-6 drinks": return 6
        case "7+ drinks": return 8
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
    case basics           // Q9
    case drinkingPattern  // Q10
    case cost             // Q11
    case motivation
    case goals
    case commitment
    case permissions
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
             .afterFeeling, .biggestFear, .previousAttempts, .basics,
             .drinkingPattern, .cost, .goals:
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
            OnboardingOption(text: "I need to cut back", icon: "arrow.down.circle.fill", color: .orange),
            OnboardingOption(text: "Someone asked me to stop", icon: "person.2.fill", color: .blue),
            OnboardingOption(text: "I'm just exploring", icon: "magnifyingglass", color: .purple),
            OnboardingOption(text: "I hit rock bottom", icon: "arrow.down.to.line", color: .red)
        ],
        allowsMultiple: false,
        icon: "questionmark.circle.fill"
    )
    
    static let lifeImpact = OnboardingQuestion(
        id: "lifeImpact",
        title: "How is alcohol affecting your life?",
        subtitle: "Select all that apply",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Damaging my relationships", icon: "heart.slash.fill", color: .red),
            OnboardingOption(text: "Affecting my work/career", icon: "briefcase.fill", color: .blue),
            OnboardingOption(text: "Harming my health", icon: "heart.text.square.fill", color: .green),
            OnboardingOption(text: "Causing financial stress", icon: "dollarsign.circle.fill", color: .yellow),
            OnboardingOption(text: "Making me anxious/depressed", icon: "brain.head.profile", color: .purple),
            OnboardingOption(text: "Ruining my sleep", icon: "moon.zzz.fill", color: .indigo),
            OnboardingOption(text: "Causing shame and guilt", icon: "person.fill.xmark", color: .orange),
            OnboardingOption(text: "Missing important moments", icon: "calendar.badge.exclamationmark", color: .pink)
        ],
        allowsMultiple: true,
        icon: "exclamationmark.triangle.fill"
    )
    
    static let symptoms = OnboardingQuestion(
        id: "symptoms",
        title: "What symptoms are you experiencing?",
        subtitle: "Your health matters - select all that apply",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Morning shakes or tremors", icon: nil, color: nil),
            OnboardingOption(text: "Constant fatigue", icon: nil, color: nil),
            OnboardingOption(text: "Memory blackouts", icon: nil, color: nil),
            OnboardingOption(text: "Anxiety when not drinking", icon: nil, color: nil),
            OnboardingOption(text: "Trouble sleeping without alcohol", icon: nil, color: nil),
            OnboardingOption(text: "Heart palpitations", icon: nil, color: nil),
            OnboardingOption(text: "Sweating or hot flashes", icon: nil, color: nil),
            OnboardingOption(text: "Mood swings", icon: nil, color: nil),
            OnboardingOption(text: "Brain fog", icon: nil, color: nil)
        ],
        allowsMultiple: true,
        icon: "stethoscope"
    )
    
    static let losses = OnboardingQuestion(
        id: "losses",
        title: "What have you lost to alcohol?",
        subtitle: "It's okay to acknowledge what alcohol has cost you",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Trust from loved ones", icon: "heart.slash.fill", color: .red),
            OnboardingOption(text: "Job opportunities", icon: "briefcase.fill", color: .orange),
            OnboardingOption(text: "Money and savings", icon: "dollarsign.circle.fill", color: .yellow),
            OnboardingOption(text: "Self-respect", icon: "person.fill.questionmark", color: .purple),
            OnboardingOption(text: "Physical health", icon: "heart.text.square.fill", color: .green),
            OnboardingOption(text: "Mental clarity", icon: "brain.head.profile", color: .blue),
            OnboardingOption(text: "Time with family", icon: "figure.2.and.child.holdinghands", color: .pink),
            OnboardingOption(text: "Personal goals", icon: "target", color: .cyan)
        ],
        allowsMultiple: true,
        icon: "exclamationmark.triangle.fill"
    )
    
    static let triggers = OnboardingQuestion(
        id: "triggers",
        title: "What triggers your drinking?",
        subtitle: "Understanding your triggers is the first step to managing them",
        type: .multipleChoice,
        options: [
            OnboardingOption(text: "Stress from work", icon: "briefcase.fill", color: .red),
            OnboardingOption(text: "Social pressure", icon: "person.3.fill", color: .orange),
            OnboardingOption(text: "Loneliness", icon: "person.fill", color: .blue),
            OnboardingOption(text: "Boredom", icon: "clock.fill", color: .purple),
            OnboardingOption(text: "Celebrating", icon: "party.popper.fill", color: .yellow),
            OnboardingOption(text: "Anger or frustration", icon: "flame.fill", color: .red),
            OnboardingOption(text: "Sadness or depression", icon: "cloud.rain.fill", color: .gray),
            OnboardingOption(text: "Habit/routine", icon: "repeat.circle.fill", color: .green),
            OnboardingOption(text: "Physical cravings", icon: "heart.fill", color: .pink)
        ],
        allowsMultiple: true,
        icon: "exclamationmark.triangle.fill"
    )
    
    static let afterFeeling = OnboardingQuestion(
        id: "afterFeeling",
        title: "How do you feel after drinking?",
        subtitle: "Your feelings are valid and shared by many others",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "Ashamed and guilty", icon: nil, color: nil),
            OnboardingOption(text: "Anxious and worried", icon: nil, color: nil),
            OnboardingOption(text: "Physically sick", icon: nil, color: nil),
            OnboardingOption(text: "Depressed", icon: nil, color: nil),
            OnboardingOption(text: "Angry at myself", icon: nil, color: nil),
            OnboardingOption(text: "Hopeless", icon: nil, color: nil)
        ],
        allowsMultiple: false,
        icon: "heart.slash.fill"
    )
    
    static let biggestFear = OnboardingQuestion(
        id: "biggestFear",
        title: "What's your biggest fear about quitting?",
        subtitle: "These fears are normal - we'll help you overcome them",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "I'll lose my friends", icon: nil, color: nil),
            OnboardingOption(text: "I can't handle stress without it", icon: nil, color: nil),
            OnboardingOption(text: "Life will be boring", icon: nil, color: nil),
            OnboardingOption(text: "I'll fail and disappoint everyone", icon: nil, color: nil),
            OnboardingOption(text: "Withdrawal symptoms", icon: nil, color: nil),
            OnboardingOption(text: "I don't know who I am without it", icon: nil, color: nil)
        ],
        allowsMultiple: false,
        icon: "exclamationmark.shield.fill"
    )
    
    static let previousAttempts = OnboardingQuestion(
        id: "previousAttempts",
        title: "Have you tried to quit before?",
        subtitle: "Every attempt is a step forward, regardless of the outcome",
        type: .singleChoice,
        options: [
            OnboardingOption(text: "Never tried", icon: nil, color: nil),
            OnboardingOption(text: "Once or twice", icon: nil, color: nil),
            OnboardingOption(text: "Several times", icon: nil, color: nil),
            OnboardingOption(text: "Many times", icon: nil, color: nil),
            OnboardingOption(text: "I've lost count", icon: nil, color: nil)
        ],
        allowsMultiple: false,
        icon: "clock.arrow.circlepath"
    )
    
    // Data collection questions
    static let ageOptions = [
        OnboardingOption(text: "18-24", icon: nil, color: nil),
        OnboardingOption(text: "25-34", icon: nil, color: nil),
        OnboardingOption(text: "35-44", icon: nil, color: nil),
        OnboardingOption(text: "45-54", icon: nil, color: nil),
        OnboardingOption(text: "55+", icon: nil, color: nil)
    ]
    
    static let genderOptions = [
        OnboardingOption(text: "Male", icon: nil, color: nil),
        OnboardingOption(text: "Female", icon: nil, color: nil),
        OnboardingOption(text: "Other", icon: nil, color: nil),
        OnboardingOption(text: "Prefer not to say", icon: nil, color: nil)
    ]
    
    static let relationshipOptions = [
        OnboardingOption(text: "Single", icon: nil, color: nil),
        OnboardingOption(text: "In a relationship", icon: nil, color: nil),
        OnboardingOption(text: "Married", icon: nil, color: nil),
        OnboardingOption(text: "Divorced", icon: nil, color: nil),
        OnboardingOption(text: "Prefer not to say", icon: nil, color: nil)
    ]
    
    static let drinkingFrequencyOptions = [
        OnboardingOption(text: "Daily", icon: "calendar.circle.fill", color: .red),
        OnboardingOption(text: "Few times a week", icon: "calendar.badge.clock", color: .orange),
        OnboardingOption(text: "Weekly", icon: "calendar", color: .yellow),
        OnboardingOption(text: "Occasionally", icon: "calendar.badge.plus", color: .green)
    ]
    
    static let drinksPerSessionOptions = [
        OnboardingOption(text: "1-2 drinks", icon: "1.circle.fill", color: .green),
        OnboardingOption(text: "3-4 drinks", icon: "3.circle.fill", color: .yellow),
        OnboardingOption(text: "5-6 drinks", icon: "5.circle.fill", color: .orange),
        OnboardingOption(text: "7+ drinks", icon: "plus.circle.fill", color: .red)
    ]
    
    static let preferredDrinkOptions = [
        OnboardingOption(text: "Beer", icon: "drop.fill", color: .yellow),
        OnboardingOption(text: "Wine", icon: "wineglass.fill", color: .purple),
        OnboardingOption(text: "Spirits", icon: "flame.fill", color: .orange),
        OnboardingOption(text: "Mixed drinks", icon: "cup.and.saucer.fill", color: .blue)
    ]
    
    static let weeklySpendingOptions = [
        OnboardingOption(text: "$0-20", icon: "dollarsign.circle", color: .green),
        OnboardingOption(text: "$20-50", icon: "dollarsign.circle.fill", color: .yellow),
        OnboardingOption(text: "$50-100", icon: "banknote.fill", color: .orange),
        OnboardingOption(text: "$100+", icon: "creditcard.fill", color: .red)
    ]
    
    static let hoursLostOptions = [
        OnboardingOption(text: "1-5 hours", icon: "clock", color: .green),
        OnboardingOption(text: "6-10 hours", icon: "clock.fill", color: .yellow),
        OnboardingOption(text: "11-20 hours", icon: "timer", color: .orange),
        OnboardingOption(text: "20+ hours", icon: "alarm.fill", color: .red)
    ]

    static let goals = [
        OnboardingGoal(icon: "🧠", title: "Clear mind", description: "Better focus and mental clarity", color: .blue),
        OnboardingGoal(icon: "❤️", title: "Rebuild trust", description: "Strengthen relationships", color: .red),
        OnboardingGoal(icon: "💪", title: "Get healthy", description: "Improve physical fitness", color: .green),
        OnboardingGoal(icon: "😴", title: "Sleep better", description: "Peaceful, restful nights", color: .indigo),
        OnboardingGoal(icon: "💰", title: "Save money", description: "Financial freedom", color: .yellow),
        OnboardingGoal(icon: "🎯", title: "Achieve goals", description: "Reach your potential", color: .orange),
        OnboardingGoal(icon: "😊", title: "Find happiness", description: "Joy without alcohol", color: .pink),
        OnboardingGoal(icon: "🏆", title: "Prove myself", description: "Show I can do this", color: .purple)
    ]
}