//
//  ConferenceDatabaseService.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import SwiftData
import Foundation

// MARK: - Протокол репозитория расписания (DIP: вместо прямого ModelContext)

@MainActor
protocol ConferenceRepository {
    func loadConferences() throws -> [ConfDataModel]
    func replaceAll(with schedule: ConferenceScheduler) throws
    func clearAll() throws
}

// MARK: - SwiftData-реализация

@MainActor
final class SwiftDataConferenceRepository: ConferenceRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadConferences() throws -> [ConfDataModel] {
        try modelContext.fetch(
            FetchDescriptor<ConfDataModel>(sortBy: [SortDescriptor(\.startDateTimeStamp, order: .forward)])
        )
    }

    func replaceAll(with schedule: ConferenceScheduler) throws {
        try clearAll()

        for info in schedule.data.data {
            modelContext.insert(
                ConfDataModel(
                    conferencePlanId: info.conferencePlanID,
                    conferenceSubject: info.conferenceSubject.subject,
                    startDateTimeStamp: Int(info.conferenceTimePattern.conferenceTime.startDateTimeStamp),
                    endDateTimeStamp: String(info.conferenceTimePattern.conferenceTime.endDateTimeStamp),
                    startTime: info.conferenceTimePattern.conferenceTime.startTime,
                    endTime: info.conferenceTimePattern.conferenceTime.endTime,
                    organizerId: info.organizer.id,
                    organizerName: info.organizer.name,
                    organizeExt: info.organizer.organizerExtension,
                    plainEmailRemark: info.plainEmailRemark
                )
            )
        }
        try modelContext.save()
    }

    func clearAll() throws {
        try modelContext.deleteAll(of: ConfDataModel.self)
    }
}