//
//  ContentView.swift
//  Sobbr
//
//  Created by Sukhman Singh on 8/14/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var dataService = DataService()
    @StateObject private var superwallManager = SuperwallManager.shared
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var hasInitialized = false
    @State private var showingOnboarding = false
    @State private var hasCompletedOnboarding = false
    @State private var hasValidSubscriptionSession = false // ATOMIC: onboarding complete AND subscribed
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.3)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        Group {
            if false { // !hasValidSubscriptionSession {
                // Show onboarding until BOTH completion AND subscription are done
                OnboardingContainerView(isPresented: $showingOnboarding)
                    .preferredColorScheme(.dark)
            } else {
                // Show main app only with atomic valid session
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        DashboardView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        LibraryView()
                    }
                    .tabItem {
                        Label("Learn", systemImage: "graduationcap.fill")
                    }
                    .tag(2)
                    
                    NavigationStack {
                        SettingsView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
                }
                .accentColor(.cyan)
                .preferredColorScheme(.dark)
                .environmentObject(dataService)
                .sheet(isPresented: $appStateManager.showCheckInModal) {
                    CheckInModal(isPresented: $appStateManager.showCheckInModal)
                        .environmentObject(dataService)
                }
            }
        }

        .onAppear {
            if !hasInitialized {
                hasInitialized = true
                checkOnboardingStatus()
                dataService.initialize(with: modelContext)
                NotificationService.shared.requestPermission()
                
                // Initialize SuperwallManager
                superwallManager.configure()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Only update when absolutely necessary
                Task {
                    await MainActor.run {
                        checkSubscriptionStatus()
                        dataService.refreshStats()
                    }
                }
            }
        }
        .onChange(of: superwallManager.isSubscribed) { _, isSubscribed in
            // ATOMIC: Only allow app access if BOTH onboarding complete AND subscribed
            updateValidSubscriptionSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { notification in
            if let profile = notification.object as? OnboardingUserProfile {
                handleOnboardingCompletion(profile)
            }
        }
        .onOpenURL { url in
            print("🔗 [CONTENTVIEW] onOpenURL called with: \(url)")
            handleDeepLink(url)
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if hasCompletedOnboarding {
            // Load onboarding profile data into data service if available
            if let data = UserDefaults.standard.data(forKey: "onboardingUserProfile"),
               let profile = try? JSONDecoder().decode(OnboardingUserProfile.self, from: data) {
                updateDataServiceWithProfile(profile)
                
                // Update streak before setting up notifications
                dataService.cleanEatingData?.updateStreak()
                dataService.cleanEatingData?.calculateStats()
                
                // Only set up viral notifications for existing users with valid subscription
                if superwallManager.hasValidSubscription(), let cleanEatingData = dataService.cleanEatingData {
                    print("✅ Existing user has valid subscription - setting up viral notifications")
                    ViralNotificationManager.shared.setupViralNotifications(cleanEatingData: cleanEatingData, onboardingProfile: profile)
                } else {
                    print("⚠️ Existing user has no valid subscription - skipping viral notifications setup")
                }
                
                // Check if subscription is needed
                checkSubscriptionStatus()
            }
        }
        // Update atomic session state
        updateValidSubscriptionSession()
    }
    
    // ATOMIC SESSION MANAGEMENT - Prevents all bypass exploits
    private func updateValidSubscriptionSession() {
        // BYPASS: Temporarily disabled subscription check for free access
        let newSessionState = hasCompletedOnboarding // && superwallManager.isSubscribed
        
        if newSessionState != hasValidSubscriptionSession {
            hasValidSubscriptionSession = newSessionState
            if newSessionState {
                print("✅ ATOMIC: Valid subscription session established (FREE MODE)")
            } else {
                print("🔒 ATOMIC: Invalid session - blocking app access")
            }
        }
    }
    
    private func checkSubscriptionStatus() {
        // Only validate subscription if onboarding is complete
        guard hasCompletedOnboarding else { return }
        
        // Rate limit subscription checks to prevent lag
        Task.detached {
            await superwallManager.validateSubscription()
            await MainActor.run {
                updateValidSubscriptionSession()
            }
        }
    }
    
    // Debug function to reset everything (for testing/fixing stuck states)
    #if DEBUG
    private func debugResetApp() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingUserProfile")
        superwallManager.debugRemoveSubscription()
        hasCompletedOnboarding = false
        hasValidSubscriptionSession = false
        print("🐛 DEBUG: App state reset")
    }
    #endif
    
    private func handleOnboardingCompletion(_ profile: OnboardingUserProfile) {
        updateDataServiceWithProfile(profile)
        
        // Update streak before setting up notifications
        dataService.cleanEatingData?.updateStreak()
        dataService.cleanEatingData?.calculateStats()
        
        // Only set up viral notifications if user has a valid subscription
        if superwallManager.hasValidSubscription(), let cleanEatingData = dataService.cleanEatingData {
            print("✅ User has valid subscription - setting up viral notifications")
            ViralNotificationManager.shared.setupViralNotifications(cleanEatingData: cleanEatingData, onboardingProfile: profile)
        } else {
            print("⚠️ User has no valid subscription - skipping viral notifications setup")
        }
        
        hasCompletedOnboarding = true
        
        // Count the onboarding commitment as the first pledge
        AppSettings.shared.incrementPledgeCount()
        
        // Update atomic session state - will only allow app access if also subscribed
        updateValidSubscriptionSession()
    }
    
    private func updateDataServiceWithProfile(_ profile: OnboardingUserProfile) {
        // Update data service with onboarding information
        // This will customize the money saved calculations and other metrics
        
        // Create or update user with onboarding data
        if let user = dataService.currentUser {
            user.name = profile.userName.isEmpty ? "User" : profile.userName
            // Add other profile updates as needed
        }
        
        // Update clean eating data with quit date and preferences
        if let cleanEatingData = dataService.cleanEatingData {
            cleanEatingData.quitDate = profile.quitDate
            
            // Update spending calculations based on onboarding data
            let weeklySpending = profile.weeklySpendingAmount
            let mealsPerWeek = profile.mealsPerWeekInt
            
            // Calculate and store user-specific metrics
            let mealsPerDay = Double(mealsPerWeek) / 7.0
            let calculatedCostPerMeal = mealsPerWeek > 0 ? weeklySpending / Double(mealsPerWeek) : 15.0
            // Ensure we never have 0 cost per meal (fallback to default $15 if calculation fails)
            let costPerMeal = calculatedCostPerMeal > 0 ? calculatedCostPerMeal : 15.0
            
            cleanEatingData.mealsPerDay = mealsPerDay
            cleanEatingData.costPerMeal = costPerMeal
            
            print("💰 DEBUG: Calculated metrics - Weekly Spending: \(weeklySpending), Meals/Week: \(mealsPerWeek)")
            print("💰 DEBUG: Derived metrics - Cost/Meal: \(costPerMeal), Meals/Day: \(mealsPerDay)")
            
            // Recalculate stats immediately
            cleanEatingData.calculateStats()
        }
        
        // Save to persistent storage
        try? modelContext.save()
    }
    
    // Debug function to reset onboarding (for testing)
    func resetOnboardingForTesting() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingUserProfile")
        hasCompletedOnboarding = false
    }
    
    private func refreshNotificationsWithCurrentStreak() {
        guard hasCompletedOnboarding,
              let cleanEatingData = dataService.cleanEatingData else { return }
        
        // Update streak calculations
        cleanEatingData.updateStreak()
        cleanEatingData.calculateStats()
        
        // Update notifications with current streak
        ViralNotificationManager.shared.updateNotificationsWithCurrentStreak(cleanEatingData: cleanEatingData)
    }
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 [CONTENTVIEW] Handling deep link: \(url)")
        
        // Check if it's our retention notification deep link
        if url.scheme == "drinkr" && url.host == "retention" {
            let placement = url.pathComponents.count > 1 ? url.pathComponents[1] : "default_paywall"
            print("🎯 [CONTENTVIEW] Retention deep link - presenting placement: \(placement)")
            SuperwallManager.shared.presentPlacement(placement)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}
