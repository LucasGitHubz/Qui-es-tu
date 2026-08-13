import SwiftUI

struct HomeHeader: View {
    var body: some View {
        HStack {
            Text("QUI ES-TU ?")
                .font(AppTheme.display(size: 14))
                .tracking(1)
                .foregroundStyle(AppTheme.turquoise)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(AppTheme.ink, in: .capsule)

            Spacer()
        }
    }
}

#Preview {
    HomeHeader()
        .padding(20)
        .background { HomeBackground() }
}
