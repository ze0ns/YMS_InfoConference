//
//  ConferenceViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//
import SwiftUI
import SwiftData

/// Презентация основного экрана конференции (SRP): работает с хранилищем
/// `ConferenceScheduleStore`, а View получает готовые данные для отображения.
@MainActor
@Observable
final class ConferenceViewModel {
    private let scheduleStore: ConferenceScheduleStore
    private let appState: AppState
    private let settings: SettingsStore

    init(api: YmsApiService? = nil,
         appState: AppState,
         modelContext: ModelContext,
         settings: SettingsStore? = nil,
         repository: ConferenceRepository? = nil) {
        let settingsStore = settings ?? SettingsStore.shared
        self.settings = settingsStore
        self.appState = appState
        self.scheduleStore = ConferenceScheduleStore(
            fetcher: ConferenceDataFetcher(
                api: api,
                repository: repository ?? SwiftDataConferenceRepository(modelContext: modelContext)
            ),
            appState: appState,
            settings: settingsStore
        )
    }

    // MARK: - Данные расписания (транзитивно наблюдаемые)

    var confDataItems: [ConfDataModel] { scheduleStore.confDataItems }
    var isLoading: Bool { scheduleStore.isLoading }
    var errorMessage: String? { scheduleStore.errorMessage }

    // MARK: - Жизненный цикл

    /// Загрузить кэш из базы и запустить периодическое обновление.
    func start() { scheduleStore.start() }

    /// Полная загрузка расписания (вызывается из View через .task(id:)).
    func loadSchedule() async { await scheduleStore.loadSchedule() }

    /// Загружает кэш расписания из базы (в демо-режиме пропускается).
    func loadCachedData() { scheduleStore.loadCachedData() }

    /// Очищает кэш расписания и текущие данные текущей комнаты.
    func clearData() { scheduleStore.clearData() }

    // MARK: - Данные для отображения

    /// ID выбранной комнаты — View использует его как .task(id:).
    var roomId: String? { scheduleStore.roomId }

    /// Имя комнаты для шапки (в демо-режиме — синтетическое).
    var displayRoomName: String { scheduleStore.displayRoomName }

    /// Готовые данные для карточки текущей встречи. View только отображает результат.
    var currentMeetingDisplay: MeetingDisplayState {
        if !settings.isDemoEnabled {
            guard appState.selectedRoom != nil else { return .noRoom }
        }

        let items = scheduleStore.confDataItems
        guard let meeting = ConferenceTimeCalculator.currentMeeting(in: items) else {
            return items.isEmpty ? .noMeetings : .free
        }

        return .occupied(ConferenceTimeCalculator.cardInfo(for: meeting))
    }

    /// Занятые слоты расписания для отображения. View не маппит модели напрямую.
    var busySlots: [BusySlot] {
        ConferenceTimeCalculator.busySlots(from: scheduleStore.confDataItems)
    }
}