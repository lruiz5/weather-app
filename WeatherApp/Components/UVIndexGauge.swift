import SwiftUI

struct UVIndexGauge: View {
    let value: Double

    private var color: Color {
        switch value {
        case 0..<3:  return .green
        case 3..<6:  return .yellow
        case 6..<8:  return .orange
        case 8..<11: return .red
        default:     return .purple
        }
    }

    private var label: String {
        switch value {
        case 0..<3:  return "Low"
        case 3..<6:  return "Moderate"
        case 6..<8:  return "High"
        case 8..<11: return "Very High"
        default:     return "Extreme"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.caption)
                    .foregroundStyle(color)
                Text("UV INDEX")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .tracking(0.6)
            }

            Text(String(format: "%.0f", value))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Gauge(value: min(value, 11), in: 0...11) {
                EmptyView()
            }
            .gaugeStyle(.linearCapacity)
            .tint(color)
            .frame(height: 6)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
