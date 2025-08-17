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
                ColorTheme.backgroundGradient
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
        VStack(spacing: 10) {
            Text("You've been alcohol-free for")
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(spacing: isCompact ? 10 : 15) {
                timeComponent(value: timeComponents.days, unit: "days")
                timeComponent(value: timeComponents.hours, unit: "hours")
                timeComponent(value: timeComponents.minutes, unit: "mins")
                timeComponent(value: timeComponents.seconds, unit: "secs")
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
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
        let columns = isCompact ? 
            [GridItem(.flexible()), GridItem(.flexible())] :
            [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: columns, spacing: isCompact ? 15 : 20) {
            actionButton(title: "Pledge", icon: "hand.raised.fill", color: ColorTheme.accentCyan)
            actionButton(title: "Meditate", icon: "leaf.fill", color: ColorTheme.accentPurple)
            actionButton(title: "Reset", icon: "arrow.clockwise", color: ColorTheme.warningOrange)
            actionButton(title: "Panic", icon: "exclamationmark.triangle.fill", color: ColorTheme.dangerRed)
        }
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