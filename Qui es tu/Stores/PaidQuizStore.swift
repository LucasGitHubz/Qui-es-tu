import CryptoKit
import Foundation

/// Downloaded content never grants access; callers must still have verified StoreKit ownership.
@MainActor
final class PaidQuizStore {
    static let shared = PaidQuizStore()
    private var entries: [String: Entry] = [:]
    private var pending: [String: Task<Quizz, Error>] = [:]
    private let directory: URL?
    private let fetch: @Sendable (Quizz, String) async throws -> Quizz

    private struct Entry: Codable {
        let quiz: Quizz
        let downloadedAt: Date
    }

    init(
        directory: URL? = URL.cachesDirectory.appending(path: "PaidQuizzes", directoryHint: .isDirectory),
        fetch: @escaping @Sendable (Quizz, String) async throws -> Quizz = { quiz, proof in
            try await PaidQuizService().fetch(quiz, proof: proof)
        }
    ) {
        self.directory = directory
        self.fetch = fetch
    }

    func cachedQuiz(for quiz: Quizz, access: QuizAccess) -> Quizz? {
        guard quiz.productID != nil, quiz.isReleased(), access.canOpen(quiz) else { return nil }
        if entries[quiz.id] == nil, let file = file(for: quiz),
           let data = try? Data(contentsOf: file), let entry = try? JSONDecoder().decode(Entry.self, from: data) {
            entries[quiz.id] = entry
        }
        guard let entry = entries[quiz.id], entry.quiz.productID == quiz.productID,
              entry.quiz.id == quiz.id, entry.quiz.questions?.isEmpty == false else { return nil }
        return entry.quiz
    }

    func prepare(_ quiz: Quizz, access: QuizAccess, proof: String, refresh: Bool = false) async throws -> Quizz {
        guard quiz.productID != nil, quiz.isReleased(), access.canOpen(quiz), !proof.isEmpty else {
            throw PaidQuizService.PaidQuizError.unavailable
        }
        if let cached = cachedQuiz(for: quiz, access: access),
           !refresh || (entries[quiz.id]?.downloadedAt.timeIntervalSinceNow ?? -.infinity) > -300 {
            return cached
        }
        if let task = pending[quiz.id] { return try await task.value }
        let task = Task { try await fetch(quiz, proof) }
        pending[quiz.id] = task
        defer { pending[quiz.id] = nil }
        let content = try await task.value
        guard content.id == quiz.id, content.productID == quiz.productID,
              content.questions?.isEmpty == false else { throw PaidQuizService.PaidQuizError.unavailable }
        let entry = Entry(quiz: content, downloadedAt: .now)
        entries[quiz.id] = entry
        if let directory, let file = file(for: quiz), let data = try? JSONEncoder().encode(entry) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try? data.write(to: file, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        }
        return content
    }

    private func file(for quiz: Quizz) -> URL? {
        let key = SHA256.hash(data: Data(quiz.id.utf8)).map { String(format: "%02x", $0) }.joined()
        return directory?.appending(path: key + ".json")
    }
}
