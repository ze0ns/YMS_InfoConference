//
//  SettingsStore.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 16.08.2026.
//
import Foundation
import Observation

// MARK: - Модель города
struct City: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
}

// Список доступных городов
enum CityCatalog {
    static let cities: [City] = [
        City(id: "krasnodar", name: "Краснодар", latitude: 45.0328, longitude: 38.9769),
        City(id: "moscow", name: "Москва", latitude: 55.7558, longitude: 37.6173),
        City(id: "spb", name: "Санкт-Петербург", latitude: 59.9375, longitude: 30.3086),
        City(id: "novosibirsk", name: "Новосибирск", latitude: 55.0084, longitude: 82.9357),
        City(id: "ekaterinburg", name: "Екатеринбург", latitude: 56.8389, longitude: 60.6057),
        City(id: "kazan", name: "Казань", latitude: 55.7963, longitude: 49.1088)
    ]
}

// MARK: - Хранилище настроек
@Observable
class SettingsStore {
    static let shared = SettingsStore()

    private static let pinKeychainKey = "settings_access_pin"
    private static let cityDefaultsKey = "settings_selected_city_id"

    private let keychain: KeychainService
    private let storage: DataStorage

    /// Пин-код доступа к настройкам (по умолчанию "0000")
    private(set) var pin: String

    /// Выбранный город
    var selectedCity: City {
        didSet { storage.set(selectedCity.id, forKey: Self.cityDefaultsKey) }
    }

    init(keychain: KeychainService? = nil, storage: DataStorage? = nil) {
        self.keychain = keychain ?? KeychainManager.shared
        self.storage = storage ?? UserDefaults.standard

        // Пин-код хранится в Keychain; если не задан — используем "0000"
        pin = self.keychain.load(key: Self.pinKeychainKey) ?? "0000"

        let savedCityId = self.storage.string(forKey: Self.cityDefaultsKey)
        selectedCity = CityCatalog.cities.first { $0.id == savedCityId }
            ?? CityCatalog.cities[0]
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
