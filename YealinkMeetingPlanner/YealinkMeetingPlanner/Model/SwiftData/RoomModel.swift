//
//  RoomModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 07.06.2026.
//


import SwiftUI
import SwiftData

// MARK: - SwiftData Model
// Модель комнаты. Поля заполняются из ответа API `room/pagedList`.
@Model
class RoomModel {
    var id: String
    var namePinyin: String
    /// Настоящее имя комнаты, как на сервере; может быть пустым.
    var name: String

    private enum CodingKeys: String, CodingKey {
        case id, namePinyin, name
    }

    init(id: String, namePinyin: String, name: String = "") {
        self.id = id
        self.namePinyin = namePinyin
        self.name = name
    }

    // MARK: - Codable (для сохранения выбранной комнаты в UserDefaults)

    /// `required` нужен для соответствия Codable в не-final классе
    /// (расширить через extension нельзя — требование протокола).
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            namePinyin: try container.decode(String.self, forKey: .namePinyin),
            name: try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        )
    }
}

// MARK: - Отображаемое имя

extension RoomModel {
    /// Имя для интерфейса: настоящее имя, если сервер его отдал, иначе pinyin-вариант.
    var displayName: String {
        name.isEmpty ? namePinyin : name
    }
}

// MARK: - Codable, кодирование

extension RoomModel: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(namePinyin, forKey: .namePinyin)
        try container.encode(name, forKey: .name)
    }
}
