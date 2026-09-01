//
//  AppState.swift
//  YealinkMeetingPlanner
//

import Foundation
import Observation

/// Глобальное состояние приложения. Создаётся один раз в App,
/// внедряется через `.environment(...)` и передаётся в ViewModel'ы.
@Observable
final class AppState {
    /// Один ключ на всю выбранную комнату (JSON всех полей RoomModel).
    private static let selectedRoomKey = "app_selected_room"

    /// Устаревшие ключи (id и имя по отдельности) — читаются один раз для миграции.
    private static let legacyRoomIdKey = "app_selected_room_id"
    private static let legacyRoomNameKey = "app_selected_room_name"

    var selectedRoom: RoomModel? {
        didSet {
            persistSelectedRoom()
        }
    }

    init() {
        selectedRoom = Self.loadSelectedRoom()
    }

    private func persistSelectedRoom() {
        if let room = selectedRoom,
           let data = try? JSONEncoder().encode(room) {
            UserDefaults.standard.set(data, forKey: Self.selectedRoomKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.selectedRoomKey)
        }
    }

    private static func loadSelectedRoom() -> RoomModel? {
        let defaults = UserDefaults.standard

        // Актуальный формат: вся комната одним JSON
        if let data = defaults.data(forKey: selectedRoomKey),
           let room = try? JSONDecoder().decode(RoomModel.self, from: data) {
            return room
        }

        // Миграция со старого формата (id и имя по отдельности)
        if let id = defaults.string(forKey: legacyRoomIdKey),
           let name = defaults.string(forKey: legacyRoomNameKey) {
            defaults.removeObject(forKey: legacyRoomIdKey)
            defaults.removeObject(forKey: legacyRoomNameKey)
            return RoomModel(id: id, namePinyin: name)
        }

        return nil
    }
}
