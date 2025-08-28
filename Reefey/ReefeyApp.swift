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
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "EBGaramond-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "EBGaramond-Regular", size: 40) ?? UIFont.systemFont(ofSize: 40)]
    }
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
