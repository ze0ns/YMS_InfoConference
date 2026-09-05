//
//  HeaderViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 29.05.2026.
//
import SwiftUI
import Combine

@MainActor
final class HeaderViewModel: ObservableObject {
    @Published private(set) var currentDate = Date()

    private var cancellable: AnyCancellable?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    init() {
        cancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentDate = Date()
            }
    }

    deinit {
        cancellable?.cancel()
    }

    func dateString(from date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    func timeString(from date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }
}
