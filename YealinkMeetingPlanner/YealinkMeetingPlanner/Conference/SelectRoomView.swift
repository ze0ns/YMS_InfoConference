//
//  SelectRoomView.swift
//  yealinkCalc
//
//  Created by Aleksandr Oschepkov on 10.10.2024.
//
import SwiftUI
import SwiftData
import Observation // Импортируем для работы с @Observable

// MARK: - Global State (Глобальная переменная)
// Используем @Observable класс-синглтон. Это современный способ хранения глобального состояния в SwiftUI.
@Observable
class GlobalAppState {
    static let shared = GlobalAppState()
    
    // Наша глобальная переменная для хранения выбранной комнаты
    var selectedRoom: RoomModel? = nil
}

// MARK: - Request Body
let getRoom: [String: Any?] = [
    "key" : nil ,
    "categoryID": nil,
    "type":nil,
    "skip": nil,
    "limit":100
]

// MARK: - View
struct SelectRoomView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // Для кнопки "Готово"

    @StateObject private var viewModel = SelectRoomViewModel()

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.rooms) { room in
                    // Превращаем строку в кнопку для обработки нажатия
                    Button {
                        // СОХРАНЯЕМ ВЫБОР В ГЛОБАЛЬНУЮ ПЕРЕМЕННУЮ
                        viewModel.selectedRoom = room
                    } label: {
                        HStack {
                            Text(room.namePinyin)
                                .foregroundColor(.primary) // Возвращаем стандартный цвет текста

                            Spacer()

                            // Показываем галочку, если ID комнаты совпадает с выбранной
                            if viewModel.selectedRoom?.id == room.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                            }
                        }
                        .contentShape(Rectangle()) // Делаем всю строку кликабельной, а не только текст
                    }
                    .buttonStyle(.plain) // Убираем стандартный синий цвет и эффект нажатия кнопки
                }
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.rooms.isEmpty {
                ProgressView()
            }
        }

        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ← Обязательно!
        .background(Color(.systemBackground)) // ← Явный фон

        .navigationTitle("Выбор комнаты")
        .toolbar {
            // Добавляем кнопку "Готово", чтобы пользователь мог вернуться назад после выбора
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") {
                    dismiss()
                }
                .disabled(viewModel.selectedRoom == nil) // Активна только если что-то выбрано
            }
        }
        .task {
            viewModel.configure(modelContext: modelContext)
            await viewModel.fetchAndSaveRooms()
        }

    }
}

// MARK: - Preview
#Preview {
    // 1. Создаем конфигурацию (хранение только в памяти)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    // 2. Создаем контейнер
    let container = try! ModelContainer(for: RoomModel.self, configurations: config)
    
    // 3. Добавляем тестовые данные в контекст
    let context = container.mainContext
    context.insert(RoomModel(id: "1", namePinyin: "Комната А"))
    context.insert(RoomModel(id: "2", namePinyin: "Зал Б"))
    
    // 4. Возвращаем View с привязанным контейнером
    return NavigationStack {
        SelectRoomView()
            .modelContainer(container)
    }
}

