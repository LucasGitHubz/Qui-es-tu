//
//  Animals.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Foundation


let animalQuestionsTab = [1: "Quelle serait ta réaction si un gland te tombait sur la tête ?",
                          2: "Que préfères-tu ?",
                          3: "Quel type de soirée préfères-tu ?",
                          4: "Quel-est ton péché mignon ?",
                          5: "Ton élément favori est :",
                          6: "Quel fruit préfères-tu ?",
                          7: "Tu achètes un nouveau coussin chez IKEA, il est :",
                          8: "Tu te décides à faire du sport :",
                          9: "Tu es plutôt :",
                          10: "Quel moyen de transport préfères-tu ?"]

let animalReponsesTab = [["Tu cherches qui te l'a jeté", "Tu le manges", "Tu le plantes", "Tu le gardes précieusement"],
                            ["Donner la patte", "Faire le mort quand tu entends PAN !", "Aller chercher la balle", "Faire le beau"],
                            ["Soirée cinéma", "Soirée karaoké", "Soirée chez des amis", "Soirée dansante"],
                            ["Le chocolat", "Les Jelly Belly goût crotte de nez", "Les chips", "Les bonbons"],
                            ["Air", "Feu", "Eau", "Terre"],
                            ["Banane", "Noix de coco", "Fraise", "Orange"],
                            ["Mou et doux", "Dur comme un parpaing", "Senteur crottin d'iguane", "Avec des plumes roses"],
                            ["Tu pars courir 10km", "Tu t'entraînes à dormir les yeux ouverts", "Tu disputes une partie endiablée de ping-pong", "Tu fais des longueurs dans ta piscine"],
                            ["Forêt", "Savane", "Jungle", "Plage"],
                            ["Avion", "Voiture", "Bateau", "Vélo"]]

let animalDescription = ["Plein de noblesse et de force, tu es l'incarnation même de la puissance ! Dirigeant les autres avec charisme et justesse, tu es un meneur dans l'âme, ce qui n'est pas étonnant car tu es, le Roi des animaux...",
"Joueur et quelque peu sournois, tu passes ton temps à faire des farces aux autres. Derrière ton côté amusant, tu es quelqu'un plein d'humanité souriant sans cesse même si tu as du chagrin, car, pour toi, sourire est une bien plus belle grimace que pleurer.",
"Mystérieux et d'une beauté sans pareil, tu es quelqu'un de très intriguant. Les gens sont attirés par toi car ils veulent en savoir plus, ou te ressembler. Cependant grâce à ta vision exceptionnelle, très rares sont ceux qui ont pu t'approcher...",
"Bizarre et je dirai même, très bizarre, tu es tout simplement une exception de la vie. Pas forcément beau ni moche, tu es tout simplement étrange et intriguant. Ce qui n'est pas une mauvaise chose, car beaucoup de gens voulant percer tes secrets, seront attirés par toi comme un aimant !",
"Contrairement à ce que l'on entend, tu es plutôt mignon ! Par contre ta mauvaise haleine n'est pas une farce et pourrait bien faire fuir ton entourage ! Si je peux te donner un conseil: Pense à bien te laver les dents !",
"Peureux et pas vraiment fut fut, tu préfères t'enfuir au moindre mouvement plutôt que de comprendre ce que c'est. Ton don pour l'orientation est ton seul atout !",
"Véritable chasseur et souvent admiré par le peuple d'en bas, tu es, comme ton nom, tout sauf con ! Vif, à la vue particulièrement affutée, tu n'hésites pas à charger toute personne dérangeant ta tranquilité.",
"Véritable prédateur des mers, tu remplis d'effroi les gens qui te croisent ! Pourtant tu n'es en réalité pas si aggressif, mais ta carrure et ta puissance naturelle font de toi quelqu'un d'impressionant !",
"Très famille et quelque peu peureux, tu es plutôt du style à t'enfuir au moindre coup de pression. Mais attention ! Si quelqu'un venait à pousser le bouchon trop loin ou toucher un de tes proches, tu n'hésiterais pas à laisser surgir ton côté sanguin et prédateur pour en venir à bout !",
"Très athlétique et rapide, tu es tout simplement un monstre de compétition ! Tes capacités physiques provoquent le respect et l'admiration, chez quiconque les voit !",
"Beau et très intelligent, les gens ne cessent de faire ton éloge lorsqu'ils parlent de toi ! Véritable sonar vivant, ton pouvoir de détection permet de comprendre tout ce qui t'entoure avec une vitesse fulgurante !",
"Plutôt étrange et peu expressif, tu es quelq'un de reservé qui préfère observer au lieu de parler. (A part pour faire des bruits chelous). Pense tout de même à cligner des yeux de temps à autres, car les gens pourraient être pris de panique en croisant ton regard...",
"Trop mignon et adorable au premier abord, tu es adoré du monde entier ! Cependant, derrière ce masque maléfique, se cache en réalité une créature sournoise et malicieuse ayant comme projet de régner sur le monde, réduisant tous les habitants de cette planète en esclavage...",
"Fidèle en amitié (mais moins en amour), on peut toujours compter sur toi. Tu es gentil et adore la tranquilité. Cependant, si par malheur quelqu'un venait à faire du mal à ton entourage, tu n'hésiterais pas à sortir les crocs... Grrr !",
"Très vif et puissant, tu sèmes la terreur sur ton passage ! Maltraitant tous ceux que tu croises sur ton chemin, une rumeur raconte que tu serais même prêt à dévorer un caillou qui t'aurait, selon toi, mal regardé...",
"Plutôt calme, au charactère quand même affirmé, tu es une personne adorant la liberté ! Véritable maître de ta vie, tu détestes qu'on te la dicte, car ton rêve est tout simplement de passer tes journées à t'empiffrer en faisant trempette dans une eau cristalline... "]

