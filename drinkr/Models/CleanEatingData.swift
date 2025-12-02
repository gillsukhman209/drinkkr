import Foundation
import SwiftData

@Model
final class CleanEatingData {
    var id: UUID
    var quitDate: Date
    var relapses: [Relapse]
    var currentStreak: Int
    var longestStreak: Int
    var totalDaysClean: Int
    var pledgeCompletedToday: Bool
    var lastPledgeDate: Date?
    var moneySaved: Double
    var mealsAvoided: Int
    var caloriesSaved: Int
    var timeReclaimed: Double
    
    // User-specific metrics
    // User-specific metrics
    var costPerMeal: Double = 15.0
    var mealsPerDay: Double = 1.0
    var caloriesPerMeal: Int = 1000
    
    init(
        quitDate: Date = Date(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalDaysClean: Int = 0,
        pledgeCompletedToday: Bool = false,
        lastPledgeDate: Date? = nil,
        moneySaved: Double = 0,
        mealsAvoided: Int = 0,
        caloriesSaved: Int = 0,
        timeReclaimed: Double = 0,
        costPerMeal: Double = 15.0,
        mealsPerDay: Double = 1.0,
        caloriesPerMeal: Int = 1000
    ) {
        self.id = UUID()
        self.quitDate = quitDate
        self.relapses = []
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalDaysClean = totalDaysClean
        self.pledgeCompletedToday = pledgeCompletedToday
        self.lastPledgeDate = lastPledgeDate
        self.moneySaved = moneySaved

        self.mealsAvoided = mealsAvoided
        self.caloriesSaved = caloriesSaved
        self.timeReclaimed = timeReclaimed
        self.costPerMeal = costPerMeal
        self.mealsPerDay = mealsPerDay
        self.caloriesPerMeal = caloriesPerMeal
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let quitDay = calendar.startOfDay(for: quitDate)
        
        if let lastRelapse = relapses.last {
            let daysSinceRelapse = calendar.dateComponents([.day], from: lastRelapse.date, to: today).day ?? 0
            currentStreak = daysSinceRelapse
        } else {
            let daysSinceQuit = calendar.dateComponents([.day], from: quitDay, to: today).day ?? 0
            currentStreak = daysSinceQuit
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    func calculateStats() {
        let averageHoursWastedPerDay = 1.0
        
        // Use stored user metrics
        mealsAvoided = Int(Double(currentStreak) * mealsPerDay)
        moneySaved = Double(mealsAvoided) * costPerMeal
        caloriesSaved = mealsAvoided * caloriesPerMeal
        timeReclaimed = Double(currentStreak) * averageHoursWastedPerDay
    }
    
    func addRelapse() {
        let relapse = Relapse(date: Date())
        relapses.append(relapse)
        currentStreak = 0
        updateStreak()
    }
    
    func getTodayRelapseCount() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return relapses.filter { calendar.isDate($0.date, inSameDayAs: today) }.count
    }
}

@Model
final class Relapse {
    var id: UUID
    var date: Date
    var notes: String?
    var trigger: String?
    
    init(date: Date, notes: String? = nil, trigger: String? = nil) {
        self.id = UUID()
        self.date = date
        self.notes = notes
        self.trigger = trigger
    }
}
