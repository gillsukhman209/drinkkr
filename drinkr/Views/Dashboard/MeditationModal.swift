import SwiftUI

struct MeditationModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedDuration = 5
    @State private var isActive = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    @State private var animationAmount = 1.0
    @State private var breathPhase: BreathPhase = .inhale
    @State private var showingCompletion = false
    
    let durations = [3, 5, 10, 15, 20]
    
    enum BreathPhase {
        case inhale, hold, exhale, pause
        
        var instruction: String {
            switch self {
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            case .pause: return "Pause"
            }
        }
        
        var duration: Double {
            switch self {
            case .inhale: return 4.0
            case .hold: return 2.0
            case .exhale: return 6.0
            case .pause: return 2.0
            }
        }
    }
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            ColorTheme.backgroundGradient
                .ignoresSafeArea()
            
            if showingCompletion {
                completionView
            } else if isActive {
                meditationActiveView
            } else {
                meditationSetupView
            }
        }
    }
    
    var meditationSetupView: some View {
        VStack(spacing: isCompact ? 25 : 35) {
            headerView
            
            durationSelector
            
            meditationOptions
            
            actionButtons
        }
        .padding(isCompact ? 20 : 30)
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.system(size: isCompact ? 50 : 60))
                .foregroundColor(ColorTheme.accentPurple)
                .glowEffect(color: ColorTheme.accentPurple, radius: 15)
            
            Text("Meditation")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("Find your center and stay focused")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var durationSelector: some View {
        VStack(spacing: 15) {
            Text("Session Duration")
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
            
            HStack(spacing: 10) {
                ForEach(durations, id: \.self) { duration in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedDuration = duration
                        }
                    }) {
                        Text("\(duration)m")
                            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                            .foregroundColor(selectedDuration == duration ? .black : ColorTheme.textPrimary)
                            .padding(.horizontal, isCompact ? 16 : 20)
                            .padding(.vertical, isCompact ? 8 : 10)
                            .background(
                                selectedDuration == duration ?
                                AnyView(ColorTheme.accentPurple) :
                                AnyView(ColorTheme.cardBackground)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedDuration == duration ? Color.clear : ColorTheme.accentPurple.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var meditationOptions: some View {
        VStack(spacing: 15) {
            meditationOptionCard(
                title: "Guided Breathing",
                description: "Follow the breathing animation",
                icon: "wind",
                isRecommended: true
            )
            
            meditationOptionCard(
                title: "Silent Meditation",
                description: "Quiet reflection time",
                icon: "moon.fill",
                isRecommended: false
            )
        }
    }
    
    func meditationOptionCard(title: String, description: String, icon: String, isRecommended: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(ColorTheme.accentCyan)
                .frame(width: isCompact ? 40 : 50)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title)
                        .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    if isRecommended {
                        Text("RECOMMENDED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(ColorTheme.accentCyan)
                            .cornerRadius(8)
                    }
                }
                
                Text(description)
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
    
    var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: startMeditation) {
                Text("Start Session")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 15 : 18)
                    .background(ColorTheme.accentPurple)
                    .cornerRadius(15)
                    .glowEffect(color: ColorTheme.accentPurple, radius: 10)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Text("Cancel")
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
    
    var meditationActiveView: some View {
        VStack(spacing: isCompact ? 30 : 40) {
            timerDisplay
            
            breathingAnimation
            
            breathingInstruction
            
            controlButtons
        }
        .padding(isCompact ? 20 : 30)
    }
    
    var timerDisplay: some View {
        VStack(spacing: 10) {
            Text("Time Remaining")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
            
            Text(formatTime(timeRemaining))
                .font(.system(size: isCompact ? 36 : 48, weight: .bold, design: .monospaced))
                .foregroundColor(ColorTheme.accentPurple)
                .glowEffect(color: ColorTheme.accentPurple, radius: 10)
        }
    }
    
    var breathingAnimation: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ColorTheme.accentPurple.opacity(0.4), ColorTheme.accentCyan.opacity(0.2)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: isCompact ? 200 : 250, height: isCompact ? 200 : 250)
                .scaleEffect(animationAmount)
                .animation(.easeInOut(duration: breathPhase.duration), value: animationAmount)
            
            Circle()
                .stroke(ColorTheme.accentPurple, lineWidth: 3)
                .frame(width: isCompact ? 180 : 220, height: isCompact ? 180 : 220)
                .opacity(0.6)
        }
    }
    
    var breathingInstruction: some View {
        Text(breathPhase.instruction)
            .font(.system(size: isCompact ? 24 : 28, weight: .medium))
            .foregroundColor(ColorTheme.textPrimary)
            .animation(.easeInOut, value: breathPhase)
    }
    
    var controlButtons: some View {
        HStack(spacing: 20) {
            Button(action: pauseMeditation) {
                Image(systemName: "pause.fill")
                    .font(.system(size: isCompact ? 24 : 28))
                    .foregroundColor(ColorTheme.warningOrange)
                    .frame(width: isCompact ? 60 : 70, height: isCompact ? 60 : 70)
                    .background(ColorTheme.warningOrange.opacity(0.2))
                    .cornerRadius(35)
            }
            
            Button(action: stopMeditation) {
                Image(systemName: "stop.fill")
                    .font(.system(size: isCompact ? 24 : 28))
                    .foregroundColor(ColorTheme.dangerRed)
                    .frame(width: isCompact ? 60 : 70, height: isCompact ? 60 : 70)
                    .background(ColorTheme.dangerRed.opacity(0.2))
                    .cornerRadius(35)
            }
        }
    }
    
    var completionView: some View {
        VStack(spacing: isCompact ? 25 : 35) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isCompact ? 80 : 100))
                .foregroundColor(ColorTheme.successGreen)
                .glowEffect(color: ColorTheme.successGreen, radius: 20)
            
            VStack(spacing: 15) {
                Text("Session Complete!")
                    .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("You meditated for \(selectedDuration) minutes. Well done!")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Session #\(AppSettings.shared.meditationCount)")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(ColorTheme.accentPurple)
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
    
    func startMeditation() {
        withAnimation(.spring()) {
            isActive = true
            timeRemaining = selectedDuration * 60
        }
        startTimer()
        startBreathingCycle()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeMeditation()
            }
        }
    }
    
    func startBreathingCycle() {
        cycleBreathPhase()
    }
    
    func cycleBreathPhase() {
        guard isActive else { return }
        
        switch breathPhase {
        case .inhale:
            animationAmount = 1.4
            breathPhase = .hold
        case .hold:
            breathPhase = .exhale
        case .exhale:
            animationAmount = 1.0
            breathPhase = .pause
        case .pause:
            breathPhase = .inhale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
            cycleBreathPhase()
        }
    }
    
    func pauseMeditation() {
        timer?.invalidate()
        isActive = false
    }
    
    func stopMeditation() {
        timer?.invalidate()
        withAnimation(.spring()) {
            isActive = false
            isPresented = false
        }
    }
    
    func completeMeditation() {
        timer?.invalidate()
        dataService.incrementMeditationCount()
        withAnimation(.spring()) {
            isActive = false
            showingCompletion = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring()) {
                isPresented = false
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    MeditationModal(isPresented: .constant(true))
        .environmentObject(DataService())
}