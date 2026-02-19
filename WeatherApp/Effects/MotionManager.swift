import CoreMotion
import SwiftUI

@MainActor
@Observable
final class MotionManager {
    var pitch: Double = 0
    var roll: Double = 0

    private let motionManager = CMMotionManager()
    private var updateTask: Task<Void, Never>?

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        nonisolated(unsafe) let cm = motionManager
        let stream = AsyncStream<(Double, Double)> { continuation in
            cm.startDeviceMotionUpdates(to: OperationQueue()) { motion, _ in
                guard let motion else { return }
                continuation.yield((motion.attitude.pitch, motion.attitude.roll))
            }
            continuation.onTermination = { _ in
                cm.stopDeviceMotionUpdates()
            }
        }

        updateTask = Task { @MainActor in
            for await (p, r) in stream {
                // Smooth the values slightly
                pitch = pitch * 0.7 + p * 0.3
                roll = roll * 0.7 + r * 0.3
            }
        }
    }

    func stop() {
        updateTask?.cancel()
        updateTask = nil
        motionManager.stopDeviceMotionUpdates()
    }
}
