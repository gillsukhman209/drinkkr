import SwiftUI

struct OnboardingWelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var animationPhase = 0
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
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
                        .frame(width: isCompact ? 120 : 150, height: isCompact ? 120 : 150)
                        .scaleEffect(animationPhase >= 1 ? 1.0 : 0.8)
                        .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: isCompact ? 60 : 75, weight: .light))
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
                
                Text("Sobbr")
                    .font(.system(size: isCompact ? 42 : 52, weight: .bold, design: .rounded))
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
                .frame(height: isCompact ? 40 : 60)
            
            // Main message
            VStack(spacing: 24) {
                Text("Break free from alcohol.")
                    .font(.system(size: isCompact ? 28 : 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animationPhase >= 4 ? 1.0 : 0.0)
                    .offset(y: animationPhase >= 4 ? 0 : 20)
                
                Text("Reclaim your life.")
                    .font(.system(size: isCompact ? 28 : 34, weight: .bold))
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
                
                Text("You're not alone in this journey. Join thousands who've taken back control and discovered a life beyond alcohol.")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, isCompact ? 20 : 40)
                    .opacity(animationPhase >= 6 ? 1.0 : 0.0)
                    .offset(y: animationPhase >= 6 ? 0 : 20)
            }
            
            Spacer()
                .frame(height: isCompact ? 50 : 80)
            
            // Stats
            HStack(spacing: isCompact ? 20 : 30) {
                statItem(number: "10K+", label: "Lives Changed", delay: 7)
                statItem(number: "95%", label: "Feel Better", delay: 8)
                statItem(number: "$2.4K", label: "Avg. Saved", delay: 9)
            }
            .padding(.horizontal)
            
            Spacer()
            
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
                .frame(height: isCompact ? 56 : 64)
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
                .frame(height: isCompact ? 50 : 80)
        }
        .onAppear {
            startAnimationSequence()
        }
        .overlay(alignment: .topTrailing) {
            #if DEBUG
            // Debug skip button
            Button(action: {
                viewModel.skipToNameSlide()
            }) {
                Text("Skip to Name")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
            #endif
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
        VStack(spacing: isCompact ? 30 : 40) {
            Spacer()
            
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
                    .frame(width: isCompact ? 140 : 180, height: isCompact ? 140 : 180)
                    .scaleEffect(isVisible ? 1.0 : 0.8)
                
                Image(systemName: introContent.imageName)
                    .font(.system(size: isCompact ? 60 : 80, weight: .light))
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
            VStack(spacing: 20) {
                Text(introContent.title)
                    .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
                
                Text(introContent.subtitle)
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, isCompact ? 30 : 50)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
            }
            
            Spacer()
            
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
                title: "Every day without alcohol\nis a victory",
                subtitle: "Your journey to freedom starts with a single decision. You've already made the hardest step by being here.",
                imageName: "trophy.fill",
                gradientColors: [ColorTheme.successGreen, ColorTheme.accentCyan]
            )
        case .intro2:
            return WelcomeContent(
                title: "You have the strength\nto overcome this",
                subtitle: "Thousands of people just like you have broken free from alcohol. You're capable of amazing things.",
                imageName: "heart.fill",
                gradientColors: [ColorTheme.accentPink, ColorTheme.accentPurple]
            )
        case .intro3:
            return WelcomeContent(
                title: "Your personalized path\nto recovery starts here",
                subtitle: "We'll understand your unique situation and create a recovery plan designed specifically for you.",
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