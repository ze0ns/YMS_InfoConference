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
    private var cancellables = Set<AnyCancellable>()

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

        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshSchedule()
            }
            .store(in: &cancellables)
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
            let schedule = try await api.getConferenceSchedule(roomId: roomId)
            saveData(schedulerInfo: schedule)
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
                let schedule = try await api.getConferenceSchedule(roomId: roomId)
                saveData(schedulerInfo: schedule)
            } catch {
                AppLog.network.error("Ошибка обновления расписания: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Текущая встреча

    var currentMeeting: ConfDataModel? {
        let nowMinutes = Self.timeToMinutes(
            hours: Calendar.current.component(.hour, from: Date()),
            minutes: Calendar.current.component(.minute, from: Date())
        )
        return confDataItems.first { conf in
            let start = Self.timeToMinutes(conf.startTime)
            let end = Self.timeToMinutes(conf.endTime)
            return nowMinutes >= start && nowMinutes < end
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
                    endDateTimeStamp: String(info.conferenceTimePattern.conferenceTime.endDateTimeStamp),
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

    // MARK: - Вспомогательные

    static func timeToMinutes(_ timeString: String) -> Int {
        let parts = timeString.split(separator: ":")
        guard parts.count == 2,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1]) else { return 0 }
        return hours * 60 + minutes
    }

    private static func timeToMinutes(hours: Int, minutes: Int) -> Int {
        hours * 60 + minutes
    }
}
