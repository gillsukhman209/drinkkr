import SwiftUI
import UIKit

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
    @State private var hapticTimer: Timer?
    
    let durations = [1, 3, 5, 10, 15, 20]
    
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
        
        var animationScale: Double {
            switch self {
            case .inhale: return 1.4  // Expand on inhale
            case .hold: return 1.4    // Stay expanded
            case .exhale: return 0.8  // Contract on exhale
            case .pause: return 0.8   // Stay contracted
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
            
            Text("Guided breathing to help you find calm")
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
        VStack(spacing: 0) {
            // Timer at top with fixed spacing
            timerDisplay
                .padding(.top, isCompact ? 40 : 60)
            
            Spacer(minLength: isCompact ? 40 : 60)
            
            // Breathing animation in center
            breathingAnimation
                .frame(height: isCompact ? 280 : 320)
            
            Spacer(minLength: isCompact ? 20 : 30)
            
            // Instruction text below animation
            breathingInstruction
                .padding(.bottom, isCompact ? 30 : 40)
            
            // Control buttons at bottom
            controlButtons
                .padding(.bottom, isCompact ? 40 : 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            // Outer glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ColorTheme.accentCyan.opacity(0.3),
                            ColorTheme.accentPurple.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: isCompact ? 240 : 280, height: isCompact ? 240 : 280)
                .scaleEffect(animationAmount * 0.8)
                .opacity(0.6)
            
            // Main breathing circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            ColorTheme.accentCyan.opacity(0.6),
                            ColorTheme.accentPurple.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isCompact ? 160 : 200, height: isCompact ? 160 : 200)
                .scaleEffect(animationAmount)
                .animation(.easeInOut(duration: breathPhase.duration), value: animationAmount)
            
            // Inner circle for depth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ColorTheme.accentCyan.opacity(0.8),
                            ColorTheme.accentCyan.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 50
                    )
                )
                .frame(width: isCompact ? 80 : 100, height: isCompact ? 80 : 100)
                .scaleEffect(animationAmount * 1.2)
                .animation(.easeInOut(duration: breathPhase.duration), value: animationAmount)
        }
    }
    
    var breathingInstruction: some View {
        VStack(spacing: 8) {
            Text(breathPhase.instruction)
                .font(.system(size: isCompact ? 28 : 34, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
                .animation(.easeInOut(duration: 0.3), value: breathPhase)
            
            Text(instructionSubtext)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
                .animation(.easeInOut(duration: 0.3), value: breathPhase)
        }
    }
    
    var instructionSubtext: String {
        switch breathPhase {
        case .inhale: return "Slowly fill your lungs"
        case .hold: return "Keep the air in"
        case .exhale: return "Release the air slowly"
        case .pause: return "Rest and prepare"
        }
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
            // Special case for 1-second test duration
            timeRemaining = selectedDuration == 1 ? 1 : selectedDuration * 60
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
        // Start with initial animation scale
        animationAmount = breathPhase.animationScale
        cycleBreathPhase()
    }
    
    func cycleBreathPhase() {
        guard isActive else { return }
        
        // Start haptic feedback that syncs with animation
        startHapticFeedbackForPhase(breathPhase)
        
        // Update animation scale based on breath phase
        withAnimation(.easeInOut(duration: breathPhase.duration)) {
            animationAmount = breathPhase.animationScale
        }
        
        // Move to next phase after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
            guard self.isActive else { return }
            
            // Stop current haptic feedback
            self.stopHapticFeedback()
            
            // Cycle through phases
            switch self.breathPhase {
            case .inhale:
                self.breathPhase = .hold
            case .hold:
                self.breathPhase = .exhale
            case .exhale:
                self.breathPhase = .pause
            case .pause:
                self.breathPhase = .inhale
            }
            
            self.cycleBreathPhase()
        }
    }
    
    func startHapticFeedbackForPhase(_ phase: BreathPhase) {
        // Stop any existing haptic timer
        stopHapticFeedback()
        
        switch phase {
        case .inhale, .exhale:
            // Create continuous stronger vibration during movement phases
            startContinuousHaptic(intensity: 0.7, interval: 0.15)
        case .hold:
            // Single medium pulse for hold
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        case .pause:
            // Light pulse for pause
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred(intensity: 0.5)
        }
    }
    
    func startContinuousHaptic(intensity: CGFloat, interval: TimeInterval) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        
        hapticTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            impact.impactOccurred(intensity: intensity)
        }
    }
    
    func stopHapticFeedback() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    func pauseMeditation() {
        timer?.invalidate()
        stopHapticFeedback()
        isActive = false
    }
    
    func stopMeditation() {
        timer?.invalidate()
        stopHapticFeedback()
        withAnimation(.spring()) {
            isActive = false
            isPresented = false
        }
    }
    
    func completeMeditation() {
        timer?.invalidate()
        stopHapticFeedback()
        
        // Save the meditation session
        dataService.saveMeditationSession(duration: selectedDuration)
        
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