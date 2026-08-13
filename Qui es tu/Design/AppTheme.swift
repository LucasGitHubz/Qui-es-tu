import SwiftUI

enum AppTheme {
    static let turquoise = Color("Turquoise")
    static let red = Color("Coral")

    static let accentGradient = LinearGradient(
        colors: [red, turquoise],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenGradient = LinearGradient(
        colors: [turquoise.opacity(0.5), red.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
}
