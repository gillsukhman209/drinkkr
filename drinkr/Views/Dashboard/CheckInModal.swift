import SwiftUI

struct CheckInModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedMood = 3
    @State private var notes = ""
    @State private var showingSuccess = false
    @State private var animationAmount = 1.0
    
    let moodOptions = [
        (1, "😔", "Struggling", ColorTheme.dangerRed),
        (2, "😟", "Difficult", ColorTheme.warningOrange),
        (3, "😐", "Neutral", ColorTheme.textSecondary),
        (4, "🙂", "Good", ColorTheme.accentCyan),
        (5, "😊", "Great", ColorTheme.successGreen)
    ]
    
    let motivationalMessages = [
        "You're doing amazing! Every day sober is a victory.",
        "Your strength inspires others. Keep going!",
        "Remember why you started. You've got this!",
        "One day at a time. You're stronger than you know.",
        "Your future self will thank you for today's choices.",
        "Progress, not perfection. You're on the right path."
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
                checkInView
            }
        }
    }
    
    var checkInView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: isCompact ? 20 : 25) {
                headerView
                moodSelector
                notesSection
                actionButtons
            }
            .padding(isCompact ? 20 : 30)
        }
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: isCompact ? 50 : 60))
                .foregroundColor(ColorTheme.accentCyan)
                .glowEffect(radius: 15)
            
            Text("Daily Check-In")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("How are you feeling today?")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var moodSelector: some View {
        VStack(spacing: 15) {
            Text("Rate your mood")
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
            
            HStack(spacing: isCompact ? 6 : 10) {
                ForEach(moodOptions, id: \.0) { mood in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedMood = mood.0
                        }
                    }) {
                        VStack(spacing: 6) {
                            Text(mood.1)
                                .font(.system(size: isCompact ? 24 : 28))
                            
                            Text(mood.2)
                                .font(.system(size: isCompact ? 9 : 11, weight: .medium))
                                .foregroundColor(selectedMood == mood.0 ? mood.3 : ColorTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, isCompact ? 6 : 8)
                        .padding(.horizontal, isCompact ? 4 : 6)
                        .background(
                            selectedMood == mood.0 ? 
                            mood.3.opacity(0.2) : 
                            Color.clear
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMood == mood.0 ? mood.3 : Color.clear, lineWidth: 2)
                        )
                        .scaleEffect(selectedMood == mood.0 ? 1.1 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
    
    var notesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Any thoughts to share? (Optional)")
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                    )
                    .frame(height: isCompact ? 100 : 120)
                
                if notes.isEmpty {
                    Text("Share what's on your mind...")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
                        .padding(.top, 12)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $notes)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textPrimary)
                    .background(Color.clear)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
            }
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: submitCheckIn) {
                Text("Submit Check-In")
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
                Text("Skip for Now")
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
        ScrollView(.vertical, showsIndicators: false) {
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
                    Text("Check-In Complete!")
                        .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text(motivationalMessages.randomElement() ?? "Keep up the great work!")
                        .font(.system(size: isCompact ? 16 : 18))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    if let streak = dataService.sobrietyData?.currentStreak, streak > 0 {
                        Text("Current streak: \(streak) days")
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
    }
    
    func submitCheckIn() {
        dataService.logCheckIn(mood: selectedMood, notes: notes)
        
        withAnimation(.spring()) {
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
    CheckInModal(isPresented: .constant(true))
        .environmentObject(DataService())
}