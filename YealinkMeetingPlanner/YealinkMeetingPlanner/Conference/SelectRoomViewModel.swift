//
//  SelectRoomViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import SwiftUI
import SwiftData
import Combine

@MainActor
class SelectRoomViewModel: ObservableObject {
    @Published var rooms: [RoomModel] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading = false

    private let ymsApi: YmsApiResponce
    private var modelContext: ModelContext?

    init(ymsApi: YmsApiResponce = YmsApiResponce()) {
        self.ymsApi = ymsApi
    }

    /// Вызывается из View при появлении — контекст доступен только через @Environment
    func configure(modelContext: ModelContext) {
        if self.modelContext == nil {
            self.modelContext = modelContext
        }
    }

    var selectedRoom: RoomModel? {
        get { GlobalAppState.shared.selectedRoom }
        set { GlobalAppState.shared.selectedRoom = newValue }
    }

    // MARK: - Загрузка и сохранение комнат

    func fetchAndSaveRooms() async {
        guard let modelContext else {
            errorMessage = "Контекст базы данных не настроен"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            // 1. Получаем данные из API
            let response = try await ymsApi.getInfo(funcURL: "api/open/v1/room/pagedList", json: getRoom)
            let fetchedRooms = response.data.data

            // 2. Удаляем старые записи из базы
            try clearRoomsInternal(modelContext)

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
            if let currentSelected = selectedRoom,
               !rooms.contains(where: { $0.id == currentSelected.id }) {
                selectedRoom = nil
            }
        } catch {
            errorMessage = "Ошибка при загрузке или сохранении комнат: \(error.localizedDescription)"
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
