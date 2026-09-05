//
//  DataStorage.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import Foundation

// MARK: - Протокол хранилища ключ-значение (DIP: вместо прямого UserDefaults)

protocol DataStorage {
    func string(forKey defaultName: String) -> String?
    func object(forKey defaultName: String) -> Any?
    func data(forKey defaultName: String) -> Data?

    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)

    func removeObject(forKey defaultName: String)
}

// UserDefaults уже предоставляет все методы — конформность пустая.
extension UserDefaults: DataStorage {}