import SwiftUI

struct PaywallBenefitRow: View {
    let title: LocalizedStringKey
    let symbol: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var iconSize = 21

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))
        layout {
            Image(systemName: symbol)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(PaywallTheme.accent)
                .frame(width: max(36, iconSize + 15), height: max(36, iconSize + 15))
                .background(PaywallTheme.accentSurface, in: .rect(cornerRadius: 14))
                .accessibilityHidden(true)
            Text(title)
                .font(.body.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
