import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var isPresented: Bool
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            OptimizedBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentPage != .welcome {
                    progressBar
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
                
                // Main content
                GeometryReader { geometry in
                    ZStack {
                        currentPageView
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }
                
                // Navigation buttons
                if viewModel.currentPage != .welcome {
                    navigationButtons
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { notification in
            if let _ = notification.object as? OnboardingUserProfile {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                    isPresented = false
                }
            }
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 12) {
            HStack {
                if viewModel.canGoBack() {
                    Button(action: {
                        viewModel.previousPage()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                            .foregroundColor(ColorTheme.accentCyan)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(ColorTheme.cardBackground)
                                    .overlay(
                                        Circle()
                                            .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // Placeholder to maintain layout balance
                    Spacer()
                        .frame(width: 32, height: 32)
                }
                
                Spacer()
                
                Text("Step \(viewModel.currentPage.pageNumber) of \(OnboardingPage.allCases.count)")
                    .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                
                Spacer()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.currentPage.progress, height: 6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentPage.progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var currentPageView: some View {
        Group {
            switch viewModel.currentPage {
            case .welcome:
                OnboardingWelcomeView(viewModel: viewModel)
            case .intro1, .intro2, .intro3:
                OnboardingIntroView(page: viewModel.currentPage, viewModel: viewModel)
            case .whyHere, .lifeImpact, .symptoms, .losses, .triggers, .afterFeeling, .biggestFear, .previousAttempts:
                OnboardingEmotionalQuestionView(page: viewModel.currentPage, viewModel: viewModel)
            case .name:
                OnboardingNameView(viewModel: viewModel)
            case .basics, .drinkingPattern, .cost:
                OnboardingDataQuestionView(page: viewModel.currentPage, viewModel: viewModel)
            case .motivation:
                OnboardingMotivationView(viewModel: viewModel)
            case .goals:
                OnboardingGoalsView(viewModel: viewModel)
            case .commitment:
                OnboardingCommitmentView(viewModel: viewModel)
            case .permissions:
                OnboardingPermissionView(viewModel: viewModel)
            case .complete:
                OnboardingCompleteView(viewModel: viewModel)
            }
        }
        .opacity(viewModel.isTransitioning ? 0.3 : 1.0)
        .scaleEffect(viewModel.isTransitioning ? 0.95 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isTransitioning)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 15) {
            
            // Next/Continue button
            Button(action: {
                if viewModel.currentPage == .complete {
                    viewModel.completeOnboarding()
                } else {
                    viewModel.nextPage()
                }
            }) {
                HStack(spacing: 8) {
                    Text(getButtonText())
                        .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if viewModel.currentPage != .complete {
                        Image(systemName: "arrow.right")
                            .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: isCompact ? 50 : 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            viewModel.canProceed ?
                            LinearGradient(
                                colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(
                    color: viewModel.canProceed ? ColorTheme.accentCyan.opacity(0.3) : .clear,
                    radius: 10,
                    x: 0,
                    y: 5
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canProceed)
            .scaleEffect(viewModel.canProceed ? 1.0 : 0.95)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.canProceed)
            .id("nextButton_\(viewModel.currentPage)_\(viewModel.canProceed)")
        }
    }
    
    
    private func getButtonText() -> String {
        switch viewModel.currentPage {
        case .welcome:
            return "Get Started"
        case .intro1, .intro2, .intro3:
            return "Continue"
        case .commitment:
            return "I'm Ready"
        case .permissions:
            return "Enable Notifications"
        case .complete:
            return "Start My Journey"
        default:
            return "Next"
        }
    }
}

#Preview {
    OnboardingContainerView(isPresented: .constant(true))
}