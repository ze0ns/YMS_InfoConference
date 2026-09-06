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

    func dateString(from date: Date) -> String {
        DateFormatters.ruFullDate.string(from: date)
    }

    func timeString(from date: Date) -> String {
        DateFormatters.timeHM.string(from: date)
    }
}
