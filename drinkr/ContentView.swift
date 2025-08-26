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
    @StateObject private var dataService = DataService()
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var hasInitialized = false
    @State private var showingOnboarding = false
    @State private var hasCompletedOnboarding = false
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.3)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
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
            } else {
                OnboardingContainerView(isPresented: $showingOnboarding)
                    .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            if !hasInitialized {
                hasInitialized = true
                checkOnboardingStatus()
                dataService.initialize(with: modelContext)
                NotificationService.shared.requestPermission()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { notification in
            if let profile = notification.object as? OnboardingUserProfile {
                handleOnboardingCompletion(profile)
            }
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if hasCompletedOnboarding {
            // Load onboarding profile data into data service if available
            if let data = UserDefaults.standard.data(forKey: "onboardingUserProfile"),
               let profile = try? JSONDecoder().decode(OnboardingUserProfile.self, from: data) {
                updateDataServiceWithProfile(profile)
                
                // Set up viral notifications for existing users
                if let sobrietyData = dataService.sobrietyData {
                    ViralNotificationManager.shared.setupViralNotifications(sobrietyData: sobrietyData, onboardingProfile: profile)
                }
            }
        }
    }
    
    private func handleOnboardingCompletion(_ profile: OnboardingUserProfile) {
        updateDataServiceWithProfile(profile)
        
        // Set up viral notifications with onboarding data
        if let sobrietyData = dataService.sobrietyData {
            ViralNotificationManager.shared.setupViralNotifications(sobrietyData: sobrietyData, onboardingProfile: profile)
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
            hasCompletedOnboarding = true
        }
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
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}
