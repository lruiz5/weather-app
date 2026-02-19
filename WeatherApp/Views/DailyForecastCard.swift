import SwiftUI
import WeatherKit
import WeatherUI

struct DailyForecastCard: View {
    let viewModel: WeatherViewModel

    var body: some View {
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
        .frostedCard()
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
}
