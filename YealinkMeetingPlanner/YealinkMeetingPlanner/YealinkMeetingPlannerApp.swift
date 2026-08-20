//
//  YealinkMeetingPlannerApp.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//

import SwiftUI
import SwiftData

@main
struct YealinkMeetingPlannerApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ConfDataModel.self,
            RoomModel.self,
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
            ConferenceRoomScreen(
                viewModel: ConferenceViewModel(
                    modelContext: sharedModelContainer.mainContext
                )
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
