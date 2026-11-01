//
//  Quizz.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Foundation

struct Quizz: Codable, Identifiable, Equatable, Sendable {
    struct Question: Codable, Equatable, Sendable {
        let number: Int
        let question: String
        let answers: [Int: String]
    }

    let id: String
    let title: String
    let image: String
    let questions: [Question]?
    let matchingResults: [String: [Int]]?
    let resultDescriptions: [String: String]?
    var productID: String? = nil
    var releasedAt: Date? = nil
    var subtitle: String? = nil
    var resultImages: [String: String]? = nil

    func isReleased(at date: Date = .now) -> Bool {
        releasedAt.map { $0 <= date } ?? true
    }

    static let empty = Quizz(
        id: "",
        title: "",
        image: "",
        questions: nil,
        matchingResults: nil,
        resultDescriptions: nil
    )

    /// Short titles for themes whose full title is too long for a grid card.
    private static let displayTitles: [String: String] = [
        "weapons": "Apocalypse"
    ]

    /// One-line teasers shown under the title of the featured quiz.
    private static let teasers: [String: String] = [
        "animals": "Lynx, loup ou ornithorynque ?",
        "cities": "Tokyo, Miami ou Amsterdam ?",
        "colors": "Rouge, violet ou turquoise ?",
        "creatures": "Dragon, sirène ou kraken ?",
        "gods": "Zeus, Athéna ou Hadès ?",
        "weapons": "Ton arme anti-zombies ?"
    ]

    var displayTitle: String {
        Self.displayTitles[id] ?? title
    }

    var teaser: String? {
        subtitle ?? Self.teasers[id]
    }

#if DEBUG
    static let previewCatalog: [Quizz] = {
        let prompts: [(String, [String])] = [
            ("Un week-end libre. Tu fais quoi ?", ["Explorer un nouvel endroit", "Retrouver ma bande", "Me ressourcer au calme", "Improviser, on verra bien"]),
            ("Dans un groupe, tu es plutôt…", ["La personne qui observe", "Celle qui rassemble", "Celle qui donne le cap", "Celle qui surprend"]),
            ("Quand un imprévu bouscule tes plans, quel est ton premier réflexe ?", ["Prendre un moment pour observer la situation avant de décider tranquillement de la suite", "Demander conseil à une personne de confiance", "Chercher une nouvelle solution", "Me lancer et apprendre en chemin"]),
            ("Ton endroit pour souffler ?", ["Un sentier en forêt", "Une table avec mes proches", "Un coin tranquille chez moi", "Une ville que je découvre"]),
            ("Face à un défi, tu préfères…", ["Observer avant d’agir", "Faire équipe", "Préparer un plan", "Suivre mon instinct"]),
            ("Tes proches apprécient surtout…", ["Mon écoute", "Ma générosité", "Ma détermination", "Ma spontanéité"]),
            ("Une journée idéale commence par…", ["Un moment de calme", "Un message à mes amis", "Un objectif motivant", "Une surprise"]),
            ("Pour prendre une décision, tu…", ["Prends du recul", "Échanges avec les autres", "Pèses les possibilités", "Écoutes ton intuition"]),
            ("Ce qui te donne de l’énergie ?", ["Apprendre quelque chose", "Partager un bon moment", "Avancer sur un projet", "Changer de décor"]),
            ("Tu suis d’abord…", ["Mon intuition", "Les gens que j’aime", "Ma curiosité", "Mon envie de liberté"])
        ]
        let questions = prompts.enumerated().map { index, prompt in
            Question(
                number: index + 1,
                question: prompt.0,
                answers: Dictionary(uniqueKeysWithValues: prompt.1.enumerated().map { ($0.offset + 1, $0.element) })
            )
        }
        let themes = [
            ("animals", "Animaux", "Lynx"),
            ("cities", "Villes", "Tokyo"),
            ("colors", "Couleurs", "Violet"),
            ("creatures", "Créatures", "Dragon"),
            ("gods", "Dieux", "Zeus"),
            ("weapons", "Apocalypse", "Le katana")
        ]
        return themes.map { id, title, image in
            Quizz(
                id: id, title: title, image: image, questions: questions,
                matchingResults: [image: Array(repeating: 1, count: questions.count)],
                resultDescriptions: [image: "Tu observes, tu suis ton instinct et tu traces ton propre chemin. Tu n’as pas besoin de faire du bruit pour trouver ta place."]
            )
        }
    }()
#endif
}
