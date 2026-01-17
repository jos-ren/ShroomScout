//
//  ShroomScoutApp.swift
//  ShroomScout
//
//  Created by Joshua Renema on 2026-01-16.
//

import SwiftUI
import SwiftData

@main
struct ShroomScoutApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Species.self,
            Sighting.self,
            UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

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
