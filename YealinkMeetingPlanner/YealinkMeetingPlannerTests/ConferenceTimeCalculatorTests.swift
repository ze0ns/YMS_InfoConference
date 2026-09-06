//
//  ConferenceTimeCalculatorTests.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import XCTest
@testable import YealinkMeetingPlanner

@MainActor
final class ConferenceTimeCalculatorTests: XCTestCase {

    private func makeConf(start: String, end: String, subject: String = "Встреча") -> ConfDataModel {
        ConfDataModel(
            conferencePlanId: "plan-1",
            conferenceSubject: subject,
            startDateTimeStamp: 0,
            startTime: start,
            endTime: end,
            organizerId: "org-1",
            organizerName: "Иванов И.И.",
            organizeExt: "+7 900 000-00-00",
            plainEmailRemark: ""
        )
    }

    // MARK: - currentMeeting

    func testCurrentMeetingFindsMeetingContainingNow() {
        let meetings = [
            makeConf(start: "9:00", end: "9:30"),
            makeConf(start: "9:30", end: "10:30", subject: "Вторая")
        ]
        XCTAssertEqual(
            ConferenceTimeCalculator.currentMeeting(in: meetings, now: TestTime.date(hour: 9, minute: 15))?.conferenceSubject,
            "Встреча"
        )
        // Границы: начало включено, конец исключён
        XCTAssertEqual(
            ConferenceTimeCalculator.currentMeeting(in: meetings, now: TestTime.date(hour: 9, minute: 30))?.conferenceSubject,
            "Вторая"
        )
        XCTAssertNil(ConferenceTimeCalculator.currentMeeting(in: meetings, now: TestTime.date(hour: 10, minute: 30)))
    }

    func testCurrentMeetingNilWhenEmpty() {
        XCTAssertNil(ConferenceTimeCalculator.currentMeeting(in: [], now: TestTime.date(hour: 9, minute: 0)))
    }

    // MARK: - busySlots

    func testBusySlotsMapsConfToSlots() {
        let meetings = [makeConf(start: "9:00", end: "9:30", subject: "Спринт")]
        let slots = ConferenceTimeCalculator.busySlots(from: meetings)
        XCTAssertEqual(slots.count, 1)
        XCTAssertEqual(slots[0].title, "Спринт")
        XCTAssertEqual(slots[0].start, "9:00")
        XCTAssertEqual(slots[0].end, "9:30")
    }

    // MARK: - cardInfo

    func testCardInfoFormat() {
        let meeting = makeConf(start: "9:00", end: "9:30", subject: "Спринт")
        let info = ConferenceTimeCalculator.cardInfo(for: meeting)
        XCTAssertEqual(info.title, "Спринт")
        XCTAssertEqual(info.time, "9:00 – 9:30")
        XCTAssertEqual(info.contactName, "Иванов И.И.")
        XCTAssertEqual(info.contactPhone, "+7 900 000-00-00")
    }

    // MARK: - MeetingDisplayState

    func testOccupiedStateExposesMeetingAndStatus() {
        let meeting = makeConf(start: "9:00", end: "9:30", subject: "Спринт")
        let state = MeetingDisplayState.occupied(ConferenceTimeCalculator.cardInfo(for: meeting))
        XCTAssertEqual(state.title, "Спринт")
        XCTAssertEqual(state.time, "9:00 – 9:30")
        XCTAssertEqual(state.contactName, "Иванов И.И.")
        XCTAssertEqual(state.contactPhone, "+7 900 000-00-00")
        XCTAssertEqual(state.roomStatus, .occupied)
    }

    func testEmptyStates() {
        XCTAssertEqual(MeetingDisplayState.free.title, "Комната свободна")
        XCTAssertEqual(MeetingDisplayState.noMeetings.title, "Нет запланированных встреч")
        XCTAssertEqual(MeetingDisplayState.noRoom.title, "Выберите комнату")
        XCTAssertEqual(MeetingDisplayState.free.roomStatus, .free)
        XCTAssertEqual(MeetingDisplayState.noRoom.roomStatus, .free)
    }

    func testFreeStateHasNoMeetingFields() {
        XCTAssertEqual(MeetingDisplayState.free.time, "")
        XCTAssertEqual(MeetingDisplayState.free.contactName, "")
        XCTAssertEqual(MeetingDisplayState.free.contactPhone, "")
    }
}