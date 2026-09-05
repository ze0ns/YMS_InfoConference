//
//  ConferenceViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//
import SwiftUI
import SwiftData
import os

@MainActor
@Observable
final class ConferenceViewModel {
    private(set) var confDataItems: [ConfDataModel] = []
    var errorMessage: String? = nil
    var isLoading = false

    private static let refreshInterval: TimeInterval = 60

    private let fetcher: ConferenceDataFetcher
    private let appState: AppState

    @ObservationIgnored
    nonisolated(unsafe) private var refreshTimer: Timer?

    /// ID выбранной комнаты — View использует его как .task(id:).
    var roomId: String? { appState.selectedRoom?.id }

    init(api: YmsApiService? = nil,
         appState: AppState,
         modelContext: ModelContext,
         repository: ConferenceRepository? = nil) {
        self.appState = appState
        self.fetcher = ConferenceDataFetcher(
            api: api,
            repository: repository ?? SwiftDataConferenceRepository(modelContext: modelContext)
        )
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Жизненный цикл

    /// Загрузить кэш из базы и запустить периодическое обновление.
    func start() {
        loadCachedData()

        refreshTimer = Timer.scheduledTimer(withTimeInterval: Self.refreshInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.refreshSchedule()
            }
        }
    }

    /// Полная загрузка расписания (вызывается из View через .task(id:)).
    func loadSchedule() async {
        guard let roomId else {
            clearData()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            confDataItems = try await fetcher.fetchSchedule(roomId: roomId)
        } catch {
            errorMessage = error.localizedDescription
            AppLog.network.error("Ошибка загрузки расписания: \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func refreshSchedule() {
        guard let roomId else { return }
        Task {
            do {
                let conferences = try await fetcher.fetchSchedule(roomId: roomId)
                confDataItems = conferences
            } catch {
                AppLog.network.error("Ошибка обновления расписания: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Текущая встреча

    /// Готовые данные для карточки текущей встречи. View только отображает результат.
    var currentMeetingDisplay: MeetingDisplayState {
        guard appState.selectedRoom != nil else { return .noRoom }

        guard let meeting = ConferenceTimeCalculator.currentMeeting(in: confDataItems) else {
            return confDataItems.isEmpty ? .noMeetings : .free
        }

        return .occupied(ConferenceTimeCalculator.cardInfo(for: meeting))
    }

    /// Занятые слоты расписания для отображения. View не маппит модели напрямую.
    var busySlots: [BusySlot] {
        ConferenceTimeCalculator.busySlots(from: confDataItems)
    }

    // MARK: - Работа с кэшем (SwiftData)

    /// Загружает кэш расписания из базы.
    func loadCachedData() {
        do {
            confDataItems = try fetcher.loadCachedConferences()
        } catch {
            AppLog.storage.error("Ошибка чтения кэша расписания: \(error.localizedDescription)")
        }
    }

    /// Очищает кэш расписания и текущие данные текущей комнаты.
    func clearData() {
        do {
            try fetcher.clearCache()
            confDataItems = []
        } catch {
            errorMessage = "Ошибка очистки данных: \(error.localizedDescription)"
        }
    }
}