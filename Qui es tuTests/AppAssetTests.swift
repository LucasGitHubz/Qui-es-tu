import XCTest
@testable import Qui_es_tu

final class AppAssetTests: XCTestCase {
    func testNameUsesAssetCatalogUnicodeNormalization() {
        let composedName = "Sir\u{E8}ne"

        let normalizedName = AppAsset.name(composedName)

        // String equality treats NFC and NFD as equivalent, so compare the actual scalars.
        XCTAssertEqual(
            Array(normalizedName.unicodeScalars),
            Array("Sire\u{300}ne".unicodeScalars)
        )
    }

    func testNameLeavesASCIIUnchanged() {
        XCTAssertEqual(AppAsset.name("Dragon"), "Dragon")
    }
}
