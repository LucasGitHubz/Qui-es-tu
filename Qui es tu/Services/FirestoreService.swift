//
//  FirestoreService.swift
//  Qui es tu
//
//  Created by Lucas on 26/12/2024.
//

import FirebaseFirestore

class FirestoreService {
    var quizz = Quizz(id: "weapons", title: "Arme en cas d'apocalypse", image: "L'AK-47", questions: [
        Quizz.Question(number: 0, question: "Quel-est ton plus grand défaut ?", answers: [
            1: "Maladroit(e)",
            2: "Inconscient(e)",
            3: "Têtu(e)",
            4: "Impatient(e)"
        ]),
        Quizz.Question(number: 1, question: "Tu es plutôt ?", answers: [
            1: "Vampire",
            2: "Zombie",
            3: "Loup-garou",
            4: "Sorcière"
        ]),
        Quizz.Question(number: 2, question: "Tu fais une chute à vélo, quelle-est ta réaction ?", answers: [
            1: "De rage, tu casses ton vélo et finis à pieds",
            2: "Tu éclates de rire car dans ta chute tu as écrasé une fourmi",
            3: "Tu vas à l'hôpital, persuadé d'avoir une triple fracture du coude",
            4: "Tu pleures à chaudes larmes"
        ]),
        Quizz.Question(number: 3, question: "Quel-est ton point fort ?", answers: [
            1: "Ta force",
            2: "Ton intelligence",
            3: "Ta beauté",
            4: "Ton charisme"
        ]),
        Quizz.Question(number: 4, question: "Tu écoutes principalement :", answers: [
            1: "Du rap",
            2: "Du rock",
            3: "De la pop/dance",
            4: "De la musique classique"
        ]),
        Quizz.Question(number: 5, question: "Quelle huile préfères-tu ?", answers: [
            1: "L'huile de noix",
            2: "L'huile de moteur",
            3: "L'huile d'olive",
            4: "L'huile de tournesol"
        ]),
        Quizz.Question(number: 6, question: "Quelle cuisson préfères-tu pour ton steak ?", answers: [
            1: "Bleue",
            2: "Saignante",
            3: "À point",
            4: "Carbonisée"
        ]),
        Quizz.Question(number: 7, question: "Tu préfères :", answers: [
            1: "Boire de l'eau",
            2: "Boire du thé",
            3: "Boire des sirops",
            4: "Boire des sodas"
        ]),
        Quizz.Question(number: 8, question: "Quelle-est ta destination favorite ?", answers: [
            1: "Le Pérou",
            2: "L'Égypte",
            3: "La Thaïlande",
            4: "L'Himalaya"
        ]),
        Quizz.Question(number: 9, question: "Quelle serait ta réaction si un policier t'attrape en train de voler une orange au marché ?", answers: [
            1: "Tu te fais pipi dessus",
            2: "Tu la manges devant lui puis, tu rotes",
            3: "Tu bouges plus en espérant être invisible",
            4: "Tu le regardes en louchant, pour lui faire croire que tu as confondu avec Pupuce ton chinchilla"
        ])
    ], matchingResults: [
        "La tronçonneuse": [4, 1, 2, 1, 2, 2, 4, 4, 3, 2],
        "Le fusil à pompe": [3, 2, 1, 1, 1, 1, 2, 1, 4, 3],
        "La brosse à dents": [2, 1, 3, 3, 4, 3, 3, 1, 4, 1],
        "Le déguisement du huissier de justice": [1, 4, 4, 2, 3, 3, 3, 2, 1, 4],
        "L'AK-47": [1, 3, 1, 1, 1, 2, 2, 4, 1, 1],
        "La batte de baseball": [2, 2, 2, 4, 2, 1, 1, 3, 2, 2],
        "Le katana": [3, 3, 3, 4, 4, 4, 1, 2, 3, 3],
        "L'arc": [3, 4, 4, 3, 4, 4, 1, 2, 2, 3]
    ], resultDescriptions: [
        "La tronçonneuse": "Complètement timbré, ta tronçonneuse est ton arme de prédilection ! L'apocalypse est pour toi une bénédiction, et ta plus grande passion est de tailler tout ce qui bouge… et même ce qui ne bouge pas. Bref, tout y passe !",
        "Le fusil à pompe": "Quelque peu bourrin et dur(e) à cuire, ton arme favorite est le fusil à pompe ! Prenant les zombies pour du gibier, tu pars chaque dimanche à la chasse, sans oublier, bien sûr, ta fidèle bouteille de pastaga (pastis).",
        "La brosse à dents": "Maniaque et un peu relou(e) sur les bords, ton arme favorite est ta super brosse à dents dernier cri ! Tu détestes par dessus tout les gens qui oublient le brossage du soir et n'hésites pas à les harceler jusqu'à ce qu'ils s'y mettent ! Aucun doute, les zombies ne feront pas long feu avec toi...",
        "Le déguisement du huissier de justice": "Effrayant(e) et intransigeant(e), ton arme favorite est ton déguisement de huissier de justice ! Semant la terreur sur ton passage, tu es craint de tous. D’un simple regard, tu peux faire fuir une horde de zombies affamés...",
        "L'AK-47": "Combattant(e) et sanguin(e), ton arme favorite est l'AK-47 ! Tu adores le gruyère et non pas seulement dans tes pâtes, mais surtout pour rendre les zombies comme tel en mitraillant dans tous les sens.",
        "La batte de baseball": "Intrépide et tête brûlée, ton arme favorite est ta batte de baseball ! Grand(e) passionné(e) de ce sport, tu fonces dans le tas à chaque occasion, en essayant, bien sûr, de réaliser un maximum de Home Run !",
        "Le katana": "Furtif(ve) et rapide, ton arme favorite est le katana ! Maître incontesté du sabre, tu es capable de découper une balle en plein vol ou de trancher du thon rouge pour préparer de délicieux sushis.",
        "L'arc": "Discret(e) et à la vue aiguisée, ton arme favorite est l'arc ! Te croyant encore au Moyen Age, tu penses que la terre est plate et es persuadé(e) que ton arc en bois miteux, est l'arme la plus meurtrière au monde !"
    ])

    func saveQuizz() async throws {
        let db = Firestore.firestore()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try db.collection("quizzes").document(quizz.id).setData(from: quizz) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

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
