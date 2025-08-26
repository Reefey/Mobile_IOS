//
//  ReefeyApp.swift
//  Reefey
//
//  Created by Reza Juliandri on 15/08/25.
//

import SwiftUI
import SwiftData

@main
struct ReefeyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UnidentifiedImageModel.self
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
