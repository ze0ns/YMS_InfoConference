//
//  SettingsView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import SwiftUI

/// Экран настроек: выбор города, смена пин-кода, выбор комнаты
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = SettingsStore.shared
    @State private var appState = AppState.shared
    @State private var isChangePinPresented = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Город
                Section("Погода") {
                    NavigationLink {
                        CityPickerView()
                    } label: {
                        LabeledContent("Город", value: settings.selectedCity.name)
                    }
                }

                // MARK: Пин-код
                Section("Безопасность") {
                    Button {
                        isChangePinPresented = true
                    } label: {
                        LabeledContent("Пин-код", value: "Изменить")
                    }
                }

                // MARK: Комната
                Section("Конференции") {
                    NavigationLink {
                        SelectRoomView()
                    } label: {
                        LabeledContent("Комната", value: appState.selectedRoom?.namePinyin ?? "Не выбрана")
                    }
                }

                // MARK: Ключи доступа к серверу
                Section("Сервер") {
                    NavigationLink {
                        KeysScannerView()
                    } label: {
                        LabeledContent(
                            "Ключи доступа",
                            value: APIConfig.usesKeychainKeys ? "Сканированы" : "Config.plist"
                        )
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .sheet(isPresented: $isChangePinPresented) {
                ChangePinView()
            }
        }
    }
}

// MARK: - Выбор города
private struct CityPickerView: View {
    @State private var settings = SettingsStore.shared

    var body: some View {
        List(CityCatalog.cities) { city in
            Button {
                settings.selectedCity = city
            } label: {
                HStack {
                    Text(city.name)
                        .foregroundColor(.primary)
                    Spacer()
                    if settings.selectedCity == city {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .fontWeight(.bold)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Город")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Смена пин-кода
private struct ChangePinView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = SettingsStore.shared

    @State private var newPin = ""
    @State private var confirmPin = ""
    @State private var errorMessage: String?
    @FocusState private var isNewPinFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Новый пин-код (4 цифры)") {
                    SecureField("Пин-код", text: $newPin)
                        .keyboardType(.numberPad)
                        .focused($isNewPinFocused)
                        .onChange(of: newPin) { _, value in
                            newPin = String(value.prefix(4).filter(\.isNumber))
                        }
                    SecureField("Повторите пин-код", text: $confirmPin)
                        .keyboardType(.numberPad)
                        .onChange(of: confirmPin) { _, value in
                            confirmPin = String(value.prefix(4).filter(\.isNumber))
                        }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                Section {
                    Button("Сохранить") { savePin() }
                        .disabled(newPin.count != 4 || confirmPin.count != 4)
                }
            }
            .navigationTitle("Смена пин-кода")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onAppear { isNewPinFocused = true }
        }
    }

    private func savePin() {
        guard newPin == confirmPin else {
            errorMessage = "Пин-коды не совпадают"
            return
        }
        if settings.changePin(to: newPin) {
            dismiss()
        } else {
            errorMessage = "Не удалось сохранить пин-код"
        }
    }
}

#Preview {
    SettingsView()
}
