//
//  WeatherViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 04.06.2026.
//

import SwiftUI
import Combine
import os

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: WeatherServiceProtocol
    private let settings: SettingsStore
    private let storage: DataStorage

    private static let cacheDataKeyPrefix = "weather_cache_data_"
    private static let cacheTimestampKeyPrefix = "weather_cache_ts_"
    private static let cacheValiditySeconds: TimeInterval = 30 * 60 // 30 минут

    init(service: WeatherServiceProtocol? = nil, settings: SettingsStore? = nil, storage: DataStorage? = nil) {
        self.service = service ?? WeatherService.shared
        self.settings = settings ?? SettingsStore.shared
        self.storage = storage ?? UserDefaults.standard
    }

    /// Загружает погоду для выбранного в настройках города.
    /// View не знает ни про город, ни про координаты.
    func fetchWeather() async {
        let city = settings.selectedCity

        // Кэш текущего города актуален — не ходим в сеть
        if isCacheValid(cityId: city.id) {
            weatherData = loadCachedWeather(cityId: city.id)
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let data = try await service.fetchWeather(latitude: city.latitude, longitude: city.longitude)
            weatherData = data
            saveCachedWeather(data, cityId: city.id)
        } catch {
            // Ошибка показывается только если нет данных вообще — иначе остаётся прежний прогноз
            if weatherData == nil {
                errorMessage = error.localizedDescription
            }
            AppLog.network.error("Ошибка погоды: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Иконки погоды (коды WMO → SF Symbols)

    private static let weatherIconNames: [Int: String] = [
        0: "sun.max.fill",
        1: "cloud.sun.fill",
        2: "cloud.fill",
        3: "smoke.fill",
        45: "cloud.fog.fill",
        51: "cloud.drizzle.fill",
        61: "cloud.rain.fill",
        63: "cloud.heavyrain.fill",
        71: "cloud.snow.fill",
        80: "cloud.sun.rain.fill",
        95: "cloud.bolt.fill"
    ]

    static func weatherIconName(for code: Int) -> String {
        weatherIconNames[code] ?? "questionmark.circle.fill"
    }

    // MARK: - Форматирование дат прогноза

    /// "2026-09-05" → "сб, 5 сент"
    func formatDate(_ dateString: String) -> String {
        if let date = DateFormatters.isoDate.date(from: dateString) {
            return DateFormatters.shortWeekdayDay.string(from: date)
        }
        return dateString
    }

    // MARK: - Кэш по городу (UserDefaults)

    private func saveCachedWeather(_ data: WeatherData, cityId: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            storage.set(encoded, forKey: Self.cacheDataKeyPrefix + cityId)
            storage.set(Date().timeIntervalSince1970, forKey: Self.cacheTimestampKeyPrefix + cityId)
        }
    }

    private func loadCachedWeather(cityId: String) -> WeatherData? {
        guard let data = storage.data(forKey: Self.cacheDataKeyPrefix + cityId) else { return nil }
        return try? JSONDecoder().decode(WeatherData.self, from: data)
    }

    private func isCacheValid(cityId: String) -> Bool {
        guard let ts = storage.object(forKey: Self.cacheTimestampKeyPrefix + cityId) as? TimeInterval else {
            return false
        }
        return Date().timeIntervalSince1970 - ts < Self.cacheValiditySeconds
    }
}
