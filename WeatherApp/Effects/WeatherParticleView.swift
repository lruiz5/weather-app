import SwiftUI
import WeatherKit

struct WeatherParticleView: View {
    let condition: WeatherCondition?
    let isThunderstorm: Bool
    let windDirection: Int

    @State private var particleSystem = ParticleSystem()

    private var particleType: ParticleSystem.ParticleType {
        ParticleSystem.particleType(for: condition)
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                particleSystem.update(
                    date: timeline.date,
                    size: size,
                    type: particleType,
                    windDirection: windDirection
                )

                let type = particleType
                for particle in particleSystem.particles {
                    switch type {
                    case .rain:
                        drawRain(context: context, particle: particle)
                    case .snow:
                        drawSnow(context: context, particle: particle)
                    case .fog:
                        drawFog(context: context, particle: particle)
                    case .none:
                        break
                    }
                }
            }
            .overlay {
                if isThunderstorm {
                    Color.white
                        .opacity(particleSystem.lightningFlashOpacity)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
        .allowsHitTesting(false)
        .drawingGroup()
    }

    private func drawRain(context: GraphicsContext, particle: Particle) {
        var path = Path()
        path.move(to: CGPoint(x: particle.x, y: particle.y))
        path.addLine(to: CGPoint(x: particle.x, y: particle.y + particle.size * 8))

        context.stroke(
            path,
            with: .color(.white.opacity(particle.opacity)),
            lineWidth: particle.size * 0.5
        )
    }

    private func drawSnow(context: GraphicsContext, particle: Particle) {
        let rect = CGRect(
            x: particle.x - particle.size / 2,
            y: particle.y - particle.size / 2,
            width: particle.size,
            height: particle.size
        )
        context.fill(
            Path(ellipseIn: rect),
            with: .color(.white.opacity(particle.opacity))
        )
    }

    private func drawFog(context: GraphicsContext, particle: Particle) {
        let rect = CGRect(
            x: particle.x - particle.size / 2,
            y: particle.y - particle.size / 4,
            width: particle.size,
            height: particle.size / 2
        )
        context.fill(
            Path(ellipseIn: rect),
            with: .color(.white.opacity(particle.opacity))
        )
    }
}
