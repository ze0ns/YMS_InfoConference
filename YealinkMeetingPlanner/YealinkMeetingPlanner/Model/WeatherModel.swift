//
//  WeatherModel.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.06.2026.
//



import Foundation

// MARK: - WeatherModel
struct WeatherData: Codable {
    let latitude: Double
    let longitude: Int
    let current: Current
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case current
        case daily
    }
}

// MARK: - Current
struct Current: Codable {
    let time: String
    let interval: Int
    let temperature2M, windSpeed10M: Double
    let weatherCode, precipitation: Int

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case windSpeed10M = "wind_speed_10m"
        case weatherCode = "weather_code"
        case precipitation
    }
}

// MARK: - Daily
struct Daily: Codable {
    let time: [String]
    let temperature2MMin, temperature2MMax, precipitationSum, windSpeed10MMax: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2MMin = "temperature_2m_min"
        case temperature2MMax = "temperature_2m_max"
        case precipitationSum = "precipitation_sum"
        case windSpeed10MMax = "wind_speed_10m_max"
        case weatherCode = "weather_code"
    }
}
