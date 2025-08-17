//
//  ContentView.swift
//  drinkr
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
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.3)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
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
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark)
        .environmentObject(dataService)
        .onAppear {
            dataService.initialize(with: modelContext)
            NotificationService.shared.requestPermission()
        }
        .sheet(isPresented: $appStateManager.showCheckInModal) {
            CheckInModal(isPresented: $appStateManager.showCheckInModal)
                .environmentObject(dataService)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}
