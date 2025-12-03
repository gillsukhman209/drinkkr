import Foundation
import SwiftData
import SwiftUI

@MainActor
class DataService: ObservableObject {
    private var modelContext: ModelContext?
    
    @Published var currentUser: User?
    @Published var cleanEatingData: CleanEatingData?
    @Published var achievements: [Achievement] = []
    @Published var checkIns: [CheckIn] = []
    @Published var meditationSessions: [MeditationSession] = []
    @Published var dailyTasks: [FocusTask] = []
    
    init() {
        
    }
    
    func initialize(with context: ModelContext) {
        self.modelContext = context
        loadOrCreateData()
    }
    
    private func loadOrCreateData() {
        guard let modelContext = modelContext else { return }
        
        let userDescriptor = FetchDescriptor<User>()
        if let users = try? modelContext.fetch(userDescriptor), let user = users.first {
            currentUser = user
        } else {
            let newUser = User(name: "Singh")
            modelContext.insert(newUser)
            currentUser = newUser
        }
        
        let cleanEatingDescriptor = FetchDescriptor<CleanEatingData>()
        if let data = try? modelContext.fetch(cleanEatingDescriptor).first {
            cleanEatingData = data
            cleanEatingData?.updateStreak()
            cleanEatingData?.calculateStats()
            
            // Store quit date and last relapse in UserDefaults for notifications
            syncCleanEatingDataToUserDefaults()
        } else {
            // Create initial data if none exists
            let newCleanEatingData = CleanEatingData(quitDate: Date())
            newCleanEatingData.updateStreak()
            newCleanEatingData.calculateStats()
            modelContext.insert(newCleanEatingData)
            cleanEatingData = newCleanEatingData
            
            // Store quit date and last relapse in UserDefaults for notifications
            syncCleanEatingDataToUserDefaults()
        }
        
        let achievementDescriptor = FetchDescriptor<Achievement>()
        if let existingAchievements = try? modelContext.fetch(achievementDescriptor), !existingAchievements.isEmpty {
            achievements = existingAchievements
        } else {
            let defaultAchievements = AchievementManager.getDefaultAchievements()
            for achievement in defaultAchievements {
                modelContext.insert(achievement)
            }
            achievements = defaultAchievements
        }
        
        updateAchievementProgress()
        
        // Load check-ins, meditation sessions, and daily tasks
        loadCheckIns()
        loadMeditationSessions()
        loadDailyTasks()
        
        try? modelContext.save()
    }
    
    func updateUserName(_ name: String) {
        currentUser?.name = name
        saveContext()
    }
    
    func updateCostPerMeal(_ cost: Double) {
        cleanEatingData?.costPerMeal = cost
        cleanEatingData?.calculateStats()
        updateAchievementProgress()
        saveContext()
        objectWillChange.send()
    }
    
    func completePledge() {
        // Increment pledge count in AppSettings
        AppSettings.shared.incrementPledgeCount()
        
        // Mark pledge as completed for today in CleanEatingData
        if let cleanEatingData = cleanEatingData {
            cleanEatingData.pledgeCompletedToday = true
            cleanEatingData.lastPledgeDate = Date()
        }
        
        saveContext()
        updateAchievementProgress()
    }
    
    func recordRelapse() {
        guard let cleanEatingData = cleanEatingData else { return }
        
        // Add the relapse
        cleanEatingData.addRelapse()
        
        // Reset the quit date to now (starting fresh)
        cleanEatingData.quitDate = Date()
        
        // Update all calculations
        cleanEatingData.updateStreak()
        cleanEatingData.calculateStats()
        
        // Sync to UserDefaults for notifications
        syncCleanEatingDataToUserDefaults()
        
        saveContext()
        updateAchievementProgress()
    }
    
    func resetProgress() {
        guard let modelContext = modelContext else { return }
        
        if let cleanEatingData = cleanEatingData {
            cleanEatingData.quitDate = Date()
            cleanEatingData.relapses = []
            cleanEatingData.currentStreak = 0
            cleanEatingData.longestStreak = 0
            cleanEatingData.totalDaysClean = 0
            cleanEatingData.pledgeCompletedToday = false
            cleanEatingData.lastPledgeDate = nil
            cleanEatingData.moneySaved = 0
            cleanEatingData.mealsAvoided = 0
            cleanEatingData.caloriesSaved = 0
            cleanEatingData.timeReclaimed = 0
        }
        
        for achievement in achievements {
            achievement.currentValue = 0
            achievement.isUnlocked = false
            achievement.dateEarned = nil
        }
        
        saveContext()
    }
    
