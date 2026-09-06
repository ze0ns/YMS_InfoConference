import Foundation
import SwiftData

// MARK: - Демо-расписание

enum DemoData {

    private static let dayStart = 7 * 60    // 07:00
    private static let dayEnd = 20 * 60     // 20:00
    private static let meetingDuration = 90 // минут
    private static let gap = 30             // минут между встречами

    private static let titles = [
        "Планирование спринта",
        "Обзор квартальных целей",
        "Совещание по продукту",
        "Технический обзор архитектуры",
        "Синхронизация команд",
        "Демо нового релиза",
        "Разбор инцидента",
        "Интервью кандидата"
    ]

    private static let organizers: [(name: String, ext: String)] = [
        ("Иванов И.И.", "+7 (999) 100-10-01"),
        ("Петров В.С.", "+7 (999) 200-20-02"),
        ("Сидорова А.Л.", "+7 (999) 300-30-03"),
        ("Кузнецов Д.М.", "+7 (999) 400-40-04"),
        ("Смирнова Е.А.", "+7 (999) 500-50-05"),
        ("Волков О.Н.", "+7 (999) 600-60-06")
    ]

    private struct Meeting {
        let title: String
        let organizer: String
        let ext: String
        let startMinutes: Int
        let endMinutes: Int
    }

    static func conferences(now: Date = Date(), calendar: Calendar = .current) -> [ConfDataModel] {
        let currentMinutes = calendar.component(.hour, from: now) * 60
            + calendar.component(.minute, from: now)

        let slotOffset = (currentMinutes - dayStart) / meetingDuration
        let currentStart = min(max(dayStart + slotOffset * meetingDuration, dayStart), dayEnd - meetingDuration)
        let currentEnd = currentStart + meetingDuration

        var meetings: [Meeting] = []
        var index = 0
        var time = dayStart
        while time + meetingDuration <= currentStart {
            meetings.append(makeMeeting(start: time, end: time + meetingDuration, index: &index))
            time += meetingDuration
        }

        meetings.append(Meeting(
            title: "Обсуждение текущих задач",
            organizer: "Организатор Демо",
            ext: "+7 (999) 000-00-00",
            startMinutes: currentStart,
            endMinutes: currentEnd
        ))

        time = currentEnd
        while time + meetingDuration <= dayEnd {
            meetings.append(makeMeeting(start: time, end: time + meetingDuration, index: &index))
            time += meetingDuration + gap
        }

        return meetings.map { makeConference($0) }
    }

    // MARK: - Helpers

    private static func makeMeeting(start: Int, end: Int, index: inout Int) -> Meeting {
        let organizer = organizers[index % organizers.count]
        defer { index += 1 }
        return Meeting(
            title: titles[index % titles.count],
            organizer: organizer.name,
            ext: organizer.ext,
            startMinutes: start,
            endMinutes: end
        )
    }

    private static func makeConference(_ meeting: Meeting) -> ConfDataModel {
        ConfDataModel(
            conferencePlanId: "demo",
            conferenceSubject: meeting.title,
            startDateTimeStamp: 0,
            startTime: minutesToTime(meeting.startMinutes),
            endTime: minutesToTime(meeting.endMinutes),
            organizerId: "demo",
            organizerName: meeting.organizer,
            organizeExt: meeting.ext,
            plainEmailRemark: "Демо-данные"
        )
    }

    private static func minutesToTime(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }
}
