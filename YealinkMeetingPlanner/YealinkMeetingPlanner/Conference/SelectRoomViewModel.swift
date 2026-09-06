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

    func fetchAndSaveRooms() async {
        guard let repository, let appState else {
            errorMessage = "Хранилище и состояние приложения не настроены"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            let response = try await api.getRooms()

            try repository.replaceAll(with: response.data.data)

            rooms = try repository.loadRooms()

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