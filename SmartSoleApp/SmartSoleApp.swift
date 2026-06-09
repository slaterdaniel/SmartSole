//
//  SmartSoleApp.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/6/26.
//

import SwiftUI
import SwiftData

@main
struct SmartSoleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            Homepage()
        }
        .modelContainer(sharedModelContainer)
    }
}

