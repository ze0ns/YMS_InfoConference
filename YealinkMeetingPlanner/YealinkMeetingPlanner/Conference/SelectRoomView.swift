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
    
    // Читаем сохраненные комнаты из SwiftData. Сортируем по имени.
    @Query(sort: \RoomModel.namePinyin) private var savedRooms: [RoomModel]
    
    // Подключаем глобальное состояние к View
    @State private var globalState = GlobalAppState.shared
    
    var ymsapi = YmsApiResponce()
    
    var body: some View {
        VStack {
            List {
                ForEach(savedRooms) { room in
                    // Превращаем строку в кнопку для обработки нажатия
                    Button {
                        // СОХРАНЯЕМ ВЫБОР В ГЛОБАЛЬНУЮ ПЕРЕМЕННУЮ
                        GlobalAppState.shared.selectedRoom = room
                    } label: {
                        HStack {
                            Text(room.namePinyin)
                                .foregroundColor(.primary) // Возвращаем стандартный цвет текста
                            
                            Spacer()
                            
                            // Показываем галочку, если ID комнаты совпадает с сохраненной в глобальной переменной
                            if GlobalAppState.shared.selectedRoom?.id == room.id {
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
        
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ← Обязательно!
        .background(Color(.systemBackground)) // ← Явный фон
        
        .navigationTitle("Выбор комнаты")
        .toolbar {
            // Добавляем кнопку "Готово", чтобы пользователь мог вернуться назад после выбора
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") {
                    print(globalState)
                    dismiss()
                }
                .disabled(GlobalAppState.shared.selectedRoom == nil) // Активна только если что-то выбрано
            }
        }
        .task {
            await fetchAndSaveRooms()
        }
        
    }
    
    // MARK: - Метод загрузки и сохранения
    private func fetchAndSaveRooms() async {
        do {
            // 1. Получаем данные из API
            let rooms = try await ymsapi.getInfo(funcURL: "api/open/v1/room/pagedList", json: getRoom)
            let fetchedRoomsData = rooms.data.data
            
            // 2. Удаляем старые записи из базы
            let descriptor = FetchDescriptor<RoomModel>()
            let oldRooms = try modelContext.fetch(descriptor)
            for oldRoom in oldRooms {
                modelContext.delete(oldRoom)
            }
            
            // 3. Сохраняем новые данные в SwiftData
            for roomData in fetchedRoomsData {
                // МАППИНГ: Здесь вы переводите свойства из DatumRoom в свойства RoomModel
                let newRoom = RoomModel(
                    id: roomData.id,
                    namePinyin: roomData.namePinyin
                )
                
                modelContext.insert(newRoom)
            }
            
            // 4. Сохраняем контекст
            try modelContext.save()
            
            // Опционально: Если ранее выбранная комната есть в новом списке, оставляем её выбранной
            // Если её удалили из API, сбрасываем выбор
            if let currentSelected = GlobalAppState.shared.selectedRoom,
               !savedRooms.contains(where: { $0.id == currentSelected.id }) {
                GlobalAppState.shared.selectedRoom = nil
            }
            
        } catch {
            print("Ошибка при загрузке или сохранении комнат: \(error)")
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

