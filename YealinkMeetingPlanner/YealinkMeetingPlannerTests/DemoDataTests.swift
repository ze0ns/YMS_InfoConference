//
//  DemoDataTests.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import XCTest
@testable import YealinkMeetingPlanner

@MainActor
final class DemoDataTests: XCTestCase {

    private let dayStart = 7 * 60
    private let dayEnd = 20 * 60

    func testScheduleIsNotEmpty() {
        XCTAssertFalse(DemoData.conferences(now: TestTime.date(hour: 12, minute: 0), calendar: TestTime.calendar).isEmpty)
    }

    func testCurrentMomentIsAlwaysOccupied() {
        for (hour, minute) in [(9, 0), (10, 17), (12, 0), (15, 45), (18, 30)] {
            let now = TestTime.date(hour: hour, minute: minute)
            let meetings = DemoData.conferences(now: now, calendar: TestTime.calendar)
            XCTAssertNotNil(
                ConferenceTimeCalculator.currentMeeting(in: meetings, now: now),
                "В \(hour):\(minute) комната должна быть занята"
            )
        }
    }

    func testAllMeetingsWithinWorkingDayAndDuration() {
        let meetings = DemoData.conferences(now: TestTime.date(hour: 12, minute: 0), calendar: TestTime.calendar)
        for meeting in meetings {
            let start = TimeUtils.minutes(of: meeting.startTime)
            let end = TimeUtils.minutes(of: meeting.endTime)
            XCTAssertGreaterThanOrEqual(start, dayStart)
            XCTAssertLessThanOrEqual(end, dayEnd)
            XCTAssertEqual(end - start, 90, "Демо-встречи должны длиться 90 минут")
        }
    }

    func testMeetingsDoNotOverlap() {
        let meetings = DemoData.conferences(now: TestTime.date(hour: 12, minute: 0), calendar: TestTime.calendar)
        let sorted = meetings.sorted {
            TimeUtils.minutes(of: $0.startTime) < TimeUtils.minutes(of: $1.startTime)
        }
        for (current, next) in zip(sorted, sorted.dropFirst()) {
            XCTAssertLessThanOrEqual(
                TimeUtils.minutes(of: current.endTime),
                TimeUtils.minutes(of: next.startTime),
                "Пересечение встреч: \(current.startTime)-\(current.endTime) и \(next.startTime)-\(next.endTime)"
            )
        }
    }

    func testFreeBeforeStartOfDay() {
        let now = TestTime.date(hour: 6, minute: 0)
        let meetings = DemoData.conferences(now: now, calendar: TestTime.calendar)
        XCTAssertNil(ConferenceTimeCalculator.currentMeeting(in: meetings, now: now))
    }

    func testTimeFormatIsHourMinute() {
        let meetings = DemoData.conferences(now: TestTime.date(hour: 12, minute: 0), calendar: TestTime.calendar)
        for meeting in meetings {
            XCTAssertTrue(meeting.startTime.contains(":"))
            XCTAssertTrue(meeting.endTime.contains(":"))
            XCTAssertFalse(meeting.startTime.isEmpty)
            XCTAssertFalse(meeting.endTime.isEmpty)
        }
    }
}