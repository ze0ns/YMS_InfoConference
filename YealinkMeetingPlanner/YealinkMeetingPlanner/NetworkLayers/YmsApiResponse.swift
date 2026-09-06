import Foundation

// MARK: - Протокол сервиса

protocol YmsApiService {
    func getConferenceSchedule(roomId: String) async throws -> ConferenceScheduler
    func getRooms() async throws -> RoomList
}

// MARK: - Типизированные тела запросов

struct ConferenceScheduleRequest: Encodable {}

/// nil-поля кодируются как явный null (как прежний формат [String: Any?] через JSONSerialization).
struct RoomListRequest: Encodable {
    var key: String? = nil
    var categoryID: String? = nil
    var type: String? = nil
    var skip: Int? = nil
    var limit: Int = 100

    enum CodingKeys: String, CodingKey {
        case key, categoryID, type, skip, limit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNil(forKey: .key)
        try container.encodeNil(forKey: .categoryID)
        try container.encodeNil(forKey: .type)
        try container.encodeNil(forKey: .skip)
        try container.encode(limit, forKey: .limit)
    }
}

// MARK: - Реализация

struct YmsApiResponse: YmsApiService {
    private let conferenceAPI: YmsConferenceApi
    private let roomAPI: YmsRoomApi

    init(config: APICredentialsProviding = APIConfig()) {
        conferenceAPI = YmsConferenceApi(config: config)
        roomAPI = YmsRoomApi(config: config)
    }

    func getConferenceSchedule(roomId: String) async throws -> ConferenceScheduler {
        try await conferenceAPI.getConferenceSchedule(roomId: roomId)
    }

    func getRooms() async throws -> RoomList {
        try await roomAPI.getRooms()
    }
}