import SwiftUI

struct HomeBackground: View {
    var body: some View {
        GeometryReader { proxy in
            HomeTheme.background
                .overlay(alignment: .top) {
                    LinearGradient(colors: [HomeTheme.topWash, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: proxy.size.height * 0.45)
                }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
