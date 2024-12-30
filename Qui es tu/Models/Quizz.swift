//
//  Quizz.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Foundation

struct Quizz: Codable, Identifiable {
    struct Question: Codable {
        let number: Int
        let question: String
        let answers: [Int: String]
    }
    // Maybe pass all the variables to let type if I can fetch and convert dirctly the object from firebase.
    var id: String
    var title: String
    var image: String
    var questions: [Question]?
    var matchingResults: [String: [Int]]?
    var resultDescriptions: [String: String]?

    static let fakeQuizz = [
        Quizz(id: "1", title: "Animals", image: "Chat", questions: [
            Question(number: 0, question: "Quelle serait ta réaction si un gland te tombait sur la tête ?", answers: [
                1: "Tu cherches qui te l'a jeté",
                2: "Tu le manges",
                3: "Tu le plantes",
                4: "Tu le gardes précieusement"
            ]),
            Question(number: 1, question: "Que préfères-tu ?", answers: [
                1: "Donner la patte",
                2: "Faire le mort quand tu entends PAN !",
                3: "Aller chercher la balle",
                4: "Faire le beau"
            ]),
            Question(number: 2, question: "Quel type de soirée préfères-tu ?", answers: [
                1: "Soirée cinéma",
                2: "Soirée karaoké",
                3: "Soirée chez des amis",
                4: "Soirée dansante"
            ]),
            Question(number: 3, question: "Quel-est ton péché mignon ?", answers: [
                1: "Le chocolat",
                2: "Les Jelly Belly goût crotte de nez",
                3: "Les chips",
                4: "Les bonbons"
            ]),
            Question(number: 4, question: "Ton élément favori est :", answers: [
                1: "Air",
                2: "Feu",
                3: "Eau",
                4: "Terre"
            ]),
            Question(number: 5, question: "Quel fruit préfères-tu ?", answers: [
                1: "Banane",
                2: "Noix de coco",
                3: "Fraise",
                4: "Orange"
            ]),
            Question(number: 6, question: "Tu achètes un nouveau coussin chez IKEA, il est :", answers: [
                1: "Mou et doux",
                2: "Dur comme un parpaing",
                3: "Senteur crottin d'iguane",
                4: "Avec des plumes roses"
            ]),
            Question(number: 7, question: "Tu te décides à faire du sport :", answers: [
                1: "Tu pars courir 10km",
                2: "Tu t'entraînes à dormir les yeux ouverts",
                3: "Tu disputes une partie endiablée de ping-pong",
                4: "Tu fais des longueurs dans ta piscine"
            ]),
            Question(number: 8, question: "Tu es plutôt :", answers: [
                1: "Forêt",
                2: "Savane",
                3: "Jungle",
                4: "Plage"
            ]),
            Question(number: 9, question: "Quel moyen de transport préfères-tu ?", answers: [
                1: "Avion",
                2: "Voiture",
                3: "Bateau",
                4: "Vélo"
            ])
        ], matchingResults: [
            "Lion": [4,1,2,1,4,2,3,2,4,4],
            "Singe": [2,3,3,4,2,2,2,3,3,2],
            "Lynx": [3,1,4,3,4,1,2,2,2,4],
            "Ornithorynque": [1,4,3,1,3,2,2,4,1,1],
            "Chacal": [3,2,4,3,3,3,3,2,4,1],
            "Pigeon": [2,4,3,2,1,1,3,4,3,2],
            "Faucon": [1,1,4,1,1,3,3,3,2,2],
            "Requin": [4,2,3,2,3,4,4,1,1,3],
            "Loup": [3,3,4,1,2,3,2,3,2,4],
            "Guépard": [4,1,2,2,1,1,1,2,4,4],
            "Dauphin": [1,4,1,4,1,4,4,1,1,3],
            "Hiboux": [2,4,1,4,3,3,1,4,2,2],
            "Chat": [3,2,1,4,4,1,4,4,4,1],
            "Chien": [4,3,2,4,4,4,1,3,3,1],
            "Crocodile": [2,3,2,3,2,2,1,1,1,3],
            "Loutre": [1,2,1,3,2,4,4,1,3,3],
        ], resultDescriptions: [
            "Lion": "Plein de noblesse et de force, tu es l'incarnation même de la puissance ! Dirigeant les autres avec charisme et justesse, tu es un meneur dans l'âme, ce qui n'est pas étonnant car tu es, le Roi des animaux...",
            "Singe": "Joueur et quelque peu sournois, tu passes ton temps à faire des farces aux autres. Derrière ton côté amusant, tu es quelqu'un plein d'humanité souriant sans cesse même si tu as du chagrin, car, pour toi, sourire est une bien plus belle grimace que pleurer.",
            "Lynx": "Mystérieux et d'une beauté sans pareil, tu es quelqu'un de très intriguant. Les gens sont attirés par toi car ils veulent en savoir plus, ou te ressembler. Cependant grâce à ta vision exceptionnelle, très rares sont ceux qui ont pu t'approcher...",
            "Ornithorynque": "Bizarre et je dirai même, très bizarre, tu es tout simplement une exception de la vie. Pas forcément beau ni moche, tu es tout simplement étrange et intriguant. Ce qui n'est pas une mauvaise chose, car beaucoup de gens voulant percer tes secrets, seront attirés par toi comme un aimant !",
            "Chacal": "Contrairement à ce que l'on entend, tu es plutôt mignon ! Par contre ta mauvaise haleine n'est pas une farce et pourrait bien faire fuir ton entourage ! Si je peux te donner un conseil: Pense à bien te laver les dents !",
            "Pigeon": "Peureux et pas vraiment fut fut, tu préfères t'enfuir au moindre mouvement plutôt que de comprendre ce que c'est. Ton don pour l'orientation est ton seul atout !",
            "Faucon": "Véritable chasseur et souvent admiré par le peuple d'en bas, tu es, comme ton nom, tout sauf con ! Vif, à la vue particulièrement affutée, tu n'hésites pas à charger toute personne dérangeant ta tranquilité.",
            "Requin": "Véritable prédateur des mers, tu remplis d'effroi les gens qui te croisent ! Pourtant tu n'es en réalité pas si aggressif, mais ta carrure et ta puissance naturelle font de toi quelqu'un d'impressionant !",
            "Loup": "Très famille et quelque peu peureux, tu es plutôt du style à t'enfuir au moindre coup de pression. Mais attention ! Si quelqu'un venait à pousser le bouchon trop loin ou toucher un de tes proches, tu n'hésiterais pas à laisser surgir ton côté sanguin et prédateur pour en venir à bout !",
            "Guépard": "Très athlétique et rapide, tu es tout simplement un monstre de compétition ! Tes capacités physiques provoquent le respect et l'admiration, chez quiconque les voit !",
            "Dauphin": "Beau et très intelligent, les gens ne cessent de faire ton éloge lorsqu'ils parlent de toi ! Véritable sonar vivant, ton pouvoir de détection permet de comprendre tout ce qui t'entoure avec une vitesse fulgurante !",
            "Hiboux": "Plutôt étrange et peu expressif, tu es quelq'un de reservé qui préfère observer au lieu de parler. (A part pour faire des bruits chelous). Pense tout de même à cligner des yeux de temps à autres, car les gens pourraient être pris de panique en croisant ton regard...",
            "Chat": "Trop mignon et adorable au premier abord, tu es adoré du monde entier ! Cependant, derrière ce masque maléfique, se cache en réalité une créature sournoise et malicieuse ayant comme projet de régner sur le monde, réduisant tous les habitants de cette planète en esclavage...",
            "Chien": "Fidèle en amitié (mais moins en amour), on peut toujours compter sur toi. Tu es gentil et adore la tranquilité. Cependant, si par malheur quelqu'un venait à faire du mal à ton entourage, tu n'hésiterais pas à sortir les crocs... Grrr !",
            "Crocodile": "Très vif et puissant, tu sèmes la terreur sur ton passage ! Maltraitant tous ceux que tu croises sur ton chemin, une rumeur raconte que tu serais même prêt à dévorer un caillou qui t'aurait, selon toi, mal regardé...",
            "Loutre": "Plutôt calme, au charactère quand même affirmé, tu es une personne adorant la liberté ! Véritable maître de ta vie, tu détestes qu'on te la dicte, car ton rêve est tout simplement de passer tes journées à t'empiffrer en faisant trempette dans une eau cristalline... ",
        ]),
        Quizz(id: "2", title: "Ville", image: "Lion", questions: nil, resultDescriptions: nil),
        Quizz(id: "3", title: "Insecte", image: "Lynx", questions: nil, resultDescriptions: nil),
        Quizz(id: "4", title: "Cocktail", image: "Singe", questions: nil, resultDescriptions: nil)
    ]
}
