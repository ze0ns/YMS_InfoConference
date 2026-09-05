//
//  TimeUtils.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

/// Единая точка конвертации времени в минуты от начала дня.
enum TimeUtils {

    /// "9:30" → 570 минут от начала дня
    static func minutes(of timeString: String) -> Int {
        let parts = timeString.split(separator: ":")
        guard parts.count == 2,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1]) else { return 0 }
        return hours * 60 + minutes
    }

    static func minutes(of date: Date, calendar: Calendar = .current) -> Int {
        calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
    }
}