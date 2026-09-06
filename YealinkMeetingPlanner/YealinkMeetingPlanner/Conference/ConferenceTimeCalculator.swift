import Foundation

enum RoomStatus {
    case free, occupied
}

// MARK: - Состояние карточки текущей встречи

enum MeetingDisplayState {
    case noRoom
    case occupied(MeetingCardInfo)
    case free
    case noMeetings

    var title: String {
        switch self {
        case .noRoom: return "Выберите комнату"
        case .occupied(let meeting): return meeting.title
        case .free: return "Комната свободна"
        case .noMeetings: return "Нет запланированных встреч"
        }
    }

    var time: String {
        if case .occupied(let meeting) = self { return meeting.time }
        return ""
    }

    var contactName: String {
        if case .occupied(let meeting) = self { return meeting.contactName }
        return ""
    }

    var contactPhone: String {
        if case .occupied(let meeting) = self { return meeting.contactPhone }
        return ""
    }

    var roomStatus: RoomStatus {
        if case .occupied = self { return .occupied }
        return .free
    }
}

struct MeetingCardInfo {
    let title: String
    let time: String
    let contactName: String
    let contactPhone: String
}

// MARK: - Чистая логика расписания

enum ConferenceTimeCalculator {

    static func currentMeeting(in conferences: [ConfDataModel], now: Date = Date()) -> ConfDataModel? {
        let nowMinutes = ScheduleSlotFormatter.minutes(of: now)
        return conferences.first { conf in
            let start = ScheduleSlotFormatter.minutes(of: conf.startTime)
            let end = ScheduleSlotFormatter.minutes(of: conf.endTime)
            return nowMinutes >= start && nowMinutes < end
        }
    }

    static func busySlots(from conferences: [ConfDataModel]) -> [BusySlot] {
        conferences.map { meeting in
            BusySlot(
                title: meeting.conferenceSubject,
                start: meeting.startTime,
                end: meeting.endTime
            )
        }
    }

    static func cardInfo(for meeting: ConfDataModel) -> MeetingCardInfo {
        MeetingCardInfo(
            title: meeting.conferenceSubject,
            time: "\(meeting.startTime) – \(meeting.endTime)",
            contactName: meeting.organizerName,
            contactPhone: meeting.organizeExt
        )
    }
}