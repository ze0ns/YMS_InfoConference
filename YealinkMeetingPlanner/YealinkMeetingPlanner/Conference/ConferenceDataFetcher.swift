import Foundation

// MARK: - Загрузка расписания и кэширование

@MainActor
struct ConferenceDataFetcher {
    private let api: YmsApiService
    private let repository: ConferenceRepository

    init(api: YmsApiService? = nil, repository: ConferenceRepository) {
        self.api = api ?? YmsApiResponse()
        self.repository = repository
    }

    func fetchSchedule(roomId: String) async throws -> [ConfDataModel] {
        let schedule = try await api.getConferenceSchedule(roomId: roomId)
        try repository.replaceAll(with: schedule)
        return try repository.loadConferences()
    }

    func loadCachedConferences() throws -> [ConfDataModel] {
        try repository.loadConferences()
    }

    func clearCache() throws {
        try repository.clearAll()
    }
}