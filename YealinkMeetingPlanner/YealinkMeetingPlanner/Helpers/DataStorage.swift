//
//  DataStorage.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

// MARK: - Протокол хранилища ключ-значение (DIP: вместо прямого UserDefaults)

/// Хранилище «ключ-значение» (DIP: вместо прямого использования UserDefaults).
protocol DataStorage {
    /// Строковое значение по ключу.
    func string(forKey defaultName: String) -> String?
    /// Логическое значение по ключу.
    func bool(forKey defaultName: String) -> Bool
    /// Любое значение по ключу (Number/Data/String) для чтения типов, которых нет в протоколе.
    func object(forKey defaultName: String) -> Any?
    /// Data-значение по ключу.
    func data(forKey defaultName: String) -> Data?

    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)

    /// Удаляет значение по ключу.
    func removeObject(forKey defaultName: String)
}

// UserDefaults уже предоставляет все методы — конформность пустая.
extension UserDefaults: DataStorage {}