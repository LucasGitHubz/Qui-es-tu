import Foundation
import Testing
import UIKit
@testable import Qui_es_tu

@MainActor
struct LoadingFlowTests {
    private let source = "https://example.test/result.jpg"

    @Test func resultWaitsForDecodedRemoteArtworkAndReusesItsInFlightDownload() async throws {
        let requested = DownloadGate()
        let release = DownloadGate()
        let calls = DownloadCounter()
        let data = try #require(UIImage(named: "Lynx")?.jpegData(compressionQuality: 0.8))
        let artwork = QuizArtworkStore(cacheDirectory: nil) { request in
            await calls.increment()
            await requested.open()
            await release.wait()
            return (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let store = finishedStore(artwork: artwork)
        let prefetch = Task { await artwork.load(source) }
        await requested.wait()
        let reveal = Task { await store.revealResult() }
        // One actor turn lets reveal join the pending artwork request.
        await Task.yield()
        #expect(store.isLoadingResult)
        #expect(artwork.images[source] == nil)
        await release.open()
        await reveal.value
        #expect(await prefetch.value)
        #expect(await calls.value == 1)
        #expect(store.isLoadingResult == false)
        #expect(store.resultArtworkFailed == false)
        #expect(artwork.images[source]?.cgImage != nil)
    }

    @Test func failedImageDoesNotRevealAnEmptyPortraitAndCanBeRetried() async throws {
        let calls = DownloadCounter()
        let data = try #require(UIImage(named: "Lynx")?.jpegData(compressionQuality: 0.8))
        let artwork = QuizArtworkStore(cacheDirectory: nil) { request in
            let number = await calls.increment()
            if number == 1 { throw URLError(.notConnectedToInternet) }
            return (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let store = finishedStore(artwork: artwork)
        await store.revealResult()
        #expect(store.resultArtworkFailed)
        #expect(store.userAnswers == [1])
        store.retryResultArtwork()
        await store.revealResult()
        #expect(store.resultArtworkFailed == false)
        #expect(artwork.images[source] != nil)
    }

    @Test func downloadedArtworkSurvivesRelaunchWithoutAnotherNetworkRequest() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let data = try #require(UIImage(named: "Lynx")?.jpegData(compressionQuality: 0.8))
        let first = QuizArtworkStore(cacheDirectory: directory) { request in
            (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        #expect(await first.load(source))
        let reopened = QuizArtworkStore(cacheDirectory: directory) { _ in
            Issue.record("A cached image must not request the network")
            throw URLError(.notConnectedToInternet)
        }
        #expect(await reopened.load(source))
        #expect(reopened.images[source]?.cgImage != nil)
    }

    @Test func resettingQuizWhileImageLoadsCannotRevealThePreviousResult() async throws {
        let requested = DownloadGate()
        let release = DownloadGate()
        let data = try #require(UIImage(named: "Lynx")?.jpegData(compressionQuality: 0.8))
        let artwork = QuizArtworkStore(cacheDirectory: nil) { request in
            await requested.open()
            await release.wait()
            return (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let store = finishedStore(artwork: artwork)
        let reveal = Task { await store.revealResult() }
        await requested.wait()
        store.resetQuizz()
        await release.open()
        await reveal.value
        #expect(store.bestMatchResult == nil)
        #expect(store.isQuizzFinished == false)
        #expect(store.resultArtworkFailed == false)
    }

    private func finishedStore(artwork: QuizArtworkStore) -> QuizzStore {
        let quiz = Quizz(id: "remote", title: "Test", image: "Lynx",
                         questions: [.init(number: 1, question: "Question", answers: [1: "Oui"])],
                         matchingResults: ["Lynx": [1]], resultDescriptions: ["Lynx": "Portrait"],
                         resultImages: ["Lynx": source])
        let store = QuizzStore(quizzes: [quiz], artwork: artwork, revealDelay: .zero)
        store.setQuizz(id: quiz.id)
        store.selectAnswer(answerNumber: 1)
        store.validateAnswer()
        return store
    }
}
