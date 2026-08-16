//
//  MainViewModel.swift
//  scantext
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//


import Foundation
import Combine

class ScanViewModel: ObservableObject {
    // Ключи хранения в Keychain (используются также в APIConfig для запросов к API)
    static let secretKeychainKey = "yl_secret_key"
    static let accessKeychainKey = "yl_access_key"

    // Состояние полей ввода
    @Published var text1: String = ""
    @Published var text2: String = ""

    // Сообщение о результате сохранения
    @Published var saveResultMessage: String?

    // Состояние сканера
    @Published var isScannerPresented: Bool = false
    @Published var activeScannerField: Int = 1 // 1 или 2, чтобы знать, куда сохранить результат

    // Валидация: кнопка "Сохранить" активна только если оба поля заполнены
    var isSaveEnabled: Bool {
        !text1.isEmpty && !text2.isEmpty
    }

    init() {
        // Предзаполняем поля значениями из Keychain, если они уже сохранены
        text1 = KeychainManager.shared.load(key: Self.secretKeychainKey) ?? ""
        text2 = KeychainManager.shared.load(key: Self.accessKeychainKey) ?? ""
    }
    
    func openScanner(for field: Int) {
        activeScannerField = field
        isScannerPresented = true
    }
    
    func handleScannedText(_ text: String) {
        if activeScannerField == 1 {
            text1 = text
        } else {
            text2 = text
        }
    }
    
    func saveData() {
        let success1 = KeychainManager.shared.save(key: Self.secretKeychainKey, value: text1)
        let success2 = KeychainManager.shared.save(key: Self.accessKeychainKey, value: text2)

        saveResultMessage = (success1 && success2)
            ? "Ключи сохранены в Keychain"
            : "Ошибка сохранения ключей"
    }

    /// Удаляет ключи из Keychain — API вернётся к ключам из Config.plist
    func deleteData() {
        KeychainManager.shared.delete(key: Self.secretKeychainKey)
        KeychainManager.shared.delete(key: Self.accessKeychainKey)
        text1 = ""
        text2 = ""
        saveResultMessage = "Ключи удалены, используются ключи из Config.plist"
    }
}
