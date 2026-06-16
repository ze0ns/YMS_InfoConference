//
//  RoomModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 07.06.2026.
//


import SwiftUI
import SwiftData

// MARK: - SwiftData Model
// Создаем модель для хранения комнат в базе данных.
// Убедитесь, что поля соответствуют тем данным из DatumRoom, которые вам нужно сохранить.
@Model
class RoomModel {
    var id: String
    var namePinyin: String
    // Добавьте другие нужные поля, например:
    // var name: String
    // var type: String
    
    init(id: String, namePinyin: String) {
        self.id = id
        self.namePinyin = namePinyin
    }
}