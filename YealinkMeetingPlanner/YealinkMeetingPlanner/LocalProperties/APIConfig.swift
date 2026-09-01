//
//  APIConfig.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//


import Foundation
import os

struct APIConfig {
    private static func loadPlistDict() -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            AppLog.app.error("Файл Config.plist не найден или поврежден")
            return nil
        }
        return dict
    }
    static let ylSecretKey = loadPlistDict()?["ylSecretKey"] as? String ?? ""
    static let ylAccessKey = loadPlistDict()?["ylAccessKey"] as? String ?? ""
    static let baseUrl = loadPlistDict()?["baseUrl"] as? String ?? ""
    static let hostURL = loadPlistDict()?["hostURL"] as? String ?? ""

    // MARK: - Актуальные ключи: Keychain имеет приоритет над Config.plist

    // MARK: - Ключи из Keychain (с кэшем)

    /// Кэш значений из Keychain: подпись каждого запроса читает оба ключа,
    /// а SecItemCopyMatching — дорогая операция. Кэш читается один раз
    /// и инвалидируется через `invalidateKeychainCache()` после изменения ключей.
    private static var keychainKeyCache: (secret: String?, access: String?)?

    /// Ключи, отсканированные и сохранённые в Keychain (nil — если их там нет)
    static var keychainSecretKey: String? {
        loadKeychainCache().secret
    }
    static var keychainAccessKey: String? {
        loadKeychainCache().access
    }

    /// Сбрасывает кэш ключей Keychain. Вызывать после сохранения/удаления ключей.
    static func invalidateKeychainCache() {
        keychainKeyCache = nil
    }

    private static func loadKeychainCache() -> (secret: String?, access: String?) {
        if let keychainKeyCache {
            return keychainKeyCache
        }
        let cache = (
            secret: KeychainManager.shared.load(key: ScanViewModel.secretKeychainKey),
            access: KeychainManager.shared.load(key: ScanViewModel.accessKeychainKey)
        )
        keychainKeyCache = cache
        return cache
    }

    /// Используются ли в данный момент ключи из Keychain
    static var usesKeychainKeys: Bool {
        keychainSecretKey != nil && keychainAccessKey != nil
    }

    /// Актуальные ключи для подписи запросов к API
    static var currentYlSecretKey: String { keychainSecretKey ?? ylSecretKey }
    static var currentYlAccessKey: String { keychainAccessKey ?? ylAccessKey }

}
