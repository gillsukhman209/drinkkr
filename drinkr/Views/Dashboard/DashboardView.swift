import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct DashboardView: View {
    @State private var animationAmount = 1.0
    @State private var showingPledgeModal = false
    @State private var showingMeditationModal = false
    @State private var showingResetModal = false
    @State private var showingPanicModal = false
    @State private var showingCelebration = false
    @State private var celebrationMilestone = 0
    @State private var timer: Timer?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var dataService: DataService
    
    @State private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) = (0, 0, 0, 0)
    
    var isCompact: Bool {
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: isCompact ? 20 : 30) {
                        weekProgressIndicator
                            .padding(.top, isCompact ? 10 : 20)
                        
                        sobrietyTimerView
                            .padding(.horizontal)
                        
                        crystalAnimation
                            .frame(height: isCompact ? 200 : 250)
                            .padding(.vertical)
                        
                        actionButtons
                            .padding(.horizontal)
                            .padding(.bottom, isCompact ? 20 : 30)
                        
                        quickStatsCards
                            .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showingPledgeModal) {
            PledgeModal(isPresented: $showingPledgeModal)
        }
        .sheet(isPresented: $showingMeditationModal) {
            MeditationModal(isPresented: $showingMeditationModal)
        }
        .sheet(isPresented: $showingResetModal) {
            ResetModal(isPresented: $showingResetModal)
        }
        .fullScreenCover(isPresented: $showingPanicModal) {
            PanicButtonModal(isPresented: $showingPanicModal)
        }
        .fullScreenCover(isPresented: $showingCelebration) {
            CelebrationView(isPresented: $showingCelebration, milestone: celebrationMilestone)
        }
    }
    
    var weekProgressIndicator: some View {
        HStack(spacing: isCompact ? 10 : 14) {
            ForEach(0..<7) { day in
                let progress = dataService.getWeekProgress()
                ZStack {
                    Circle()
                        .fill(progress[day] ? 
                              LinearGradient(colors: [ColorTheme.accentCyan, ColorTheme.accentPurple], 
                                           startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)], 
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)
                        .overlay(
                            Circle()
                                .stroke(progress[day] ? .white.opacity(0.3) : .white.opacity(0.1), lineWidth: 1)
                        )
                    
                    Text(dayLabel(for: day))
                        .font(.system(size: isCompact ? 11 : 13, weight: .bold))
                        .foregroundColor(progress[day] ? .white : .white.opacity(0.4))
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                .scaleEffect(progress[day] ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: progress[day])
                .glowEffect(color: progress[day] ? ColorTheme.accentCyan : .clear, radius: 6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, isCompact ? 8 : 12)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    func dayLabel(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
    
    var sobrietyTimerView: some View {
        VStack(spacing: isCompact ? 24 : 32) {
            Text("You've been alcohol-free for")
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.5)
            
            // Smart timer display that adapts based on duration
            Text(getSmartTimeDisplay())
                .font(.system(size: isCompact ? 72 : 96, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, ColorTheme.accentCyan.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .glowEffect(color: ColorTheme.accentCyan, radius: 8)
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                .animation(.easeInOut(duration: 0.3), value: getSmartTimeDisplay())
        }
        .padding(.vertical, isCompact ? 40 : 56)
    }
    
    func timeComponent(value: Int, unit: String) -> some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: isCompact ? 28 : 36, weight: .bold, design: .monospaced))
                .foregroundColor(ColorTheme.accentCyan)
                .glowEffect(radius: 5)
            
            Text(unit)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var crystalAnimation: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: isCompact ? 16 : 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ColorTheme.accentCyan.opacity(0.4),
                                    ColorTheme.accentPurple.opacity(0.3),
                                    ColorTheme.accentPink.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: isCompact ? 16 : 24)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                        .rotationEffect(.degrees(Double(index) * 60))
                        .scaleEffect(animationAmount)
                        .blur(radius: 0.5)
                        .animation(
                            Animation.easeInOut(duration: 3)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                            value: animationAmount
                        )
                        .shadow(color: ColorTheme.accentCyan.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                // Central glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [ColorTheme.accentCyan.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.3
                        )
                    )
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    .animation(
                        Animation.easeInOut(duration: 4)
                            .repeatForever(autoreverses: true),
                        value: animationAmount
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                animationAmount = 1.3
            }
        }
    }
    
    var actionButtons: some View {
        HStack(spacing: isCompact ? 30 : 40) {
            circularActionButton(title: "Pledge", icon: "hand.raised.fill")
            circularActionButton(title: "Meditate", icon: "leaf.fill")
            circularActionButton(title: "Reset", icon: "arrow.clockwise")
            panicButton()
        }
        .padding(.horizontal, isCompact ? 20 : 40)
    }
    
    func circularActionButton(title: String, icon: String) -> some View {
        Button(action: {
            handleActionButton(title: title)
        }) {
            VStack(spacing: isCompact ? 10 : 12) {
                ZStack {
                    // Shadow layer
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: isCompact ? 68 : 80, height: isCompact ? 68 : 80)
                        .blur(radius: 12)
                        .offset(y: 2)
                    
                    // Main button
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: isCompact ? 68 : 80, height: isCompact ? 68 : 80)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.white.opacity(0.05), .clear],
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 40
                                    )
                                )
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 22 : 26, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.accentCyan, .white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                Text(title)
                    .font(.system(size: isCompact ? 13 : 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    func panicButton() -> some View {
        Button(action: {
            showingPanicModal = true
        }) {
            VStack(spacing: isCompact ? 10 : 12) {
                ZStack {
                    // Pulsing glow effect
                    Circle()
                        .fill(ColorTheme.dangerRed.opacity(0.6))
                        .frame(width: isCompact ? 80 : 90, height: isCompact ? 80 : 90)
                        .blur(radius: 15)
                        .scaleEffect(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: animationAmount
                        )
                    
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.dangerRed, ColorTheme.warningOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: isCompact ? 78 : 88, height: isCompact ? 78 : 88)
                    
                    // Main button
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [ColorTheme.dangerRed, ColorTheme.dangerRed.opacity(0.8)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 35
                            )
                        )
                        .frame(width: isCompact ? 68 : 80, height: isCompact ? 68 : 80)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                
                Text("PANIC")
                    .font(.system(size: isCompact ? 13 : 15, weight: .bold))
                    .foregroundColor(ColorTheme.dangerRed)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    func actionButton(title: String, icon: String, color: Color) -> some View {
        Button(action: {
            handleActionButton(title: title)
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 24 : 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: isCompact ? 80 : 100)
            .futuristicCard()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            }
        }
    }
    
    func handleActionButton(title: String) {
        switch title {
        case "Pledge":
            showingPledgeModal = true
        case "Meditate":
            showingMeditationModal = true
        case "Reset":
            showingResetModal = true
        case "Panic":
            showingPanicModal = true
        default:
            break
        }
    }
    
    var quickStatsCards: some View {
        VStack(spacing: 15) {
            Text("Today's Progress")
                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: isCompact ? 10 : 15) {
                quickStatCard(
                    title: "Money Saved",
                    value: "$\(Int(dataService.sobrietyData?.moneySaved ?? 0))",
                    icon: "dollarsign.circle.fill",
                    color: ColorTheme.successGreen
                )
                
                quickStatCard(
                    title: "Days Strong",
                    value: "\(dataService.sobrietyData?.currentStreak ?? 0)",
                    icon: "flame.fill",
                    color: ColorTheme.accentCyan
                )
            }
            
            HStack(spacing: isCompact ? 10 : 15) {
                quickStatCard(
                    title: "Drinks Avoided",
                    value: "\(dataService.sobrietyData?.drinksAvoided ?? 0)",
                    icon: "wineglass",
                    color: ColorTheme.accentPurple
                )
                
                quickStatCard(
                    title: "Pledges Made",
                    value: "\(AppSettings.shared.totalPledges)",
                    icon: "hand.raised.fill",
                    color: ColorTheme.accentPink
                )
            }
        }
    }
    
    func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: isCompact ? 10 : 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: isCompact ? 40 : 48, height: isCompact ? 40 : 48)
                
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 18 : 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(value)
                .font(.system(size: isCompact ? 20 : 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(title)
                .font(.system(size: isCompact ? 11 : 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    func getMainTimeDisplay() -> String {
        let totalMinutes = timeComponents.days * 24 * 60 + timeComponents.hours * 60 + timeComponents.minutes
        
        if totalMinutes < 60 {
            return "\(totalMinutes) Mins"
        } else if timeComponents.days < 1 {
            let hours = totalMinutes / 60
            return "\(hours) Hours"
        } else {
            return "\(timeComponents.days) Days"
        }
    }
    
    func getSmartTimeDisplay() -> String {
        let totalSeconds = timeComponents.days * 24 * 3600 + timeComponents.hours * 3600 + timeComponents.minutes * 60 + timeComponents.seconds
        
        // Less than 60 seconds: show seconds
        if totalSeconds < 60 {
            return "\(timeComponents.seconds)s"
        }
        // Less than 60 minutes: show minutes and seconds
        else if totalSeconds < 3600 {
            let totalMinutes = totalSeconds / 60
            let remainingSeconds = totalSeconds % 60
            if remainingSeconds == 0 {
                return "\(totalMinutes)m"
            } else {
                return "\(totalMinutes)m \(remainingSeconds)s"
            }
        }
        // Less than 24 hours: show hours and minutes
        else if totalSeconds < 86400 {
            let totalHours = totalSeconds / 3600
            let remainingMinutes = (totalSeconds % 3600) / 60
            if remainingMinutes == 0 {
                return "\(totalHours)h"
            } else {
                return "\(totalHours)h \(remainingMinutes)m"
            }
        }
        // 24 hours or more: show days and hours
        else {
            let days = timeComponents.days
            let hours = timeComponents.hours
            if hours == 0 {
                return "\(days)d"
            } else {
                return "\(days)d \(hours)h"
            }
        }
    }
    
    
    func startTimer() {
        updateTimeComponents()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeComponents()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateTimeComponents() {
        let previousStreak = timeComponents.days
        timeComponents = dataService.getTimeComponents()
        
        let currentStreak = timeComponents.days
        if currentStreak > previousStreak {
            checkForMilestone(currentStreak)
        }
    }
    
    func checkForMilestone(_ streak: Int) {
        let milestones = [1, 7, 14, 30, 60, 90, 180, 365]
        if milestones.contains(streak) {
            celebrationMilestone = streak
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingCelebration = true
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataService())
}