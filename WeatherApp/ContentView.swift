import SwiftUI
import WeatherKit
import WeatherUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel(repository: WeatherRepository())
    @State private var searchText = ""
    @State private var showingSearch = false

    var body: some View {
        backgroundGradient
            .ignoresSafeArea()
            .overlay {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if viewModel.isLoading {
                            loadingView
                        } else if let error = viewModel.errorMessage, viewModel.currentWeather == nil {
                            errorView(error)
                        } else if viewModel.currentWeather != nil {
                            myLocationCard
                            if !viewModel.hourlyForecast.isEmpty {
                                hourlyForecastCard
                            }
                            if !viewModel.dailyForecast.isEmpty {
                                dailyForecastCard
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                        Spacer()
                        Button { showingSearch = true } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
            }
            .task {
                await viewModel.loadWeatherForCurrentLocation()
            }
            .sheet(isPresented: $showingSearch) {
                searchView
            }
    }

    // MARK: - Background

    private var backgroundGradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
    }

    private var gradientColors: [Color] {
        guard let weather = viewModel.currentWeather else {
            return [Color(red: 0.18, green: 0.35, blue: 0.60), Color(red: 0.10, green: 0.20, blue: 0.38)]
        }
        if !weather.isDay {
            return [Color(red: 0.08, green: 0.13, blue: 0.25), Color(red: 0.04, green: 0.08, blue: 0.17)]
        }
        switch weather.condition {
        case .clear:
            return [Color(red: 0.29, green: 0.56, blue: 0.89), Color(red: 0.53, green: 0.80, blue: 0.95)]
        case .partlyCloudy:
            return [Color(red: 0.34, green: 0.54, blue: 0.78), Color(red: 0.50, green: 0.68, blue: 0.88)]
        case .cloudy, .overcast, .fog:
            return [Color(red: 0.42, green: 0.49, blue: 0.58), Color(red: 0.57, green: 0.63, blue: 0.71)]
        case .rain, .drizzle, .showers, .freezingRain:
            return [Color(red: 0.25, green: 0.33, blue: 0.44), Color(red: 0.16, green: 0.22, blue: 0.32)]
        case .snow:
            return [Color(red: 0.53, green: 0.68, blue: 0.84), Color(red: 0.70, green: 0.82, blue: 0.93)]
        case .thunderstorm:
            return [Color(red: 0.18, green: 0.19, blue: 0.27), Color(red: 0.10, green: 0.11, blue: 0.18)]
        case .unknown:
            return [Color(red: 0.18, green: 0.35, blue: 0.60), Color(red: 0.10, green: 0.20, blue: 0.38)]
        }
    }

    // MARK: - My Location Card

    private var myLocationCard: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 3) {
                Text("My Location")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.75))
                    .tracking(1.5)
                    .textCase(.uppercase)
                if let location = viewModel.currentLocation {
                    Text(location.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(.bottom, 20)

            if let weather = viewModel.currentWeather {
                // Icon
                Image(systemName: weather.condition.systemIconName)
                    .font(.system(size: 72))
                    .symbolRenderingMode(.multicolor)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    .padding(.bottom, 4)

                // Temperature (tap to toggle °C/°F)
                Text(viewModel.displayTemperature(weather.temperature))
                    .font(.system(size: 96, weight: .thin))
                    .foregroundStyle(.white)
                    .padding(.bottom, 2)
                    .onTapGesture {
                        viewModel.toggleTemperatureUnit()
                    }

                // Condition
                Text(weather.condition.description)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.bottom, 10)

                // Feels like + H/L
                HStack(spacing: 6) {
                    if let feelsLike = weather.feelsLike {
                        Text("Feels like \(viewModel.displayTemperature(feelsLike))")
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    if let today = viewModel.dailyForecast.first {
                        if weather.feelsLike != nil {
                            Text("·").foregroundStyle(.white.opacity(0.45))
                        }
                        Text("H:\(viewModel.displayTemperature(today.temperatureHigh))")
                            .foregroundStyle(.white.opacity(0.85))
                        Text("L:\(viewModel.displayTemperature(today.temperatureLow))")
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 20)

                // Sunrise / Sunset
                if let today = viewModel.dailyForecast.first,
                   today.sunrise != nil || today.sunset != nil {
                    Rectangle()
                        .fill(.white.opacity(0.25))
                        .frame(height: 0.5)
                        .padding(.bottom, 16)

                    HStack(alignment: .top) {
                        if let sunrise = today.sunrise {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 4) {
                                    Image(systemName: "sunrise.fill")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.caption)
                                    Text("SUNRISE")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.65))
                                        .tracking(0.8)
                                }
                                Text(sunrise, style: .time)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }

                        Spacer()

                        if let sunset = today.sunset {
                            VStack(alignment: .trailing, spacing: 5) {
                                HStack(spacing: 4) {
                                    Text("SUNSET")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.65))
                                        .tracking(0.8)
                                    Image(systemName: "sunset.fill")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.caption)
                                }
                                Text(sunset, style: .time)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Hourly Forecast Card

    private var hourlyForecastCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("HOURLY FORECAST", systemImage: "clock")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.65))
                .tracking(0.8)

            Rectangle()
                .fill(.white.opacity(0.25))
                .frame(height: 0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(viewModel.hourlyForecast.prefix(12)) { forecast in
                        hourlyItem(forecast)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func hourlyItem(_ forecast: HourlyForecast) -> some View {
        VStack(spacing: 7) {
            Text(forecast.time, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.75))

            Image(systemName: forecast.condition.systemIconName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)

            // Precipitation probability placeholder keeps layout stable
            Text(forecast.precipitationProbability > 0 ? "\(forecast.precipitationProbability)%" : " ")
                .font(.caption2)
                .foregroundStyle(Color(red: 0.45, green: 0.82, blue: 1.0))

            Text(viewModel.displayTemperature(forecast.temperature))
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .frame(width: 52)
        .padding(.vertical, 8)
    }

    // MARK: - Daily Forecast Card

    private var dailyForecastCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("7-DAY FORECAST", systemImage: "calendar")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.65))
                .tracking(0.8)

            Rectangle()
                .fill(.white.opacity(0.25))
                .frame(height: 0.5)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.dailyForecast.enumerated()), id: \.element.id) { index, forecast in
                    dailyRow(forecast, isToday: index == 0)
                    if index < viewModel.dailyForecast.count - 1 {
                        Rectangle()
                            .fill(.white.opacity(0.15))
                            .frame(height: 0.5)
                            .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func dailyRow(_ forecast: DailyForecast, isToday: Bool) -> some View {
        HStack(spacing: 10) {
            Group {
                if isToday {
                    Text("Today")
                } else {
                    Text(forecast.date, format: .dateTime.weekday(.abbreviated))
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(width: 52, alignment: .leading)

            Image(systemName: forecast.condition.systemIconName)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .frame(width: 28)

            Text(forecast.precipitationProbability > 0 ? "\(forecast.precipitationProbability)%" : "")
                .font(.caption)
                .foregroundStyle(Color(red: 0.45, green: 0.82, blue: 1.0))
                .frame(width: 34, alignment: .leading)

            Spacer()

            HStack(spacing: 10) {
                Text(viewModel.displayTemperature(forecast.temperatureLow))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(width: 34, alignment: .trailing)

                Text(viewModel.displayTemperature(forecast.temperatureHigh))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 34, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading weather…")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 120)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.yellow)

            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.loadWeatherForCurrentLocation() }
            } label: {
                Text("Try Again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 80)
        .padding(.horizontal, 32)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 64))
                .symbolRenderingMode(.multicolor)

            Text("No Weather Data")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Button {
                Task { await viewModel.loadWeatherForCurrentLocation() }
            } label: {
                Text("Load Weather")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 80)
    }

    // MARK: - Search Sheet

    private var searchView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { location in
                    Button {
                        Task {
                            await viewModel.selectLocation(location)
                            showingSearch = false
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(location.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(location.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search for a city")
            .onChange(of: searchText) { _, newValue in
                Task { await viewModel.searchLocations(query: newValue) }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingSearch = false }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}