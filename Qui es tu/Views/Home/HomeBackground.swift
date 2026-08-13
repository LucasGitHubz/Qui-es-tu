import SwiftUI

struct HomeBackground: View {
    var body: some View {
        AppTheme.screenGradient
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
