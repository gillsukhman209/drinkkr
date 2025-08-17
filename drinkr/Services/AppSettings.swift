import Foundation

class AppSettings {
    static let shared = AppSettings()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        registerDefaults()
    }
    
    private func registerDefaults() {
        userDefaults.register(defaults: [
            Keys.hasCompletedOnboarding: false,
            Keys.notificationsEnabled: true,
            Keys.notificationHour: 9,
            Keys.notificationMinute: 0,
            Keys.soundEnabled: true,
            Keys.hapticsEnabled: true,
            Keys.totalPledges: 0,
            Keys.meditationCount: 0,
            Keys.lastLaunchDate: Date(),
            Keys.appLaunchCount: 0
        ])
    }
    
    private struct Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let notificationsEnabled = "notificationsEnabled"
        static let notificationHour = "notificationHour"
        static let notificationMinute = "notificationMinute"
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
        static let totalPledges = "totalPledges"
        static let meditationCount = "meditationCount"
        static let lastLaunchDate = "lastLaunchDate"
        static let appLaunchCount = "appLaunchCount"
    }
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    var notificationsEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.notificationsEnabled) }
        set { userDefaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }
    
    var notificationTime: (hour: Int, minute: Int) {
        get {
            (userDefaults.integer(forKey: Keys.notificationHour),
             userDefaults.integer(forKey: Keys.notificationMinute))
        }
        set {
            userDefaults.set(newValue.hour, forKey: Keys.notificationHour)
            userDefaults.set(newValue.minute, forKey: Keys.notificationMinute)
        }
    }
    
    var soundEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.soundEnabled) }
        set { userDefaults.set(newValue, forKey: Keys.soundEnabled) }
    }
    
    var hapticsEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.hapticsEnabled) }
        set { userDefaults.set(newValue, forKey: Keys.hapticsEnabled) }
    }
    
    var totalPledges: Int {
        get { userDefaults.integer(forKey: Keys.totalPledges) }
        set { userDefaults.set(newValue, forKey: Keys.totalPledges) }
    }
    
    var meditationCount: Int {
        get { userDefaults.integer(forKey: Keys.meditationCount) }
        set { userDefaults.set(newValue, forKey: Keys.meditationCount) }
    }
    
    var lastLaunchDate: Date? {
        get { userDefaults.object(forKey: Keys.lastLaunchDate) as? Date }
        set { userDefaults.set(newValue, forKey: Keys.lastLaunchDate) }
    }
    
    var appLaunchCount: Int {
        get { userDefaults.integer(forKey: Keys.appLaunchCount) }
        set { userDefaults.set(newValue, forKey: Keys.appLaunchCount) }
    }
    
    func incrementPledgeCount() {
        totalPledges += 1
    }
    
    func incrementMeditationCount() {
        meditationCount += 1
    }
    
    func incrementLaunchCount() {
        appLaunchCount += 1
        lastLaunchDate = Date()
    }
    
    func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
        registerDefaults()
    }
}