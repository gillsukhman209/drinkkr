import SwiftUI

struct PledgeModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedCheckInTime = Date()
    @State private var showingSuccess = false
    @State private var animationAmount = 1.0
    @StateObject private var notificationService = NotificationService.shared
    
    let checkInMessages = [
        "How are you feeling today?",
        "Remember your strength and progress",
        "Take a moment to reflect on your journey",
        "You've got this - one day at a time",
        "Check in with yourself and your goals",
        "Your sobriety matters - how are you doing?"
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
            // Set default check-in time to 24 hours from now
            selectedCheckInTime = Date().addingTimeInterval(24 * 60 * 60)
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
            
            Text("Schedule Check-In")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("Set a reminder to check on your progress")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var pledgeContent: some View {
        VStack(spacing: isCompact ? 20 : 25) {
            Text("When would you like your check-in?")
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 15) {
                DatePicker(
                    "Check-in Time",
                    selection: $selectedCheckInTime,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .accentColor(ColorTheme.accentCyan)
                .foregroundColor(ColorTheme.textPrimary)
                
                Text("You'll receive a gentle reminder at this time")
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(isCompact ? 20 : 25)
            .futuristicCard()
            
            VStack(spacing: 10) {
                Text("Quick Options:")
                    .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                
                HStack(spacing: 10) {
                    quickTimeButton("24 Hours", hours: 24)
                    quickTimeButton("12 Hours", hours: 12)
                    quickTimeButton("6 Hours", hours: 6)
                }
            }
        }
    }
    
    func quickTimeButton(_ title: String, hours: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedCheckInTime = Date().addingTimeInterval(TimeInterval(hours * 3600))
            }
        }) {
            Text(title)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundColor(ColorTheme.accentPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(ColorTheme.accentPurple.opacity(0.2))
                .cornerRadius(15)
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: scheduleCheckIn) {
                Text("Schedule Check-In")
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
                Text("Check-In Scheduled!")
                    .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("You'll receive a gentle reminder to check in on your progress.")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(formatCheckInTime())
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(ColorTheme.accentCyan)
                    .padding(.top, 10)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Text("Continue")
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
    
    func scheduleCheckIn() {
        // Check permission status for debugging
        notificationService.checkPermissionStatus()
        
        // Schedule the notification
        notificationService.scheduleCheckInNotification(for: selectedCheckInTime)
        
        // Increment pledge count
        dataService.completePledge()
        
        withAnimation(.spring()) {
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring()) {
                isPresented = false
            }
        }
    }
    
    func formatCheckInTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Reminder set for \(formatter.string(from: selectedCheckInTime))"
    }
}

#Preview {
    PledgeModal(isPresented: .constant(true))
        .environmentObject(DataService())
}