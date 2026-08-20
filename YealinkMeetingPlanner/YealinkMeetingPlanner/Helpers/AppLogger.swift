//
//  AppLogger.swift
//  YealinkMeetingPlanner
//

import os
import Foundation

enum AppLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "YealinkMeetingPlanner"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let storage = Logger(subsystem: subsystem, category: "storage")
    static let app = Logger(subsystem: subsystem, category: "app")
}
