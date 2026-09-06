import SwiftUI

// MARK: - Цвет тона

extension ScheduleBlockTone {
    var color: Color {
        switch self {
        case .endingSoon:  return .orange.opacity(0.25)
        case .endingLater: return .red.opacity(0.4)
        case .active:      return .pink.opacity(0.2)
        case .inactive:    return .green.opacity(0.15)
        }
    }
}