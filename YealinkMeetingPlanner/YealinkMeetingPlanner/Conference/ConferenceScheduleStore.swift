//
//  ConferenceScheduleStore.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import Foundation
import SwiftData
import os

/// Управление расписанием конференций (SRP): загрузка из API, кэширование,
/// демо-режим и периодическое обновление. Выделено из `ConferenceViewModel`,
/// чтобы хранение данных и жизненный цикл обновлений не смешивались с презентацией.
@MainActor
@Observable
final class ConferenceScheduleStore {
    private(set) var confDataItems: [ConfDataModel] = []
    var isLoading = false
    var errorMessage: String? = nil

    private static let refreshInterval: TimeInterval = 60

    private let fetcher: ConferenceDataFetcher
    private let appState: AppState
    private let settings: SettingsStore

    @ObservationIgnored
    nonisolated(unsafe) private var refreshTimer: Timer?

    /// ID выбранной комнаты — View использует его как .task(id:).
    var roomId: String? { appState.selectedRoom?.id }

    /// Имя комнаты для шапки (в демо-режиме — синтетическое).
    var displayRoomName: String {
        if settings.isDemoEnabled { return "Демо-конференц-зал" }
        return appState.selectedRoom?.namePinyin ?? "Выберите комнату"
    }

    init(fetcher: ConferenceDataFetcher, appState: AppState, settings: SettingsStore) {
        self.fetcher = fetcher
        self.appState = appState
        self.settings = settings
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
        if settings.isDemoEnabled {
            confDataItems = DemoData.conferences()
            isLoading = false
            errorMessage = nil
            return
        }

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
        if settings.isDemoEnabled {
            confDataItems = DemoData.conferences()
            return
        }
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

    // MARK: - Работа с кэшем (SwiftData)

    /// Загружает кэш расписания из базы (в демо-режиме пропускается).
    func loadCachedData() {
        guard !settings.isDemoEnabled else { return }
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