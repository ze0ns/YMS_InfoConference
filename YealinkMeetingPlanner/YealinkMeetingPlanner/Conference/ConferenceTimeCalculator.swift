//
//  ConferenceTimeCalculator.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

// MARK: - Состояние карточки текущей встречи

/// Готовое состояние карточки для отображения. View не принимает решения о логике.
enum MeetingDisplayState {
    case noRoom
    case occupied(MeetingCardInfo)
    case free
    case noMeetings
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