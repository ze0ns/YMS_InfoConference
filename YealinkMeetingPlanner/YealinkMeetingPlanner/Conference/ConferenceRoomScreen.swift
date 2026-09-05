//
//  ConferenceRoomScreen.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//
import SwiftUI
import SwiftData

struct ConferenceRoomScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var viewModel: ConferenceViewModel
    @State private var isPinEntryPresented = false
    @State private var isSettingsPresented = false

    init(viewModel: ConferenceViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let meetingCardWidth = (screenWidth - 32) * 0.7
            let weatherCardHeight = geometry.size.height * 0.15

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    HeaderView(roomName: appState.selectedRoom?.namePinyin ?? "Выберите комнату")
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
                Button(action: { isPinEntryPresented = true }) {
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
            .sheet(isPresented: $isPinEntryPresented) {
                PinEntryView {
                    isPinEntryPresented = false
                    isSettingsPresented = true
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
        }
        .task {
            viewModel.start()
        }
        .task(id: viewModel.roomId) {
            await viewModel.loadSchedule()
        }
    }

    // MARK: - Компоненты данных

    @ViewBuilder
    private func currentMeetingView(width: CGFloat) -> some View {
        let cardInfo: (title: String, time: String, contactName: String, contactPhone: String, status: RoomStatus) = {
            switch viewModel.currentMeetingDisplay {
            case .noRoom:
                return ("Выберите комнату", "", "", "", .free)
            case .occupied(let meeting):
                return (meeting.title, meeting.time, meeting.contactName, meeting.contactPhone, .occupied)
            case .free:
                return ("Комната свободна", "", "", "", .free)
            case .noMeetings:
                return ("Нет запланированных встреч", "", "", "", .free)
            }
        }()

        CurrentMeetingView(
            title: cardInfo.title,
            time: cardInfo.time,
            contactName: cardInfo.contactName,
            contactPhone: cardInfo.contactPhone,
            status: cardInfo.status
        )
        .frame(width: width)
        .frame(maxHeight: .infinity)
        .cardStyle()
    }

    @ViewBuilder
    private func scheduleView() -> some View {
        ScheduleView(
            currentDate: Date(),
            busySlots: viewModel.busySlots
        )
        .cardStyle()
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Preview
struct ConferenceRoomScreen_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        guard let container = try? ModelContainer(
            for: ConfDataModel.self,
            RoomModel.self,
            configurations: config
        ) else {
            return AnyView(Text("Ошибка создания ModelContainer"))
        }

        return AnyView(
            ConferenceRoomScreen(
                viewModel: ConferenceViewModel(
                    appState: appState,
                    modelContext: container.mainContext
                )
            )
            .modelContainer(container)
            .environment(appState)
        )
    }
}
