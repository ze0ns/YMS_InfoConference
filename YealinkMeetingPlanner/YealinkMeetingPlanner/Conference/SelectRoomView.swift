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
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = SelectRoomViewModel()

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.rooms) { room in
                    Button {
                        viewModel.selectedRoom = room
                    } label: {
                        HStack {
                            Text(room.namePinyin)
                                .foregroundColor(.primary)

                            Spacer()

                            if viewModel.selectedRoom?.id == room.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.rooms.isEmpty {
                ProgressView()
            }
        }

        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))

        .navigationTitle("Выбор комнаты")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") {
                    dismiss()
                }
                .disabled(viewModel.selectedRoom == nil)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: RoomModel.self, configurations: config)

    let context = container.mainContext
    context.insert(RoomModel(id: "1", namePinyin: "Комната А"))
    context.insert(RoomModel(id: "2", namePinyin: "Зал Б"))

    return NavigationStack {
        SelectRoomView()
            .modelContainer(container)
    }
}
