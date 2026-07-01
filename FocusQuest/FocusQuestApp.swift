//
//  FocusQuestApp.swift
//  FocusQuest
//
//  Created by Fedor Donskov on 30.06.2026.
//

import SwiftUI
import SwiftData

@main
struct FocusQuestApp: App {
    @State private var settings = AppSettings()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Character.self,
            FocusSession.self,
            InventoryItem.self,
            Achievement.self,
            Location.self,
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
                .environment(settings)
        }
        .modelContainer(sharedModelContainer)
    }
}
