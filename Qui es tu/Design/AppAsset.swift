import Foundation

enum AppAsset {
    static func name(_ name: String) -> String {
        name.decomposedStringWithCanonicalMapping
    }
}
