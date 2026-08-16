import XCTest
@testable import Qui_es_tu

final class AppAssetTests: XCTestCase {
    func testNameUsesAssetCatalogUnicodeNormalization() {
        let composedName = "Sir\u{E8}ne"

        let normalizedName = AppAsset.name(composedName)

        XCTAssertEqual(normalizedName, "Sire\u{300}ne")
        XCTAssertTrue(normalizedName.isDecomposed)
    }

    func testNameLeavesASCIIUnchanged() {
        XCTAssertEqual(AppAsset.name("Dragon"), "Dragon")
    }
}

private extension String {
    var isDecomposed: Bool {
        self == decomposedStringWithCanonicalMapping
    }
}
