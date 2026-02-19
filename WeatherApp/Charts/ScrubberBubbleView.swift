import SwiftUI
import WeatherKit
import WeatherUI

struct ScrubberBubbleView: View {
    let forecast: HourlyForecast
    let displayTemperature: (Double) -> String

    var body: some View {
        VStack(spacing: 4) {
            Text(forecast.time, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                .font(.caption2)
                .fontWeight(.medium)

            Image(systemName: forecast.condition.systemIconName)
                .font(.body)
                .symbolRenderingMode(.multicolor)

            Text(displayTemperature(forecast.temperature))
                .font(.callout)
                .fontWeight(.bold)

            if forecast.precipitationProbability > 0 {
                Text("\(forecast.precipitationProbability)%")
                    .font(.caption2)
                    .foregroundStyle(Color(red: 0.45, green: 0.82, blue: 1.0))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}
