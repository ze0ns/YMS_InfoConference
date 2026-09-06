//
//  TestHelpers.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import Foundation

/// Стабильные время/календарь для тестов (не зависят от часового пояса машины).
enum TestTime {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")!
        return calendar
    }()

    /// 2026-09-05 в указанное время по московскому времени.
    static func date(hour: Int, minute: Int, second: Int = 0) -> Date {
        calendar.date(
            from: DateComponents(
                year: 2026, month: 9, day: 5,
                hour: hour, minute: minute, second: second
            )
        )!
    }
}