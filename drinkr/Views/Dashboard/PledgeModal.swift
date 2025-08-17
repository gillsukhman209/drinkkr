import SwiftUI

struct PledgeModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedPledge = ""
    @State private var showingSuccess = false
    @State private var animationAmount = 1.0
    
    let pledgeOptions = [
        "I will stay strong and alcohol-free today",
        "I choose my health and well-being over alcohol",
        "Today I am in control of my choices",
        "I am committed to my sobriety journey",
        "I will find joy in sober moments today",
        "My future self will thank me for today's choices"
    ]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            ColorTheme.backgroundGradient
                .ignoresSafeArea()
            
            if showingSuccess {
                successView
            } else {
                pledgeSelectionView
            }
        }
        .onAppear {
            selectedPledge = pledgeOptions.randomElement() ?? pledgeOptions[0]
        }
    }
    
    var pledgeSelectionView: some View {
        VStack(spacing: isCompact ? 25 : 35) {
            headerView
            
            pledgeContent
            
            actionButtons
        }
        .padding(isCompact ? 20 : 30)
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: isCompact ? 50 : 60))
                .foregroundColor(ColorTheme.accentCyan)
                .glowEffect(radius: 15)
            
            Text("Daily Pledge")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("Make your commitment for today")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var pledgeContent: some View {
        VStack(spacing: isCompact ? 20 : 25) {
            Text("Today's Pledge:")
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            Text(selectedPledge)
                .font(.system(size: isCompact ? 20 : 24, weight: .medium))
                .foregroundColor(ColorTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(isCompact ? 20 : 25)
                .futuristicCard()
            
            Button(action: {
                withAnimation(.spring()) {
                    selectedPledge = pledgeOptions.randomElement() ?? pledgeOptions[0]
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Different Pledge")
                }
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.accentPurple)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(ColorTheme.accentPurple.opacity(0.2))
                .cornerRadius(20)
            }
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: completePledge) {
                Text("Make This Pledge")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 15 : 18)
                    .background(ColorTheme.accentCyan)
                    .cornerRadius(15)
                    .glowEffect(color: ColorTheme.accentCyan, radius: 10)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Text("Maybe Later")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 12 : 15)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(ColorTheme.textSecondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    var successView: some View {
        VStack(spacing: isCompact ? 25 : 35) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isCompact ? 80 : 100))
                .foregroundColor(ColorTheme.successGreen)
                .glowEffect(color: ColorTheme.successGreen, radius: 20)
                .scaleEffect(animationAmount)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        animationAmount = 1.2
                    }
                }
            
            VStack(spacing: 15) {
                Text("Pledge Completed!")
                    .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("You've made your commitment for today. Stay strong!")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                if let currentStreak = dataService.sobrietyData?.currentStreak {
                    Text("Current Streak: \(currentStreak) days")
                        .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                        .foregroundColor(ColorTheme.accentCyan)
                        .padding(.top, 10)
                }
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Text("Continue Journey")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 15 : 18)
                    .background(ColorTheme.successGreen)
                    .cornerRadius(15)
                    .glowEffect(color: ColorTheme.successGreen, radius: 10)
            }
        }
        .padding(isCompact ? 20 : 30)
    }
    
    func completePledge() {
        withAnimation(.spring()) {
            dataService.completePledge()
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring()) {
                isPresented = false
            }
        }
    }
}

#Preview {
    PledgeModal(isPresented: .constant(true))
        .environmentObject(DataService())
}