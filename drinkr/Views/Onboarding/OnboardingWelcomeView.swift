import SwiftUI

struct OnboardingWelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var superwallManager = SuperwallManager.shared
    @State private var animationPhase = 0
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: isCompact ? 20 : 40)
                    
                    // Logo and app name
                    VStack(spacing: 20) {
                        // Logo animation
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [ColorTheme.accentCyan.opacity(0.3), ColorTheme.accentPurple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: isCompact ? 100 : 150, height: isCompact ? 100 : 150)
                                .scaleEffect(animationPhase >= 1 ? 1.0 : 0.8)
                                .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: isCompact ? 50 : 75, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(animationPhase >= 2 ? 1.0 : 0.5)
                                .opacity(animationPhase >= 2 ? 1.0 : 0.0)
                        }
                        
                        Text("CleanEats")
                            .font(.system(size: isCompact ? 36 : 52, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, ColorTheme.accentCyan.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animationPhase >= 3 ? 1.0 : 0.9)
                            .opacity(animationPhase >= 3 ? 1.0 : 0.0)
                    }
                    
                    Spacer()
                        .frame(height: isCompact ? 30 : 60)
                    
                    // Main message
                    VStack(spacing: isCompact ? 16 : 24) {
                        Text("Break free from fast food.")
                            .font(.system(size: isCompact ? 24 : 34, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(animationPhase >= 4 ? 1.0 : 0.0)
                            .offset(y: animationPhase >= 4 ? 0 : 20)
                        
                        Text("Reclaim your health.")
                            .font(.system(size: isCompact ? 24 : 34, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .opacity(animationPhase >= 5 ? 1.0 : 0.0)
                            .offset(y: animationPhase >= 5 ? 0 : 20)
                        
                        Text("You're not alone in this journey. Join thousands who've taken back control and discovered a life of healthy eating.")
                            .font(.system(size: isCompact ? 14 : 18, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, isCompact ? 20 : 40)
                            .opacity(animationPhase >= 6 ? 1.0 : 0.0)
                            .offset(y: animationPhase >= 6 ? 0 : 20)
                    }
                    
                    Spacer()
                        .frame(height: isCompact ? 30 : 80)
                    
                    // Stats
                    HStack(spacing: isCompact ? 15 : 30) {
                        statItem(number: "10K+", label: "Lives Changed", delay: 7)
                        statItem(number: "95%", label: "Feel Better", delay: 8)
                        statItem(number: "$2.4K", label: "Avg. Saved", delay: 9)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: isCompact ? 30 : 50)
                    
                    // Get started button
                    Button(action: {
                        viewModel.nextPage()
                    }) {
                        HStack(spacing: 12) {
                            Text("Get Started")
                                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: isCompact ? 20 : 24))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: isCompact ? 50 : 64)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: ColorTheme.accentCyan.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, isCompact ? 30 : 50)
                    .scaleEffect(animationPhase >= 10 ? 1.0 : 0.9)
                    .opacity(animationPhase >= 10 ? 1.0 : 0.0)
                    
                    Spacer()
                        .frame(height: isCompact ? 30 : 80)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
        .overlay(alignment: .topTrailing) {
            // Skip to Premium Button
            Button(action: {
                // Grant subscription and complete onboarding
                superwallManager.debugGrantSubscription()
                viewModel.completeOnboarding()
            }) {
                Text("Skip to Premium")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
    }
    
    private func statItem(number: String, label: String, delay: Int) -> some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.system(size: isCompact ? 24 : 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(label)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .opacity(animationPhase >= delay ? 1.0 : 0.0)
        .offset(y: animationPhase >= delay ? 0 : 15)
    }
    
    private func startAnimationSequence() {
        // Stagger animations for smooth entrance
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animationPhase = i
                }
            }
        }
    }
}

// MARK: - Intro Views

struct OnboardingIntroView: View {
    let page: OnboardingPage
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isVisible = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: isCompact ? 20 : 40) {
                    Spacer()
                        .frame(height: isCompact ? 20 : 40)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [introContent.gradientColors[0].opacity(0.3), introContent.gradientColors[1].opacity(0.1)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: isCompact ? 120 : 180, height: isCompact ? 120 : 180)
                            .scaleEffect(isVisible ? 1.0 : 0.8)
                        
                        Image(systemName: introContent.imageName)
                            .font(.system(size: isCompact ? 50 : 80, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: introContent.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isVisible ? 1.0 : 0.5)
                    }
                    
                    Spacer()
                        .frame(height: isCompact ? 20 : 40)
                    
                    // Content
                    VStack(spacing: isCompact ? 16 : 20) {
                        Text(introContent.title)
                            .font(.system(size: isCompact ? 24 : 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .opacity(isVisible ? 1.0 : 0.0)
                            .offset(y: isVisible ? 0 : 20)
                        
                        Text(introContent.subtitle)
                            .font(.system(size: isCompact ? 15 : 18, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(isCompact ? 4 : 6)
                            .padding(.horizontal, isCompact ? 24 : 50)
                            .opacity(isVisible ? 1.0 : 0.0)
                            .offset(y: isVisible ? 0 : 20)
                    }
                    
                    Spacer()
                        .frame(height: isCompact ? 40 : 80)
                    
                    // Continue gesture hint
                    VStack(spacing: 12) {
                        Image(systemName: "chevron.right.2")
                            .font(.system(size: isCompact ? 16 : 20, weight: .medium))
                            .foregroundColor(ColorTheme.accentCyan.opacity(0.7))
                            .opacity(isVisible ? 1.0 : 0.0)
                        
                        Text("Tap to continue")
                            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.8))
                            .opacity(isVisible ? 1.0 : 0.0)
                    }
                    .padding(.bottom, isCompact ? 40 : 60)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.nextPage()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
    
    private var introContent: WelcomeContent {
        switch page {
        case .intro1:
            return WelcomeContent(
                title: "Every healthy meal\nis a victory",
                subtitle: "Your journey to health starts with a single decision. You've already made the hardest step by being here.",
                imageName: "trophy.fill",
                gradientColors: [ColorTheme.successGreen, ColorTheme.accentCyan]
            )
        case .intro2:
            return WelcomeContent(
                title: "You have the strength\nto overcome this",
                subtitle: "Thousands of people just like you have broken free from fast food. You're capable of amazing things.",
                imageName: "heart.fill",
                gradientColors: [ColorTheme.accentPink, ColorTheme.accentPurple]
            )
        case .intro3:
            return WelcomeContent(
                title: "Your personalized path\nto health starts here",
                subtitle: "We'll understand your unique situation and create a healthy eating plan designed specifically for you.",
                imageName: "map.fill",
                gradientColors: [ColorTheme.accentCyan, ColorTheme.accentPurple]
            )
        default:
            return WelcomeContent(
                title: "Welcome",
                subtitle: "Let's get started",
                imageName: "heart.fill",
                gradientColors: [ColorTheme.accentCyan, ColorTheme.accentPurple]
            )
        }
    }
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingWelcomeView(viewModel: OnboardingViewModel())
    }
}