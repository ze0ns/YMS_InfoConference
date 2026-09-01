//
//  SelectRoomViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import SwiftUI
import SwiftData
import Combine
import os

@MainActor
class SelectRoomViewModel: ObservableObject {
    @Published var rooms: [RoomModel] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading = false

    private let api: YmsApiService
    private var modelContext: ModelContext?
    private var appState: AppState?

    init(api: YmsApiService? = nil) {
        self.api = api ?? YmsApiResponse()
    }

    /// Вызывается из View при появлении — modelContext и appState доступны
    /// только через @Environment
    func configure(modelContext: ModelContext, appState: AppState) {
        if self.modelContext == nil {
            self.modelContext = modelContext
        }
        if self.appState == nil {
            self.appState = appState
        }
    }

    var selectedRoom: RoomModel? {
        appState?.selectedRoom
    }

    func selectRoom(_ room: RoomModel) {
        appState?.selectedRoom = room
    }

    // MARK: - Загрузка и сохранение комнат

    func fetchAndSaveRooms() async {
        guard let modelContext, let appState else {
            errorMessage = "Контекст базы данных не настроен"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            // 1. Получаем данные из API
            let response = try await api.getRooms()
            let fetchedRooms = response.data.data

            // 2. Удаляем старые записи из базы
            try clearRoomsInternal(modelContext)

            // 3. Маппим и сохраняем новые данные
            for roomData in fetchedRooms {
                modelContext.insert(
                    RoomModel(id: roomData.id, namePinyin: roomData.namePinyin, name: roomData.name)
                )
            }
            try modelContext.save()

            // 4. Обновляем список из базы
            rooms = try modelContext.fetch(FetchDescriptor<RoomModel>(sortBy: [SortDescriptor(\.namePinyin)]))

            // 5. Если выбранная комната удалена из API — сбрасываем выбор
            if let currentSelected = appState.selectedRoom,
               !rooms.contains(where: { $0.id == currentSelected.id }) {
                appState.selectedRoom = nil
            }
        } catch {
            errorMessage = "Ошибка при загрузке или сохранении комнат: \(error.localizedDescription)"
            AppLog.network.error("Ошибка загрузки комнат: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Работа с базой данных (SwiftData)

    private func clearRoomsInternal(_ modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<RoomModel>()
        let oldRooms = try modelContext.fetch(descriptor)
        for oldRoom in oldRooms {
            modelContext.delete(oldRoom)
        }
    }
}