    func updateCleanEatingDate(_ date: Date) {
        cleanEatingData?.quitDate = date
        cleanEatingData?.updateStreak()
        cleanEatingData?.calculateStats()
        
        // Sync to UserDefaults for notifications
        syncCleanEatingDataToUserDefaults()
        
        saveContext()
        updateAchievementProgress()
    }
    
    func refreshStats() {
        objectWillChange.send()
        cleanEatingData?.updateStreak()
        cleanEatingData?.calculateStats()
        updateAchievementProgress()
    }
    
    private func updateAchievementProgress() {
        guard let cleanEatingData = cleanEatingData else { return }
        
        for achievement in achievements {
            switch achievement.category {
            case .streak, .milestone:
                achievement.checkProgress(cleanEatingData.currentStreak)
            case .savings:
                achievement.checkProgress(Int(cleanEatingData.moneySaved))
            case .health:
                achievement.checkProgress(cleanEatingData.caloriesSaved)
            case .community:
                if achievement.title == "Pledge Keeper" {
                    let pledgeCount = calculatePledgeCount()
                    achievement.checkProgress(pledgeCount)
                }
            case .meditation:
                break
            }
        }
        
        saveContext()
    }
    
    private func calculatePledgeCount() -> Int {
        return AppSettings.shared.totalPledges
    }
    
    func incrementMeditationCount() {
        AppSettings.shared.incrementMeditationCount()
        let currentCount = AppSettings.shared.meditationCount
        
        for achievement in achievements where achievement.category == .meditation {
            achievement.checkProgress(currentCount)
        }
        
        saveContext()
    }
    
    func logCheckIn(mood: Int, notes: String) {
        guard let modelContext = modelContext else { return }
        
        // Create and save new check-in
        let checkIn = CheckIn(mood: mood, notes: notes, timestamp: Date())
        modelContext.insert(checkIn)
        
        // Update local array
        checkIns.append(checkIn)
        checkIns.sort { $0.timestamp > $1.timestamp } // Keep sorted by newest first
        
        // Update last check-in date
        if let user = currentUser {
            user.lastCheckInDate = Date()
        }
        
        saveContext()
    }
    
    func saveMeditationSession(duration: Int) {
        guard let modelContext = modelContext else { return }
        
        // Create and save new meditation session
        let session = MeditationSession(duration: duration, timestamp: Date(), completed: true)
        modelContext.insert(session)
        
        // Update local array
        meditationSessions.append(session)
        meditationSessions.sort { $0.timestamp > $1.timestamp } // Keep sorted by newest first
        
        // Also increment the meditation count for achievements
        incrementMeditationCount()
        
        saveContext()
    }
    
