//
//  ConferenceDataFetcher.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

// MARK: - Загрузка расписания из API + кэширование в хранилище

@MainActor
struct ConferenceDataFetcher {
    private let api: YmsApiService
    private let repository: ConferenceRepository

    init(api: YmsApiService? = nil, repository: ConferenceRepository) {
        self.api = api ?? YmsApiResponse()
        self.repository = repository
    }

    /// Полная загрузка расписания: запрос в API, обновление кэша и чтение из него.
    /// Возвращает актуальный список конференций.
    func fetchSchedule(roomId: String) async throws -> [ConfDataModel] {
        let schedule = try await api.getConferenceSchedule(roomId: roomId)
        try repository.replaceAll(with: schedule)
        return try repository.loadConferences()
    }

    /// Кэш расписания из базы
    func loadCachedConferences() throws -> [ConfDataModel] {
        try repository.loadConferences()
    }

    /// Очистка кэша
    func clearCache() throws {
        try repository.clearAll()
    }
}