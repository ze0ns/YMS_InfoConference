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
    let generationtimeMS: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Int
    let currentUnits: CurrentUnits
    let current: Current
    let dailyUnits: DailyUnits
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
        case generationtimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone = "timezone"
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation = "elevation"
        case currentUnits = "current_units"
        case current = "current"
        case dailyUnits = "daily_units"
        case daily = "daily"
    }
}

// MARK: - Current
struct Current: Codable {
    let time: String
    let interval: Int
    let temperature2M: Double
    let windSpeed10M: Double
    let weatherCode: Int
    let precipitation: Double

    enum CodingKeys: String, CodingKey {
        case time = "time"
        case interval = "interval"
        case temperature2M = "temperature_2m"
        case windSpeed10M = "wind_speed_10m"
        case weatherCode = "weather_code"
        case precipitation = "precipitation"
    }
}

// MARK: - CurrentUnits
struct CurrentUnits: Codable {
    let time: String
    let interval: String
    let temperature2M: String
    let windSpeed10M: String
    let weatherCode: String
    let precipitation: String

    enum CodingKeys: String, CodingKey {
        case time = "time"
        case interval = "interval"
        case temperature2M = "temperature_2m"
        case windSpeed10M = "wind_speed_10m"
        case weatherCode = "weather_code"
        case precipitation = "precipitation"
    }
}

// MARK: - Daily
struct Daily: Codable {
    let time: [String]
    let temperature2MMin: [Double]
    let temperature2MMax: [Double]
    let precipitationSum: [Double]
    let windSpeed10MMax: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time = "time"
        case temperature2MMin = "temperature_2m_min"
        case temperature2MMax = "temperature_2m_max"
        case precipitationSum = "precipitation_sum"
        case windSpeed10MMax = "wind_speed_10m_max"
        case weatherCode = "weather_code"
    }
}

// MARK: - DailyUnits
struct DailyUnits: Codable {
    let time: String
    let temperature2MMin: String
    let temperature2MMax: String
    let precipitationSum: String
    let windSpeed10MMax: String
    let weatherCode: String

    enum CodingKeys: String, CodingKey {
        case time = "time"
        case temperature2MMin = "temperature_2m_min"
        case temperature2MMax = "temperature_2m_max"
        case precipitationSum = "precipitation_sum"
        case windSpeed10MMax = "wind_speed_10m_max"
        case weatherCode = "weather_code"
    }
}
