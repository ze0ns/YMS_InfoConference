//
//  ConferenceRoomScreen.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//


import SwiftUI
import SwiftData
import Combine

// MARK: - View
struct ConferenceRoomScreen: View {
    @Environment(\.modelContext) private var modelContext
    let container = try! ModelContainer(for: RoomModel.self)
    
    // Читаем данные из SwiftData, отсортированные по времени начала
    @Query(sort: \ConfDataModel.startDateTimeStamp, order: .forward)
    private var conferences: [ConfDataModel]
    
    @StateObject private var viewModel: ConferenceViewModel
    
    // Подключаем глобальное состояние, чтобы View реагировала на смену выбранной комнаты
    @State private var globalState = GlobalAppState.shared
    
    // 1. Добавляем переменную состояния для управления открытием окна
    @State private var isSelectRoomPresented = false
    
    private let scheduleConf: [String: Any] = [:]
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // MARK: - Динамический URL
 
    private var apiUrl: String {
        guard let roomId = globalState.selectedRoom?.id else { return "" }
        return "api/open/v1/conference/record/\(roomId)/pagedList"
    }
    
    init(viewModel: ConferenceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let meetingCardWidth = (screenWidth - 32) * 0.7
            let weatherCardHeight = geometry.size.height * 0.15
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    // Берем название комнаты из глобальной переменной
                    HeaderView(roomName: globalState.selectedRoom?.namePinyin ?? "Выберите комнату")
                        .cardStyle()
                        .padding(.horizontal, 20)
                    
                    HStack(alignment: .top, spacing: 20) {
                        currentMeetingView(width: meetingCardWidth)
                        scheduleView()
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                WeatherForecastView()
                    .frame(maxWidth: .infinity)
                    .frame(height: weatherCardHeight)
                    .padding(.bottom, 20)
                    .cardStyle()
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
            }
            .background(Color.BG)
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    // 2. При нажатии меняем состояние на true, чтобы открыть окно
                    isSelectRoomPresented = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 30)
                .padding(.bottom, 10)
            }
            .sheet(isPresented: $isSelectRoomPresented) {
                NavigationStack {
                    SelectRoomView()
                        .modelContainer(container)
                }
            }
        }
        .task {
            if !apiUrl.isEmpty {
                do {
                    try viewModel.clearData()
                } catch {
                    print("Ошибка очистки данных: $error)")
                }
                await viewModel.fetchConferenceSchedule(url: apiUrl, scheduleConf: scheduleConf)
            }
        }
        .onReceive(timer) { _ in
            guard !apiUrl.isEmpty else { return }
            Task {
                await viewModel.fetchConferenceSchedule(url: apiUrl, scheduleConf: scheduleConf)
            }
        }
    }
    
    // MARK: - Компоненты данных
    
    @ViewBuilder
    private func currentMeetingView(width: CGFloat) -> some View {
        // Если комната еще не выбрана, показываем заглушку
        if globalState.selectedRoom == nil {
            CurrentMeetingView(
                title: "Выберите комнату",
                time: "",
                contactName: "",
                contactPhone: "",
                status: .free
            )
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .cardStyle()
        }
        // Берем первую встречу из массива (она самая ближайшая, т.к. отсортировано)
        else if let meeting = conferences.first {
            CurrentMeetingView(
                title: meeting.conferenceSubject,
                time: "\(meeting.startTime) – \(meeting.endTime)",
                contactName: meeting.organizerName,
                contactPhone: meeting.organizeExt,
                status: .occupied
            )
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .cardStyle()
        } else {
            // Placeholder, если встреч нет
            CurrentMeetingView(
                title: "Нет запланированных встреч",
                time: "",
                contactName: "",
                contactPhone: "",
                status: .free
            )
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .cardStyle()
        }
    }
    
    @ViewBuilder
    private func scheduleView() -> some View {
        // Маппим модели SwiftData в кортежи для ScheduleView
        let slots = conferences.map { meeting in
            (meeting.conferenceSubject, meeting.startTime, meeting.endTime)
        }
        
        ScheduleView(
            currentDate: Date(),
            busySlots: slots
        )
        .cardStyle()
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Preview
struct ConferenceRoomScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Безопасное создание контейнера для превью
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: ConfDataModel.self, configurations: config)
        
        return ConferenceRoomScreen(
            viewModel: ConferenceViewModel(
                ymsApi: YmsApiResponce(),
                modelContext: container.mainContext
            )
        )
        .modelContainer(container)
    }
}
