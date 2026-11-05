import CoreHaptics
import Foundation

/// A grainy orbit of taps, swelling with the particles' one-second breathing phases.
@MainActor
final class ParticleHaptics {
    private var engine: CHHapticEngine?
    private var player: (any CHHapticPatternPlayer)?

    func start() {
        stop()
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true
            try engine.start()
            self.engine = engine
            let player = try engine.makePlayer(with: Self.pattern())
            self.player = player
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Haptic interruptions or unsupported hardware must never block the reveal.
            stop()
        }
    }

    func stop() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
        engine?.stop(completionHandler: nil)
        engine = nil
    }

    private static func pattern() throws -> CHHapticPattern {
        let duration = 3.0
        var events = [CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.22),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
            ],
            relativeTime: 0,
            duration: duration
        )]
        var time = 0.0
        while time < duration - 0.08 {
            let expansion = Float((1 - cos(.pi * time / 1.0)) / 2)
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55 + 0.4 * expansion),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5 + 0.45 * expansion)
                ],
                relativeTime: time
            ))
            // More distinct grains as the orbit expands; a softer return as it contracts.
            time += 0.095 - 0.04 * Double(expansion)
        }
        return try CHHapticPattern(events: events, parameters: [])
    }
}
