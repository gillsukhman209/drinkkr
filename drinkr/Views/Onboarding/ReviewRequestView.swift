//
//  ReviewRequestView.swift
//  drinkr
//
//  Created by Assistant on 2025
//

import SwiftUI
import StoreKit

struct ReviewRequestView: View {
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var animatingGradient = false
    @State private var starAnimations = [false, false, false, false, false]
    @State private var contentOpacity = 0.0
    @State private var buttonScale = 0.9
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: animatingGradient ? 
                    [Color(hex: "1a1a2e"), Color(hex: "0f0f1e")] : 
                    [Color(hex: "0f0f1e"), Color(hex: "1a1a2e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animatingGradient)
            
            // Subtle pattern overlay
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ColorTheme.accentCyan.opacity(0.03),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 20)
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: isCompact ? 60 : 80)
                
                // Main content
                VStack(spacing: isCompact ? 30 : 40) {
                    // Icon and title section
                    VStack(spacing: isCompact ? 20 : 25) {
                        // Animated icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ColorTheme.accentCyan.opacity(0.2),
                                            ColorTheme.accentPurple.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: isCompact ? 100 : 120, height: isCompact ? 100 : 120)
                                .blur(radius: 20)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: isCompact ? 50 : 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolEffect(.pulse.byLayer, options: .repeating)
                        }
                        
                        VStack(spacing: isCompact ? 12 : 16) {
                            Text("You're Not Alone")
                                .font(.system(size: isCompact ? 32 : 38, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("12,847 people started their recovery this week")
                                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Stars animation
                    HStack(spacing: isCompact ? 8 : 12) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: isCompact ? 36 : 42))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(starAnimations[index] ? 1.2 : 1.0)
                                .animation(
                                    .spring(response: 0.3, dampingFraction: 0.6)
                                        .delay(Double(index) * 0.1),
                                    value: starAnimations[index]
                                )
                        }
                    }
                    .padding(.vertical, isCompact ? 10 : 15)
                    
                    // Message
                    VStack(spacing: isCompact ? 16 : 20) {
                        Text("Your story matters")
                            .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("A quick review helps others discover their path to recovery. Your words could be the reason someone chooses life today.")
                            .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, isCompact ? 20 : 30)
                    }
                    
                    // Social proof
                    HStack(spacing: isCompact ? 20 : 25) {
                        statItem(number: "4.9", label: "Rating", icon: "star.fill")
                        statItem(number: "8.7k", label: "Reviews", icon: "text.bubble.fill")
                        statItem(number: "92%", label: "Success", icon: "chart.line.uptrend.xyaxis")
                    }
                    .padding(isCompact ? 16 : 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, isCompact ? 30 : 40)
                }
                .opacity(contentOpacity)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: isCompact ? 12 : 16) {
                    // Primary CTA - Review button
                    Button(action: {
                        requestReview()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: isCompact ? 20 : 22))
                            
                            Text("Help Others Find Recovery")
                                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                        }
                        .foregroundColor(.white)
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
                        .shadow(color: ColorTheme.accentCyan.opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(buttonScale)
                    
                    // Secondary - Skip button
                    Button(action: {
                        skipReview()
                    }) {
                        Text("I'll do it later")
                            .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(height: isCompact ? 44 : 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Trust indicator
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 12))
                        Text("Your review helps save lives")
                            .font(.system(size: isCompact ? 12 : 14))
                    }
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 8)
                }
                .padding(.horizontal, isCompact ? 30 : 40)
                .padding(.bottom, isCompact ? 40 : 50)
                .opacity(contentOpacity)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func statItem(number: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 20 : 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(number)
                .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: isCompact ? 11 : 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private func startAnimations() {
        // Start gradient animation
        withAnimation {
            animatingGradient = true
        }
        
        // Fade in content
        withAnimation(.easeOut(duration: 0.8)) {
            contentOpacity = 1.0
        }
        
        // Animate stars with delay
        for index in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15 + 0.5) {
                starAnimations[index] = true
            }
        }
        
        // Scale button
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8)) {
            buttonScale = 1.0
        }
    }
    
    private func requestReview() {
        // Save that review was requested
        UserDefaults.standard.set(true, forKey: "hasRequestedReview")
        UserDefaults.standard.set(Date(), forKey: "reviewRequestDate")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Request review using SKStoreReviewController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        
        // Continue to paywall after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            proceedToPaywall()
        }
    }
    
    private func skipReview() {
        // Save that review was skipped
        UserDefaults.standard.set(true, forKey: "hasSkippedReview")
        UserDefaults.standard.set(Date(), forKey: "reviewSkipDate")
        
        proceedToPaywall()
    }
    
    private func proceedToPaywall() {
        withAnimation(.easeOut(duration: 0.3)) {
            contentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
            onComplete()
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ReviewRequestView(isPresented: .constant(true)) {
        print("Proceeding to paywall")
    }
}