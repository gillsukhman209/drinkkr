//
//  OnboardingMotivationView.swift
//  Sobbr
//
//  Created by Assistant on 8/26/25.
//

import SwiftUI

struct OnboardingMotivationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var animationPhase = 0
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var moneySaved: Double {
        viewModel.userProfile.weeklySpendingAmount * 52 // Annual savings
    }
    
    var hoursSaved: Int {
        viewModel.userProfile.hoursLostWeeklyInt * 52 // Annual hours
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: isCompact ? 30 : 40) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: isCompact ? 60 : 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animationPhase >= 1 ? 1.0 : 0.5)
                        .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                    
                    Text("Your Potential Unleashed")
                        .font(.system(size: isCompact ? 28 : 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(animationPhase >= 2 ? 1.0 : 0.0)
                    
                    Text("Based on your answers, here's what freedom from fast food means for you:")
                        .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(animationPhase >= 3 ? 1.0 : 0.0)
                }
                .padding(.top, 30)
                
                // Impact cards
                VStack(spacing: 20) {
                    // Money saved card
                    impactCard(
                        icon: "dollarsign.circle.fill",
                        title: "Financial Freedom",
                        value: String(format: "$%.0f", moneySaved),
                        subtitle: "saved per year",
                        description: "That's a vacation, debt payment, or investment in your future.",
                        gradientColors: [ColorTheme.successGreen, ColorTheme.accentCyan],
                        delay: 4
                    )
                    
                    // Time reclaimed card
                    impactCard(
                        icon: "clock.fill",
                        title: "Time Reclaimed",
                        value: "\(hoursSaved)",
                        subtitle: "hours per year",
                        description: "That's \(hoursSaved / 24) full days to pursue your dreams.",
                        gradientColors: [ColorTheme.accentPurple, ColorTheme.accentPink],
                        delay: 5
                    )
                    
                    // Health restored card
                    impactCard(
                        icon: "heart.fill",
                        title: "Health Restored",
                        value: "90%",
                        subtitle: "digestion reset in 2 weeks",
                        description: "Your body begins healing immediately after you stop.",
                        gradientColors: [ColorTheme.accentPink, Color.red.opacity(0.8)],
                        delay: 6
                    )
                    
                    // Relationships card (if applicable)
                    if viewModel.selectedLifeImpacts.contains(where: { $0.text.contains("relationships") }) {
                        impactCard(
                            icon: "person.2.fill",
                            title: "Trust Rebuilt",
                            value: "100%",
                            subtitle: "authentic connections",
                            description: "Be fully present with the people who matter most.",
                            gradientColors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                            delay: 7
                        )
                    }
                }
                .padding(.horizontal, isCompact ? 20 : 30)
                
                // Motivational message based on biggest fear
                if let fear = viewModel.selectedBiggestFear {
                    motivationalMessage(for: fear.text)
                        .opacity(animationPhase >= 8 ? 1.0 : 0.0)
                        .padding(.horizontal, isCompact ? 20 : 30)
                }
                
                // Success rate
                VStack(spacing: 15) {
                    Text("Join the 87% who succeed")
                        .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("People with your profile have an 87% success rate in their first 30 days with NoBite")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, isCompact ? 30 : 50)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorTheme.cardBackground.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, isCompact ? 20 : 30)
                .opacity(animationPhase >= 9 ? 1.0 : 0.0)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func impactCard(
        icon: String,
        title: String,
        value: String,
        subtitle: String,
        description: String,
        gradientColors: [Color],
        delay: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 24 : 28, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                Text(value)
                    .font(.system(size: isCompact ? 36 : 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(subtitle)
                    .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding(.bottom, isCompact ? 6 : 8)
            }
            
            Text(description)
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(isCompact ? 20 : 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorTheme.cardBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: gradientColors[0].opacity(0.2), radius: 10, x: 0, y: 5)
        .scaleEffect(animationPhase >= delay ? 1.0 : 0.95)
        .opacity(animationPhase >= delay ? 1.0 : 0.0)
    }
    
    private func motivationalMessage(for fear: String) -> some View {
        let message: String
        
        switch fear {
        case _ where fear.contains("fail"):
            message = "💪 You're not going to fail. You have everything you need to succeed, and we'll be with you every step."
        case _ where fear.contains("boring"):
            message = "🎯 Life becomes MORE exciting when you're fully present and clear-minded for every moment."
        case _ where fear.contains("friends"):
            message = "❤️ True friends will celebrate your growth. You'll attract people who value the real you."
        case _ where fear.contains("stress"):
            message = "🧘 You'll discover healthier ways to manage stress that actually solve problems, not mask them."
        default:
            message = "✨ Your fears are valid, but your courage is stronger. You've got this."
        }
        
        return Text(message)
            .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [ColorTheme.accentPurple.opacity(0.2), ColorTheme.accentCyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ColorTheme.accentPurple.opacity(0.3), lineWidth: 1)
                    )
            )
    }
    
    private func startAnimationSequence() {
        for i in 1...9 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animationPhase = i
                }
            }
        }
    }
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingMotivationView(viewModel: OnboardingViewModel())
    }
}