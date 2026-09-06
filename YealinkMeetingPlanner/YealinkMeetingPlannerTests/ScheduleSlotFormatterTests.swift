//
//  ScheduleSlotFormatterTests.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import XCTest
@testable import YealinkMeetingPlanner

@MainActor
final class ScheduleSlotFormatterTests: XCTestCase {

    func testTimeSlotsCoversSevenToTwentyByHalfHour() {
        let slots = ScheduleSlotFormatter.timeSlots()
        XCTAssertEqual(slots.first, "7:00")
        XCTAssertEqual(slots.last, "20:00")
        XCTAssertEqual(slots.count, (20 - 7) * 2 + 1) // 27 слотов
        let minutes = slots.map { ScheduleSlotFormatter.minutes(of: $0) }
        XCTAssertEqual(minutes, minutes.sorted(), "Слоты должны идти в хронологическом порядке")
    }

    func testMinutesOfDelegatesToTimeUtils() {
        XCTAssertEqual(ScheduleSlotFormatter.minutes(of: "9:30"), 570)
        XCTAssertEqual(
            ScheduleSlotFormatter.minutes(of: TestTime.date(hour: 9, minute: 30), calendar: TestTime.calendar),
            570
        )
    }

    func testIsBusyEndIsExclusive() {
        let busy = BusySlot(title: "Встреча", start: "9:00", end: "10:00")
        XCTAssertTrue(ScheduleSlotFormatter.isBusy("9:00", slots: [busy]))
        XCTAssertTrue(ScheduleSlotFormatter.isBusy("9:30", slots: [busy]))
        XCTAssertFalse(ScheduleSlotFormatter.isBusy("10:00", slots: [busy]))
        XCTAssertFalse(ScheduleSlotFormatter.isBusy("8:30", slots: [busy]))
    }

    func testTitleOnlyAtStartOfMeeting() {
        let slot = BusySlot(title: "Спринт", start: "11:00", end: "12:00")
        XCTAssertEqual(ScheduleSlotFormatter.title(at: "11:00", slots: [slot]), "Спринт")
        XCTAssertNil(ScheduleSlotFormatter.title(at: "11:30", slots: [slot]))
    }

    func testGroupedBlocksMergeAdjacentBusySlots() {
        let meeting = BusySlot(title: "Утренняя", start: "9:00", end: "10:00")
        let blocks = ScheduleSlotFormatter.groupedBlocks(from: [meeting])

        guard let busyBlock = blocks.first(where: { $0.isBusy }) else {
            return XCTFail("Ожидался занятый блок")
        }
        XCTAssertEqual(busyBlock.times, ["9:00", "9:30"])
        XCTAssertEqual(busyBlock.title, "Утренняя")
        XCTAssertEqual(busyBlock.id, "9:00")
    }

    func testGroupedBlocksStartWithFreeSlot() {
        let blocks = ScheduleSlotFormatter.groupedBlocks(from: [])
        XCTAssertEqual(blocks.count, 1, "Весь день без встреч — один свободный блок")
        XCTAssertEqual(blocks.first?.isBusy, false)
        XCTAssertEqual(blocks.first?.times.count, 27)
    }

    func testToneAwayFromBlockIsInactive() {
        let block = ScheduleBlock(id: "9:00", times: ["9:00"], isBusy: true, title: nil)
        XCTAssertEqual(ScheduleSlotFormatter.tone(for: block, now: TestTime.date(hour: 7, minute: 0), calendar: TestTime.calendar), .inactive)
    }

    func testToneEndingSoonWhenLessThanHalfHourLeft() {
        let block = ScheduleBlock(id: "9:00", times: ["9:00", "9:30"], isBusy: true, title: nil) // до 10:00
        XCTAssertEqual(ScheduleSlotFormatter.tone(for: block, now: TestTime.date(hour: 9, minute: 45), calendar: TestTime.calendar), .endingSoon)
    }

    func testToneEndingLaterWhenUpToHourLeft() {
        let block = ScheduleBlock(id: "9:00", times: ["9:00", "9:30", "10:00", "10:30"], isBusy: true, title: nil) // до 11:00
        XCTAssertEqual(ScheduleSlotFormatter.tone(for: block, now: TestTime.date(hour: 10, minute: 0), calendar: TestTime.calendar), .endingLater)
    }

    func testToneActiveWhenMoreThanHourLeft() {
        let block = ScheduleBlock(id: "9:00", times: ["9:00", "9:30", "10:00", "10:30"], isBusy: true, title: nil) // до 11:00
        XCTAssertEqual(ScheduleSlotFormatter.tone(for: block, now: TestTime.date(hour: 9, minute: 30), calendar: TestTime.calendar), .active)
    }

    func testToneInactiveForFreeBlock() {
        let block = ScheduleBlock(id: "8:00", times: ["8:00"], isBusy: false, title: nil)
        XCTAssertEqual(ScheduleSlotFormatter.tone(for: block, now: TestTime.date(hour: 12, minute: 0), calendar: TestTime.calendar), .inactive)
    }
}