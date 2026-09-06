import Foundation
import Observation

@Observable
final class AppState {
    private static let selectedRoomIdKey = "app_selected_room_id"
    private static let selectedRoomNameKey = "app_selected_room_name"

    private let storage: DataStorage

    var selectedRoom: RoomModel? {
        didSet {
            persistSelectedRoom()
        }
    }

    init(storage: DataStorage? = nil) {
        self.storage = storage ?? UserDefaults.standard

        let savedId = self.storage.string(forKey: Self.selectedRoomIdKey)
        let savedName = self.storage.string(forKey: Self.selectedRoomNameKey)
        if let id = savedId, let name = savedName {
            selectedRoom = RoomModel(id: id, namePinyin: name)
        }
    }

    private func persistSelectedRoom() {
        if let room = selectedRoom {
            storage.set(room.id, forKey: Self.selectedRoomIdKey)
            storage.set(room.namePinyin, forKey: Self.selectedRoomNameKey)
        } else {
            storage.removeObject(forKey: Self.selectedRoomIdKey)
            storage.removeObject(forKey: Self.selectedRoomNameKey)
        }
    }
}
