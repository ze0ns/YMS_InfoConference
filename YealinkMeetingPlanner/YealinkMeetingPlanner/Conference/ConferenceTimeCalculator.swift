//
//  ConferenceTimeCalculator.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

/// Статус комнаты (свободна/занята) — модель, не несёт SwiftUI-кода.
enum RoomStatus {
    case free, occupied
}

// MARK: - Состояние карточки текущей встречи

/// Готовое состояние карточки для отображения. View не принимает решения о логике
/// и не применяет switch: все данные состояния предоставляются computed-свойствами (OCP).
enum MeetingDisplayState {
    case noRoom
    case occupied(MeetingCardInfo)
    case free
    case noMeetings

    /// Заголовок карточки для текущего состояния.
    var title: String {
        switch self {
        case .noRoom: return "Выберите комнату"
        case .occupied(let meeting): return meeting.title
        case .free: return "Комната свободна"
        case .noMeetings: return "Нет запланированных встреч"
        }
    }

    /// Время встречи (пустое, если комната не занята).
    var time: String {
        if case .occupied(let meeting) = self { return meeting.time }
        return ""
    }

    /// Имя контактного лица (пустое, если комната не занята).
    var contactName: String {
        if case .occupied(let meeting) = self { return meeting.contactName }
        return ""
    }

    /// Телефон контактного лица (пустой, если комната не занята).
    var contactPhone: String {
        if case .occupied(let meeting) = self { return meeting.contactPhone }
        return ""
    }

    /// Статус занятости комнаты.
    var roomStatus: RoomStatus {
        if case .occupied = self { return .occupied }
        return .free
    }
}

/// Отображаемые данные карточки занятой встречи.
struct MeetingCardInfo {
    let title: String
    let time: String
    let contactName: String
    let contactPhone: String
}

// MARK: - Чистая логика расписания (не зависит от SwiftData и View)

enum ConferenceTimeCalculator {

    /// Текущая встреча в указанный момент времени
    static func currentMeeting(in conferences: [ConfDataModel], now: Date = Date()) -> ConfDataModel? {
        let nowMinutes = ScheduleSlotFormatter.minutes(of: now)
        return conferences.first { conf in
            let start = ScheduleSlotFormatter.minutes(of: conf.startTime)
            let end = ScheduleSlotFormatter.minutes(of: conf.endTime)
            return nowMinutes >= start && nowMinutes < end
        }
    }

    /// Маппинг моделей расписания в слоты занятости для расписания
    static func busySlots(from conferences: [ConfDataModel]) -> [BusySlot] {
        conferences.map { meeting in
            BusySlot(
                title: meeting.conferenceSubject,
                start: meeting.startTime,
                end: meeting.endTime
            )
        }
    }

    /// Готовые отображаемые данные карточки встречи
    static func cardInfo(for meeting: ConfDataModel) -> MeetingCardInfo {
        MeetingCardInfo(
            title: meeting.conferenceSubject,
            time: "\(meeting.startTime) – \(meeting.endTime)",
            contactName: meeting.organizerName,
            contactPhone: meeting.organizeExt
        )
    }
}