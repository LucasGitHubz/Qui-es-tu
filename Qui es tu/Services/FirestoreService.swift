//
//  FirestoreService.swift
//  Qui es tu
//
//  Created by Lucas on 26/12/2024.
//

import FirebaseFirestore

class FirestoreService {
    func fetchAllQuizzes() async throws -> [Quizz] {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("quizzes").getDocuments()
            let quizzes = try snapshot.documents.compactMap { document in
                try document.data(as: Quizz.self)
            }
            return quizzes
        } catch {
            throw error
        }
    }
}
