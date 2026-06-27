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

    init(ymsApi: YmsApiResponce, modelContext: ModelContext) {
        self.ymsApi = ymsApi
        self.modelContext = modelContext
    }

    func fetchConferenceSchedule(url: String, scheduleConf: [String: Any]) async {
        isLoading = true
        errorMessage = nil

        do {
            // Используем структуру ConferenseSheduler из вашего вопроса
            let confInfo = try await ymsApi.getConfSchedule(funcURL: url, json: scheduleConf)
            saveData(schedulerInfo: confInfo)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Работа с базой данных (SwiftData)

    /// Очистка старых данных и запись новых
    private func saveData(schedulerInfo: ConferenseSheduler) {
        do {
            // 1. Удаляем старые данные
            try clearDataInternal()

            // 2. Записываем новые данные
            let confInfoList = schedulerInfo.data.data
            for info in confInfoList {
                
                let remark = (info.plainEmailRemark)
                
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
            
            // 3. Сохраняем изменения в базу
            try modelContext.save()
            
        } catch {
            errorMessage = "Ошибка сохранения данных: \(error.localizedDescription)"
        }
    }

    /// Публичный метод для очистки данных
    func clearData() {
        do {
            try clearDataInternal()
            try modelContext.save()
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
