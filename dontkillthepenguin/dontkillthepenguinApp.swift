//
//  dontkillthepenguinApp.swift
//  dontkillthepenguin
//
//  Created by Michael Chen on 11/4/23.
//

import SwiftUI
import SwiftData
import FamilyControls

@main
struct dontkillthepenguinApp: App {
    let center = AuthorizationCenter.shared
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
            ContentView().onAppear {
                Task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to authenticate with error: \(error)")
                    }
                }
            }
            .modelContainer(sharedModelContainer)
        }
    }
}
