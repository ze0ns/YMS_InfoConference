//
//  MainViewModel.swift
//  scantext
//
//  Created by Oschepkov Aleksandr on 27.06.2026.
//


import Foundation
import Combine

class ScanViewModel: ObservableObject {
    // Состояние полей ввода
    @Published var text1: String = ""
    @Published var text2: String = ""
    
    // Состояние сканера
    @Published var isScannerPresented: Bool = false
    @Published var activeScannerField: Int = 1 // 1 или 2, чтобы знать, куда сохранить результат
    
    // Ключи для Keychain
    private let key1 = "secret_code_1"
    private let key2 = "secret_code_2"
    
    // Валидация: кнопка "Сохранить" активна только если оба поля заполнены
    var isSaveEnabled: Bool {
        !text1.isEmpty && !text2.isEmpty
    }
    
    init() {}
    
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
        let success1 = KeychainManager.shared.save(key: key1, value: text1)
        let success2 = KeychainManager.shared.save(key: key2, value: text2)
        
        if success1 && success2 {
            print("✅ Данные успешно и безопасно сохранены в Keychain!")
            // Здесь можно показать алерт об успехе
        } else {
            print("❌ Ошибка сохранения данных")
        }
    }
}
