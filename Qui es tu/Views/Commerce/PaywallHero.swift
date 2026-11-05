import SwiftUI

struct PaywallHero: View {
    var body: some View {
        Color.clear
            .aspectRatio(1.5, contentMode: .fit)
            .overlay {
                GeometryReader { geometry in
                    ZStack {
                        PaywallConstellation()
                        PaywallHeroCard(asset: "PaywallPhoenix", angle: -13, delay: 0.08)
                            .frame(width: geometry.size.width * 0.31, height: geometry.size.height * 0.68)
                            .position(x: geometry.size.width * 0.235, y: geometry.size.height * 0.52)
                        PaywallHeroCard(asset: "PaywallOwl", angle: 12, delay: 0.28)
                            .frame(width: geometry.size.width * 0.31, height: geometry.size.height * 0.68)
                            .position(x: geometry.size.width * 0.765, y: geometry.size.height * 0.52)
                        PaywallHeroCard(asset: "PaywallFox", angle: 4, delay: 0.48)
                            .frame(width: geometry.size.width * 0.40, height: geometry.size.height * 0.85)
                            .position(x: geometry.size.width * 0.50, y: geometry.size.height * 0.49)
                    }
                }
                .allowsHitTesting(false)
            }
            .background {
                GeometryReader { geometry in
                    EllipticalGradient(
                        stops: [
                            .init(color: PaywallTheme.glow.opacity(0.72), location: 0),
                            .init(color: PaywallTheme.glow.opacity(0.32), location: 0.5),
                            .init(color: .clear, location: 1)
                        ],
                        center: .center,
                        startRadiusFraction: 0,
                        endRadiusFraction: 0.5
                    )
                    .frame(width: geometry.size.width * 1.55, height: geometry.size.height * 1.9)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.45)
                }
                .allowsHitTesting(false)
            }
            .accessibilityHidden(true)
    }
}
