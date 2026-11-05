import Foundation

enum PaywallSparklePhase {
    case rest, shine, warm

    var scale: CGFloat {
        switch self {
        case .rest: 0.94
        case .shine: 1.10
        case .warm: 1.02
        }
    }

    var opacity: Double {
        switch self {
        case .rest: 0.78
        case .shine: 1
        case .warm: 0.90
        }
    }

    var hue: Double {
        switch self {
        case .rest: 0
        case .shine: -5
        case .warm: 8
        }
    }

    var highlight: Double {
        switch self {
        case .rest: 0.05
        case .shine: 0.4
        case .warm: 0.16
        }
    }
}
