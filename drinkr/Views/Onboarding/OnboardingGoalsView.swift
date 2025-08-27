import SwiftUI

struct OnboardingGoalsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isVisible = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: isCompact ? 25 : 35) {
                // Header
                VStack(spacing: 15) {
                    Text("What do you want to achieve?")
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -20)
                    
                    Text("Select all the goals that resonate with you")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -15)
                }
                .padding(.top, isCompact ? 20 : 30)
                
                // Goals grid
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(Array(OnboardingQuestions.goals.enumerated()), id: \.element.id) { index, goal in
                        goalCard(goal: goal, index: index)
                    }
                }
                .padding(.horizontal, 20)
                
                // Motivation message
                if !viewModel.selectedGoals.isEmpty {
                    motivationMessage
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: isVisible)
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
    
    private func goalCard(goal: OnboardingGoal, index: Int) -> some View {
        let isSelected = viewModel.selectedGoals.contains(goal)
        
        return Button(action: {
            selectGoal(goal)
        }) {
            VStack(spacing: 12) {
                // Emoji icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            goal.color.opacity(0.2) :
                            Color.white.opacity(0.05)
                        )
                        .frame(width: isCompact ? 50 : 60, height: isCompact ? 50 : 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? goal.color.opacity(0.5) : Color.white.opacity(0.1),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                    
                    Text(goal.icon)
                        .font(.system(size: isCompact ? 24 : 28))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                // Goal text
                VStack(spacing: 4) {
                    Text(goal.title)
                        .font(.system(size: isCompact ? 14 : 16, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(goal.description)
                        .font(.system(size: isCompact ? 11 : 12, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // Selection indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(isSelected ? goal.color : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                    
                    if isSelected {
                        Text("Selected")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(goal.color)
                    }
                }
                .opacity(isSelected ? 1.0 : 0.3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [goal.color.opacity(0.1), goal.color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.05), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? goal.color.opacity(0.4) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? goal.color.opacity(0.2) : .clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.08), value: isVisible)
    }
    
    private var motivationMessage: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(ColorTheme.accentCyan)
                
                Text("Your goals will guide your journey")
                    .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                    .foregroundColor(ColorTheme.accentCyan)
            }
            
            Text("You've selected \(viewModel.selectedGoals.count) goal\(viewModel.selectedGoals.count == 1 ? "" : "s"). We'll track your progress and celebrate every milestone with you.")
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [ColorTheme.accentCyan.opacity(0.1), ColorTheme.accentPurple.opacity(0.1)],
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
    
    private func selectGoal(_ goal: OnboardingGoal) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            if viewModel.selectedGoals.contains(goal) {
                viewModel.selectedGoals.remove(goal)
            } else {
                viewModel.selectedGoals.insert(goal)
            }
        }
    }
}


#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingGoalsView(viewModel: OnboardingViewModel())
    }
}