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
        DateFormatters.ruFullDate.string(from: date)
    }

    func timeString(from date: Date) -> String {
        DateFormatters.timeHM.string(from: date)
    }
}
