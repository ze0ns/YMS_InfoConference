//
//  PinEntryView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import SwiftUI

/// Экран запроса пин-кода для доступа к настройкам.
/// При успешном вводе вызывает onSuccess.
struct PinEntryView: View {
    let onSuccess: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var settings = SettingsStore.shared

    @State private var enteredPin = ""
    @State private var wrongAttempts = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundColor(.accentColor)

            Text("Введите пин-код")
                .font(.title2.bold())

            // Индикатор введённых цифр
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < enteredPin.count ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.top, 4)

            if wrongAttempts > 0 {
                Text("Неверный пин-код")
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            // Скрытое поле ввода
            TextField("", text: $enteredPin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: enteredPin) { _, newValue in
                    let filtered = String(newValue.prefix(4)).filter(\.isNumber)
                    if filtered != newValue {
                        enteredPin = filtered
                    }
                    // Проверяем автоматически, когда введено 4 цифры
                    if filtered.count == 4 {
                        verifyPin(filtered)
                    }
                }

            Button("Отмена") {
                dismiss()
            }
            .padding(.top, 20)
        }
        .padding(30)
        .presentationDetents([.medium])
        .onAppear { isFocused = true }
    }

    private func verifyPin(_ pin: String) {
        if settings.checkPin(pin) {
            onSuccess()
        } else {
            wrongAttempts += 1
            // Небольшая задержка, чтобы пользователь увидел 4-ю точку
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                enteredPin = ""
            }
        }
    }
}

#Preview {
    PinEntryView(onSuccess: {})
}
