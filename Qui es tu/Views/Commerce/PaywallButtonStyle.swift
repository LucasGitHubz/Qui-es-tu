import SwiftUI

struct PaywallButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.bold))
            .foregroundStyle(PaywallTheme.actionInk)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(PaywallTheme.action, in: .capsule)
            .shadow(color: PaywallTheme.action.opacity(isEnabled ? 0.16 : 0), radius: 12, y: 6)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.5)
    }
}
