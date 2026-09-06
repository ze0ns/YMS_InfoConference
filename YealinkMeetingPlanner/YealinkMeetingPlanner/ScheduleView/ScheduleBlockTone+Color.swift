//
//  ScheduleBlockTone+Color.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import SwiftUI

// MARK: - Тон занятого блока → цвет (OCP: расширение вместо switch во View)

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