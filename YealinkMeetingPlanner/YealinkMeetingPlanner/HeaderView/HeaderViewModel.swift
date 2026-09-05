//
//  HeaderViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 29.05.2026.
//
import SwiftUI

@MainActor
@Observable
final class HeaderViewModel {
    private(set) var currentDate = Date()

    private static let refreshInterval: TimeInterval = 60

    @ObservationIgnored
    nonisolated(unsafe) private var refreshTimer: Timer?

    init() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Self.refreshInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.currentDate = Date()
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }

    /// Полная дата: "5 сентября 2026"
    func dateString(from date: Date) -> String {
        DateFormatters.ruFullDate.string(from: date)
    }

    /// Время: "14:30"
    func timeString(from date: Date) -> String {
        DateFormatters.timeHM.string(from: date)
    }
}
