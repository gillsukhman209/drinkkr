import SwiftUI

struct ProfileView: View {
    @State private var selectedTimeFrame = "All Time"
    @State private var showingAchievements = false
    @State private var showingRelapseHistory = false
    @State private var hasAppeared = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var dataService: DataService
    
    let timeFrames = ["All Time", "This Month", "This Week"]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: isCompact ? 20 : 25) {
                        profileHeader
                            .padding(.horizontal)
                            .padding(.top)
                        
                        streakCards
                            .padding(.horizontal)
                        
                        timeFramePicker
                            .padding(.horizontal)
                        
                        statsView
                            .padding(.horizontal)
                        
                        achievementsSection
                            .padding(.horizontal)
                        
                        milestonesSection
                            .padding(.horizontal)
                        
                        checkInHistorySection
                            .padding(.horizontal)
                        
                        meditationStatsSection
                            .padding(.horizontal)
                        
                        relapseHistorySection
                            .padding(.horizontal)
                        
                        // Test buttons for viral notifications (Debug)
                        #if DEBUG
                        testNotificationButtons
                            .padding(.horizontal)
                        #endif
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationTitle("\(dataService.currentUser?.name ?? "Your") Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            hasAppeared = true
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementDetailModal(isPresented: $showingAchievements)
                .environmentObject(dataService)
        }
        .sheet(isPresented: $showingRelapseHistory) {
            RelapseHistoryModal(isPresented: $showingRelapseHistory)
                .environmentObject(dataService)
        }
    }
    
    var profileHeader: some View {
        HStack(spacing: isCompact ? 15 : 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: isCompact ? 60 : 80))
                .foregroundColor(ColorTheme.accentCyan)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome back, \(dataService.currentUser?.name ?? "friend")!")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
                
                Text(dataService.currentUser?.name ?? "Anonymous")
                    .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(dataService.sobrietyData?.currentStreak ?? 0) Day Streak")
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var streakCards: some View {
        HStack(spacing: isCompact ? 12 : 15) {
            streakCard(title: "Current", value: "\(dataService.sobrietyData?.currentStreak ?? 0)", unit: "days", color: ColorTheme.successGreen)
            streakCard(title: "Best", value: "\(dataService.sobrietyData?.longestStreak ?? 0)", unit: "days", color: ColorTheme.accentPurple)
        }
    }
    
    func streakCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary)
            
            Text(value)
                .font(.system(size: isCompact ? 36 : 44, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var timeFramePicker: some View {
        HStack(spacing: 0) {
            ForEach(timeFrames, id: \.self) { timeFrame in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTimeFrame = timeFrame
                    }
                }) {
                    Text(timeFrame)
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(selectedTimeFrame == timeFrame ? .black : ColorTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isCompact ? 12 : 15)
                        .background(
                            selectedTimeFrame == timeFrame ?
                            AnyView(ColorTheme.accentCyan) :
                            AnyView(Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(ColorTheme.cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
        )
    }
    
    var statsView: some View {
        VStack(spacing: isCompact ? 15 : 20) {
            let stats = getStatsForTimeFrame()
            
            statRow(label: "Money Saved", value: "$\(Int(stats.moneySaved))", icon: "dollarsign.circle.fill", color: ColorTheme.successGreen)
            statRow(label: "Drinks Avoided", value: "\(stats.drinksAvoided)", icon: "wineglass", color: ColorTheme.accentPurple)
            statRow(label: "Calories Saved", value: "\(stats.caloriesSaved)", icon: "flame.fill", color: .orange)
            statRow(label: "Time Reclaimed", value: "\(Int(stats.timeReclaimed)) hrs", icon: "clock.fill", color: ColorTheme.accentCyan)
            
            Divider()
                .background(ColorTheme.textSecondary.opacity(0.3))
            
            statRow(label: "Check-ins", value: "\(stats.checkIns)", icon: "checkmark.circle.fill", color: ColorTheme.accentCyan)
            statRow(label: "Meditations", value: "\(stats.meditations)", icon: "leaf.fill", color: ColorTheme.accentPurple)
            statRow(label: "Achievements", value: "\(stats.achievements)", icon: "trophy.fill", color: ColorTheme.successGreen)
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func statRow(label: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 20 : 24))
                .foregroundColor(color)
                .frame(width: isCompact ? 30 : 35)
            
            Text(label)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: isCompact ? 18 : 20, weight: .bold, design: .monospaced))
                .foregroundColor(ColorTheme.textPrimary)
        }
    }
    
    var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    showingAchievements = true
                }
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.accentCyan)
            }
            
            let recentAchievements = getRecentAchievements()
            if recentAchievements.isEmpty {
                Text("Complete your first day to unlock achievements!")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding(.vertical, 10)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(recentAchievements.prefix(4), id: \.id) { achievement in
                        achievementCard(achievement)
                    }
                }
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func achievementCard(_ achievement: Achievement) -> some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(achievement.isUnlocked ? ColorTheme.accentCyan : ColorTheme.textSecondary)
            
            Text(achievement.title)
                .font(.system(size: isCompact ? 11 : 12, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.accentPurple))
                    .scaleEffect(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 12 : 15)
        .background(achievement.isUnlocked ? ColorTheme.successGreen.opacity(0.1) : ColorTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? ColorTheme.successGreen.opacity(0.3) : ColorTheme.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Upcoming Milestones")
                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            let milestones = getUpcomingMilestones()
            ForEach(milestones, id: \.0) { milestone in
                milestoneRow(days: milestone.0, title: milestone.1, daysLeft: milestone.2)
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func milestoneRow(days: Int, title: String, daysLeft: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("\(days) days")
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if daysLeft <= 0 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: isCompact ? 20 : 24))
                        .foregroundColor(ColorTheme.successGreen)
                } else {
                    Text("\(daysLeft) days left")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.accentPurple)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    var checkInHistorySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Check-In History")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                if !dataService.checkIns.isEmpty {
                    Text("\(dataService.checkIns.count) total")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            if dataService.checkIns.isEmpty {
                Text("No check-ins yet. Start tracking your mood!")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                // Show last 3 check-ins
                ForEach(dataService.checkIns.prefix(3), id: \.id) { checkIn in
                    HStack {
                        // Mood emoji
                        Text(getMoodEmoji(checkIn.mood))
                            .font(.system(size: isCompact ? 24 : 28))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatCheckInDate(checkIn.timestamp))
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(ColorTheme.textSecondary)
                            
                            if !checkIn.notes.isEmpty {
                                Text(checkIn.notes)
                                    .font(.system(size: isCompact ? 14 : 16))
                                    .foregroundColor(ColorTheme.textPrimary)
                                    .lineLimit(2)
                            } else {
                                Text("Mood: \(checkIn.mood)/5")
                                    .font(.system(size: isCompact ? 14 : 16))
                                    .foregroundColor(ColorTheme.textPrimary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(isCompact ? 12 : 15)
                    .background(ColorTheme.cardBackground.opacity(0.5))
                    .cornerRadius(10)
                }
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var meditationStatsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Meditation Progress")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: isCompact ? 20 : 24))
                    .foregroundColor(ColorTheme.accentPurple)
            }
            
            let totalSessions = dataService.meditationSessions.count
            let totalMinutes = dataService.meditationSessions.reduce(0) { $0 + $1.duration }
            let averageMinutes = totalSessions > 0 ? totalMinutes / totalSessions : 0
            
            VStack(spacing: 12) {
                statRow(label: "Total Sessions", value: "\(totalSessions)", icon: "leaf.fill", color: ColorTheme.successGreen)
                statRow(label: "Total Time", value: "\(totalMinutes) min", icon: "clock.fill", color: ColorTheme.accentCyan)
                statRow(label: "Average Session", value: "\(averageMinutes) min", icon: "chart.bar.fill", color: ColorTheme.accentPurple)
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var relapseHistorySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Relapse History")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    showingRelapseHistory = true
                }
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.accentCyan)
            }
            
            let relapseStats = getRelapseStats()
            VStack(spacing: 12) {
                statRow(label: "Total Relapses", value: "\(relapseStats.total)", icon: "exclamationmark.triangle.fill", color: ColorTheme.warningOrange)
                statRow(label: "This Month", value: "\(relapseStats.thisMonth)", icon: "calendar", color: ColorTheme.accentPurple)
                statRow(label: "Average per Month", value: String(format: "%.1f", relapseStats.averagePerMonth), icon: "chart.line.uptrend.xyaxis", color: ColorTheme.accentCyan)
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    // MARK: - Helper Functions
    
    func getRecentAchievements() -> [Achievement] {
        return dataService.achievements.filter { $0.isUnlocked }.sorted { first, second in
            (first.dateEarned ?? Date.distantPast) > (second.dateEarned ?? Date.distantPast)
        }
    }
    
    func getUpcomingMilestones() -> [(Int, String, Int)] {
        let currentStreak = dataService.sobrietyData?.currentStreak ?? 0
        let milestones = [
            (1, "First Day", 1),
            (3, "3 Days Strong", 3),
            (7, "One Week", 7),
            (14, "Two Weeks", 14),
            (30, "One Month", 30),
            (60, "Two Months", 60),
            (90, "Three Months", 90),
            (180, "Six Months", 180),
            (365, "One Year", 365),
            (730, "Two Years", 730)
        ]
        
        return milestones.map { (days, title, target) in
            let daysLeft = max(0, target - currentStreak)
            return (days, title, daysLeft)
        }.filter { $0.2 >= 0 }.prefix(4).map { $0 }
    }
    
    func getRelapseStats() -> (total: Int, thisMonth: Int, averagePerMonth: Double) {
        guard let sobrietyData = dataService.sobrietyData else {
            return (0, 0, 0.0)
        }
        
        let total = sobrietyData.relapses.count
        
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let thisMonth = sobrietyData.relapses.filter { relapse in
            relapse.date >= startOfMonth
        }.count
        
        // Calculate average per month since quit date
        let monthsSinceQuit = max(1, calendar.dateComponents([.month], from: sobrietyData.quitDate, to: now).month ?? 1)
        let averagePerMonth = Double(total) / Double(monthsSinceQuit)
        
        return (total, thisMonth, averagePerMonth)
    }
    
    func getStatsForTimeFrame() -> (moneySaved: Double, drinksAvoided: Int, caloriesSaved: Int, timeReclaimed: Double, checkIns: Int, meditations: Int, achievements: Int) {
        guard let sobrietyData = dataService.sobrietyData else {
            return (0, 0, 0, 0, 0, 0, 0)
        }
        
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        
        switch selectedTimeFrame {
        case "This Week":
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case "This Month":
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        default: // "All Time"
            startDate = sobrietyData.quitDate
        }
        
        let daysSinceStart = max(0, calendar.dateComponents([.day], from: startDate, to: now).day ?? 0)
        
        // Calculate stats based on time frame
        let averageDrinksPerDay = 3.0
        let averageCostPerDrink = 10.0
        let averageCaloriesPerDrink = 150
        let averageHoursWastedPerDay = 2.0
        
        let drinksAvoided = daysSinceStart * Int(averageDrinksPerDay)
        let moneySaved = Double(drinksAvoided) * averageCostPerDrink
        let caloriesSaved = drinksAvoided * averageCaloriesPerDrink
        let timeReclaimed = Double(daysSinceStart) * averageHoursWastedPerDay
        
        // Count activities in timeframe
        let meditationCount = AppSettings.shared.meditationCount // This could be enhanced to be time-aware
        let achievementCount = dataService.achievements.filter { $0.isUnlocked }.count
        
        // For now, we'll use simplified check-in counting
        let checkInCount = daysSinceStart > 0 ? min(daysSinceStart, 30) : 0 // Estimate
        
        return (moneySaved, drinksAvoided, caloriesSaved, timeReclaimed, checkInCount, meditationCount, achievementCount)
    }
    
    func getMoodEmoji(_ mood: Int) -> String {
        switch mood {
        case 1: return "😔"
        case 2: return "😟"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    func formatCheckInDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    #if DEBUG
    var testNotificationButtons: some View {
        VStack(spacing: 15) {
            Text("🧪 Viral Notification Testing")
                .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                .foregroundColor(ColorTheme.accentCyan)
            
            // Main test buttons
            HStack(spacing: 10) {
                Button(action: {
                    ViralNotificationManager.shared.testNotifications()
                }) {
                    Text("Test All Phases")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ColorTheme.accentPurple)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    ViralNotificationManager.shared.cancelAllViralNotifications()
                }) {
                    Text("Cancel All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red)
                        .cornerRadius(12)
                }
            }
            
            // Individual phase test buttons
            VStack(spacing: 8) {
                Text("Test Individual Phases")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ColorTheme.textSecondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    // Phase 3: Milestone
                    Button(action: {
                        NotificationService.shared.scheduleMilestoneNotification(
                            userName: "Test User",
                            milestone: 30,
                            moneySaved: "$400",
                            hoursReclaimed: 90
                        )
                    }) {
                        Text("🏆 Milestone")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                    
                    // Phase 4: Savage
                    Button(action: {
                        NotificationService.shared.scheduleSavageMotivationNotifications(
                            userName: "Test User",
                            losses: ["Time", "Trust"],
                            afterFeeling: "Ashamed",
                            daysSober: 15
                        )
                    }) {
                        Text("💪 Savage")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    
                    // Phase 5: Fear Crusher
                    Button(action: {
                        NotificationService.shared.scheduleFearCrusherNotification(
                            userName: "Test User",
                            biggestFear: "Life will be boring",
                            daysSober: 20
                        )
                    }) {
                        Text("🦁 Fear")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    
                    // Phase 6: Wisdom
                    Button(action: {
                        NotificationService.shared.scheduleWisdomDropNotification()
                    }) {
                        Text("✨ Wisdom")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    #endif
}

#Preview {
    ProfileView()
        .environmentObject(DataService())
}