//
//  WeatherService.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.06.2026.
//
import Foundation
import Combine

class WeatherService {
    static let shared = WeatherService()
    
    private init() {}
    
    func fetchWeatherData(latitude: Double, longitude: Double) -> AnyPublisher<WeatherData, Error> {
        guard let url = createURL(latitude: latitude, longitude: longitude) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func createURL(latitude: Double, longitude: Double) -> URL? {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=45.0328&longitude=38.9769&daily=temperature_2m_min,temperature_2m_max,precipitation_sum,wind_speed_10m_max,weather_code&current=temperature_2m,wind_speed_10m,weather_code,precipitation&timezone=Europe%2FMoscow&forecast_days=3"
        return URL(string: urlString)
    }
}

