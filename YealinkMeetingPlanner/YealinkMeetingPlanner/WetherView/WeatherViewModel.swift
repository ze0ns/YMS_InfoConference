//
//  WeatherViewModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 04.06.2026.
//

import SwiftUI
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()

    
    func fetchWeather(latitude: Double, longitude: Double) {
        isLoading = true
        errorMessage = nil
        WeatherService.shared.fetchWeatherData(latitude: latitude, longitude: longitude)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                },
                receiveValue: { data in
                    self.weatherData = data
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    func getWeatherIconFor(for code: Int) -> String {
        // Словарь: Код WMO -> Имя SF Symbol
        let weatherMap: [Int: String] = [
            0: "sun.max.fill",             // Ясно
            1: "cloud.sun.fill",           // Преимущественно ясно
            2: "cloud.fill",               // Переменная облачность
            3: "smoke.fill",               // Пасмурно (Apple использует smoke для сплошной облачности)
            45: "cloud.fog.fill",          // Туман
            51: "cloud.drizzle.fill",      // Легкая морось
            61: "cloud.rain.fill",         // Небольшой дождь
            63: "cloud.heavyrain.fill",    // Дождь
            71: "cloud.snow.fill",         // Небольшой снег
            80: "cloud.sun.rain.fill",     // Ливень (дождь с прояснениями)
            95: "cloud.bolt.fill"          // Гроза
        ]
        
        // Если код есть в словаре, возвращаем имя иконки.
        // Если нет — возвращаем иконку вопроса по умолчанию.
        return weatherMap[code] ?? "questionmark.circle.fill"
    }
}
