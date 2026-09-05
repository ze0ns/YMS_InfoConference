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

    private static let cacheDataKeyPrefix = "weather_cache_data_"
    private static let cacheTimestampKeyPrefix = "weather_cache_ts_"
    private static let cacheValiditySeconds: TimeInterval = 30 * 60 // 30 минут

    init(service: WeatherServiceProtocol? = nil, settings: SettingsStore? = nil) {
        self.service = service ?? WeatherService.shared
        self.settings = settings ?? SettingsStore.shared
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

    static func weatherIconName(for code: Int) -> String {
        switch code {
        case 0:  return "sun.max.fill"
        case 1:  return "cloud.sun.fill"
        case 2:  return "cloud.fill"
        case 3:  return "smoke.fill"
        case 45: return "cloud.fog.fill"
        case 51: return "cloud.drizzle.fill"
        case 61: return "cloud.rain.fill"
        case 63: return "cloud.heavyrain.fill"
        case 71: return "cloud.snow.fill"
        case 80: return "cloud.sun.rain.fill"
        case 95: return "cloud.bolt.fill"
        default: return "questionmark.circle.fill"
        }
    }

    // MARK: - Форматирование дат прогноза

    /// "2026-09-05" → "сб, 5 сент"
    func formatDate(_ dateString: String) -> String {
        if let date = Self.inputDateFormatter.date(from: dateString) {
            return Self.outputDateFormatter.string(from: date)
        }
        return dateString
    }

    private static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE, d MMM"
        return formatter
    }()

    // MARK: - Кэш по городу (UserDefaults)

    private func saveCachedWeather(_ data: WeatherData, cityId: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.cacheDataKeyPrefix + cityId)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Self.cacheTimestampKeyPrefix + cityId)
        }
    }

    private func loadCachedWeather(cityId: String) -> WeatherData? {
        guard let data = UserDefaults.standard.data(forKey: Self.cacheDataKeyPrefix + cityId) else { return nil }
        return try? JSONDecoder().decode(WeatherData.self, from: data)
    }

    private func isCacheValid(cityId: String) -> Bool {
        guard let ts = UserDefaults.standard.object(forKey: Self.cacheTimestampKeyPrefix + cityId) as? TimeInterval else {
            return false
        }
        return Date().timeIntervalSince1970 - ts < Self.cacheValiditySeconds
    }
}
