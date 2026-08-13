import SwiftUI

struct HomeBackground: View {
    var body: some View {
        GeometryReader { proxy in
            AppTheme.background
                .overlay(alignment: .top) {
                    AppTheme.topWash
                        .frame(height: proxy.size.height * 0.45)
                }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
