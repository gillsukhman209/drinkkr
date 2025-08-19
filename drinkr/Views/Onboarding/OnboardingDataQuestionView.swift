import SwiftUI

struct OnboardingDataQuestionView: View {
    let page: OnboardingPage
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isVisible = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: isCompact ? 25 : 35) {
                // Header
                VStack(spacing: 15) {
                    Text(questionTitle)
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -20)
                    
                    if let subtitle = questionSubtitle {
                        Text(subtitle)
                            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .opacity(isVisible ? 1.0 : 0.0)
                            .offset(y: isVisible ? 0 : -15)
                    }
                }
                .padding(.top, isCompact ? 20 : 30)
                
                // Multi-part questions (like basics page)
                if page == .basics {
                    basicsQuestions
                } else if page == .drinkingPattern {
                    drinkingPatternQuestions
                } else if page == .cost {
                    costQuestions
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
    
    private var basicsQuestions: some View {
        VStack(spacing: 30) {
            // Age question
            questionSection(
                title: "Your age range",
                options: OnboardingQuestions.ageOptions,
                selectedOption: viewModel.selectedAge,
                onSelect: { viewModel.selectedAge = $0 }
            )
            
            // Gender question
            questionSection(
                title: "Gender",
                options: OnboardingQuestions.genderOptions,
                selectedOption: viewModel.selectedGender,
                onSelect: { viewModel.selectedGender = $0 }
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var drinkingPatternQuestions: some View {
        VStack(spacing: 30) {
            // Frequency question
            questionSection(
                title: "How often do you drink?",
                options: OnboardingQuestions.drinkingFrequencyOptions,
                selectedOption: viewModel.selectedDrinkingFrequency,
                onSelect: { viewModel.selectedDrinkingFrequency = $0 }
            )
            
            // Amount question
            questionSection(
                title: "Drinks per session",
                options: OnboardingQuestions.drinksPerSessionOptions,
                selectedOption: viewModel.selectedDrinksPerSession,
                onSelect: { viewModel.selectedDrinksPerSession = $0 }
            )
            
            // Type question
            questionSection(
                title: "Preferred drink type",
                options: OnboardingQuestions.preferredDrinkOptions,
                selectedOption: viewModel.selectedPreferredDrink,
                onSelect: { viewModel.selectedPreferredDrink = $0 }
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var costQuestions: some View {
        VStack(spacing: 30) {
            // Money question
            questionSection(
                title: "Weekly spending on alcohol",
                options: OnboardingQuestions.weeklySpendingOptions,
                selectedOption: viewModel.selectedWeeklySpending,
                onSelect: { viewModel.selectedWeeklySpending = $0 }
            )
            
            // Time question
            questionSection(
                title: "Hours per week lost to drinking/hangovers",
                options: OnboardingQuestions.hoursLostOptions,
                selectedOption: viewModel.selectedHoursLost,
                onSelect: { viewModel.selectedHoursLost = $0 }
            )
            
            // Impact preview
            if let spending = viewModel.selectedWeeklySpending,
               let hours = viewModel.selectedHoursLost {
                impactPreview(spending: spending.text, hours: hours.text)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isVisible)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func questionSection(
        title: String,
        options: [OnboardingOption],
        selectedOption: OnboardingOption?,
        onSelect: @escaping (OnboardingOption) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            VStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    let isSelected = selectedOption == option
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onSelect(option)
                        }
                    }) {
                        HStack(spacing: 15) {
                            // Selection indicator
                            ZStack {
                                Circle()
                                    .stroke(
                                        isSelected ? ColorTheme.accentCyan : Color.white.opacity(0.3),
                                        lineWidth: 2
                                    )
                                    .frame(width: 20, height: 20)
                                
                                if isSelected {
                                    Circle()
                                        .fill(ColorTheme.accentCyan)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            
                            // Option content
                            HStack(spacing: 12) {
                                if let icon = option.icon {
                                    Image(systemName: icon)
                                        .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                        .foregroundColor(option.color ?? ColorTheme.accentCyan)
                                        .frame(width: 24)
                                }
                                
                                Text(option.text)
                                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    isSelected ?
                                    ColorTheme.accentCyan.opacity(0.15) :
                                    Color.white.opacity(0.05)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            isSelected ? ColorTheme.accentCyan.opacity(0.5) : Color.white.opacity(0.1),
                                            lineWidth: isSelected ? 2 : 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(isSelected ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: isVisible)
                }
            }
        }
    }
    
    
    private func impactPreview(spending: String, hours: String) -> some View {
        VStack(spacing: 12) {
            Text("💡 Quick calculation")
                .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                .foregroundColor(ColorTheme.accentCyan)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Monthly savings potential:")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Spacer()
                    
                    Text(calculateMonthlySavings(from: spending))
                        .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                        .foregroundColor(ColorTheme.successGreen)
                }
                
                HStack {
                    Text("Time you'll reclaim monthly:")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Spacer()
                    
                    Text(calculateTimeReclaimed(from: hours))
                        .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                        .foregroundColor(ColorTheme.accentPurple)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [ColorTheme.successGreen.opacity(0.1), ColorTheme.accentPurple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Methods
    
    private var questionTitle: String {
        switch page {
        case .basics:
            return "Tell us a bit about yourself"
        case .drinkingPattern:
            return "Your drinking pattern"
        case .cost:
            return "The real cost"
        default:
            return ""
        }
    }
    
    private var questionSubtitle: String? {
        switch page {
        case .basics:
            return "This helps us personalize your experience"
        case .drinkingPattern:
            return "Understanding your habits helps us calculate your progress"
        case .cost:
            return "Let's see how much alcohol is really costing you"
        default:
            return nil
        }
    }
    
    // These methods are not used in data question view since we use question sections
    
    private func calculateMonthlySavings(from spending: String) -> String {
        switch spending {
        case "$0-20": return "$40-80"
        case "$20-50": return "$80-200"
        case "$50-100": return "$200-400"
        case "$100+": return "$400+"
        default: return "$0"
        }
    }
    
    private func calculateTimeReclaimed(from hours: String) -> String {
        switch hours {
        case "1-5 hours": return "4-20 hours"
        case "6-10 hours": return "24-40 hours"
        case "11-20 hours": return "44-80 hours"
        case "20+ hours": return "80+ hours"
        default: return "0 hours"
        }
    }
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingDataQuestionView(
            page: .cost,
            viewModel: OnboardingViewModel()
        )
    }
}