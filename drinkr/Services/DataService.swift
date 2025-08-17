import Foundation
import SwiftData
import SwiftUI

@MainActor
class DataService: ObservableObject {
    private var modelContext: ModelContext?
    
    @Published var currentUser: User?
    @Published var sobrietyData: SobrietyData?
    @Published var achievements: [Achievement] = []
    
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
            let newUser = User(name: "John Doe")
            modelContext.insert(newUser)
            currentUser = newUser
        }
        
        let sobrietyDescriptor = FetchDescriptor<SobrietyData>()
        if let sobrietyDatas = try? modelContext.fetch(sobrietyDescriptor), let data = sobrietyDatas.first {
            sobrietyData = data
            sobrietyData?.updateStreak()
            sobrietyData?.calculateStats()
        } else {
            let newSobrietyData = SobrietyData(quitDate: Date().addingTimeInterval(-86400 * 3))
            newSobrietyData.updateStreak()
            newSobrietyData.calculateStats()
            modelContext.insert(newSobrietyData)
            sobrietyData = newSobrietyData
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
        
        try? modelContext.save()
    }
    
    func updateUserName(_ name: String) {
        currentUser?.name = name
        saveContext()
    }
    
    func completePledge() {
        // This function is now deprecated - keeping for compatibility
        // Pledge functionality has been changed to check-in notifications
        AppSettings.shared.incrementPledgeCount()
        saveContext()
        updateAchievementProgress()
    }
    
    func recordRelapse() {
        guard let sobrietyData = sobrietyData else { return }
        
        // Add the relapse
        sobrietyData.addRelapse()
        
        // Reset the quit date to now (starting fresh)
        sobrietyData.quitDate = Date()
        
        // Update all calculations
        sobrietyData.updateStreak()
        sobrietyData.calculateStats()
        
        saveContext()
        updateAchievementProgress()
    }
    
    func resetProgress() {
        guard let modelContext = modelContext else { return }
        
        if let sobrietyData = sobrietyData {
            sobrietyData.quitDate = Date()
            sobrietyData.relapses = []
            sobrietyData.currentStreak = 0
            sobrietyData.longestStreak = 0
            sobrietyData.totalDaysSober = 0
            sobrietyData.pledgeCompletedToday = false
            sobrietyData.lastPledgeDate = nil
            sobrietyData.moneySaved = 0
            sobrietyData.drinksAvoided = 0
            sobrietyData.caloriesSaved = 0
            sobrietyData.timeReclaimed = 0
        }
        
        for achievement in achievements {
            achievement.currentValue = 0
            achievement.isUnlocked = false
            achievement.dateEarned = nil
        }
        
        saveContext()
    }
    
    func updateSobrietyDate(_ date: Date) {
        sobrietyData?.quitDate = date
        sobrietyData?.updateStreak()
        sobrietyData?.calculateStats()
        saveContext()
        updateAchievementProgress()
    }
    
    private func updateAchievementProgress() {
        guard let sobrietyData = sobrietyData else { return }
        
        for achievement in achievements {
            switch achievement.category {
            case .streak, .milestone:
                achievement.checkProgress(sobrietyData.currentStreak)
            case .savings:
                achievement.checkProgress(Int(sobrietyData.moneySaved))
            case .health:
                achievement.checkProgress(sobrietyData.caloriesSaved)
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
        // Log the check-in (you can expand this to save detailed data)
        print("Check-in logged: Mood \(mood)/5, Notes: \(notes)")
        
        // Update last check-in date
        if let user = currentUser {
            user.lastCheckInDate = Date()
            saveContext()
        }
    }
    
    private func saveContext() {
        guard let modelContext = modelContext else { return }
        try? modelContext.save()
    }
    
    func getTimeComponents() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        guard let sobrietyData = sobrietyData else {
            return (0, 0, 0, 0)
        }
        
        let interval = Date().timeIntervalSince(sobrietyData.quitDate)
        let days = Int(interval) / 86400
        let hours = Int(interval) % 86400 / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        return (days, hours, minutes, seconds)
    }
    
    func getWeekProgress() -> [Bool] {
        guard let sobrietyData = sobrietyData else {
            return Array(repeating: false, count: 7)
        }
        
        let currentStreak = sobrietyData.currentStreak
        return (0..<7).map { $0 < currentStreak }
    }
}