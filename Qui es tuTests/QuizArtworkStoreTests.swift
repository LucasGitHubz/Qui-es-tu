import XCTest
@testable import Qui_es_tu

final class QuizArtworkStoreTests: XCTestCase {
    @MainActor
    func testPreloadMakesEveryCoverAvailableBeforeReturning() async throws {
        let store = QuizArtworkStore()
        let sources = ["Lynx", "Tokyo", "Violet", "Dragon", "Zeus", "Le katana"]

        await store.preload(sources + sources)

        XCTAssertEqual(store.images.count, Set(sources).count)
        for source in sources {
            let image = try XCTUnwrap(store.images[source], "Cover not ready: \(source)")
            XCTAssertNotNil(image.cgImage)
        }
        let first = try XCTUnwrap(store.images[sources[0]])
        await store.load(sources[0])
        XCTAssertTrue(first === store.images[sources[0]], "Display should reuse the prepared cover")
    }

    @MainActor
    func testMissingCoverDoesNotBlockOtherCovers() async {
        let store = QuizArtworkStore()

        await store.preload(["missing-test-cover", "Lynx"])

        XCTAssertNil(store.images["missing-test-cover"])
        XCTAssertNotNil(store.images["Lynx"])
    }
}
