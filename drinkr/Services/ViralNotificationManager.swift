import Foundation
import SwiftUI

// MARK: - Viral Notification Manager

class ViralNotificationManager: ObservableObject {
    static let shared = ViralNotificationManager()
    private let notificationService = NotificationService.shared
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Sets up ALL Phase 1-6 notifications using onboarding data and current user status
    func setupViralNotifications(sobrietyData: SobrietyData, onboardingProfile: OnboardingUserProfile) {
        print("🚀 Setting up viral notifications for \(onboardingProfile.userName)")
        
        let daysSober = sobrietyData.currentStreak
        
        // Phase 1: Daily Check-In
        setupDailyCheckIn(
            sobrietyData: sobrietyData, 
            profile: onboardingProfile, 
            daysSober: daysSober
        )
        
        // Phase 2: Craving Crushers  
        setupCravingCrushers(
            profile: onboardingProfile, 
            daysSober: daysSober
        )
        
        // Phase 3: Milestone Celebrations
        checkAndScheduleMilestone(
            sobrietyData: sobrietyData,
            profile: onboardingProfile
        )
        
        // Phase 4: Savage Motivation
        setupSavageMotivation(
            profile: onboardingProfile,
            daysSober: daysSober
        )
        
        // Phase 5: Fear Crusher
        setupFearCrusher(
            profile: onboardingProfile,
            daysSober: daysSober
        )
        
        // Phase 6: Wisdom Drops
        setupWisdomDrops()
        
        print("✅ All 6 phases of viral notifications setup complete!")
    }
    
    /// Updates notifications with current streak data (call daily)
    func updateNotificationsWithCurrentStreak(sobrietyData: SobrietyData) {
        guard let profile = loadOnboardingProfile() else {
            print("❌ No onboarding profile found for notification update")
            return
        }
        
        let daysSober = sobrietyData.currentStreak
        print("🔄 Updating notifications with current streak: \(daysSober) days")
        
        // Update daily check-in with current streak
        notificationService.schedulePersonalizedDailyCheckIn(
            userName: profile.userName,
            checkInTime: profile.checkInTime,
            daysSober: daysSober,
            weeklySpending: profile.weeklySpending
        )
        
        // Update craving crushers with current streak
        notificationService.scheduleCravingCrusherNotifications(
            userName: profile.userName,
            triggers: profile.triggers,
            afterFeeling: profile.afterFeeling,
            daysSober: daysSober
        )
    }
    
    // MARK: - Private Implementation
    
    private func setupDailyCheckIn(sobrietyData: SobrietyData, profile: OnboardingUserProfile, daysSober: Int) {
        print("📅 Setting up daily check-in at \(formatTime(profile.checkInTime))")
        
        notificationService.schedulePersonalizedDailyCheckIn(
            userName: profile.userName,
            checkInTime: profile.checkInTime,
            daysSober: daysSober,
            weeklySpending: profile.weeklySpending
        )
    }
    
    private func setupCravingCrushers(profile: OnboardingUserProfile, daysSober: Int) {
        print("💥 Setting up craving crusher notifications")
        print("📝 User triggers: \(profile.triggers.joined(separator: ", "))")
        print("😔 After feeling: \(profile.afterFeeling)")
        
        notificationService.scheduleCravingCrusherNotifications(
            userName: profile.userName,
            triggers: profile.triggers,
            afterFeeling: profile.afterFeeling,
            daysSober: daysSober
        )
    }
    
    // MARK: - Phase 3: Milestone Celebrations
    
    private func checkAndScheduleMilestone(sobrietyData: SobrietyData, profile: OnboardingUserProfile) {
        print("🏆 Checking for milestone achievements")
        
        let milestones = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        let currentStreak = sobrietyData.currentStreak
        
        // Check if current streak matches any milestone
        if milestones.contains(currentStreak) {
            let moneySaved = calculateMoneySaved(profile: profile, days: currentStreak)
            let hoursReclaimed = currentStreak * 3 // Estimate 3 hours per day reclaimed
            
            notificationService.scheduleMilestoneNotification(
                userName: profile.userName,
                milestone: currentStreak,
                moneySaved: moneySaved,
                hoursReclaimed: hoursReclaimed
            )
        }
    }
    
    // MARK: - Phase 4: Savage Motivation
    
    private func setupSavageMotivation(profile: OnboardingUserProfile, daysSober: Int) {
        print("💪 Setting up savage motivation notifications")
        print("📝 User losses: \(profile.losses.joined(separator: ", "))")
        print("😔 After feeling: \(profile.afterFeeling)")
        
        notificationService.scheduleSavageMotivationNotifications(
            userName: profile.userName,
            losses: profile.losses,
            afterFeeling: profile.afterFeeling,
            daysSober: daysSober
        )
    }
    
    // MARK: - Phase 5: Fear Crusher
    
    private func setupFearCrusher(profile: OnboardingUserProfile, daysSober: Int) {
        print("🦁 Setting up fear crusher notifications")
        print("😨 Biggest fear: \(profile.biggestFear)")
        
        notificationService.scheduleFearCrusherNotification(
            userName: profile.userName,
            biggestFear: profile.biggestFear,
            daysSober: daysSober
        )
    }
    
    // MARK: - Phase 6: Wisdom Drops
    
    private func setupWisdomDrops() {
        print("✨ Setting up wisdom drop notifications")
        notificationService.scheduleWisdomDropNotification()
    }
    
    private func calculateDaysSober(from quitDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        return max(components.day ?? 0, 0)
    }
    
    private func calculateMoneySaved(profile: OnboardingUserProfile, days: Int) -> String {
        let weeklyAmount = profile.weeklySpendingAmount
        let dailyAmount = weeklyAmount / 7.0
        let total = dailyAmount * Double(days)
        return "$\(Int(total))"
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadOnboardingProfile() -> OnboardingUserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "onboardingUserProfile"),
              let profile = try? JSONDecoder().decode(OnboardingUserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    func cancelAllViralNotifications() {
        print("🛑 Cancelling all viral notifications...")
        notificationService.cancelDailyCheckInNotifications()
        notificationService.cancelCravingCrusherNotifications()
        notificationService.cancelMilestoneNotifications()
        notificationService.cancelSavageMotivationNotifications()
        notificationService.cancelFearCrusherNotifications()
        notificationService.cancelWisdomDropNotifications()
        print("✅ All 6 phases of viral notifications cancelled")
    }
}