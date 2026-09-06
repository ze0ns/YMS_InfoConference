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
    @State private var appState: AppState
    @State private var conferenceViewModel: ConferenceViewModel

    private let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            ConfDataModel.self,
            RoomModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        let state = AppState()
        let modelContainer = sharedModelContainer
        _appState = State(initialValue: state)
        _conferenceViewModel = State(
            initialValue: ConferenceViewModel(
                appState: state,
                modelContext: modelContainer.mainContext
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ConferenceRoomScreen(viewModel: conferenceViewModel)
        }
        .modelContainer(sharedModelContainer)
        .environment(appState)
        .environment(SettingsStore.shared)
    }
}