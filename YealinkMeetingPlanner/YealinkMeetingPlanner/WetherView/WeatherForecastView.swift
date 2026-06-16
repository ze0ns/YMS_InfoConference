//
//  WeatherForecastView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//
import SwiftUI
import Combine

struct WeatherForecastView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    var body: some View {
        ZStack {
            if weatherViewModel.isLoading {
                loadingView
            } else if let errorMessage = weatherViewModel.errorMessage {
                errorView(message: errorMessage)
            } else if let data = weatherViewModel.weatherData {
                weatherContent(data: data)
            }
        }
        .onAppear {
            weatherViewModel.fetchWeather(latitude: 45.0328, longitude: 38.9769)
        }
        .background(Color.bgColorScheduler)
    }
    
    // MARK: - Состояния (вынесены из body)
    @ViewBuilder
    private var loadingView: some View {
        ProgressView("Загрузка...")
            .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Ошибка: \(message)")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Button("Повторить") {
                weatherViewModel.fetchWeather(latitude: 45.0328, longitude: 38.9769)
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    // MARK: - Основной контент
    @ViewBuilder
    private func weatherContent(data: WeatherData) -> some View {
        HStack(spacing: 26) {
            currentWeatherView(data: data)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            dailyForecastView(data: data)
        }
    }
    
    // MARK: - Текущая погода
    @ViewBuilder
    private func currentWeatherView(data: WeatherData) -> some View {
        HStack {
            Spacer()
            Image(systemName: weatherViewModel.getWeatherIconFor(for: data.current.weatherCode))
                .resizable()
                .scaledToFit() // Исправлено с scaledToFill
                .frame(width: 60, height: 60)
                .symbolRenderingMode(.multicolor)
                .padding(.trailing, 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Сейчас")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("\(Int(data.current.temperature2M))°C")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "wind")
                    Text("\(Int(data.current.windSpeed10M)) м/с")
                    
                    Image(systemName: "humidity")
                    Text("\(Int(data.current.precipitation))%")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding()
        .cornerRadius(12)
    }
    
    // MARK: - Прогноз на 3 дня
    @ViewBuilder
    private func dailyForecastView(data: WeatherData) -> some View {
        HStack(spacing: 12) {
            let daysToShow = min(3, data.daily.time.count)
            
            ForEach(0..<daysToShow, id: \.self) { (idx: Int) in
                VStack {
                    Text(formatDate(data.daily.time[idx]))
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.white)
                    
                    Image(systemName: weatherViewModel.getWeatherIconFor(for: data.daily.weatherCode[idx]))
                        .symbolRenderingMode(.multicolor)
                        .font(.title)
                    
                    Text("\(Int(data.daily.temperature2MMax[idx]))°C / \(Int(data.daily.temperature2MMin[idx]))°C")
                        .frame(width: 100, alignment: .leading)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label("\(Int(data.daily.windSpeed10MMax[idx])) м/с", systemImage: "wind")
                        Label("\(Int(data.daily.precipitationSum[idx]))%", systemImage: "humidity")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                }
                .font(.subheadline)
                
                if idx < daysToShow - 1 {
                    Divider()
                        .background(Color.white.opacity(0.3))
                }
            }
            Spacer()
        }
        .padding()
        .cornerRadius(12)
    }
    
    // MARK: - Вспомогательные функции
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "ru_RU")
            outputFormatter.dateFormat = "EEE, d MMM"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
}
#Preview {
    WeatherForecastView()
}

