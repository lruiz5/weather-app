import SwiftUI

enum SplineInterpolation {
    /// Creates a smooth Catmull-Rom spline path through the given points.
    static func path(through points: [CGPoint], tension: CGFloat = 0.5) -> Path {
        guard points.count >= 2 else {
            return Path()
        }

        var path = Path()
        path.move(to: points[0])

        if points.count == 2 {
            path.addLine(to: points[1])
            return path
        }

        for i in 0..<points.count - 1 {
            let p0 = points[max(i - 1, 0)]
            let p1 = points[i]
            let p2 = points[min(i + 1, points.count - 1)]
            let p3 = points[min(i + 2, points.count - 1)]

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / (6 * tension),
                y: p1.y + (p2.y - p0.y) / (6 * tension)
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / (6 * tension),
                y: p2.y - (p3.y - p1.y) / (6 * tension)
            )

            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }

        return path
    }

    /// Interpolates y-value at a given x along the spline.
    static func interpolateY(at x: CGFloat, points: [CGPoint]) -> CGFloat? {
        guard points.count >= 2 else { return nil }

        // Find the segment that contains x
        for i in 0..<points.count - 1 {
            if x >= points[i].x && x <= points[i + 1].x {
                let t = (x - points[i].x) / (points[i + 1].x - points[i].x)

                let p0 = points[max(i - 1, 0)]
                let p1 = points[i]
                let p2 = points[min(i + 1, points.count - 1)]
                let p3 = points[min(i + 2, points.count - 1)]

                // Catmull-Rom interpolation
                let t2 = t * t
                let t3 = t2 * t

                let y = 0.5 * (
                    (2 * p1.y) +
                    (-p0.y + p2.y) * t +
                    (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
                    (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3
                )
                return y
            }
        }

        // Clamp to edges
        if x <= points.first!.x { return points.first!.y }
        return points.last!.y
    }
}
