import SwiftUI
import WeatherKit
import WeatherUI

struct CurrentWeatherView: View {
    let viewModel: WeatherViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let weather = viewModel.currentWeather,
               let today = viewModel.dailyForecast.first,
               let sunrise = today.sunrise,
               let sunset = today.sunset {

                ZStack {
                    // Celestial clock circle
                    CelestialClockView(sunrise: sunrise, sunset: sunset, timeZoneIdentifier: viewModel.currentLocation?.timezone)

                    // Centered weather info inside the circle
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
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.bottom, 8)

                        // Icon
                        Image(systemName: weather.condition.iconName(isDay: weather.isDay))
                            .font(.system(size: 52))
                            .symbolRenderingMode(.multicolor)
                            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                            .padding(.bottom, 2)

                        // Temperature (tap to toggle)
                        Text(viewModel.displayTemperature(weather.temperature))
                            .font(.system(size: 72, weight: .thin))
                            .foregroundStyle(.white)
                            .onTapGesture {
                                viewModel.toggleTemperatureUnit()
                            }

                        // Condition
                        Text(weather.condition.description)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.bottom, 4)

                        // Feels like + H/L
                        HStack(spacing: 5) {
                            if let feelsLike = weather.feelsLike {
                                Text("Feels like \(viewModel.displayTemperature(feelsLike))")
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                            if weather.feelsLike != nil {
                                Text("·").foregroundStyle(.white.opacity(0.45))
                            }
                            Text("H:\(viewModel.displayTemperature(today.temperatureHigh))")
                                .foregroundStyle(.white.opacity(0.85))
                            Text("L:\(viewModel.displayTemperature(today.temperatureLow))")
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal, 40)
                }

            } else if let weather = viewModel.currentWeather {
                // Fallback without sunrise/sunset data
                weatherInfoFallback(weather: weather)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }

    private func weatherInfoFallback(weather: Weather) -> some View {
        VStack(spacing: 0) {
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

            Image(systemName: weather.condition.iconName(isDay: weather.isDay))
                .font(.system(size: 72))
                .symbolRenderingMode(.multicolor)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                .padding(.bottom, 4)

            Text(viewModel.displayTemperature(weather.temperature))
                .font(.system(size: 96, weight: .thin))
                .foregroundStyle(.white)
                .padding(.bottom, 2)
                .onTapGesture {
                    viewModel.toggleTemperatureUnit()
                }

            Text(weather.condition.description)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
    }
}
