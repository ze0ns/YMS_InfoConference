import SwiftData
import Foundation

// MARK: - Протокол репозитория расписания

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

// MARK: - Протокол репозитория комнат

@MainActor
protocol RoomRepository {
    func loadRooms() throws -> [RoomModel]
    func replaceAll(with rooms: [DatumRoom]) throws
    func clearAll() throws
}

// MARK: - SwiftData-реализация

@MainActor
final class SwiftDataRoomRepository: RoomRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadRooms() throws -> [RoomModel] {
        try modelContext.fetch(
            FetchDescriptor<RoomModel>(sortBy: [SortDescriptor(\.namePinyin)])
        )
    }

    func replaceAll(with rooms: [DatumRoom]) throws {
        try clearAll()

        for room in rooms {
            modelContext.insert(RoomModel(id: room.id, namePinyin: room.namePinyin))
        }
        try modelContext.save()
    }

    func clearAll() throws {
        try modelContext.deleteAll(of: RoomModel.self)
    }
}