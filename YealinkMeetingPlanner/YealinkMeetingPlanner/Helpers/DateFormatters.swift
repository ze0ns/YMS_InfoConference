//
//  DateFormatters.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

/// Единые DateFormatter-ы приложения (создаются один раз и потокобезопасны на чтение).
enum DateFormatters {

    /// "5 сентября 2026"
    static let ruFullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    /// "14:30"
    static let timeHM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    /// "2026-09-05" (для парсинга дат API)
    static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// "сб, 5 сент"
    static let shortWeekdayDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE, d MMM"
        return formatter
    }()
}