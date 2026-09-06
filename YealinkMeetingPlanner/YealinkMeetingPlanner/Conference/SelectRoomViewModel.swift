//
//  SelectRoomViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import Foundation
import Observation
import os

@MainActor
@Observable
final class SelectRoomViewModel {
    var rooms: [RoomModel] = []
    var errorMessage: String? = nil
    var isLoading = false

    private let api: YmsApiService
    private var repository: RoomRepository?
    private var appState: AppState?

    init(api: YmsApiService? = nil, repository: RoomRepository? = nil, appState: AppState? = nil) {
        self.api = api ?? YmsApiResponse()
        self.repository = repository
        self.appState = appState
    }

    /// Вызывается из View при появлении — repository и appState доступны
    /// только через @Environment
    func configure(repository: RoomRepository, appState: AppState) {
        if self.repository == nil {
            self.repository = repository
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
        guard let repository, let appState else {
            errorMessage = "Хранилище и состояние приложения не настроены"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            // 1. Получаем данные из API
            let response = try await api.getRooms()

            // 2. Заменяем записи в базе данными из API
            try repository.replaceAll(with: response.data.data)

            // 3. Обновляем список из базы
            rooms = try repository.loadRooms()

            // 4. Если выбранная комната удалена из API — сбрасываем выбор
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