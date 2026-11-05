import SwiftUI

struct PaywallSparkle: View {
    let color: Color
    let size: CGFloat
    let start: UnitPoint
    let end: UnitPoint
    let canvas: CGSize
    let delay: Double
    let shimmerDuration: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasEntered = false
    @State private var isShimmering = false

    var body: some View {
        let isVisible = hasEntered || reduceMotion
        let shouldShimmer = isShimmering && !reduceMotion && scenePhase == .active
        let phases: [PaywallSparklePhase] = shouldShimmer
            ? [.rest, .shine, .rest, .warm]
            : [.rest]

        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(color.gradient)
            .phaseAnimator(phases) { content, phase in
                content
                    .overlay {
                        Image(systemName: "sparkle")
                            .foregroundStyle(.white)
                            .scaleEffect(0.42)
                            .blur(radius: 0.6)
                            .opacity(phase.highlight)
                    }
                    .scaleEffect(phase.scale)
                    .opacity(phase.opacity)
                    .hueRotation(.degrees(phase.hue))
                    .shadow(color: color.opacity(phase.highlight), radius: phase == .shine ? 6 : 3)
            } animation: { _ in
                reduceMotion ? nil : .easeInOut(duration: shimmerDuration)
            }
            .id(shouldShimmer)
            .scaleEffect(isVisible ? 1 : 0.35)
            .opacity(isVisible ? 1 : 0)
            .position(
                x: canvas.width * (isVisible ? end.x : start.x),
                y: canvas.height * (isVisible ? end.y : start.y)
            )
            .onAppear {
                guard !hasEntered else { return }
                if reduceMotion {
                    hasEntered = true
                    isShimmering = true
                } else {
                    withAnimation(.smooth(duration: 1.25).delay(delay)) {
                        hasEntered = true
                    } completion: {
                        isShimmering = true
                    }
                }
            }
    }
}
