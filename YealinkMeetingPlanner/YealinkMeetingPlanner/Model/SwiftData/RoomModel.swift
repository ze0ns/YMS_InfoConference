import SwiftUI
import SwiftData

// MARK: - SwiftData Model
@Model
class RoomModel {
    var id: String
    var namePinyin: String

    init(id: String, namePinyin: String) {
        self.id = id
        self.namePinyin = namePinyin
    }
}