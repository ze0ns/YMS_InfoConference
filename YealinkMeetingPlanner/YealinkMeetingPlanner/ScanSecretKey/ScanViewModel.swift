//
//  MainViewModel.swift
//  scantext
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//


import Foundation
import Observation

@Observable
final class ScanViewModel {
    // Ключи хранения в Keychain (используются также в APIConfig для запросов к API)
    static let secretKeychainKey = "yl_secret_key"
    static let accessKeychainKey = "yl_access_key"

    private let keychain: KeychainService

    // Состояние полей ввода
    var text1: String = ""
    var text2: String = ""

    // Сообщение о результате сохранения
    var saveResultMessage: String?

    // Состояние сканера
    var isScannerPresented: Bool = false
    var activeScannerField: Int = 1 // 1 или 2, чтобы знать, куда сохранить результат

    // Валидация: кнопка "Сохранить" активна только если оба поля заполнены
    var isSaveEnabled: Bool {
        !text1.isEmpty && !text2.isEmpty
    }

    init(keychain: KeychainService? = nil) {
        self.keychain = keychain ?? KeychainManager.shared

        // Предзаполняем поля значениями из Keychain, если они уже сохранены
        text1 = self.keychain.load(key: Self.secretKeychainKey) ?? ""
        text2 = self.keychain.load(key: Self.accessKeychainKey) ?? ""
    }
    
    /// Открывает сканер для указанного поля (1 — секретный ключ, 2 — ключ доступа).
    func openScanner(for field: Int) {
        activeScannerField = field
        isScannerPresented = true
    }
    
    /// Записывает распознанный текст в активное поле ввода.
    func handleScannedText(_ text: String) {
        if activeScannerField == 1 {
            text1 = text
        } else {
            text2 = text
        }
    }
    
    /// Сохраняет введённые ключи в Keychain и показывает результат.
    func saveData() {
        let success1 = keychain.save(key: Self.secretKeychainKey, value: text1)
        let success2 = keychain.save(key: Self.accessKeychainKey, value: text2)

        saveResultMessage = (success1 && success2)
            ? "Ключи сохранены в Keychain"
            : "Ошибка сохранения ключей"
    }

    /// Удаляет ключи из Keychain — API вернётся к ключам из Config.plist
    func deleteData() {
        keychain.delete(key: Self.secretKeychainKey)
        keychain.delete(key: Self.accessKeychainKey)
        text1 = ""
        text2 = ""
        saveResultMessage = "Ключи удалены, используются ключи из Config.plist"
    }
}
