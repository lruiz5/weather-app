import SwiftUI
import WeatherKit
import WeatherUI

struct HourlyForecastCard: View {
    let viewModel: WeatherViewModel

    var body: some View {
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
        .frostedCard()
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
}
