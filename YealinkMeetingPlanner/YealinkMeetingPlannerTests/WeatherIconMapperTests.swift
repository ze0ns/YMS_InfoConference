//
//  WeatherIconMapperTests.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import XCTest
@testable import YealinkMeetingPlanner

@MainActor
final class WeatherIconMapperTests: XCTestCase {

    func testKnownCodesMap() {
        XCTAssertEqual(WeatherIconMapper.name(for: 0), "sun.max.fill")
        XCTAssertEqual(WeatherIconMapper.name(for: 1), "cloud.sun.fill")
        XCTAssertEqual(WeatherIconMapper.name(for: 45), "cloud.fog.fill")
        XCTAssertEqual(WeatherIconMapper.name(for: 95), "cloud.bolt.fill")
    }

    func testUnknownCodeFallsBackToPlaceholder() {
        XCTAssertEqual(WeatherIconMapper.name(for: 999), "questionmark.circle.fill")
        XCTAssertEqual(WeatherIconMapper.name(for: -1), "questionmark.circle.fill")
    }

    func testAnyCodeNeverProducesEmptyName() {
        for code in stride(from: 0, through: 100, by: 1) {
            XCTAssertFalse(WeatherIconMapper.name(for: code).isEmpty, "Код \(code) дал пустую иконку")
        }
    }

    func testDistinctCodesHaveDistinctIcons() {
        let codes = [0, 1, 2, 3, 45, 51, 61, 63, 71, 80, 95]
        let names = Set(codes.map { WeatherIconMapper.name(for: $0) })
        XCTAssertEqual(names.count, codes.count, "Два разных кода погоды дали одинаковую иконку")
    }
}