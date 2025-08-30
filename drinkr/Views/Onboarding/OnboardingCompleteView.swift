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
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
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
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .opacity(isAnimating ? 1.0 : 0.5)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: isCompact ? 80 : 100, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.successGreen, ColorTheme.accentCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
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
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
                
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
                .opacity(isAnimating ? 1.0 : 0.0)
                
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
                .opacity(isAnimating ? 1.0 : 0.0)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                isAnimating = true
            }
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
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingCompleteView(viewModel: OnboardingViewModel())
    }
}