    func loadCheckIns() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        if let fetchedCheckIns = try? modelContext.fetch(descriptor) {
            checkIns = fetchedCheckIns
        }
    }
    
    func loadMeditationSessions() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<MeditationSession>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        if let fetchedSessions = try? modelContext.fetch(descriptor) {
            meditationSessions = fetchedSessions
        }
    }
    
    func loadDailyTasks() {
        guard let modelContext = modelContext else { return }
        
        // Fetch tasks for today
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<FocusTask>(
            predicate: #Predicate<FocusTask> { task in
                task.date >= startOfDay && task.date < endOfDay
            }
        )
        
        if let tasks = try? modelContext.fetch(descriptor), !tasks.isEmpty {
            dailyTasks = tasks
        } else {
            generateDailyTasks()
        }
    }
    
    func generateDailyTasks() {
        guard let modelContext = modelContext else { return }
        
        // Clear old tasks from memory (optional: could delete from DB if we don't want history)
        dailyTasks = []
        
        let streak = cleanEatingData?.currentStreak ?? 0
        var newTasks: [FocusTask] = []
        
        if streak < 3 {
            newTasks = [
                FocusTask(title: "Hydrate", subtitle: "Drink 8 glasses of water", icon: "drop.fill"),
                FocusTask(title: "Healthy Swap", subtitle: "Replace one fast food meal", icon: "leaf.fill"),
                FocusTask(title: "Reflection", subtitle: "Write down your 'Why'", icon: "pencil")
            ]
        } else if streak < 7 {
            newTasks = [
                FocusTask(title: "Meal Prep", subtitle: "Plan tomorrow's lunch", icon: "calendar"),
                FocusTask(title: "Movement", subtitle: "15 min walk after dinner", icon: "figure.walk"),
                FocusTask(title: "Mindfulness", subtitle: "5 min breathing exercise", icon: "lungs.fill")
            ]
        } else {
            newTasks = [
                FocusTask(title: "New Recipe", subtitle: "Try cooking something new", icon: "fork.knife"),
                FocusTask(title: "Share Success", subtitle: "Tell a friend your progress", icon: "message.fill"),
                FocusTask(title: "Reward", subtitle: "Treat yourself (non-food)", icon: "gift.fill")
            ]
        }
        
        for task in newTasks {
            modelContext.insert(task)
            dailyTasks.append(task)
        }
        
        saveContext()
    }
    
    func toggleTask(_ task: FocusTask) {
        task.isCompleted.toggle()
        saveContext()
        objectWillChange.send()
    }
    
    private func saveContext() {
        guard let modelContext = modelContext else { return }
        try? modelContext.save()
    }
    
    func getTimeComponents() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        guard let cleanEatingData = cleanEatingData else {
            return (0, 0, 0, 0)
        }
        
        // Use debug time if available, otherwise use real time
        #if DEBUG
        let currentTime = DebugTimeManager.shared.getCurrentTime()
        #else
        let currentTime = Date()
        #endif
        
        let interval = currentTime.timeIntervalSince(cleanEatingData.quitDate)
        let days = Int(interval) / 86400
        let hours = Int(interval) % 86400 / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        return (days, hours, minutes, seconds)
    }
    
    func getWeekProgress() -> [Bool] {
        guard let cleanEatingData = cleanEatingData else {
            return Array(repeating: false, count: 7)
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of the current week (Monday)
        // Note: weekday 1 is Sunday, 2 is Monday
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        guard let startOfWeek = calendar.date(from: components) else {
            return Array(repeating: false, count: 7)
        }
        
        var progress: [Bool] = []
        
        // Check each day of the week (Mon-Sun)
        for dayOffset in 0..<7 {
            guard let dateToCheck = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                progress.append(false)
                continue
            }
            
            // If date is in the future, it's not completed
            if dateToCheck > today {
                progress.append(false)
                continue
            }
            
            // Check if date is after quit date
            let isAfterQuitDate = dateToCheck >= calendar.startOfDay(for: cleanEatingData.quitDate)
            
            // Check if there was a relapse on this day
            let hasRelapse = cleanEatingData.relapses.contains { relapse in
                calendar.isDate(relapse.date, inSameDayAs: dateToCheck)
            }
            
            progress.append(isAfterQuitDate && !hasRelapse)
        }
        
        return progress
    }
    
    // MARK: - UserDefaults Sync for Notifications
    
    private func syncCleanEatingDataToUserDefaults() {
        guard let cleanEatingData = cleanEatingData else { return }
        
        // Store quit date for notification calculations
        UserDefaults.standard.set(cleanEatingData.quitDate, forKey: "cleanEatingQuitDate")
        
        // Store last relapse date if any
        if let lastRelapse = cleanEatingData.relapses.last {
            UserDefaults.standard.set(lastRelapse.date, forKey: "lastRelapseDate")
        } else {
            UserDefaults.standard.removeObject(forKey: "lastRelapseDate")
        }
        
        // Store current streak for quick access
        UserDefaults.standard.set(cleanEatingData.currentStreak, forKey: "currentStreak")
        
        print("✅ Synced clean eating data to UserDefaults - Quit date: \(cleanEatingData.quitDate), Current streak: \(cleanEatingData.currentStreak)")
    }
}