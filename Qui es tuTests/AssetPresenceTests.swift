import UIKit
import XCTest
@testable import Qui_es_tu

/// Checks the bundled catalog, including the Retina renditions used by distributed iPhone apps.
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

    func testEveryAssetLoadsForATwoTimesIPhoneDisplay() throws {
        try assertEveryAssetLoads(at: 2)
    }

    func testEveryAssetLoadsForAThreeTimesIPhoneDisplay() throws {
        try assertEveryAssetLoads(at: 3)
    }

    private func assertEveryAssetLoads(at scale: CGFloat) throws {
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceIdiom: .phone),
            UITraitCollection(displayScale: scale)
        ])

        for name in Self.names {
            let image = try XCTUnwrap(
                UIImage(named: AppAsset.name(name), in: .main, compatibleWith: traits),
                "Missing \(name) at \(scale)×"
            )
            // Xcode can thin a test build to the destination's scale, so a request
            // for the other Retina scale may fall back. The archive verifier
            // separately checks that both exact renditions are packaged.
            XCTAssertTrue([2, 3].contains(image.scale), "\(name) has no Retina rendition")
            let bitmap = try XCTUnwrap(image.cgImage, "\(name) has no decodable bitmap")
            XCTAssertGreaterThan(bitmap.width, 0)
            XCTAssertGreaterThan(bitmap.height, 0)
        }
    }
}
