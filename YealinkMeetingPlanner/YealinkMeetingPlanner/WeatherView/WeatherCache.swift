//
//  WeatherCache.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import Foundation

/// Кэш прогноза погоды по городам (SRP: извлечён из `WeatherViewModel`).
/// Хранение в UserDefaults с контролем актуальности по timestamp.
struct WeatherCache {

    private static let dataKeyPrefix = "weather_cache_data_"
    private static let timestampKeyPrefix = "weather_cache_ts_"
    private static let validitySeconds: TimeInterval = 30 * 60 // 30 минут

    private let storage: DataStorage

    init(storage: DataStorage) {
        self.storage = storage
    }

    /// Загружает кэшированный прогноз для города.
    func load(cityId: String) -> WeatherData? {
        guard let data = storage.data(forKey: Self.dataKeyPrefix + cityId) else { return nil }
        return try? JSONDecoder().decode(WeatherData.self, from: data)
    }

    /// Сохраняет прогноз для города вместе с timestamp.
    func save(_ data: WeatherData, cityId: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            storage.set(encoded, forKey: Self.dataKeyPrefix + cityId)
            storage.set(Date().timeIntervalSince1970, forKey: Self.timestampKeyPrefix + cityId)
        }
    }

    /// Актуален ли кэш для города.
    func isCacheValid(cityId: String) -> Bool {
        guard let ts = storage.object(forKey: Self.timestampKeyPrefix + cityId) as? TimeInterval else {
            return false
        }
        return Date().timeIntervalSince1970 - ts < Self.validitySeconds
    }
}