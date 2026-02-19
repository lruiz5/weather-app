import SwiftUI
import WeatherKit
import WeatherUI

struct CurrentWeatherView: View {
    let viewModel: WeatherViewModel

    var body: some View {
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

                // Temperature (tap to toggle)
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

                // Sun/Moon Arc
                if let today = viewModel.dailyForecast.first,
                   let sunrise = today.sunrise,
                   let sunset = today.sunset {
                    Rectangle()
                        .fill(.white.opacity(0.25))
                        .frame(height: 0.5)
                        .padding(.bottom, 8)

                    SunArcView(
                        sunrise: sunrise,
                        sunset: sunset,
                        currentTime: Date()
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
    }
}
