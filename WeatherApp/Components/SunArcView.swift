import SwiftUI

struct SunArcView: View {
    let sunrise: Date
    let sunset: Date
    let currentTime: Date

    private let arcHeight: CGFloat = 80
    private let horizontalInset: CGFloat = 30

    private func dayProgress(at time: Date) -> Double {
        let total = sunset.timeIntervalSince(sunrise)
        guard total > 0 else { return 0.5 }
        let elapsed = time.timeIntervalSince(sunrise)
        return max(0, min(1, elapsed / total))
    }

    private func isNight(at time: Date) -> Bool {
        time < sunrise || time > sunset
    }

var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            arcContent(now: timeline.date)
        }
    }

    private func arcContent(now: Date) -> some View {
        let progress = dayProgress(at: now)
        let night = isNight(at: now)

        return VStack(spacing: 0) {
            Canvas { context, size in
                let width = size.width
                let arcWidth = width - horizontalInset * 2
                let baseY = size.height - 30
                let centerX = width / 2

                // Draw the arc
                let arcPath = createArcPath(
                    center: CGPoint(x: centerX, y: baseY),
                    width: arcWidth,
                    height: arcHeight
                )

                // Dashed arc below horizon (full arc, dimmer)
                context.stroke(
                    arcPath,
                    with: .color(.white.opacity(0.15)),
                    style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                )

                // Solid arc for daylight portion
                if !night {
                    let daylightPath = createPartialArc(
                        center: CGPoint(x: centerX, y: baseY),
                        width: arcWidth,
                        height: arcHeight,
                        progress: progress
                    )
                    context.stroke(
                        daylightPath,
                        with: .color(.white.opacity(0.4)),
                        lineWidth: 2
                    )
                }

                // Horizon line
                let horizonPath = Path { p in
                    p.move(to: CGPoint(x: horizontalInset - 10, y: baseY))
                    p.addLine(to: CGPoint(x: width - horizontalInset + 10, y: baseY))
                }
                context.stroke(
                    horizonPath,
                    with: .color(.white.opacity(0.2)),
                    lineWidth: 0.5
                )

                // Sun/moon orb position
                let orbPosition = pointOnArc(
                    center: CGPoint(x: centerX, y: baseY),
                    width: arcWidth,
                    height: arcHeight,
                    progress: night ? 0 : progress
                )

                if !night {
                    // Sun glow
                    let glowRect = CGRect(
                        x: orbPosition.x - 18,
                        y: orbPosition.y - 18,
                        width: 36,
                        height: 36
                    )
                    context.fill(
                        Path(ellipseIn: glowRect),
                        with: .radialGradient(
                            Gradient(colors: [
                                .yellow.opacity(0.4),
                                .yellow.opacity(0.1),
                                .clear
                            ]),
                            center: orbPosition,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )

                    // Sun orb
                    let orbRect = CGRect(
                        x: orbPosition.x - 6,
                        y: orbPosition.y - 6,
                        width: 12,
                        height: 12
                    )
                    context.fill(
                        Path(ellipseIn: orbRect),
                        with: .color(.yellow)
                    )
                } else {
                    // Moon orb (below horizon indicator)
                    let moonPos = CGPoint(x: centerX, y: baseY + 10)
                    let moonRect = CGRect(
                        x: moonPos.x - 5,
                        y: moonPos.y - 5,
                        width: 10,
                        height: 10
                    )
                    context.fill(
                        Path(ellipseIn: moonRect),
                        with: .color(.white.opacity(0.6))
                    )
                }
            }
            .frame(height: arcHeight + 40)

            // Sunrise / Sunset labels
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "sunrise.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 10))
                        Text("SUNRISE")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.55))
                            .tracking(0.6)
                    }
                    Text(sunrise, style: .time)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 3) {
                        Text("SUNSET")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.55))
                            .tracking(0.6)
                        Image(systemName: "sunset.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 10))
                    }
                    Text(sunset, style: .time)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Arc Geometry

    private func createArcPath(center: CGPoint, width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            let startX = center.x - width / 2
            let endX = center.x + width / 2
            let control1 = CGPoint(x: startX + width * 0.25, y: center.y - height)
            let control2 = CGPoint(x: endX - width * 0.25, y: center.y - height)

            path.move(to: CGPoint(x: startX, y: center.y))
            path.addCurve(
                to: CGPoint(x: endX, y: center.y),
                control1: control1,
                control2: control2
            )
        }
    }

    private func createPartialArc(center: CGPoint, width: CGFloat, height: CGFloat, progress: Double) -> Path {
        // Approximate by sampling points
        let steps = 50
        let endStep = Int(Double(steps) * progress)
        guard endStep > 0 else { return Path() }

        var path = Path()
        for i in 0...endStep {
            let t = Double(i) / Double(steps)
            let point = pointOnArc(center: center, width: width, height: height, progress: t)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private func pointOnArc(center: CGPoint, width: CGFloat, height: CGFloat, progress: Double) -> CGPoint {
        let t = CGFloat(progress)
        let startX = center.x - width / 2
        let endX = center.x + width / 2
        let control1 = CGPoint(x: startX + width * 0.25, y: center.y - height)
        let control2 = CGPoint(x: endX - width * 0.25, y: center.y - height)
        let start = CGPoint(x: startX, y: center.y)
        let end = CGPoint(x: endX, y: center.y)

        // Cubic bezier: B(t) = (1-t)^3*P0 + 3*(1-t)^2*t*P1 + 3*(1-t)*t^2*P2 + t^3*P3
        let mt = 1 - t
        let mt2 = mt * mt
        let mt3 = mt2 * mt
        let t2 = t * t
        let t3 = t2 * t

        let x = mt3 * start.x + 3 * mt2 * t * control1.x + 3 * mt * t2 * control2.x + t3 * end.x
        let y = mt3 * start.y + 3 * mt2 * t * control1.y + 3 * mt * t2 * control2.y + t3 * end.y

        return CGPoint(x: x, y: y)
    }
}
