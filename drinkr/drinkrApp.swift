//
//  SobbrApp.swift
//  Sobbr
//
//  Created by Sukhman Singh on 8/14/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct SobbrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appStateManager = AppStateManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            SobrietyData.self,
            Achievement.self,
            Relapse.self,
            CheckIn.self,
            MeditationSession.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appStateManager)
                .onAppear {
                    // Note: AppStateManager handles notification delegation
                    print("🔔 SwiftUI app loaded - AppStateManager manages notifications")
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
