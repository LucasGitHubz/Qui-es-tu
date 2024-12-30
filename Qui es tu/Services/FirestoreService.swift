//
//  FirestoreService.swift
//  Qui es tu
//
//  Created by Lucas on 26/12/2024.
//

import FirebaseFirestore

class FirestoreService {
    func saveQuizz(_ quizz: Quizz, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        do {
            try db.collection("quizzes").document(quizz.id).setData(from: quizz) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    func fetchAllQuizzes(completion: @escaping ([Quizz]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("quizzes").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            do {
                // Use compactMap to decode each document into a Quizz object
                let quizzes = try snapshot?.documents.compactMap { document in
                    try document.data(as: Quizz.self)
                }
                completion(quizzes, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
