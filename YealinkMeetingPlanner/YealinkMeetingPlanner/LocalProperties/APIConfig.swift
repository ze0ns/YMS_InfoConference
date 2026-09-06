//
//  APIConfig.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//

import Foundation
import os

// MARK: - Протокол конфигурации API (DIP: подменяется в тестах)

/// Источник адреса сервера и ключей подписи запросов к YMS API.
protocol APICredentialsProviding {
    /// Базовый адрес сервера (без завершающего слэша).
    var hostURL: String { get }
    /// Секретный ключ; приоритет у ключей из Keychain.
    var currentYlSecretKey: String { get }
    /// Ключ доступа; приоритет у ключей из Keychain.
    var currentYlAccessKey: String { get }
    /// Используются ли в данный момент ключи из Keychain.
    var usesKeychainKeys: Bool { get }
}

// MARK: - Реализация (Config.plist + Keychain)

/// Конфигурация API: ключи и адрес читаются из Config.plist,
/// но отсканированные пользователем ключи из Keychain имеют приоритет.
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

    private var ylSecretKey: String { Self.plist?["ylSecretKey"] as? String ?? "" }
    private var ylAccessKey: String { Self.plist?["ylAccessKey"] as? String ?? "" }

    // MARK: - Актуальные ключи: Keychain имеет приоритет над Config.plist

    /// Ключи, отсканированные и сохранённые в Keychain (nil — если их там нет)
    private var keychainSecretKey: String? {
        keychain.load(key: ScanViewModel.secretKeychainKey)
    }

    private var keychainAccessKey: String? {
        keychain.load(key: ScanViewModel.accessKeychainKey)
    }

    var usesKeychainKeys: Bool {
        keychainSecretKey != nil && keychainAccessKey != nil
    }

    var currentYlSecretKey: String { keychainSecretKey ?? ylSecretKey }
    var currentYlAccessKey: String { keychainAccessKey ?? ylAccessKey }
}