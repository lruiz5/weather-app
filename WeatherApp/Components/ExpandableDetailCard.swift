import SwiftUI
import WeatherKit

struct ExpandableDetailCard: View {
    let weather: Weather

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Tap indicator
            Button {
                withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("DETAILS", systemImage: "info.circle")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.65))
                        .tracking(0.8)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.45))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Rectangle()
                    .fill(.white.opacity(0.25))
                    .frame(height: 0.5)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 20) {
                    // Humidity
                    if let humidity = weather.humidity {
                        DetailGaugeView(
                            icon: "humidity.fill",
                            title: "HUMIDITY",
                            value: "\(Int(humidity))%",
                            subtitle: humidityDescription(humidity),
                            gaugeValue: humidity,
                            gaugeMax: 100,
                            gaugeColor: .cyan
                        )
                    }

                    // UV Index
                    if let uvIndex = weather.uvIndex {
                        UVIndexGauge(value: uvIndex)
                    }

                    // Pressure
                    if let pressure = weather.pressure {
                        DetailGaugeView(
                            icon: "gauge.medium",
                            title: "PRESSURE",
                            value: "\(Int(pressure)) hPa",
                            subtitle: pressureDescription(pressure),
                            gaugeValue: pressure - 950,
                            gaugeMax: 100,
                            gaugeColor: .white.opacity(0.6)
                        )
                    }

                    // Visibility
                    if let visibility = weather.visibility {
                        let km = visibility / 1000
                        DetailGaugeView(
                            icon: "eye.fill",
                            title: "VISIBILITY",
                            value: String(format: "%.1f km", km),
                            subtitle: visibilityDescription(km),
                            gaugeValue: min(km, 20),
                            gaugeMax: 20,
                            gaugeColor: .white.opacity(0.6)
                        )
                    }

                    // Wind
                    DetailGaugeView(
                        icon: "wind",
                        title: "WIND",
                        value: "\(Int(weather.windSpeed)) km/h",
                        subtitle: windDirection(weather.windDirection),
                        gaugeValue: min(weather.windSpeed, 100),
                        gaugeMax: 100,
                        gaugeColor: .mint
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frostedCard()
    }

    // MARK: - Descriptions

    private func humidityDescription(_ value: Double) -> String {
        switch value {
        case 0..<30: return "Dry"
        case 30..<60: return "Comfortable"
        case 60..<80: return "Humid"
        default: return "Very Humid"
        }
    }

    private func pressureDescription(_ value: Double) -> String {
        switch value {
        case 0..<1000: return "Low"
        case 1000..<1020: return "Normal"
        default: return "High"
        }
    }

    private func visibilityDescription(_ km: Double) -> String {
        switch km {
        case 0..<1: return "Very Poor"
        case 1..<4: return "Poor"
        case 4..<10: return "Moderate"
        default: return "Good"
        }
    }

    private func windDirection(_ degrees: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((Double(degrees) / 22.5).rounded()) % 16
        return "From \(directions[index])"
    }
}
