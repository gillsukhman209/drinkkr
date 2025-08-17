import Foundation
import SwiftData

@Model
final class SobrietyData {
    var id: UUID
    var quitDate: Date
    var relapses: [Relapse]
    var currentStreak: Int
    var longestStreak: Int
    var totalDaysSober: Int
    var pledgeCompletedToday: Bool
    var lastPledgeDate: Date?
    var moneySaved: Double
    var drinksAvoided: Int
    var caloriesSaved: Int
    var timeReclaimed: Double
    
    init(
        quitDate: Date = Date(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalDaysSober: Int = 0,
        pledgeCompletedToday: Bool = false,
        lastPledgeDate: Date? = nil,
        moneySaved: Double = 0,
        drinksAvoided: Int = 0,
        caloriesSaved: Int = 0,
        timeReclaimed: Double = 0
    ) {
        self.id = UUID()
        self.quitDate = quitDate
        self.relapses = []
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalDaysSober = totalDaysSober
        self.pledgeCompletedToday = pledgeCompletedToday
        self.lastPledgeDate = lastPledgeDate
        self.moneySaved = moneySaved
        self.drinksAvoided = drinksAvoided
        self.caloriesSaved = caloriesSaved
        self.timeReclaimed = timeReclaimed
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
        let averageDrinksPerDay = 3.0
        let averageCostPerDrink = 10.0
        let averageCaloriesPerDrink = 150
        let averageHoursWastedPerDay = 2.0
        
        drinksAvoided = currentStreak * Int(averageDrinksPerDay)
        moneySaved = Double(drinksAvoided) * averageCostPerDrink
        caloriesSaved = drinksAvoided * averageCaloriesPerDrink
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