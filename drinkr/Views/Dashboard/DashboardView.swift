import SwiftUI
import Combine
import UserNotifications

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct DashboardView: View {
    @State private var hasAppeared = false
    @State private var showingPledgeModal = false
    @State private var showingMeditationModal = false
    @State private var showingResetModal = false
    @State private var showingPanicModal = false
    @State private var showingCelebration = false {
        didSet {
            #if DEBUG
            print("🚨 showingCelebration changed to: \(showingCelebration)")
            #endif
        }
    }
    @State private var celebrationMilestone = 0 {
        didSet {
            #if DEBUG
            print("🚨 celebrationMilestone changed to: \(celebrationMilestone)")
            #endif
        }
    }
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var dataService: DataService
    
    @State private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) = (0, 0, 0, 0)
    @State private var lastCelebratedMilestone = 0
    @State private var currentQuoteIndex = 0
    @State private var todaysReflection = ""
    
    // Timer removed in favor of TimelineView
    
    let motivationalQuotes = [
        "Your energy grows with every healthy meal.",
        "Progress, not perfection. Every choice counts.",
        "You're not giving up food, you're gaining vitality.",
        "The hardest step was the first one. Keep going.",
        "Your future self is thanking you right now.",
        "Healthy eating delivers everything fast food promised.",
        "You are stronger than your strongest craving.",
        "One meal at a time becomes a lifetime of health."
    ]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 16 : 20) {
                        // App name header
                        HStack {
                            Text("NoBite")
                                .font(.system(size: isCompact ? 30 : 34, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, ColorTheme.accentCyan.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, isCompact ? 0 : 5)
                        
                        weekProgressIndicator
                        
                        sobrietyTimerView
                            .padding(.horizontal)
                        
                        crystalAnimation
                            .frame(height: isCompact ? 200 : 250)
                            .padding(.vertical)
                        
                        actionButtons
                            .padding(.horizontal)
                        
                        motivationalQuoteSection
                            .padding(.horizontal)
                        
                        quickStatsCards
                            .padding(.horizontal)
                        

                        
                        recentAchievementsSection
                            .padding(.horizontal)
                        
                        healthBenefitsSection
                            .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                updateTimeComponents() // Initialize on first appearance
            }
        }

        #if DEBUG
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceMilestone"))) { notification in
            if let userInfo = notification.userInfo,
               let days = userInfo["days"] as? Int {
                print("🚨 FORCE milestone trigger received for \(days) days")
                celebrationMilestone = days
                showingCelebration = true
                print("🚨 showingCelebration = \(showingCelebration)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TestMilestone"))) { notification in
            if let userInfo = notification.userInfo,
               let days = userInfo["days"] as? Int {
                print("🧪 Received test milestone trigger for \(days) days")
                
                // Force trigger milestone check regardless of history
                let milestones = [1, 7, 14, 30, 60, 90, 180, 365]
                if milestones.contains(days) {
                    celebrationMilestone = days
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingCelebration = true
                    }
                }
            }
        }
        #endif
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
            PanicButtonModal(isPresented: $showingPanicModal, showingMeditationModal: $showingMeditationModal)
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
                .scaleEffect(progress[day] ? 1.02 : 1.0)
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
            Text(dataService.currentUser?.name != nil ? "\(dataService.currentUser!.name) you have been fast food free for" : "You have been fast food free for")
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.5)
            
            // Smart timer display that adapts based on duration
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                Text(getSmartTimeDisplay(for: context.date))
                    .font(.system(size: isCompact ? 72 : 96, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, ColorTheme.accentCyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .onChange(of: context.date) { _, _ in
                        updateTimeComponents()
                    }
            }
        }
        .padding(.vertical, isCompact ? 20 : 30)
    }
    
    func getSmartTimeDisplay(for date: Date) -> String {
        guard let quitDate = dataService.cleanEatingData?.quitDate else { return "0s" }
        
        let interval = date.timeIntervalSince(quitDate)
        let totalSeconds = Int(interval)
        
        // Less than 60 seconds: show seconds
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
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
            let days = totalSeconds / 86400
            let hours = (totalSeconds % 86400) / 3600
            if hours == 0 {
                return "\(days)d"
            } else {
                return "\(days)d \(hours)h"
            }
        }
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
                        .blur(radius: 0.5)
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
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    var actionButtons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: isCompact ? 30 : 40) {
                circularActionButton(title: "Commit", icon: "hand.raised.fill")
                circularActionButton(title: "Meditate", icon: "leaf.fill")
                circularActionButton(title: "Reset", icon: "arrow.clockwise")
                panicButton()
            }
            .padding(.horizontal, isCompact ? 20 : 40)
            
            // Fallback for smaller screens
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    circularActionButton(title: "Commit", icon: "hand.raised.fill")
                    circularActionButton(title: "Meditate", icon: "leaf.fill")
                    circularActionButton(title: "Reset", icon: "arrow.clockwise")
                    panicButton()
                }
                .padding(.horizontal, 20)
            }
        }
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
                .padding(2)
                
                Text("CRAVING")
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
    }
    
    func handleActionButton(title: String) {
        switch title {
        case "Commit":
            showingPledgeModal = true
        case "Meditate":
            showingMeditationModal = true
        case "Reset":
            showingResetModal = true
        case "Craving":
            showingPanicModal = true
        default:
            break
        }
    }
    
    var quickStatsCards: some View {
        VStack(spacing: 15) {
            Text("\(dataService.currentUser?.name ?? "Your") Progress")
                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: isCompact ? 10 : 15) {
                quickStatCard(
                    title: "Money Saved",
                    value: "$\(Int(dataService.cleanEatingData?.moneySaved ?? 0))",
                    icon: "dollarsign.circle.fill",
                    color: ColorTheme.successGreen
                )
                
                quickStatCard(
                    title: "Clean Streak",
                    value: "\(dataService.cleanEatingData?.currentStreak ?? 0)",
                    icon: "flame.fill",
                    color: ColorTheme.accentCyan
                )
            }
            
            HStack(spacing: isCompact ? 10 : 15) {
                quickStatCard(
                    title: "Meals Avoided",
                    value: "\(dataService.cleanEatingData?.mealsAvoided ?? 0)",
                    icon: "fork.knife",
                    color: ColorTheme.accentPurple
                )
                
                quickStatCard(
                    title: "Commitments",
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
    

    
    
    
    func updateTimeComponents() {
        let newTimeComponents = dataService.getTimeComponents()
        let oldDays = timeComponents.days
        
        
        // Always update the time components for live timer
        timeComponents = newTimeComponents
        
        // Check milestones when:
        // 1. In debug mode with active debug time
        // 2. When days change (including from 0 to any number on first run)  
        // 3. Force check on first appearance or when system time might have changed
        #if DEBUG
        let isDebugActive = DebugTimeManager.shared.isDebugMode
        let shouldCheckMilestone = isDebugActive || newTimeComponents.days != oldDays || oldDays == 0
        #else
        let shouldCheckMilestone = newTimeComponents.days != oldDays || oldDays == 0  
        #endif
        
        if shouldCheckMilestone {
            // Load last celebrated milestone from UserDefaults
            #if DEBUG
            let milestoneKey = DebugTimeManager.shared.isDebugMode ? "debugLastCelebratedMilestone" : "lastCelebratedMilestone"
            lastCelebratedMilestone = UserDefaults.standard.integer(forKey: milestoneKey)
            #else
            lastCelebratedMilestone = UserDefaults.standard.integer(forKey: "lastCelebratedMilestone")
            #endif
            
            // Check if we've reached a new milestone
            checkForMilestone(newTimeComponents.days)
            
            // Refresh stats (money saved, meals avoided, etc.)
            dataService.refreshStats()
        }
    }
    
    func checkForMilestone(_ streak: Int) {
        let milestones = [1, 7, 14, 30, 60, 90, 180, 365]
        
        
        // Only celebrate if this is a milestone AND we haven't celebrated it before
        if milestones.contains(streak) && streak > lastCelebratedMilestone {
            print("🎉 NEW MILESTONE REACHED: \(streak) days (last celebrated: \(lastCelebratedMilestone))")
            
            celebrationMilestone = streak
            lastCelebratedMilestone = streak
            
            // Save the milestone to UserDefaults so we don't celebrate it again
            #if DEBUG
            let milestoneKey = DebugTimeManager.shared.isDebugMode ? "debugLastCelebratedMilestone" : "lastCelebratedMilestone"
            UserDefaults.standard.set(streak, forKey: milestoneKey)
            #else
            UserDefaults.standard.set(streak, forKey: "lastCelebratedMilestone")
            #endif
            
            // Trigger celebration and send notification
            #if DEBUG
            showingCelebration = true
            #else
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingCelebration = true
            }
            #endif
            
            // Send iOS notification
            sendMilestoneNotification(for: streak)
        }
    }
    
    private func sendMilestoneNotification(for days: Int) {
        print("🎯 Scheduling milestone notification for \(days) days")
        let content = UNMutableNotificationContent()
        
        switch days {
        case 1:
            content.title = "🌟 First Day Complete!"
            content.body = "You did it! Every journey begins with a single step."
        case 7:
            content.title = "🎉 One Week Strong!"
            content.body = "You're building incredible habits. Keep it up!"
        case 30:
            content.title = "🏆 One Month Milestone!"
            content.body = "A full month! You're proving to yourself what's possible."
        case 90:
            content.title = "👑 Three Months!"
            content.body = "You've created lasting change. You're unstoppable!"
        case 365:
            content.title = "🎆 One Year Achievement!"
            content.body = "A full year! You've completely transformed your life!"
        default:
            content.title = "✨ \(days) Days Milestone!"
            content.body = "Keep going strong! Every day counts."
        }
        
        content.sound = .default
        content.badge = NSNumber(value: days)
        
        let request = UNNotificationRequest(
            identifier: "milestone-\(days)-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send milestone notification: \(error)")
            } else {
                print("✅ Milestone notification sent for \(days) days")
                
                // Log all pending notifications for testing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationService.shared.logAllPendingNotifications()
                }
            }
        }
    }
    
    var motivationalQuoteSection: some View {
        VStack(spacing: isCompact ? 12 : 16) {
            let quote = motivationalQuotes[currentQuoteIndex % motivationalQuotes.count]
            
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: isCompact ? 18 : 22))
                    .foregroundColor(ColorTheme.accentCyan.opacity(0.6))
                
                Spacer()
                
                Image(systemName: "quote.closing")
                    .font(.system(size: isCompact ? 18 : 22))
                    .foregroundColor(ColorTheme.accentCyan.opacity(0.6))
            }
            
            Text(quote)
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            Button(action: {
                currentQuoteIndex += 1
            }) {
                HStack(spacing: 6) {
                    Text("Next Quote")
                        .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: isCompact ? 14 : 16))
                }
                .foregroundColor(ColorTheme.accentCyan)
            }
            .padding(.top, 4)
        }
        .padding(isCompact ? 20 : 24)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                .fill(
                    LinearGradient(
                        colors: [
                            ColorTheme.accentPurple.opacity(0.15),
                            ColorTheme.accentCyan.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .onAppear {
            currentQuoteIndex = Int.random(in: 0..<motivationalQuotes.count)
        }
    }
    


    

    
    @ViewBuilder
    func achievementRow(_ achievement: Achievement) -> some View {
        HStack(spacing: isCompact ? 12 : 16) {
            Image(systemName: achievement.icon)
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(ColorTheme.accentCyan)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(achievement.achievementDescription)
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isCompact ? 18 : 20))
                .foregroundColor(ColorTheme.successGreen)
        }
        .padding(isCompact ? 12 : 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
    }
    
    @ViewBuilder
    var achievementsContent: some View {
        let unlockedAchievements = dataService.achievements.filter { $0.isUnlocked }
        
        if unlockedAchievements.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "star.circle")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("Your achievements will appear here")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else {
            VStack(spacing: 8) {
                ForEach(Array(unlockedAchievements.prefix(3))) { achievement in
                    achievementRow(achievement)
                }
            }
        }
    }
    
    var recentAchievementsSection: some View {
        VStack(spacing: isCompact ? 16 : 20) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: isCompact ? 18 : 20))
                    .foregroundColor(ColorTheme.warningOrange)
                
                Text("Recent Achievements")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: ProfileView()) {
                    Text("View All")
                        .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                        .foregroundColor(ColorTheme.accentCyan)
                }
            }
            
            achievementsContent
        }
        .padding(isCompact ? 20 : 24)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    var healthBenefitsSection: some View {
        VStack(spacing: isCompact ? 16 : 20) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: isCompact ? 18 : 20))
                    .foregroundColor(ColorTheme.dangerRed)
                
                Text("Your Body is Healing")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            let daysSober = timeComponents.days
            let benefits = getHealthBenefits(for: daysSober)
            
            VStack(spacing: isCompact ? 12 : 14) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                    HStack(spacing: isCompact ? 12 : 16) {
                        Image(systemName: benefit.2 ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: isCompact ? 20 : 24))
                            .foregroundColor(benefit.2 ? ColorTheme.successGreen : .white.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(benefit.0)
                                .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                .foregroundColor(benefit.2 ? .white : .white.opacity(0.5))
                            
                            Text(benefit.1)
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(benefit.2 ? .white.opacity(0.8) : .white.opacity(0.4))
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(isCompact ? 20 : 24)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                .fill(
                    LinearGradient(
                        colors: [
                            ColorTheme.dangerRed.opacity(0.1),
                            ColorTheme.accentPink.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    func getHealthBenefits(for days: Int) -> [(String, String, Bool)] {
        let allBenefits = [
            (1, "Digestion Improving", "Your digestive system is resetting"),
            (2, "Less Bloating", "Water retention and bloating are decreasing"),
            (7, "Taste Buds Reset", "Natural flavors start tasting better"),
            (14, "Energy Boost", "Stable energy without sugar crashes"),
            (30, "Skin Clearing", "Your skin is looking healthier and brighter"),
            (60, "Mental Clarity", "Brain fog from processed food has lifted"),
            (90, "Metabolism", "Your metabolism is functioning optimally"),
            (180, "Heart Health", "Cholesterol and blood pressure improving"),
            (365, "Full Transformation", "You have built a completely new lifestyle")
        ]
        
        // Show next 3 benefits (including current if just achieved)
        let nextBenefits = allBenefits.filter { $0.0 > days || ($0.0 <= days && days < $0.0 + 2) }.prefix(3)
        
        // If we have less than 3 upcoming, show some completed ones at the start
        if nextBenefits.count < 3 {
             return allBenefits.suffix(3).map { ($0.1, $0.2, days >= $0.0) }
        }
        
        return nextBenefits.map { ($0.1, $0.2, days >= $0.0) }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataService())
}
