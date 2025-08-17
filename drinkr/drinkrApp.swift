//
//  drinkrApp.swift
//  drinkr
//
//  Created by Sukhman Singh on 8/14/25.
//

import SwiftUI
import SwiftData

@main
struct drinkrApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            SobrietyData.self,
            Achievement.self,
            Relapse.self
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
        }
        .modelContainer(sharedModelContainer)
    }
}
