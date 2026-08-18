import UIKit
import XCTest

/// Temporary diagnostic: verifies every quiz asset resolves through UIImage(named:)
/// in the iOS runtime, in both NFC (precomposed) and NFD (decomposed) forms.
final class AssetPresenceTests: XCTestCase {
    private static let names = [
        // Animals
        "Chacal", "Chat", "Chien", "Crocodile", "Dauphin", "Faucon", "Guépard", "Hiboux",
        "Lion", "Loup", "Loutre", "Lynx", "Ornithorynque", "Pigeon", "Requin", "Singe",
        // Cities
        "Amsterdam", "Londres", "Miami", "New York", "Paris", "Rio de Janeiro", "Shanghaï", "Tokyo",
        // Colors theme
        "Blanc", "Bleu", "Jaune", "Orange", "Rose", "Rouge", "Vert", "Violet",
        // Créatures
        "Basilic", "Centaure", "Cerbère", "Chimère", "Dragon", "Fée", "Griffon", "Hydre",
        "Kraken", "Licorne", "Phoenix", "Sirène",
        // Gods
        "Aphrodite", "Apollon", "Artémis", "Arès", "Athéna", "Dionysos", "Hadès", "Hermès",
        "Héphaïstos", "Héra", "Poséidon", "Zeus",
        // Weapons
        "L'AK-47", "L'arc", "La batte de baseball", "La brosse à dents", "La tronçonneuse",
        "Le déguisement du huissier de justice", "Le fusil à pompe", "Le katana",
        // Misc
        "launchScreen"
    ]

    func testEveryAssetResolvesInBothUnicodeForms() {
        var failures: [String] = []

        for name in Self.names {
            let nfc = name.precomposedStringWithCanonicalMapping
            let nfd = name.decomposedStringWithCanonicalMapping

            if UIImage(named: nfc) == nil {
                failures.append("NFC:\(name)")
            }
            if UIImage(named: nfd) == nil {
                failures.append("NFD:\(name)")
            }
        }

        XCTAssertTrue(failures.isEmpty, "Unresolved assets: \(failures.joined(separator: ", "))")
    }
}