let allAnimalNameTab = ["Lion",
                        "Singe",
                        "Lynx",
                        "Ornithorynque",
                        "Chacal",
                        "Pigeon",
                        "Faucon",
                        "Requin",
                        "Loup",
                        "Guépard",
                        "Dauphin",
                        "Hiboux",
                        "Chat",
                        "Chien ",
                        "Crocodile",
                        "Loutre"]

let lionAttribut = [4,1,2,1,4,2,3,2,4,4]
let singeAttribut = [2,3,3,4,2,2,2,3,3,2]
let lynxAttribut = [3,1,4,3,4,1,2,2,2,4]
let orniAttribut = [1,4,3,1,3,2,2,4,1,1]
let chacalAttribut = [3,2,4,3,3,3,3,2,4,1]
let pigeonAttribut = [2,4,3,2,1,1,3,4,3,2]
let fauconAttribut = [1,1,4,1,1,3,3,3,2,2]
let requinAttribut = [4,2,3,2,3,4,4,1,1,3]
let loupAttribut = [3,3,4,1,2,3,2,3,2,4]
let guepardAttribut = [4,1,2,2,1,1,1,2,4,4]
let dauphinAttribut = [1,4,1,4,1,4,4,1,1,3]
let hibouxAttribut = [2,4,1,4,3,3,1,4,2,2]
let chatAttribut = [3,2,1,4,4,1,4,4,4,1]
let chienAttribut = [4,3,2,4,4,4,1,3,3,1]
let crocodileAttribut = [2,3,2,3,2,2,1,1,1,3]
let loutreAttribut = [1,2,1,3,2,4,4,1,3,3]

let allAnimalTab = [lionAttribut,
                    singeAttribut,
                    lynxAttribut,
                    orniAttribut,
                    chacalAttribut,
                    pigeonAttribut,
                    fauconAttribut,
                    requinAttribut,
                    loupAttribut,
                    guepardAttribut,
                    dauphinAttribut,
                    hibouxAttribut,
                    chatAttribut,
                    chienAttribut,
                    crocodileAttribut,
                    loutreAttribut]
