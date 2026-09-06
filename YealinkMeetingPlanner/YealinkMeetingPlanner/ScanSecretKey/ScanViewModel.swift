import Foundation
import Observation

@Observable
final class ScanViewModel {
    // Ключи хранения в Keychain (используются также в APIConfig для запросов к API)
    static let secretKeychainKey = "yl_secret_key"
    static let accessKeychainKey = "yl_access_key"

    private let keychain: KeychainService

    var text1: String = ""
    var text2: String = ""

    var saveResultMessage: String?

    var isScannerPresented: Bool = false
    var activeScannerField: Int = 1

    var isSaveEnabled: Bool {
        !text1.isEmpty && !text2.isEmpty
    }

    init(keychain: KeychainService? = nil) {
        self.keychain = keychain ?? KeychainManager.shared

        text1 = self.keychain.load(key: Self.secretKeychainKey) ?? ""
        text2 = self.keychain.load(key: Self.accessKeychainKey) ?? ""
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
        let success1 = keychain.save(key: Self.secretKeychainKey, value: text1)
        let success2 = keychain.save(key: Self.accessKeychainKey, value: text2)

        saveResultMessage = (success1 && success2)
            ? "Ключи сохранены в Keychain"
            : "Ошибка сохранения ключей"
    }

    func deleteData() {
        keychain.delete(key: Self.secretKeychainKey)
        keychain.delete(key: Self.accessKeychainKey)
        text1 = ""
        text2 = ""
        saveResultMessage = "Ключи удалены, используются ключи из Config.plist"
    }
}
