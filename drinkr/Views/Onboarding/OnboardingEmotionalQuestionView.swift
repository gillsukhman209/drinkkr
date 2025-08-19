import SwiftUI

struct OnboardingEmotionalQuestionView: View {
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
                
                // Options
                LazyVStack(spacing: 12) {
                    ForEach(Array(questionOptions.enumerated()), id: \.element.id) { index, option in
                        optionButton(option: option, index: index)
                    }
                }
                .padding(.horizontal, 20)
                
                // Community connection (for emotional questions)
                if shouldShowCommunityStats() {
                    communityStats
                        .padding(.top, 20)
                        .opacity(isVisible ? 1.0 : 0.0)
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
    
    private func optionButton(option: OnboardingOption, index: Int) -> some View {
        let isSelected = isOptionSelected(option)
        let isMultiple = allowsMultipleSelection
        
        return Button(action: {
            selectOption(option)
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
                        if isMultiple {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ColorTheme.accentCyan)
                        } else {
                            Circle()
                                .fill(ColorTheme.accentCyan)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                
                // Option content
                HStack(spacing: 12) {
                    if let icon = option.icon {
                        Image(systemName: icon)
                            .font(.system(size: isCompact ? 18 : 20, weight: .medium))
                            .foregroundColor(option.color ?? ColorTheme.accentCyan)
                            .frame(width: 24)
                    }
                    
                    Text(option.text)
                        .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                
                // Percentage (for some emotional questions)
                if shouldShowPercentage(for: option) {
                    Text(getPercentage(for: option))
                        .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        ColorTheme.accentCyan.opacity(0.15) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
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
        .offset(y: isVisible ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: isVisible)
    }
    
    private var communityStats: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14))
                    .foregroundColor(ColorTheme.accentCyan)
                
                Text("You're not alone")
                    .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                    .foregroundColor(ColorTheme.accentCyan)
            }
            
            Text("Thousands of people have shared similar experiences and are now living alcohol-free lives.")
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorTheme.accentCyan.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTheme.accentCyan.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    
    private var questionTitle: String {
        switch page {
        case .whyHere:
            return "Why are you here today?"
        case .lifeImpact:
            return "How is alcohol affecting your life?"
        case .symptoms:
            return "What symptoms are you experiencing?"
        case .losses:
            return "What have you lost to alcohol?"
        case .triggers:
            return "What triggers your drinking?"
        case .afterFeeling:
            return "How do you feel after drinking?"
        case .biggestFear:
            return "What's your biggest fear about quitting?"
        case .previousAttempts:
            return "Have you tried to quit before?"
        default:
            return ""
        }
    }
    
    private var questionSubtitle: String? {
        switch page {
        case .whyHere:
            return "This helps us understand your journey"
        case .lifeImpact:
            return "Select all that apply - your honesty helps us help you"
        case .symptoms:
            return "Your health matters - select all that apply"
        case .losses:
            return "It's okay to acknowledge what alcohol has cost you"
        case .triggers:
            return "Understanding your triggers is the first step to managing them"
        case .afterFeeling:
            return "Your feelings are valid and shared by many others"
        case .biggestFear:
            return "These fears are normal - we'll help you overcome them"
        case .previousAttempts:
            return "Every attempt is a step forward, regardless of the outcome"
        default:
            return nil
        }
    }
    
    private var questionOptions: [OnboardingOption] {
        switch page {
        case .whyHere:
            return OnboardingQuestions.whyHere.options
        case .lifeImpact:
            return OnboardingQuestions.lifeImpact.options
        case .symptoms:
            return OnboardingQuestions.symptoms.options
        case .losses:
            return OnboardingQuestions.losses.options
        case .triggers:
            return OnboardingQuestions.triggers.options
        case .afterFeeling:
            return OnboardingQuestions.afterFeeling.options
        case .biggestFear:
            return OnboardingQuestions.biggestFear.options
        case .previousAttempts:
            return OnboardingQuestions.previousAttempts.options
        default:
            return []
        }
    }
    
    private var allowsMultipleSelection: Bool {
        switch page {
        case .lifeImpact, .symptoms, .losses, .triggers:
            return true
        default:
            return false
        }
    }
    
    private func isOptionSelected(_ option: OnboardingOption) -> Bool {
        switch page {
        case .whyHere:
            return viewModel.selectedWhyHere == option
        case .lifeImpact:
            return viewModel.selectedLifeImpacts.contains(option)
        case .symptoms:
            return viewModel.selectedSymptoms.contains(option)
        case .losses:
            return viewModel.selectedLosses.contains(option)
        case .triggers:
            return viewModel.selectedTriggers.contains(option)
        case .afterFeeling:
            return viewModel.selectedAfterFeeling == option
        case .biggestFear:
            return viewModel.selectedBiggestFear == option
        case .previousAttempts:
            return viewModel.selectedPreviousAttempts == option
        default:
            return false
        }
    }
    
    private func selectOption(_ option: OnboardingOption) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            switch page {
            case .whyHere:
                viewModel.selectedWhyHere = option
            case .lifeImpact:
                if viewModel.selectedLifeImpacts.contains(option) {
                    viewModel.selectedLifeImpacts.remove(option)
                } else {
                    viewModel.selectedLifeImpacts.insert(option)
                }
            case .symptoms:
                if viewModel.selectedSymptoms.contains(option) {
                    viewModel.selectedSymptoms.remove(option)
                } else {
                    viewModel.selectedSymptoms.insert(option)
                }
            case .losses:
                if viewModel.selectedLosses.contains(option) {
                    viewModel.selectedLosses.remove(option)
                } else {
                    viewModel.selectedLosses.insert(option)
                }
            case .triggers:
                if viewModel.selectedTriggers.contains(option) {
                    viewModel.selectedTriggers.remove(option)
                } else {
                    viewModel.selectedTriggers.insert(option)
                }
            case .afterFeeling:
                viewModel.selectedAfterFeeling = option
            case .biggestFear:
                viewModel.selectedBiggestFear = option
            case .previousAttempts:
                viewModel.selectedPreviousAttempts = option
            default:
                break
            }
        }
    }
    
    private func shouldShowCommunityStats() -> Bool {
        switch page {
        case .lifeImpact, .symptoms, .losses, .afterFeeling:
            return true
        default:
            return false
        }
    }
    
    private func shouldShowPercentage(for option: OnboardingOption) -> Bool {
        // Show percentages for emotional connection
        return page == .lifeImpact || page == .triggers
    }
    
    private func getPercentage(for option: OnboardingOption) -> String {
        // Simulated percentages for community connection
        switch option.text {
        case "Damaging my relationships":
            return "78%"
        case "Affecting my work/career":
            return "65%"
        case "Harming my health":
            return "89%"
        case "Causing financial stress":
            return "71%"
        case "Making me anxious/depressed":
            return "84%"
        case "Ruining my sleep":
            return "92%"
        case "Stress from work":
            return "76%"
        case "Social pressure":
            return "58%"
        case "Loneliness":
            return "63%"
        case "Boredom":
            return "45%"
        default:
            return "52%"
        }
    }
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingEmotionalQuestionView(
            page: .lifeImpact,
            viewModel: OnboardingViewModel()
        )
    }
}