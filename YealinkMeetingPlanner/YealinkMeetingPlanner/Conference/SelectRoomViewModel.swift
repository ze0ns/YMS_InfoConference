//
//  SelectRoomViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import Foundation
import SwiftData
import Observation
import os

@MainActor
@Observable
final class SelectRoomViewModel {
    var rooms: [RoomModel] = []
    var errorMessage: String? = nil
    var isLoading = false

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

    /// Загружает комнаты из API, обновляет базу данных и отображаемый список.
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
            try modelContext.deleteAll(of: RoomModel.self)

            // 3. Маппим и сохраняем новые данные
            for roomData in fetchedRooms {
                modelContext.insert(
                    RoomModel(id: roomData.id, namePinyin: roomData.namePinyin)
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
}