import Foundation

enum WeatherIconMapper {

    private static let iconNames: [Int: String] = [
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

    static func name(for code: Int) -> String {
        iconNames[code] ?? "questionmark.circle.fill"
    }
}