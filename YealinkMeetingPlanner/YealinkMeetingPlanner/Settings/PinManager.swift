//
//  PinManager.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import Foundation

/// Хранение и проверка пин-кода в Keychain (SRP: извлечено из `SettingsStore`).
final class PinManager {

    private static let pinKeychainKey = "settings_access_pin"

    private let keychain: KeychainService
    private(set) var pin: String

    init(keychain: KeychainService? = nil) {
        self.keychain = keychain ?? KeychainManager.shared

        // Пин-код хранится в Keychain; если не задан — используем "0000"
        pin = self.keychain.load(key: Self.pinKeychainKey) ?? "0000"
    }

    /// Смена пин-кода: сохраняет новый в Keychain
    @discardableResult
    func changePin(to newPin: String) -> Bool {
        guard newPin.count == 4, newPin.allSatisfy(\.isNumber) else { return false }
        let saved = keychain.save(key: Self.pinKeychainKey, value: newPin)
        if saved {
            pin = newPin
        }
        return saved
    }

    func checkPin(_ entered: String) -> Bool {
        entered == pin
    }
}