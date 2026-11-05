import SwiftUI

struct PaywallHeroCard: View {
    let asset: String
    let angle: Double
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        let isVisible = hasAppeared || reduceMotion

        GeometryReader { geometry in
            let border = geometry.size.width * 0.04
            let radius = geometry.size.width * 0.11

            Image(asset)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width - border * 2, height: geometry.size.height - border * 2)
                .clipShape(.rect(cornerRadius: radius - border))
                .padding(border)
                .background(Color(red: 0.995, green: 0.991, blue: 0.975), in: .rect(cornerRadius: radius))
                .shadow(color: .black.opacity(0.16), radius: 7, y: 5)
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.92)
        .rotationEffect(.degrees(isVisible ? angle : angle * 0.45))
        .offset(y: isVisible ? 0 : 22)
        .animation(reduceMotion ? nil : .smooth(duration: 0.85).delay(delay), value: hasAppeared)
        .onAppear { hasAppeared = true }
    }
}
