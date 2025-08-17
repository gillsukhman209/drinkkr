import SwiftUI

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
        HStack(spacing: isCompact ? 8 : 12) {
            ForEach(0..<7) { day in
                let progress = dataService.getWeekProgress()
                Circle()
                    .fill(progress[day] ? ColorTheme.accentCyan : Color.gray.opacity(0.3))
                    .frame(width: isCompact ? 35 : 40, height: isCompact ? 35 : 40)
                    .overlay(
                        Text(dayLabel(for: day))
                            .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                            .foregroundColor(progress[day] ? .black : .gray)
                    )
                    .glowEffect(color: progress[day] ? ColorTheme.accentCyan : .clear, radius: 5)
            }
        }
        .padding(.horizontal)
    }
    
    func dayLabel(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
    
    var sobrietyTimerView: some View {
        VStack(spacing: isCompact ? 20 : 30) {
            Text("You've been alcohol-free for:")
                .font(.system(size: isCompact ? 18 : 22, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            // Main time display - simplified
            Text(getMainTimeDisplay())
                .font(.system(size: isCompact ? 60 : 80, weight: .bold))
                .foregroundColor(.white)
            
            // Detailed timer below
            Text(getDetailedTimeDisplay())
                .font(.system(size: isCompact ? 16 : 20, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, isCompact ? 30 : 40)
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
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ColorTheme.accentCyan.opacity(0.3),
                                    ColorTheme.accentPurple.opacity(0.3),
                                    ColorTheme.accentPink.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        .rotationEffect(.degrees(Double(index) * 60))
                        .scaleEffect(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                animationAmount = 1.2
            }
        }
    }
    
    var actionButtons: some View {
        HStack(spacing: isCompact ? 30 : 40) {
            circularActionButton(title: "Pledge", icon: "hand.raised.fill")
            circularActionButton(title: "Meditate", icon: "leaf.fill")
            circularActionButton(title: "Reset", icon: "arrow.clockwise")
            circularActionButton(title: "More", icon: "ellipsis")
        }
        .padding(.horizontal, isCompact ? 20 : 40)
    }
    
    func circularActionButton(title: String, icon: String) -> some View {
        Button(action: {
            handleActionButton(title: title)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: isCompact ? 60 : 70, height: isCompact ? 60 : 70)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: isCompact ? 60 : 70, height: isCompact ? 60 : 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 20 : 24))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text(title)
                    .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .buttonStyle(PlainButtonStyle())
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
        case "More":
            showingPanicModal = true
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
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 20 : 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: isCompact ? 18 : 22, weight: .bold, design: .monospaced))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(title)
                .font(.system(size: isCompact ? 10 : 12))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 12 : 15)
        .futuristicCard()
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
    
    func getDetailedTimeDisplay() -> String {
        return "\(timeComponents.days)d \(timeComponents.hours)h \(timeComponents.minutes)m \(timeComponents.seconds)s"
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