import SwiftUI
import SwiftData

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

    func start() { scheduleStore.start() }

    func loadSchedule() async { await scheduleStore.loadSchedule() }

    func loadCachedData() { scheduleStore.loadCachedData() }

    func clearData() { scheduleStore.clearData() }

    // MARK: - Данные для отображения
    var roomId: String? { scheduleStore.roomId }

    var displayRoomName: String { scheduleStore.displayRoomName }

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

    var busySlots: [BusySlot] {
        ConferenceTimeCalculator.busySlots(from: scheduleStore.confDataItems)
    }
}