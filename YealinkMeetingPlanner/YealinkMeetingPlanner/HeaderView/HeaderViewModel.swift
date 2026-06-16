//
//  HeaderViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 29.05.2026.
//

import Foundation
struct HeaderViewModel{
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
}
extension HeaderViewModel{
    func extractDateString(from date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
    func extractTimeOnly(from date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.string(from: date)
    }
}
