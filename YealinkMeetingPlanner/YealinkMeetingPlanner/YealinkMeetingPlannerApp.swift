//
//  YealinkMeetingPlannerApp.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//

import SwiftUI
import SwiftData
import os

@main
struct YealinkMeetingPlannerApp: App {
    @State private var appState = AppState()

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ConfDataModel.self,
            RoomModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try Self.makeModelContainer(schema: schema, configuration: modelConfiguration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ConferenceRoomScreen(
                viewModel: ConferenceViewModel(
                    appState: appState,
                    modelContext: sharedModelContainer.mainContext
                )
            )
        }
        .modelContainer(sharedModelContainer)
        .environment(appState)
    }

    // MARK: - Хранилище SwiftData

    /// Создаёт контейнер; если сохранённое хранилище несовместимо со схемой
    /// (например, после обновления приложения со старой версией модели),
    /// сбрасывает кэш и пробует снова. Кэш расписания и комнат полностью
    /// перезагружается с сервера, поэтому сброс безопасен.
    private static func makeModelContainer(schema: Schema, configuration: ModelConfiguration) throws -> ModelContainer {
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            AppLog.storage.error("Хранилище несовместимо со схемой, сбрасываю кэш: \(error.localizedDescription, privacy: .public)")
            resetPersistentStore(at: configuration.url)
            return try ModelContainer(for: schema, configurations: [configuration])
        }
    }

    private static func resetPersistentStore(at url: URL) {
        let fileManager = FileManager.default
        for suffix in ["", "-wal", "-shm"] {
            try? fileManager.removeItem(atPath: url.path + suffix)
        }
    }
}
