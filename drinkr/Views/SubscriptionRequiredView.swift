//
//  SubscriptionRequiredView.swift
//  Sobbr
//
//  Created by Assistant on 8/26/25.
//

import SwiftUI

struct SubscriptionRequiredView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var isShowingPaywall = false
    @State private var pulseAnimation = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            OptimizedBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Lock icon with animation
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [ColorTheme.accentCyan.opacity(0.3), ColorTheme.accentPurple.opacity(0.1)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: isCompact ? 140 : 180, height: isCompact ? 140 : 180)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: isCompact ? 60 : 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.bottom, isCompact ? 40 : 60)
                
                // Title
                Text("Unlock Your Recovery Journey")
                    .font(.system(size: isCompact ? 28 : 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Description
                Text("Your journey to sobriety begins with a commitment.\nSubscribe to access all features and start transforming your life today.")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, isCompact ? 30 : 50)
                    .padding(.bottom, isCompact ? 40 : 60)
                
                // Benefits list
                VStack(alignment: .leading, spacing: 20) {
                    benefitRow(icon: "checkmark.circle.fill", text: "Track sobriety milestones")
                    benefitRow(icon: "bell.badge.fill", text: "Daily motivation & check-ins")
                    benefitRow(icon: "heart.fill", text: "24/7 panic button support")
                    benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Progress tracking & insights")
                    benefitRow(icon: "book.fill", text: "Educational recovery content")
                }
                .padding(.horizontal, isCompact ? 40 : 60)
                
                Spacer()
                
                // Subscribe button
                Button(action: {
                    showPaywall()
                }) {
                    HStack(spacing: 12) {
                        Text("Subscribe Now")
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
                
                // Restore purchases button
                Button(action: {
                    restorePurchases()
                }) {
                    Text("Restore Purchases")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.accentCyan)
                        .padding(.vertical, 10)
                }
                .padding(.bottom, isCompact ? 40 : 60)
            }
        }
        .onAppear {
            pulseAnimation = true
            // Automatically show paywall after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showPaywall()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .subscriptionStatusChanged)) { notification in
            if let userInfo = notification.userInfo,
               let isActive = userInfo["isActive"] as? Bool,
               isActive {
                // Subscription became active, the ContentView will handle the transition
            }
        }
    }
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 20 : 24, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func showPaywall() {
        subscriptionManager.presentPaywall { success in
            if !success && !subscriptionManager.hasActiveSubscription {
                // User dismissed without subscribing, show again
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showPaywall()
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            await subscriptionManager.updateSubscriptionStatus()
        }
    }
}

#Preview {
    SubscriptionRequiredView()
        .environmentObject(SubscriptionManager.shared)
        .preferredColorScheme(.dark)
}