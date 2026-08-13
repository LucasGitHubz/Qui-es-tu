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

        return try snapshot.documents.map { document in
            try document.data(as: Quizz.self)
        }
    }
}
