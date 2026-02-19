import SwiftUI
import WeatherKit

struct AnimatedGradientBackground: View {
    let condition: WeatherCondition?
    let isDay: Bool

    @State private var phase: Float = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: meshPoints,
                colors: meshColors
            )
            .onChange(of: timeline.date) { _, _ in
                phase += 0.008
                if phase > .pi * 2 { phase -= .pi * 2 }
            }
        }
        .ignoresSafeArea()
    }

    private var meshPoints: [SIMD2<Float>] {
        let t = phase
        let drift: Float = 0.03

        return [
            // Top row
            SIMD2(0, 0),
            SIMD2(0.5 + sin(t * 0.7) * drift, 0),
            SIMD2(1, 0),
            // Middle row
            SIMD2(0, 0.5 + cos(t * 0.5) * drift),
            SIMD2(0.5 + sin(t) * drift, 0.5 + cos(t * 0.8) * drift),
            SIMD2(1, 0.5 + sin(t * 0.6) * drift),
            // Bottom row
            SIMD2(0, 1),
            SIMD2(0.5 + cos(t * 0.9) * drift, 1),
            SIMD2(1, 1),
        ]
    }

    private var meshColors: [Color] {
        let (primary, secondary) = baseColors
        let accent = accentColor

        return [
            primary, primary.opacity(0.95), primary,
            accent, secondary, accent.opacity(0.9),
            secondary, secondary.opacity(0.95), secondary,
        ]
    }

    private var baseColors: (Color, Color) {
        guard let condition else {
            return (Color(red: 0.18, green: 0.35, blue: 0.60), Color(red: 0.10, green: 0.20, blue: 0.38))
        }
        if !isDay {
            return (Color(red: 0.08, green: 0.13, blue: 0.25), Color(red: 0.04, green: 0.08, blue: 0.17))
        }
        switch condition {
        case .clear:
            return (Color(red: 0.29, green: 0.56, blue: 0.89), Color(red: 0.53, green: 0.80, blue: 0.95))
        case .partlyCloudy:
            return (Color(red: 0.34, green: 0.54, blue: 0.78), Color(red: 0.50, green: 0.68, blue: 0.88))
        case .cloudy, .overcast, .fog:
            return (Color(red: 0.42, green: 0.49, blue: 0.58), Color(red: 0.57, green: 0.63, blue: 0.71))
        case .rain, .drizzle, .showers, .freezingRain:
            return (Color(red: 0.25, green: 0.33, blue: 0.44), Color(red: 0.16, green: 0.22, blue: 0.32))
        case .snow:
            return (Color(red: 0.53, green: 0.68, blue: 0.84), Color(red: 0.70, green: 0.82, blue: 0.93))
        case .thunderstorm:
            return (Color(red: 0.18, green: 0.19, blue: 0.27), Color(red: 0.10, green: 0.11, blue: 0.18))
        case .unknown:
            return (Color(red: 0.18, green: 0.35, blue: 0.60), Color(red: 0.10, green: 0.20, blue: 0.38))
        }
    }

    private var accentColor: Color {
        guard let condition else {
            return Color(red: 0.14, green: 0.28, blue: 0.50)
        }
        if !isDay {
            return Color(red: 0.06, green: 0.10, blue: 0.20)
        }
        switch condition {
        case .clear:
            return Color(red: 0.35, green: 0.65, blue: 0.92)
        case .partlyCloudy:
            return Color(red: 0.40, green: 0.58, blue: 0.82)
        case .cloudy, .overcast, .fog:
            return Color(red: 0.48, green: 0.55, blue: 0.64)
        case .rain, .drizzle, .showers, .freezingRain:
            return Color(red: 0.20, green: 0.28, blue: 0.38)
        case .snow:
            return Color(red: 0.60, green: 0.74, blue: 0.88)
        case .thunderstorm:
            return Color(red: 0.14, green: 0.15, blue: 0.22)
        case .unknown:
            return Color(red: 0.14, green: 0.28, blue: 0.50)
        }
    }
}
