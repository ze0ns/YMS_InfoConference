//
//  LayoutDimensions.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import CoreGraphics

/// Именованные константы layout вместо «магических чисел».
enum LayoutDimensions {

    // ConferenceRoomScreen
    static let screenHorizontalPadding: CGFloat = 20
    static let headerToContentSpacing: CGFloat = 24
    static let mainColumnsSpacing: CGFloat = 20
    static let meetingCardWidthInset: CGFloat = 32
    static let meetingCardWidthFactor: CGFloat = 0.7
    static let weatherCardHeightFactor: CGFloat = 0.15
    static let weatherCardBottomPadding: CGFloat = 20
    static let weatherCardTopPadding: CGFloat = 20
    static let settingsButtonSize: CGFloat = 40
    static let settingsButtonTrailing: CGFloat = 30
    static let settingsButtonBottom: CGFloat = 10

    // CurrentMeetingView
    static let meetingCircleSize: CGFloat = 130
    static let meetingRowIconSize: CGFloat = 30
    static let meetingRowHorizontalPadding: CGFloat = 60

    // WeatherForecastView
    static let weatherCurrentIconSize: CGFloat = 60
    static let weatherContentSpacing: CGFloat = 26
    static let weatherDailyDividerSpacing: CGFloat = 12
    static let weatherDailyDayWidth: CGFloat = 80
    static let weatherDailyTempWidth: CGFloat = 100
}