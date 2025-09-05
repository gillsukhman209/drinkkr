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
            if !hasValidSubscriptionSession {
                // Show onboarding until BOTH completion AND subscription are done
                OnboardingContainerView(isPresented: $showingOnboarding)
                    .preferredColorScheme(.dark)
            } else {
                // Show main app only with atomic valid session
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    ProfileView()
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                        .tag(1)
                    
                    LibraryView()
                        .tabItem {
                            Label("Learn", systemImage: "graduationcap.fill")
                        }
                        .tag(2)
                    
                    SettingsView()
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
                // Update streak and refresh notifications when app becomes active
                refreshNotificationsWithCurrentStreak()
                
                // Check subscription status when app becomes active
                checkSubscriptionStatus()
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
        #if DEBUG
        .onLongPressGesture(minimumDuration: 3.0) {
            // Debug: Long press anywhere for 3 seconds to reset app state
            debugResetApp()
        }
        #endif
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if hasCompletedOnboarding {
            // Load onboarding profile data into data service if available
            if let data = UserDefaults.standard.data(forKey: "onboardingUserProfile"),
               let profile = try? JSONDecoder().decode(OnboardingUserProfile.self, from: data) {
                updateDataServiceWithProfile(profile)
                
                // Update streak before setting up notifications
                dataService.sobrietyData?.updateStreak()
                dataService.sobrietyData?.calculateStats()
                
                // Set up viral notifications for existing users with updated streak
                if let sobrietyData = dataService.sobrietyData {
                    ViralNotificationManager.shared.setupViralNotifications(sobrietyData: sobrietyData, onboardingProfile: profile)
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
        let newSessionState = hasCompletedOnboarding && superwallManager.isSubscribed
        
        if newSessionState != hasValidSubscriptionSession {
            hasValidSubscriptionSession = newSessionState
            if newSessionState {
                print("✅ ATOMIC: Valid subscription session established")
            } else {
                print("🔒 ATOMIC: Invalid session - blocking app access")
            }
        }
    }
    
    private func checkSubscriptionStatus() {
        // Only validate subscription if onboarding is complete
        guard hasCompletedOnboarding else { return }
        
        superwallManager.validateSubscription()
        
        // Update atomic session state
        updateValidSubscriptionSession()
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
        dataService.sobrietyData?.updateStreak()
        dataService.sobrietyData?.calculateStats()
        
        // Set up viral notifications with onboarding data and current streak
        if let sobrietyData = dataService.sobrietyData {
            ViralNotificationManager.shared.setupViralNotifications(sobrietyData: sobrietyData, onboardingProfile: profile)
        }
        
        hasCompletedOnboarding = true
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
        
        // Update sobriety data with quit date and preferences
        if let sobrietyData = dataService.sobrietyData {
            sobrietyData.quitDate = profile.quitDate
            // Update spending calculations based on onboarding data
            let weeklySpending = profile.weeklySpendingAmount
            let daysAlcoholFree = Calendar.current.dateComponents([.day], from: profile.quitDate, to: Date()).day ?? 0
            sobrietyData.moneySaved = weeklySpending * (Double(daysAlcoholFree) / 7.0)
            sobrietyData.drinksAvoided = profile.drinksPerSessionInt * max(1, daysAlcoholFree)
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
              let sobrietyData = dataService.sobrietyData else { return }
        
        // Update streak calculations
        sobrietyData.updateStreak()
        sobrietyData.calculateStats()
        
        // Update notifications with current streak
        ViralNotificationManager.shared.updateNotificationsWithCurrentStreak(sobrietyData: sobrietyData)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}
