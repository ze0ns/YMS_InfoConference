import Foundation
import os

// MARK: - Протокол конфигурации API

protocol APICredentialsProviding {
    var hostURL: String { get }
    var currentYlSecretKey: String { get }
    var currentYlAccessKey: String { get }
    var usesKeychainKeys: Bool { get }
}

// MARK: - Реализация

struct APIConfig: APICredentialsProviding {
    private let keychain: KeychainService

    init(keychain: KeychainService = KeychainManager.shared) {
        self.keychain = keychain
    }

    private static let plist: [String: Any]? = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            AppLog.app.error("Файл Config.plist не найден или поврежден")
            return nil
        }
        return dict
    }()

    var hostURL: String { Self.plist?["hostURL"] as? String ?? "" }

    // MARK: - Keychain keys

    private var keychainSecretKey: String? {
        keychain.load(key: ScanViewModel.secretKeychainKey)
    }

    private var keychainAccessKey: String? {
        keychain.load(key: ScanViewModel.accessKeychainKey)
    }

    var usesKeychainKeys: Bool {
        keychainSecretKey != nil && keychainAccessKey != nil
    }

    var currentYlSecretKey: String { keychainSecretKey ?? "" }
    var currentYlAccessKey: String { keychainAccessKey ?? "" }
}