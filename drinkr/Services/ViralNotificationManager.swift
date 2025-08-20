import Foundation
import SwiftUI

// MARK: - Viral Notification Manager

class ViralNotificationManager: ObservableObject {
    static let shared = ViralNotificationManager()
    private let notificationService = NotificationService.shared
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Sets up Phase 1 & 2 notifications using onboarding data and current user status
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
        
        print("✅ Viral notifications setup complete!")
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
    
    private func calculateDaysSober(from quitDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        return max(components.day ?? 0, 0)
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
    
    // MARK: - Testing Methods
    
    func testNotifications() {
        print("🧪 Testing viral notifications...")
        
        // Test with sample data
        let sampleProfile = OnboardingUserProfile()
        var profile = sampleProfile
        profile.userName = "Alex"
        profile.triggers = ["Stress from work", "Loneliness"]
        profile.afterFeeling = "Ashamed and guilty"
        profile.weeklySpending = "$50-100"
        profile.checkInTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        
        let daysSober = 15
        
        // Schedule test daily check-in
        notificationService.schedulePersonalizedDailyCheckIn(
            userName: profile.userName,
            checkInTime: profile.checkInTime,
            daysSober: daysSober,
            weeklySpending: profile.weeklySpending
        )
        
        // Schedule test craving crushers
        notificationService.scheduleCravingCrusherNotifications(
            userName: profile.userName,
            triggers: profile.triggers,
            afterFeeling: profile.afterFeeling,
            daysSober: daysSober
        )
        
        print("✅ Test notifications scheduled!")
    }
    
    func cancelAllViralNotifications() {
        print("🛑 Cancelling all viral notifications...")
        notificationService.cancelDailyCheckInNotifications()
        notificationService.cancelCravingCrusherNotifications()
        print("✅ All viral notifications cancelled")
    }
}