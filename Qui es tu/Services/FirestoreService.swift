//
//  FirestoreService.swift
//  Qui es tu
//
//  Created by Lucas on 26/12/2024.
//

import FirebaseFirestore

class FirestoreService {
    var quizz = Quizz(id: "gods", title: "Dieux", image: "Zeus", questions: [
        Quizz.Question(number: 0, question: "Quelle-est ta saison préférée ?", answers: [
            1: "Eté",
            2: "Hiver",
            3: "Automne",
            4: "Printemps"
        ]),
        Quizz.Question(number: 1, question: "Tu préfères :", answers: [
            1: "Les spaghettis bolognaise",
            2: "Les pâtes à pouf",
            3: "Les pâtes aux fruits de mer",
            4: "Les pâtes carbonara"
        ]),
        Quizz.Question(number: 2, question: "Où aimes-tu passer du temps ?", answers: [
            1: "Dans un aquarium",
            2: "Dans une bibliothèque",
            3: "Dans une galerie d'art",
            4: "Dans un musée"
        ]),
        Quizz.Question(number: 3, question: "Quelle serait ta réaction si les habitants de la planète, sauf toi, se changeaient en vache ?", answers: [
            1: "Tu organiserais une gigantesque steak-partie avec, toi, comme seul(e) participant(e)",
            2: "Tu es persuadé(e) d'être une vache depuis ta naissance, donc rien ne change à ta vie",
            3: "Tu serais tout simplement content(e) d'avoir une superbe pelouse",
            4: "Tu t'entraînerais au rodéo, afin de devenir un(e) véritable cow-boy/cow-girl"
        ]),
        Quizz.Question(number: 4, question: "Quelle type de série aimes-tu ?", answers: [
            1: "Les séries policières",
            2: "Tu n'es pas série",
            3: "Les séries fantastiques",
            4: "Les séries romantiques"
        ]),
        Quizz.Question(number: 5, question: "Quel serait ton voeu ?", answers: [
            1: "Être plus petit(e)",
            2: "Être plus gros(se)",
            3: "Être plus mince",
            4: "Être plus grand(e)"
        ]),
        Quizz.Question(number: 6, question: "Tu es plutôt :", answers: [
            1: "Soirée romantique",
            2: "Soirée à la maison",
            3: "Soirée entre amis",
            4: "Suavemente"
        ]),
        Quizz.Question(number: 7, question: "Quel continent préfères-tu ?", answers: [
            1: "Afrique",
            2: "Europe",
            3: "Asie",
            4: "Amérique"
        ]),
        Quizz.Question(number: 8, question: "Tu es plus du genre :", answers: [
            1: "Méfiant(e)",
            2: "Sauvage",
            3: "Peureux(se)",
            4: "Craintif(ve)"
        ]),
        Quizz.Question(number: 9, question: "En train de perdre au Monopoly, tu :", answers: [
            1: "T'en fiches car dans la vraie vie c'est toi le/la plus riche",
            2: "Agis dans la plus grande discrétion et balance le plateau de jeu contre un mur",
            3: "Pleures à chaudes larmes en enchaînant une série de pas de danse",
            4: "Es prêt(e) à commettre un acte cruel pour remporter la victoire"
        ])
    ], matchingResults: [
        "Zeus": [4, 4, 3, 1, 4, 4, 4, 2, 1, 1],
        "Héra": [4, 1, 2, 2, 4, 3, 2, 1, 3, 3],
        "Poséidon": [1, 3, 1, 4, 3, 1, 3, 4, 1, 2],
        "Apollon": [4, 4, 3, 3, 2, 1, 4, 2, 4, 1],
        "Athéna": [2, 1, 3, 4, 1, 2, 1, 3, 2, 4],
        "Artémis": [2, 2, 4, 2, 4, 1, 1, 1, 3, 3],
        "Aphrodite": [4, 2, 4, 3, 4, 3, 4, 4, 4, 3],
        "Arès": [3, 1, 2, 1, 3, 2, 2, 3, 2, 4],
        "Héphaïstos": [1, 2, 1, 1, 2, 1, 2, 2, 1, 2],
        "Hadès": [2, 1, 4, 1, 1, 1, 2, 2, 1, 4],
        "Hermès": [1, 3, 1, 4, 4, 3, 3, 4, 3, 2],
        "Dionysos": [3, 4, 3, 3, 3, 3, 3, 2, 4, 1]
    ], resultDescriptions: [
        "Zeus": "Charismatique et fier, tu rayonnes par ta force et ta prestance. Protecteur des tiens, tu inspires le respect, mais attention: un excès de confiance pourrait te faire trébucher… Même les dieux ne sont pas invincibles !",
        "Héra": "Fière et jalouse, tu n'es pas très agréable à vivre... Mais on te comprend ! Cette attitude est due à ton entourage. Alors si tu veux un conseil, change tes fréquentations !!",
        "Poséidon": "Rapide et majestueux, tu règnes sur les océans avec une puissance divine. Ton calme est légendaire, mais gare à celui qui troublera tes eaux : ton trident ne sera pas là pour décorer !",
        "Apollon": "Grand, beau et fort, tu sembles être l'idéal incarné. Mais reste humble, car une trop grosse tête risque de te laisser seul… comme le soleil, une fois la nuit tombée.",
        "Athéna": "Sage et brillante, tu as un esprit vif capable de lire les autres d’un simple regard. Ton tempérament passionné est une force, mais veille à ne pas brûler ceux qui s’approchent trop près de toi.",
        "Artémis": "Sauvage et captivante, tu es l’essence même de la beauté naturelle. Pourtant, tu n’en fais aucun cas et renvoies avec élégance ceux qui ne voient pas au-delà de ton apparence.",
        "Aphrodite": "Séductrice et intelligente, ton charme est une arme redoutable que tu manies avec maîtrise. On te cède tout, mais attention: à trop vouloir, on finit parfois par tout perdre…",
        "Arès": "Sanguin et impulsif, tu es une véritable boule d’énergie, toujours prêt à foncer tête baissée dans l’action. Mais réfléchis un peu: foncer sans plan, c’est comme vouloir courir avant de savoir marcher...",
        "Héphaïstos": "Acharné et persévérant, tu ne comptes pas tes efforts pour atteindre tes objectifs. Mais prends garde: la vie n’est pas qu’une course. Lève parfois les yeux pour admirer les étoiles… avant qu’il ne soit trop tard.",
        "Hadès": "Colérique et calculateur, tu as soif de pouvoir et ne recules devant rien pour l’obtenir. Ton humour masque une certaine noirceur… Après tout, tu n’es pas surnommé le maître des enfers pour rien !",
        "Hermès": "Loyal et rapide d’esprit, tu es une personne de confiance et un pilier pour ton entourage. Ta nature protectrice te rend précieux, et on sait qu’avec toi, tout est sous contrôle.",
        "Dionysos": "Fêtard invétéré, tu as un humour décalé et une imagination débordante. Et quand il s’agit de lever un verre, ton endurance est légendaire. Gare toutefois à ne pas finir dans un tonneaun, sans fond..."
    ])
    func saveQuizz(completion: @escaping (Error?) -> Void) {
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
