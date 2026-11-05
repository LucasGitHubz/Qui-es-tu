import SwiftUI

struct PaywallConstellation: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PaywallSparkle(color: PaywallTheme.accent, size: 19,
                               start: .init(x: 0.30, y: 0.34), end: .init(x: 0.16, y: 0.12),
                               canvas: geometry.size, delay: 1.15, shimmerDuration: 1.7)
                PaywallSparkle(color: PaywallTheme.action, size: 21,
                               start: .init(x: 0.71, y: 0.34), end: .init(x: 0.84, y: 0.12),
                               canvas: geometry.size, delay: 1.4, shimmerDuration: 2.1)
                PaywallSparkle(color: PaywallTheme.accent, size: 12,
                               start: .init(x: 0.30, y: 0.68), end: .init(x: 0.075, y: 0.92),
                               canvas: geometry.size, delay: 1.65, shimmerDuration: 2.3)
                PaywallSparkle(color: HomeTheme.premiumInk, size: 14,
                               start: .init(x: 0.71, y: 0.68), end: .init(x: 0.925, y: 0.91),
                               canvas: geometry.size, delay: 1.85, shimmerDuration: 1.9)
            }
        }
    }
}
