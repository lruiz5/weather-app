import SwiftUI

struct ParallaxModifier: ViewModifier {
    let motionManager: MotionManager
    let magnitude: Double

    func body(content: Content) -> some View {
        content
            .offset(
                x: motionManager.roll * magnitude,
                y: -motionManager.pitch * magnitude
            )
    }
}

extension View {
    func parallax(manager: MotionManager, magnitude: Double) -> some View {
        modifier(ParallaxModifier(motionManager: manager, magnitude: magnitude))
    }
}
