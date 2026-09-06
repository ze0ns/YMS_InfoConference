//
//  WeatherViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 04.06.2026.
//

import Foundation
import Observation
import os

@MainActor
@Observable
final class WeatherViewModel {
    var weatherData: WeatherData?
    var isLoading = false
    var errorMessage: String?

    private let service: WeatherServiceProtocol
    private let settings: SettingsStore
    private let cache: WeatherCache

    init(service: WeatherServiceProtocol? = nil, settings: SettingsStore? = nil, storage: DataStorage? = nil) {
        self.service = service ?? WeatherService.shared
        self.settings = settings ?? SettingsStore.shared
        self.cache = WeatherCache(storage: storage ?? UserDefaults.standard)
    }

    /// Загружает погоду для выбранного в настройках города.
    /// View не знает ни про город, ни про координаты.
    func fetchWeather() async {
        let city = settings.selectedCity

        // Кэш текущего города актуален — не ходим в сеть
        if cache.isCacheValid(cityId: city.id) {
            weatherData = cache.load(cityId: city.id)
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let data = try await service.fetchWeather(latitude: city.latitude, longitude: city.longitude)
            weatherData = data
            cache.save(data, cityId: city.id)
        } catch {
            // Ошибка показывается только если нет данных вообще — иначе остаётся прежний прогноз
            if weatherData == nil {
                errorMessage = error.localizedDescription
            }
            AppLog.network.error("Ошибка погоды: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Форматирование дат прогноза

    /// "2026-09-05" → "сб, 5 сент"
    func formatDate(_ dateString: String) -> String {
        if let date = DateFormatters.isoDate.date(from: dateString) {
            return DateFormatters.shortWeekdayDay.string(from: date)
        }
        return dateString
    }
}