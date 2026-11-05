import CryptoKit
import Observation
import UIKit

/// Prepared images are shared by prefetching, the result screen, and sharing.
@MainActor
@Observable
final class QuizArtworkStore {
    static let shared = QuizArtworkStore()
    private(set) var images: [String: UIImage] = [:]
    @ObservationIgnored private var pending: [String: (id: UUID, task: Task<UIImage?, Never>)] = [:]
    @ObservationIgnored private let cacheDirectory: URL?
    @ObservationIgnored private let fetchData: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    init(
        cacheDirectory: URL? = URL.cachesDirectory.appending(path: "QuizArtwork", directoryHint: .isDirectory),
        fetchData: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse) = {
            try await URLSession.shared.data(for: $0)
        }
    ) {
        self.cacheDirectory = cacheDirectory
        self.fetchData = fetchData
    }

    @discardableResult
    func load(_ source: String) async -> Bool {
        guard !Task.isCancelled else { return false }
        if images[source] != nil { return true }
        let work: (id: UUID, task: Task<UIImage?, Never>)
        if let existing = pending[source] {
            work = existing
        } else {
            // Store-owned work survives a disappearing card: the reveal can await the same request.
            work = (UUID(), Task { await self.prepare(source) })
            pending[source] = work
        }
        let image = await work.task.value
        if pending[source]?.id == work.id {
            pending[source] = nil
            if let image { images[source] = image }
        }
        return image != nil && !Task.isCancelled
    }

    private func prepare(_ source: String) async -> UIImage? {
        let image: UIImage?
        if let url = URL(string: source), url.scheme == "https" {
            let key = SHA256.hash(data: Data(source.utf8)).map { String(format: "%02x", $0) }.joined()
            let file = cacheDirectory?.appending(path: key)
            if let file, let data = try? Data(contentsOf: file), let cached = UIImage(data: data) {
                image = cached
            } else {
                do {
                    let (data, response) = try await fetchData(URLRequest(url: url, timeoutInterval: 12))
                    guard let response = response as? HTTPURLResponse,
                          (200..<300).contains(response.statusCode), let downloaded = UIImage(data: data) else { return nil }
                    image = downloaded
                    if let cacheDirectory, let file {
                        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
                        try? data.write(to: file, options: .atomic)
                    }
                } catch { return nil }
            }
        } else {
            image = UIImage(named: AppAsset.name(source))
        }
        guard let image else { return nil }
        return await image.byPreparingThumbnail(ofSize: CGSize(width: 1200, height: 1200)) ?? image
    }

    func preload(_ sources: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            var remaining = Set(sources).makeIterator()
            for _ in 0..<4 {
                guard let source = remaining.next() else { break }
                group.addTask { _ = await self.load(source) }
            }
            for await _ in group {
                guard !Task.isCancelled else { break }
                if let source = remaining.next() {
                    group.addTask { _ = await self.load(source) }
                }
            }
        }
    }
}
