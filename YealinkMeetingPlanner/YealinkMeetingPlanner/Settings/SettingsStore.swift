import Foundation
import Observation

// MARK: - Модель города
struct City: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
}

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

    private static let cityDefaultsKey = "settings_selected_city_id"
    private static let demoEnabledKey = "settings_demo_enabled"
    private static let serverURLKey = "settings_server_url"

    private let storage: DataStorage
    private let pinManager: PinManager

    var selectedCity: City {
        didSet { storage.set(selectedCity.id, forKey: Self.cityDefaultsKey) }
    }

    var isDemoEnabled: Bool {
        didSet { storage.set(isDemoEnabled, forKey: Self.demoEnabledKey) }
    }

    var serverURL: String {
        didSet { storage.set(serverURL, forKey: Self.serverURLKey) }
    }

    init(keychain: KeychainService? = nil, storage: DataStorage? = nil) {
        self.storage = storage ?? UserDefaults.standard
        self.pinManager = PinManager(keychain: keychain)

        let savedCityId = self.storage.string(forKey: Self.cityDefaultsKey)
        selectedCity = CityCatalog.cities.first { $0.id == savedCityId }
            ?? CityCatalog.cities[0]

        isDemoEnabled = self.storage.bool(forKey: Self.demoEnabledKey)
        serverURL = self.storage.string(forKey: Self.serverURLKey) ?? ""
    }

    @discardableResult
    func changePin(to newPin: String) -> Bool {
        pinManager.changePin(to: newPin)
    }

    func checkPin(_ entered: String) -> Bool {
        pinManager.checkPin(entered)
    }
}