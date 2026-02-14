import SwiftUI
import WeatherKit
import WeatherUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel(
        repository: WeatherRepository()
    )
    @State private var searchText = ""
    @State private var showingSearch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else if let weather = viewModel.currentWeather {
                        currentWeatherView(weather)
                        hourlyForecastView
                        dailyForecastView
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(errorMessage)
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.currentLocation?.name ?? "Weather")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .task {
                await viewModel.loadWeatherForCurrentLocation()
            }
            .sheet(isPresented: $showingSearch) {
                searchView
            }
        }
    }

    // MARK: - Current Weather

    @ViewBuilder
    private func currentWeatherView(_ weather: Weather) -> some View {
        VStack(spacing: 16) {
            Image(systemName: weather.condition.systemIconName)
                .font(.system(size: 80))
                .symbolRenderingMode(.multicolor)

            Text("\(Int(weather.temperature))°")
                .font(.system(size: 72, weight: .thin))

            Text(weather.condition.description)
                .font(.title2)
                .foregroundStyle(.secondary)

            HStack(spacing: 32) {
                weatherDetail(
                    icon: "wind",
                    value: "\(Int(weather.windSpeed)) km/h"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func weatherDetail(icon: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
            Text(value)
                .font(.caption)
        }
    }

    // MARK: - Hourly Forecast

    @ViewBuilder
    private var hourlyForecastView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.hourlyForecast.prefix(24)) { forecast in
                        hourlyForecastCard(forecast)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func hourlyForecastCard(_ forecast: HourlyForecast) -> some View {
        VStack(spacing: 8) {
            Text(forecast.time, style: .time)
                .font(.caption)

            Image(systemName: forecast.condition.systemIconName)
                .font(.title2)
                .symbolRenderingMode(.multicolor)

            Text("\(Int(forecast.temperature))°")
                .font(.body)
                .fontWeight(.semibold)

            if forecast.precipitationProbability > 0 {
                Text("\(forecast.precipitationProbability)%")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Daily Forecast

    @ViewBuilder
    private var dailyForecastView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Forecast")
                .font(.headline)

            ForEach(viewModel.dailyForecast) { forecast in
                dailyForecastRow(forecast)
                if forecast.id != viewModel.dailyForecast.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func dailyForecastRow(_ forecast: DailyForecast) -> some View {
        HStack {
            Text(forecast.date, style: .date)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            Image(systemName: forecast.condition.systemIconName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
                .frame(width: 30)

            if forecast.precipitationProbability > 0 {
                Text("\(forecast.precipitationProbability)%")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .frame(width: 40)
            } else {
                Spacer()
                    .frame(width: 40)
            }

            Spacer()

            HStack(spacing: 12) {
                Text("\(Int(forecast.temperatureLow))°")
                    .foregroundStyle(.secondary)

                Text("\(Int(forecast.temperatureHigh))°")
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Empty & Error States

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 60))
                .symbolRenderingMode(.multicolor)

            Text("No Weather Data")
                .font(.title2)
                .fontWeight(.semibold)

            Button("Load Weather") {
                Task {
                    await viewModel.loadWeatherForCurrentLocation()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)

            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadWeatherForCurrentLocation()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Search View

    @ViewBuilder
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.headline)
                            Text(location.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search for a city")
            .onChange(of: searchText) { _, newValue in
                Task {
                    await viewModel.searchLocations(query: newValue)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingSearch = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
