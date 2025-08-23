//
//  drinkrApp.swift
//  drinkr
//
//  Created by Sukhman Singh on 8/14/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct drinkrApp: App {
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
        }
        .modelContainer(sharedModelContainer)
    }
}
