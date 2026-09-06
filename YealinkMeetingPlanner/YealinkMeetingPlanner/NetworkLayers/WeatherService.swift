import Foundation

// MARK: - Протокол

protocol WeatherServiceProtocol {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData
}

// MARK: - Реализация (Open-Meteo)

final class WeatherService: WeatherServiceProtocol {
    static let shared = WeatherService()

    private init() {}

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        guard let url = makeURL(latitude: latitude, longitude: longitude) else {
            throw NetError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NetError.invalidResponse(statusCode: code)
        }

        do {
            return try JSONDecoder().decode(WeatherData.self, from: data)
        } catch {
            throw NetError.decodingFailed(underlying: error)
        }
    }

    private func makeURL(latitude: Double, longitude: Double) -> URL? {
        URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_min,temperature_2m_max,precipitation_sum,wind_speed_10m_max,weather_code&current=temperature_2m,wind_speed_10m,weather_code,precipitation&timezone=Europe%2FMoscow&forecast_days=3")
    }
}
