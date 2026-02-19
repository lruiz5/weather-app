import SwiftUI
import WeatherKit
import WeatherUI

struct TemperatureCurveView: View {
    let forecasts: [HourlyForecast]
    let displayTemperature: (Double) -> String

    private let pointSpacing: CGFloat = 52
    private let chartHeight: CGFloat = 120
    private let precipBarHeight: CGFloat = 40
    private let verticalPadding: CGFloat = 30

    @State private var scrubIndex: Int?
    @State private var scrubLocation: CGPoint?
    @State private var haptic = UIImpactFeedbackGenerator(style: .light)

    private var displayForecasts: [HourlyForecast] {
        Array(forecasts.prefix(12))
    }

    private var totalWidth: CGFloat {
        CGFloat(max(displayForecasts.count - 1, 1)) * pointSpacing + pointSpacing
    }

    private var tempRange: (min: Double, max: Double) {
        let temps = displayForecasts.map(\.temperature)
        let minT = temps.min() ?? 0
        let maxT = temps.max() ?? 1
        let padding = max((maxT - minT) * 0.15, 2)
        return (minT - padding, maxT + padding)
    }

    private func chartPoints() -> [CGPoint] {
        let range = tempRange
        return displayForecasts.enumerated().map { index, forecast in
            let x = CGFloat(index) * pointSpacing + pointSpacing / 2
            let normalized = (forecast.temperature - range.min) / (range.max - range.min)
            let y = verticalPadding + chartHeight * (1 - normalized)
            return CGPoint(x: x, y: y)
        }
    }

