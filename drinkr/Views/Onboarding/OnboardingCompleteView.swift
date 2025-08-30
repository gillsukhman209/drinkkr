//
//  OnboardingCompleteView.swift
//  Sobbr
//
//  Created by Assistant on 8/26/25.
//

import SwiftUI

struct OnboardingCompleteView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isAnimating = false
    @State private var showingPaywall = false
    @State private var loadingProgress: Double = 0
    @State private var isLoading = true
    @State private var showContent = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                // Loading view
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Loading animation
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 12)
                            .frame(width: isCompact ? 200 : 260, height: isCompact ? 200 : 260)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: loadingProgress / 100)
                            .stroke(
                                LinearGradient(
                                    colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: isCompact ? 200 : 260, height: isCompact ? 200 : 260)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.1), value: loadingProgress)
                        
                        // Percentage text - perfectly centered
                        Text("\(Int(loadingProgress))%")
                            .font(.system(size: isCompact ? 52 : 68, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .multilineTextAlignment(.center)
                    }
                    
                    // Loading label
                    Text("Loading")
                        .font(.system(size: isCompact ? 18 : 22, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                        .padding(.bottom, isCompact ? 50 : 70)
                    
                    // Loading message
                    VStack(spacing: 16) {
                        Text("Preparing your plan...")
                            .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Analyzing your responses to create a personalized recovery journey tailored just for you")
                            .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                }
                .transition(.opacity)
            } else {
                // Success view
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Success animation
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [ColorTheme.successGreen.opacity(0.3), ColorTheme.accentCyan.opacity(0.1)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: isCompact ? 160 : 200, height: isCompact ? 160 : 200)
                            .scaleEffect(showContent ? 1.1 : 0.9)
                            .opacity(showContent ? 1.0 : 0.0)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: isCompact ? 80 : 100, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.successGreen, ColorTheme.accentCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1.0 : 0.0)
                    }
                    .padding(.bottom, isCompact ? 40 : 60)
                    
                    // Congratulations message
                    VStack(spacing: 20) {
                        Text("Perfect, \(viewModel.userName.isEmpty ? "friend" : viewModel.userName)!")
                            .font(.system(size: isCompact ? 32 : 40, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Your personalized recovery plan is ready.")
                            .font(.system(size: isCompact ? 18 : 22, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                
                    Spacer()
                        .frame(height: isCompact ? 40 : 60)
                    
                    // What's next section
                    VStack(alignment: .leading, spacing: 25) {
                        nextStepItem(
                            number: "1",
                            title: "Unlock Full Access",
                            description: "Subscribe to access all recovery features"
                        )
                        
                        nextStepItem(
                            number: "2",
                            title: "Start Your Timer",
                            description: "Begin tracking your sobriety journey"
                        )
                        
                        nextStepItem(
                            number: "3",
                            title: "Daily Check-ins",
                            description: "Stay accountable with daily reflections"
                        )
                    }
                    .padding(.horizontal, isCompact ? 30 : 50)
                    .opacity(showContent ? 1.0 : 0.0)
                
                    Spacer()
                    
                    // Start button
                    Button(action: {
                        showingPaywall = true
                        viewModel.completeOnboarding()
                    }) {
                        HStack(spacing: 12) {
                            Text("Start My Journey")
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
                    .padding(.bottom, isCompact ? 30 : 40)
                    .opacity(showContent ? 1.0 : 0.0)
                    .scaleEffect(showContent ? 1.0 : 0.9)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func nextStepItem(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            // Number circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ColorTheme.accentCyan.opacity(0.3), ColorTheme.accentPurple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 40 : 50, height: isCompact ? 40 : 50)
                
                Text(number)
                    .font(.system(size: isCompact ? 18 : 22, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.accentCyan)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private func startLoadingAnimation() {
        // Simulate loading from 0 to 100
        let totalDuration = 3.0 // 3 seconds total
        let steps = 100
        let stepDuration = totalDuration / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                withAnimation(.linear(duration: 0.05)) {
                    loadingProgress = Double(i)
                }
                
                // Add haptic feedback at certain intervals
                if i % 10 == 0 && i > 0 {
                    HapticManager.impact(style: .light)
                }
                
                // Complete loading
                if i == steps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isLoading = false
                        }
                        
                        // Trigger success haptic
                        HapticManager.notification(type: .success)
                        
                        // Show content after transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                                showContent = true
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Haptic Manager
struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingCompleteView(viewModel: OnboardingViewModel())
    }
}