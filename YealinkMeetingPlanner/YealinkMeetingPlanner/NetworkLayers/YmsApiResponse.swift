//
//  YmsApiResponse.swift
//  yealinkCalc
//
//  Created by Oschepkov Aleksandr on 04.03.2024.
//
import Foundation

// MARK: - Протокол сервиса (позволяет подменять реализацию в тестах)

/// Сервис YMS API: расписание конференций и список комнат.
protocol YmsApiService {
    /// Расписание конференций указанной комнаты.
    func getConferenceSchedule(roomId: String) async throws -> ConferenceScheduler
    /// Список доступных комнат.
    func getRooms() async throws -> RoomList
}

// MARK: - Типизированные тела запросов

/// Тело запроса расписания: пустой JSON `{}` (как раньше слался пустой словарь)
struct ConferenceScheduleRequest: Encodable {}

/// Тело запроса списка комнат. nil-поля кодируются как явный null,
/// чтобы совпадать с прежним форматом [String: Any?] через JSONSerialization.
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

// MARK: - Реализация (фасад над YmsConferenceApi и YmsRoomApi)

/// Фасад YMS API: объединяет конференции и комнаты за единым протоколом.
/// Подробности подписи и HTTP — в `YmsRequestSigner`/`YmsHTTPClient`.
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