//
//  FirestoreService.swift
//  Qui es tu
//
//  Created by Lucas on 26/12/2024.
//

import FirebaseFirestore

struct FirestoreService: QuizzService {
    func fetchAllQuizzes() async throws -> [Quizz] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("quizzes").getDocuments()

        let free = try snapshot.documents.map { document in
            try document.data(as: Quizz.self)
        }
        // A separate collection keeps paid content out of older app versions.
        // Failure of the optional weekly catalogue must not remove free quizzes.
        do {
            let releases = try await db.collection("quizReleases").getDocuments()
            let paid = try releases.documents.map { try $0.data(as: Quizz.self) }
                .filter { $0.productID != nil && $0.isReleased() }
            let freeIDs = Set(free.map(\.id))
            return free + paid.filter { !freeIDs.contains($0.id) }
                .sorted { ($0.releasedAt ?? .distantPast) > ($1.releasedAt ?? .distantPast) }
        } catch {
            return free
        }
    }
}
