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
    private static let selectedRoomIdKey = "app_selected_room_id"
    private static let selectedRoomNameKey = "app_selected_room_name"

    var selectedRoom: RoomModel? {
        didSet {
            persistSelectedRoom()
        }
    }

    init() {
        let savedId = UserDefaults.standard.string(forKey: Self.selectedRoomIdKey)
        let savedName = UserDefaults.standard.string(forKey: Self.selectedRoomNameKey)
        if let id = savedId, let name = savedName {
            selectedRoom = RoomModel(id: id, namePinyin: name)
        }
    }

    private func persistSelectedRoom() {
        if let room = selectedRoom {
            UserDefaults.standard.set(room.id, forKey: Self.selectedRoomIdKey)
            UserDefaults.standard.set(room.namePinyin, forKey: Self.selectedRoomNameKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.selectedRoomIdKey)
            UserDefaults.standard.removeObject(forKey: Self.selectedRoomNameKey)
        }
    }
}
