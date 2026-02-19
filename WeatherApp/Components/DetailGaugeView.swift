import SwiftUI

struct DetailGaugeView: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let gaugeValue: Double
    let gaugeMax: Double
    let gaugeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .tracking(0.6)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Gauge(value: gaugeValue, in: 0...gaugeMax) {
                EmptyView()
            }
            .gaugeStyle(.linearCapacity)
            .tint(gaugeColor)
            .frame(height: 6)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
