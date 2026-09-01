//
//  ConferenceViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//
import SwiftUI
import Combine
import SwiftData
import os

@MainActor
class ConferenceViewModel: ObservableObject {
    @Published var confDataItems: [ConfDataModel] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading = false

    private let api: YmsApiService
    private let appState: AppState
    private let modelContext: ModelContext

    /// Периодическое фоновое обновление расписания.
    private var autoRefreshTask: Task<Void, Never>?

    /// Интервал фонового обновления расписания, секунды.
    private static let autoRefreshInterval: TimeInterval = 60

    /// ID выбранной комнаты — View использует его как .task(id:).
    var roomId: String? { appState.selectedRoom?.id }

    init(api: YmsApiService? = nil, appState: AppState, modelContext: ModelContext) {
        self.api = api ?? YmsApiResponse()
        self.appState = appState
        self.modelContext = modelContext
    }

    // MARK: - Жизненный цикл

    /// Загрузить кэш из базы и запустить периодическое обновление.
    func start() {
        loadCachedData()
        startAutoRefresh()
    }

    /// Единственный источник периодических обновлений — этот отменяемый цикл.
    /// Живёт, пока жива ViewModel (создаётся один раз в App).
    private func startAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.autoRefreshInterval))
                guard let self, !Task.isCancelled else { return }
                // Комната не выбрана — обновлять нечего (кэш уже очищен через .task(id:)).
                guard self.roomId != nil else { continue }
                // Фоновое обновление — без индикатора загрузки.
                await self.loadSchedule(showLoadingIndicator: false)
            }
        }
    }

    /// Полная загрузка расписания (вызывается из View через .task(id:)).
    /// - Parameter showLoadingIndicator: показывать ли состояние isLoading.
    func loadSchedule(showLoadingIndicator: Bool = true) async {
        guard let roomID = roomId else {
            clearData()
            return
        }

        if showLoadingIndicator {
            isLoading = true
            errorMessage = nil
        }

        do {
            let schedule = try await api.getConferenceSchedule(roomId: roomID)
            // Пока шёл запрос, комната могла смениться — ответ устарел.
            guard roomID == roomId else { return }
            saveData(schedulerInfo: schedule)
        } catch is CancellationError {
            // Запрос отменён (смена комнаты) — результат не нужен.
            return
        } catch {
            guard roomID == roomId else { return }
            errorMessage = error.localizedDescription
            AppLog.network.error("Ошибка загрузки расписания: \(error.localizedDescription)")
        }

        if showLoadingIndicator {
            isLoading = false
        }
    }

    // MARK: - Текущая встреча

    /// Встреча, идущая прямо сейчас. Сравнение по epoch-timestamp'ам:
    /// не зависит от формата строк времени и таймзоны устройства.
    var currentMeeting: ConfDataModel? {
        let now = Date()
        return confDataItems.first { conf in
            conf.startDate <= now && now < conf.endDate
        }
    }

    // MARK: - Работа с базой данных (SwiftData)

    func loadCachedData() {
        do {
            confDataItems = try modelContext.fetch(
                FetchDescriptor<ConfDataModel>(sortBy: [SortDescriptor(\.startDateTimeStamp)])
            )
        } catch {
            AppLog.storage.error("Ошибка чтения кэша расписания: \(error.localizedDescription)")
        }
    }

    private func saveData(schedulerInfo: ConferenseSheduler) {
        do {
            try clearDataInternal()

            let confInfoList = schedulerInfo.data.data
            for info in confInfoList {
                let confsInfo = ConfDataModel(
                    conferencePlanId: info.conferencePlanID,
                    conferenceSubject: info.conferenceSubject.subject,
                    startDateTimeStamp: Int(info.conferenceTimePattern.conferenceTime.startDateTimeStamp),
                    endDateTimeStamp: Int(info.conferenceTimePattern.conferenceTime.endDateTimeStamp),
                    startTime: info.conferenceTimePattern.conferenceTime.startTime,
                    endTime: info.conferenceTimePattern.conferenceTime.endTime,
                    organizerId: info.organizer.id,
                    organizerName: info.organizer.name,
                    organizeExt: info.organizer.organizerExtension,
                    plainEmailRemark: info.plainEmailRemark
                )
                modelContext.insert(confsInfo)
            }
            try modelContext.save()
            loadCachedData()
        } catch {
            errorMessage = "Ошибка сохранения данных: \(error.localizedDescription)"
            AppLog.storage.error("Ошибка сохранения расписания: \(error.localizedDescription)")
        }
    }

    func clearData() {
        do {
            try clearDataInternal()
            try modelContext.save()
            confDataItems = []
        } catch {
            errorMessage = "Ошибка очистки данных: \(error.localizedDescription)"
        }
    }

    private func clearDataInternal() throws {
        let descriptor = FetchDescriptor<ConfDataModel>()
        let existingItems = try modelContext.fetch(descriptor)
        for item in existingItems {
            modelContext.delete(item)
        }
        try modelContext.save()
    }
}
