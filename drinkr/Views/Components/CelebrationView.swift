import SwiftUI

struct CelebrationView: View {
    @Binding var isPresented: Bool
    let milestone: Int
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var animationAmount = 0.8
    @State private var particleAnimations: [Bool] = Array(repeating: false, count: 20)
    @State private var confettiOffset: [CGSize] = Array(repeating: .zero, count: 30)
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var milestoneText: String {
        switch milestone {
        case 1: return "First Day!"
        case 7: return "One Week!"
        case 14: return "Two Weeks!"
        case 30: return "One Month!"
        case 60: return "Two Months!"
        case 90: return "Three Months!"
        case 180: return "Six Months!"
        case 365: return "One Year!"
        default: return "\(milestone) Days!"
        }
    }
    
    var milestoneEmoji: String {
        switch milestone {
        case 1: return "🌟"
        case 7: return "🎉"
        case 14: return "💪"
        case 30: return "🏆"
        case 60: return "🚀"
        case 90: return "👑"
        case 180: return "💎"
        case 365: return "🎆"
        default: return "✨"
        }
    }
    
    var celebrationMessage: String {
        switch milestone {
        case 1: return "You did it! Every journey begins with a single step."
        case 7: return "One week strong! You're building incredible habits."
        case 14: return "Two weeks of dedication! Your strength is showing."
        case 30: return "A full month! You're proving to yourself what's possible."
        case 60: return "Two months of commitment! You're unstoppable."
        case 90: return "Three months! You've created lasting change."
        case 180: return "Six months! You're living proof that transformation is real."
        case 365: return "ONE FULL YEAR! You are absolutely incredible!"
        default: return "Amazing progress! Keep up the incredible work!"
        }
    }
    
    var body: some View {
        ZStack {
            ColorTheme.backgroundGradient
                .ignoresSafeArea()
            
            confettiLayer
            
            VStack(spacing: isCompact ? 25 : 35) {
                Spacer()
                
                milestoneDisplay
                
                achievementBadge
                
                messageSection
                
                actionButtons
                
                Spacer()
            }
            .padding(isCompact ? 20 : 30)
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    var confettiLayer: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(confettiColors.randomElement() ?? ColorTheme.accentCyan)
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(confettiOffset[index])
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .delay(Double(index) * 0.05),
                        value: confettiOffset[index]
                    )
            }
        }
    }
    
    var confettiColors: [Color] {
        [ColorTheme.accentCyan, ColorTheme.accentPurple, ColorTheme.accentPink, ColorTheme.successGreen, .yellow, .orange]
    }
    
    var milestoneDisplay: some View {
        VStack(spacing: 15) {
            Text(milestoneEmoji)
                .font(.system(size: isCompact ? 80 : 100))
                .scaleEffect(animationAmount)
                .animation(
                    Animation.spring(response: 0.6, dampingFraction: 0.6)
                        .repeatCount(3, autoreverses: true),
                    value: animationAmount
                )
            
            Text(milestoneText)
                .font(.system(size: isCompact ? 32 : 42, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
                .glowEffect(color: ColorTheme.accentCyan, radius: 15)
            
            Text("Milestone Reached")
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(ColorTheme.accentCyan)
                .textCase(.uppercase)
                .tracking(2)
        }
    }
    
    var achievementBadge: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 120 : 150, height: isCompact ? 120 : 150)
                    .glowEffect(color: ColorTheme.accentCyan, radius: 20)
                
                VStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: isCompact ? 40 : 50))
                        .foregroundColor(.white)
                    
                    Text("\(milestone)")
                        .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(animationAmount)
            .animation(
                Animation.spring(response: 0.8, dampingFraction: 0.7)
                    .delay(0.3),
                value: animationAmount
            )
            
            Text("Days Sober")
                .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var messageSection: some View {
        VStack(spacing: 15) {
            Text(celebrationMessage)
                .font(.system(size: isCompact ? 18 : 22, weight: .medium))
                .foregroundColor(ColorTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 10)
            
            if milestone >= 30 {
                VStack(spacing: 8) {
                    Text("Amazing Stats:")
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(ColorTheme.accentPurple)
                    
                    HStack(spacing: 20) {
                        statItem(value: "$\(milestone * 10)", label: "Saved")
                        statItem(value: "\(milestone * 3)", label: "Drinks Avoided")
                        statItem(value: "\(milestone * 150)", label: "Calories Saved")
                    }
                }
                .padding(isCompact ? 15 : 20)
                .futuristicCard()
            }
        }
    }
    
    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                .foregroundColor(ColorTheme.successGreen)
            
            Text(label)
                .font(.system(size: isCompact ? 10 : 12))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: shareAchievement) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Achievement")
                }
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(isCompact ? 15 : 18)
                .background(ColorTheme.successGreen)
                .cornerRadius(15)
                .glowEffect(color: ColorTheme.successGreen, radius: 10)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Text("Continue Journey")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 12 : 15)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    func startCelebrationAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            animationAmount = 1.2
        }
        
        for index in 0..<30 {
            let randomX = CGFloat.random(in: -200...200)
            let randomY = CGFloat.random(in: (-400)...(-100))
            confettiOffset[index] = CGSize(width: randomX, height: randomY)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) {
                animationAmount = 1.0
            }
        }
    }
    
    func shareAchievement() {
        print("Share achievement: \(milestone) days sober!")
    }
}

#Preview {
    CelebrationView(isPresented: .constant(true), milestone: 30)
}