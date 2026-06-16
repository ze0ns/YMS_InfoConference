//
//  SelectRoomView.swift
//  yealinkCalc
//
//  Created by Aleksandr Oschepkov on 10.10.2024.
//

import SwiftUI
import SwiftData


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
    
    // Читаем сохраненные комнаты из SwiftData. Сортируем по имени.
    @Query(sort: \RoomModel.namePinyin) private var savedRooms: [RoomModel]
    
    var ymsapi = YmsApiResponce()
    
    var body: some View {
        VStack {
            List {
                // Теперь отображаем данные из SwiftData, а не из временной @State переменной
                ForEach(savedRooms) { room in
                    Text(room.namePinyin)
                }
                .frame(height: 45)
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
                // Замените roomData.id и roomData.namePinyin на реальные свойства вашего DatumRoom
                let newRoom = RoomModel(
                    id: roomData.id, // Предполагаем, что у DatumRoom есть id
                    namePinyin: roomData.namePinyin
                )
                modelContext.insert(newRoom)
            }
            
            // 4. Сохраняем контекст
            try modelContext.save()
            
        } catch {
            print("Ошибка при загрузке или сохранении комнат: \(error)")
        }
    }
}

// MARK: - Preview
#Preview {
    // 1. Создаем конфигурацию (хранение только в памяти, чтобы не засорять базу при превью)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    // 2. Создаем контейнер
    let container = try! ModelContainer(for: RoomModel.self, configurations: config)
    
    // 3. Добавляем тестовые данные в контекст
    let context = container.mainContext
    context.insert(RoomModel(id: "1", namePinyin: "Комната А"))
    context.insert(RoomModel(id: "2", namePinyin: "Зал Б"))
    
    // 4. Возвращаем View с привязанным контейнером
    return SelectRoomView()
        .modelContainer(container)
}
