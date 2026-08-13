import SwiftUI

enum AppTheme {
    // MARK: - Colors

    static let turquoise = Color("Turquoise")
    static let red = Color("Coral")

    /// Near-black used for display type and the brand pill.
    static let ink = Color(red: 0.043, green: 0.043, blue: 0.059)
    /// Near-white screen background.
    static let background = Color(red: 0.984, green: 0.992, blue: 0.992)
    /// Darker turquoise, for small accents on white.
    static let turquoiseAccent = Color(red: 0.016, green: 0.761, blue: 0.698)
    /// Coral used for call-to-action capsules.
    static let coralCTA = Color(red: 1.0, green: 0.302, blue: 0.306)
    /// Coral tint of the featured card shadow.
    static let coralShadow = Color(red: 0.878, green: 0.282, blue: 0.247)

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

    /// Turquoise wash fading out over the top of the home screen.
    static let topWash = LinearGradient(
        colors: [turquoise.opacity(0.28), turquoise.opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Typography

    enum DisplayWeight {
        case bold
        case extraBold

        fileprivate var systemWeight: Font.Weight {
            switch self {
            case .bold: .bold
            case .extraBold: .heavy
            }
        }
    }

    /// Display face for titles and pills.
    ///
    /// The design calls for Bricolage Grotesque; until the font files are
    /// bundled this falls back to the system font at an equivalent weight.
    /// Swap the return value here once `BricolageGrotesque-*` is registered.
    static func display(size: CGFloat, weight: DisplayWeight = .extraBold) -> Font {
        .system(size: size, weight: weight.systemWeight)
    }
}
