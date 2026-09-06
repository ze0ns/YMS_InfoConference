//
//  TimeUtilsTests.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import XCTest
import Foundation
@testable import YealinkMeetingPlanner

@MainActor
final class TimeUtilsTests: XCTestCase {

    func testMinutesOfTimeString() {
        XCTAssertEqual(TimeUtils.minutes(of: "7:00"), 420)
        XCTAssertEqual(TimeUtils.minutes(of: "9:30"), 570)
        XCTAssertEqual(TimeUtils.minutes(of: "20:00"), 1200)
        XCTAssertEqual(TimeUtils.minutes(of: "00:00"), 0)
        XCTAssertEqual(TimeUtils.minutes(of: "23:59"), 1439)
    }

    func testMinutesOfInvalidStringIsZero() {
        XCTAssertEqual(TimeUtils.minutes(of: ""), 0)
        XCTAssertEqual(TimeUtils.minutes(of: "not-a-time"), 0)
        XCTAssertEqual(TimeUtils.minutes(of: "9"), 0)
    }

    func testMinutesOfDate() {
        let date = TestTime.date(hour: 9, minute: 30)
        XCTAssertEqual(TimeUtils.minutes(of: date, calendar: TestTime.calendar), 570)

        let midnight = TestTime.date(hour: 0, minute: 15)
        XCTAssertEqual(TimeUtils.minutes(of: midnight, calendar: TestTime.calendar), 15)
    }

    func testDateAndStringAgree() {
        let date9_30 = TestTime.date(hour: 9, minute: 30)
        let minutes = TimeUtils.minutes(of: date9_30, calendar: TestTime.calendar)
        XCTAssertEqual(TimeUtils.minutes(of: "\(9):\(30)"), minutes)
    }
}