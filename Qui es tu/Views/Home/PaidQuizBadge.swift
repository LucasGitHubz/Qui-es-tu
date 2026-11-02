import SwiftUI

struct PaidQuizBadge: View {
    var body: some View {
        Text("PAYANT")
            .font(.caption2.weight(.semibold))
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .tracking(0.5)
            .foregroundStyle(.primary)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(.regularMaterial, in: .capsule)
            .accessibilityHidden(true)
    }
}
