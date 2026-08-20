//
//  ConferenceViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//
import SwiftUI
import Combine
import SwiftData

@MainActor
class ConferenceViewModel: ObservableObject {
    @Published var confDataItems: [ConfDataModel] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading = false

    private let ymsApi: YmsApiResponce
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    init(ymsApi: YmsApiResponce = YmsApiResponce(), modelContext: ModelContext) {
        self.ymsApi = ymsApi
        self.modelContext = modelContext
    }

    // MARK: - Текущая встреча

    /// Возвращает встречу, которая идёт прямо сейчас, или nil если комната свободна.
    var currentMeeting: ConfDataModel? {
        let nowMinutes = Self.currentMinutes()
        return confDataItems.first { conf in
            let start = Self.timeToMinutes(conf.startTime)
            let end = Self.timeToMinutes(conf.endTime)
            return nowMinutes >= start && nowMinutes < end
        }
    }

    // MARK: - Загрузка из базы

    /// Загружает сохранённые встречи из SwiftData (кэш на случай запуска без сети).
    func loadCachedData() {
        do {
            confDataItems = try modelContext.fetch(
                FetchDescriptor<ConfDataModel>(sortBy: [SortDescriptor(\.startDateTimeStamp)])
            )
        } catch {
            errorMessage = "Ошибка чтения данных: \(error.localizedDescription)"
        }
    }

    // MARK: - Сетевые запросы

    func fetchConferenceSchedule(url: String, scheduleConf: [String: Any]) async {
        isLoading = true
        errorMessage = nil

        do {
            let confInfo = try await ymsApi.getConfSchedule(funcURL: url, json: scheduleConf)
            saveData(schedulerInfo: confInfo)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Работа с базой данных (SwiftData)

    private func saveData(schedulerInfo: ConferenseSheduler) {
        do {
            try clearDataInternal()

            let confInfoList = schedulerInfo.data.data
            for info in confInfoList {
                let remark = info.plainEmailRemark
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
                    plainEmailRemark: remark
                )
                modelContext.insert(confsInfo)
            }
            try modelContext.save()
            loadCachedData()
        } catch {
            errorMessage = "Ошибка сохранения данных: \(error.localizedDescription)"
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

    private static func currentMinutes() -> Int {
        let now = Date()
        let calendar = Calendar.current
        return calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
    }

    private static func timeToMinutes(_ timeString: String) -> Int {
        let parts = timeString.split(separator: ":")
        guard parts.count == 2,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1]) else { return 0 }
        return hours * 60 + minutes
    }
}
