import SwiftUI
import WeatherKit

struct Particle {
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var opacity: Double
    var size: Double
    var rotation: Double
    var age: Double
    var lifetime: Double
}

@MainActor
@Observable
final class ParticleSystem {
    var particles: [Particle] = []

    private var canvasSize: CGSize = .zero
    private var lastUpdate: Date?
    private var flashOpacity: Double = 0
    private var nextFlashTime: Double = 0
    private var flashTimer: Double = 0

    var lightningFlashOpacity: Double { flashOpacity }

    enum ParticleType {
        case rain(intensity: Double)
        case snow(intensity: Double)
        case fog
        case none

        var maxParticles: Int {
            switch self {
            case .rain: 150
            case .snow: 100
            case .fog: 20
            case .none: 0
            }
        }
    }

    static func particleType(for condition: WeatherCondition?) -> ParticleType {
        guard let condition else { return .none }
        switch condition {
        case .rain, .showers, .freezingRain:
            return .rain(intensity: 1.0)
        case .drizzle:
            return .rain(intensity: 0.4)
        case .thunderstorm:
            return .rain(intensity: 1.0)
        case .snow:
            return .snow(intensity: 1.0)
        case .fog:
            return .fog
        default:
            return .none
        }
    }

    func update(date: Date, size: CGSize, type: ParticleType, windDirection: Int) {
        canvasSize = size
        let now = date
        let dt = lastUpdate.map { now.timeIntervalSince($0) } ?? 0
        lastUpdate = now

        guard dt > 0, dt < 0.5 else { return }

        // Emit new particles
        let deficit = type.maxParticles - particles.count
        if deficit > 0 {
            let emitCount = min(deficit, max(1, Int(Double(deficit) * dt * 5)))
            for _ in 0..<emitCount {
                emit(type: type, windDirection: windDirection)
            }
        }

        // Update existing particles
        let windAngle = Double(windDirection) * .pi / 180.0
        let windOffsetX = sin(windAngle) * 20

        for i in particles.indices.reversed() {
            particles[i].age += dt
            if particles[i].age >= particles[i].lifetime || particles[i].y > size.height + 20 {
                particles.remove(at: i)
                continue
            }

            switch type {
            case .rain:
                particles[i].x += (particles[i].velocityX + windOffsetX) * dt
                particles[i].y += particles[i].velocityY * dt
            case .snow:
                let drift = sin(particles[i].age * 2 + particles[i].rotation) * 30
                particles[i].x += (drift + windOffsetX * 0.3) * dt
                particles[i].y += particles[i].velocityY * dt
                particles[i].rotation += dt * 0.5
            case .fog:
                particles[i].x += particles[i].velocityX * dt
                let progress = particles[i].age / particles[i].lifetime
                particles[i].opacity = sin(progress * .pi) * 0.3
            case .none:
                break
            }
        }

        // Lightning for thunderstorm
        updateLightning(dt: dt, condition: type)
    }

    private func emit(type: ParticleType, windDirection: Int) {
        let w = canvasSize.width
        let h = canvasSize.height
        guard w > 0, h > 0 else { return }

        switch type {
        case .rain(let intensity):
            let p = Particle(
                x: Double.random(in: -20...w + 20),
                y: Double.random(in: -40...(-10)),
                velocityX: Double.random(in: -10...10),
                velocityY: Double.random(in: 600...900) * intensity,
                opacity: Double.random(in: 0.15...0.4),
                size: Double.random(in: 1.5...3.0),
                rotation: 0,
                age: 0,
                lifetime: 3.0
            )
            particles.append(p)

        case .snow(let intensity):
            let p = Particle(
                x: Double.random(in: -20...w + 20),
                y: Double.random(in: -20...(-5)),
                velocityX: 0,
                velocityY: Double.random(in: 30...80) * intensity,
                opacity: Double.random(in: 0.4...0.9),
                size: Double.random(in: 2...6),
                rotation: Double.random(in: 0...Double.pi * 2),
                age: 0,
                lifetime: 15.0
            )
            particles.append(p)

        case .fog:
            let p = Particle(
                x: Double.random(in: -100...w),
                y: Double.random(in: 0...h),
                velocityX: Double.random(in: 10...30),
                velocityY: 0,
                opacity: 0,
                size: Double.random(in: 100...250),
                rotation: 0,
                age: 0,
                lifetime: Double.random(in: 8...15)
            )
            particles.append(p)

        case .none:
            break
        }
    }

    private func updateLightning(dt: Double, condition: ParticleType) {
        if case .rain = condition {} else {
            flashOpacity = 0
            return
        }

        flashTimer += dt
        if flashTimer >= nextFlashTime {
            flashOpacity = 0.8
            nextFlashTime = flashTimer + Double.random(in: 5...15)
        }
        if flashOpacity > 0 {
            flashOpacity -= dt * 4
            if flashOpacity < 0 { flashOpacity = 0 }
        }
    }
}
