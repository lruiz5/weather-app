import SwiftUI

struct CelestialClockView: View {
    let sunrise: Date
    let sunset: Date
    let timeZoneIdentifier: String?

    private let circleInset: CGFloat = 4
    private let strokeWidth: CGFloat = 1.5
    private let orbRadius: CGFloat = 7
    private let glowRadius: CGFloat = 20

    private var locationCalendar: Calendar {
        var cal = Calendar.current
        if let tz = timeZoneIdentifier, let zone = TimeZone(identifier: tz) {
            cal.timeZone = zone
        }
        return cal
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            clockContent(now: timeline.date)
        }
    }

    private func clockContent(now: Date) -> some View {
        let isDaytime = now >= sunrise && now <= sunset
        let nowAngle = timeToAngle(now)
        let sunriseAngle = timeToAngle(sunrise)
        let sunsetAngle = timeToAngle(sunset)

        return VStack(spacing: 6) {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: size / 2)
                let radius = (size - circleInset * 2) / 2

                Canvas { context, _ in
                    drawTrack(context: context, center: center, radius: radius)
                    drawDaylightArc(context: context, center: center, radius: radius, sunriseAngle: sunriseAngle, sunsetAngle: sunsetAngle)
                    drawProgressArc(context: context, center: center, radius: radius, nowAngle: nowAngle, sunriseAngle: sunriseAngle, sunsetAngle: sunsetAngle, isDaytime: isDaytime)

                    drawTickMarks(context: context, center: center, radius: radius, sunriseAngle: sunriseAngle, sunsetAngle: sunsetAngle)

                    if isDaytime {
                        drawSun(context: context, center: center, radius: radius, angle: nowAngle)
                    } else {
                        drawMoon(context: context, center: center, radius: radius, angle: nowAngle)
                    }
                }
                .frame(width: geo.size.width, height: size)
            }
            .aspectRatio(1, contentMode: .fit)

            // Sunrise / Sunset labels
            sunriseSunsetLabels
        }
    }

    // MARK: - 24-Hour Clock Angle Mapping

    /// Maps a time to an angle on the circle (SwiftUI coordinate system, y-down).
    /// 12:00 AM (midnight) = bottom (π/2)
    /// 6:00 AM = left (π)
    /// 12:00 PM (noon) = top (3π/2 or -π/2)
    /// 6:00 PM = right (0 or 2π)
    /// Time progresses clockwise.
    private func timeToAngle(_ time: Date) -> Angle {
        let hour = locationCalendar.component(.hour, from: time)
        let minute = locationCalendar.component(.minute, from: time)
        let fractionalHour = Double(hour) + Double(minute) / 60.0
        // Map 0-24 hours to 0-2π, starting at bottom (π/2) going clockwise
        let radians = (fractionalHour / 24.0) * 2 * .pi + .pi / 2
        return .radians(radians)
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y + radius * CGFloat(sin(angle.radians))
        )
    }

    // MARK: - Drawing

    private func drawTrack(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let track = Path { p in
            p.addArc(center: center, radius: radius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        }
        context.stroke(
            track,
            with: .color(.white.opacity(0.1)),
            style: StrokeStyle(lineWidth: strokeWidth, dash: [4, 4])
        )
    }

    /// Draws a subtle highlight for the daylight portion of the circle (sunrise → sunset, clockwise through top)
    private func drawDaylightArc(context: GraphicsContext, center: CGPoint, radius: CGFloat, sunriseAngle: Angle, sunsetAngle: Angle) {
        let path = Path { p in
            // Sunrise to sunset going clockwise (through the top of the circle)
            p.addArc(
                center: center,
                radius: radius,
                startAngle: sunriseAngle,
                endAngle: sunsetAngle,
                clockwise: false
            )
        }
        context.stroke(path, with: .color(.white.opacity(0.2)), lineWidth: strokeWidth)
    }

    /// Draws the elapsed progress arc from the start of the current phase (sunrise or sunset) to now
    private func drawProgressArc(context: GraphicsContext, center: CGPoint, radius: CGFloat, nowAngle: Angle, sunriseAngle: Angle, sunsetAngle: Angle, isDaytime: Bool) {
        let path = Path { p in
            if isDaytime {
                // From sunrise to now, clockwise
                p.addArc(
                    center: center,
                    radius: radius,
                    startAngle: sunriseAngle,
                    endAngle: nowAngle,
                    clockwise: false
                )
            } else {
                // From sunset to now, clockwise
                p.addArc(
                    center: center,
                    radius: radius,
                    startAngle: sunsetAngle,
                    endAngle: nowAngle,
                    clockwise: false
                )
            }
        }

        let color: Color = isDaytime
            ? .yellow.opacity(0.55)
            : .white.opacity(0.3)

        context.stroke(path, with: .color(color), lineWidth: strokeWidth + 0.5)
    }


    private func drawTickMarks(context: GraphicsContext, center: CGPoint, radius: CGFloat, sunriseAngle: Angle, sunsetAngle: Angle) {
        let tickLength: CGFloat = 6
        for angle in [sunriseAngle, sunsetAngle] {
            let outer = pointOnCircle(center: center, radius: radius + tickLength / 2, angle: angle)
            let inner = pointOnCircle(center: center, radius: radius - tickLength / 2, angle: angle)
            var path = Path()
            path.move(to: inner)
            path.addLine(to: outer)
            context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
        }
    }

    private func drawSun(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Angle) {
        let pos = pointOnCircle(center: center, radius: radius, angle: angle)

        // Glow
        let glowRect = CGRect(
            x: pos.x - glowRadius, y: pos.y - glowRadius,
            width: glowRadius * 2, height: glowRadius * 2
        )
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(
                Gradient(colors: [
                    .yellow.opacity(0.5),
                    .yellow.opacity(0.15),
                    .clear
                ]),
                center: pos,
                startRadius: 0,
                endRadius: glowRadius
            )
        )

        // Orb
        let orbRect = CGRect(
            x: pos.x - orbRadius, y: pos.y - orbRadius,
            width: orbRadius * 2, height: orbRadius * 2
        )
        context.fill(Path(ellipseIn: orbRect), with: .color(.yellow))
    }

    private func drawMoon(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Angle) {
        let pos = pointOnCircle(center: center, radius: radius, angle: angle)

        // Subtle glow
        let glow: CGFloat = 14
        let glowRect = CGRect(
            x: pos.x - glow, y: pos.y - glow,
            width: glow * 2, height: glow * 2
        )
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(
                Gradient(colors: [
                    .white.opacity(0.2),
                    .white.opacity(0.05),
                    .clear
                ]),
                center: pos,
                startRadius: 0,
                endRadius: glow
            )
        )

        // Orb
        let r = orbRadius - 1
        let orbRect = CGRect(
            x: pos.x - r, y: pos.y - r,
            width: r * 2, height: r * 2
        )
        context.fill(Path(ellipseIn: orbRect), with: .color(.white.opacity(0.85)))
    }

    // MARK: - Labels

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        if let tz = timeZoneIdentifier, let zone = TimeZone(identifier: tz) {
            formatter.timeZone = zone
        }
        return formatter.string(from: date)
    }

    private var sunriseSunsetLabels: some View {
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
                Text(formatTime(sunrise))
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
                Text(formatTime(sunset))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(.horizontal, 4)
    }
}
