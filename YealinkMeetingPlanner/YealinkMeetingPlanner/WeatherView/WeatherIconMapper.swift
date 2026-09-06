//
//  WeatherIconMapper.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import Foundation

/// Маппинг кодов погоды WMO → SF Symbols (данные, а не switch — OCP:
/// добавление кода = запись в словарь, без изменения логики).
enum WeatherIconMapper {

    private static let iconNames: [Int: String] = [
        0: "sun.max.fill",
        1: "cloud.sun.fill",
        2: "cloud.fill",
        3: "smoke.fill",
        45: "cloud.fog.fill",
        51: "cloud.drizzle.fill",
        61: "cloud.rain.fill",
        63: "cloud.heavyrain.fill",
        71: "cloud.snow.fill",
        80: "cloud.sun.rain.fill",
        95: "cloud.bolt.fill"
    ]

    /// SF Symbol для кода погоды WMO; fallback — «questionmark.circle.fill».
    static func name(for code: Int) -> String {
        iconNames[code] ?? "questionmark.circle.fill"
    }
}