    private func nowPosition(points: [CGPoint]) -> CGPoint? {
        let now = Date()
        let forecasts = displayForecasts
        guard forecasts.count >= 2 else { return nil }

        for i in 0..<(forecasts.count - 1) {
            let t0 = forecasts[i].time
            let t1 = forecasts[i + 1].time
            if now >= t0 && now < t1 {
                let fraction = CGFloat(now.timeIntervalSince(t0) / t1.timeIntervalSince(t0))
                let x = points[i].x + (points[i + 1].x - points[i].x) * fraction
                let y = SplineInterpolation.interpolateY(at: x, points: points) ?? (points[i].y + (points[i + 1].y - points[i].y) * fraction)
                return CGPoint(x: x, y: y)
            }
        }
        // If now is before first forecast, use first point
        if now < forecasts[0].time { return points[0] }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("HOURLY FORECAST", systemImage: "clock")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.65))
                .tracking(0.8)

            Rectangle()
                .fill(.white.opacity(0.25))
                .frame(height: 0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                let points = chartPoints()

                ZStack(alignment: .top) {
                    // Temperature curve with gradient fill
                    temperatureCurve(points: points)

                    // Temperature labels at data points
                    temperatureLabels(points: points)

                    // Time labels
                    timeLabels

                    // Precipitation bars
                    precipitationBars
                        .offset(y: chartHeight + verticalPadding * 2 + 8)

                    // "Now" label (above the chart)
                    if let nowPos = nowPosition(points: points) {
                        Text("Now")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .position(x: nowPos.x, y: verticalPadding - 16)
                    }

                    // Scrubber line and bubble
                    if let idx = scrubIndex, let loc = scrubLocation, idx < displayForecasts.count {
                        scrubberOverlay(index: idx, location: loc, points: points)
                    }
                }
                .frame(width: totalWidth, height: chartHeight + verticalPadding * 2 + precipBarHeight + 30)
                .contentShape(Rectangle())
                .gesture(scrubGesture(points: points))
            }
        }
        .frostedCard()
    }

    // MARK: - Chart Components

    private func temperatureCurve(points: [CGPoint]) -> some View {
        Canvas { context, size in
            guard points.count >= 2 else { return }

            let curvePath = SplineInterpolation.path(through: points)

            // Gradient fill
            var fillPath = curvePath
            if let lastPoint = points.last, let firstPoint = points.first {
                fillPath.addLine(to: CGPoint(x: lastPoint.x, y: chartHeight + verticalPadding))
                fillPath.addLine(to: CGPoint(x: firstPoint.x, y: chartHeight + verticalPadding))
                fillPath.closeSubpath()
            }

            context.fill(
                fillPath,
                with: .linearGradient(
                    Gradient(colors: [
                        .white.opacity(0.25),
                        .white.opacity(0.05),
                        .clear
                    ]),
                    startPoint: CGPoint(x: 0, y: verticalPadding),
                    endPoint: CGPoint(x: 0, y: chartHeight + verticalPadding)
                )
            )

            // Curve stroke
            context.stroke(
                curvePath,
                with: .color(.white.opacity(0.8)),
                lineWidth: 2.5
            )

            // Data point dots
            for point in points {
                let dotRect = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: dotRect), with: .color(.white))
            }

            // "Now" indicator
            if let now = nowPosition(points: points) {
                // Vertical dashed line
                var dashPath = Path()
                dashPath.move(to: CGPoint(x: now.x, y: verticalPadding))
                dashPath.addLine(to: CGPoint(x: now.x, y: chartHeight + verticalPadding))
                context.stroke(
                    dashPath,
                    with: .color(.white.opacity(0.4)),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )

                // Outer glow ring
                let glowRect = CGRect(x: now.x - 8, y: now.y - 8, width: 16, height: 16)
                context.fill(Path(ellipseIn: glowRect), with: .color(.white.opacity(0.15)))

                // Inner dot
                let nowDot = CGRect(x: now.x - 5, y: now.y - 5, width: 10, height: 10)
                context.fill(Path(ellipseIn: nowDot), with: .color(.white))

                // Center accent
                let centerDot = CGRect(x: now.x - 2.5, y: now.y - 2.5, width: 5, height: 5)
                context.fill(Path(ellipseIn: centerDot), with: .color(Color(red: 0.45, green: 0.82, blue: 1.0)))
            }
        }
    }

    private func temperatureLabels(points: [CGPoint]) -> some View {
        ForEach(Array(displayForecasts.enumerated()), id: \.element.id) { index, forecast in
            if index < points.count {
                let point = points[index]
                let isLocalMin = isLocalMinimum(at: index)
                let isLocalMax = isLocalMaximum(at: index)

                if isLocalMin || isLocalMax || index == 0 || index == displayForecasts.count - 1 {
                    Text(displayTemperature(forecast.temperature))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .position(x: point.x, y: point.y + (isLocalMin ? 16 : -16))
                }
            }
        }
    }

    private var timeLabels: some View {
        ForEach(Array(displayForecasts.enumerated()), id: \.element.id) { index, forecast in
            if index % 2 == 0 {
                Text(forecast.time, format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                    .position(
                        x: CGFloat(index) * pointSpacing + pointSpacing / 2,
                        y: chartHeight + verticalPadding * 2 - 2
                    )
            }
        }
    }

    private var precipitationBars: some View {
        HStack(spacing: 0) {
            ForEach(displayForecasts) { forecast in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.45, green: 0.82, blue: 1.0).opacity(0.7))
                        .frame(
                            width: 8,
                            height: max(2, precipBarHeight * CGFloat(forecast.precipitationProbability) / 100)
                        )
                        .frame(height: precipBarHeight, alignment: .bottom)

                    if forecast.precipitationProbability > 0 {
                        Text("\(forecast.precipitationProbability)%")
                            .font(.system(size: 8))
                            .foregroundStyle(Color(red: 0.45, green: 0.82, blue: 1.0))
                            .fixedSize()
                    }
                }
                .frame(width: pointSpacing)
            }
        }
    }

    // MARK: - Scrubber

    private func scrubGesture(points: [CGPoint]) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let x = value.location.x
                let newIndex = resolveHourIndex(x: x)
                if newIndex != scrubIndex {
                    haptic.impactOccurred()
                    scrubIndex = newIndex
                }
                if let idx = newIndex, idx < points.count {
                    let yOnCurve = SplineInterpolation.interpolateY(at: x, points: points) ?? points[idx].y
                    scrubLocation = CGPoint(x: x, y: yOnCurve)
                }
            }
            .onEnded { _ in
                scrubIndex = nil
                scrubLocation = nil
            }
    }

    private func scrubberOverlay(index: Int, location: CGPoint, points: [CGPoint]) -> some View {
        let point = points[index]
        return ZStack {
            // Vertical scrub line
            Rectangle()
                .fill(.white.opacity(0.3))
                .frame(width: 1)
                .offset(x: point.x - totalWidth / 2)

            // Bubble
            ScrubberBubbleView(
                forecast: displayForecasts[index],
                displayTemperature: displayTemperature
            )
            .position(x: point.x, y: max(point.y - 60, 30))
        }
    }

    // MARK: - Helpers

    private func resolveHourIndex(x: CGFloat) -> Int? {
        let index = Int((x - pointSpacing / 4) / pointSpacing)
        guard index >= 0, index < displayForecasts.count else { return nil }
        return index
    }

    private func isLocalMinimum(at index: Int) -> Bool {
        let temps = displayForecasts.map(\.temperature)
        guard index > 0, index < temps.count - 1 else { return false }
        return temps[index] <= temps[index - 1] && temps[index] <= temps[index + 1]
    }

    private func isLocalMaximum(at index: Int) -> Bool {
        let temps = displayForecasts.map(\.temperature)
        guard index > 0, index < temps.count - 1 else { return false }
        return temps[index] >= temps[index - 1] && temps[index] >= temps[index + 1]
    }
}
