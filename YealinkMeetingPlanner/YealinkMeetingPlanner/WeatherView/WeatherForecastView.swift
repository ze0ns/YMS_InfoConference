//
//  WeatherForecastView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//
import SwiftUI

struct WeatherForecastView: View {
    @State private var viewModel: WeatherViewModel

    init(viewModel: WeatherViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? WeatherViewModel())
    }

    var body: some View {
        ZStack {
            // Данные приоритетнее ошибки: при сбое сети остаётся последний прогноз
            if let data = viewModel.weatherData {
                weatherContent(data: data)
            } else if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            }
        }
        .task {
            await viewModel.fetchWeather()
        }
        .background(Color.bgColorScheduler)
    }

    // MARK: - Состояния

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
                Task {
                    await viewModel.fetchWeather()
                }
            }
            .foregroundColor(.blue)
        }
        .padding()
    }

    // MARK: - Основной контент

    @ViewBuilder
    private func weatherContent(data: WeatherData) -> some View {
        HStack(spacing: LayoutDimensions.weatherContentSpacing) {
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
            Image(systemName: WeatherViewModel.weatherIconName(for: data.current.weatherCode))
                .resizable()
                .scaledToFit()
                .frame(width: LayoutDimensions.weatherCurrentIconSize, height: LayoutDimensions.weatherCurrentIconSize)
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
        HStack(spacing: LayoutDimensions.weatherDailyDividerSpacing) {
            let daysToShow = min(3, data.daily.time.count)

            ForEach(0..<daysToShow, id: \.self) { (idx: Int) in
                VStack {
                    Text(viewModel.formatDate(data.daily.time[idx]))
                        .frame(width: LayoutDimensions.weatherDailyDayWidth, alignment: .leading)
                        .foregroundColor(.white)

                    Image(systemName: WeatherViewModel.weatherIconName(for: data.daily.weatherCode[idx]))
                        .symbolRenderingMode(.multicolor)
                        .font(.title)

                    Text("\(Int(data.daily.temperature2MMax[idx]))°C / \(Int(data.daily.temperature2MMin[idx]))°C")
                        .frame(width: LayoutDimensions.weatherDailyTempWidth, alignment: .leading)
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
}

#Preview {
    WeatherForecastView()
}
