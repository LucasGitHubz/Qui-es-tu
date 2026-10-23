## Qui es tu ? / Application

![Preview](https://github.com/LucasGitHubz/Qui-es-tu/blob/main/Preview.jpg)

## Qu'est ce que c'est ? 
Qui es tu ? est une application fun avec un concept simple. Choisis un thème, réponds à 10 questions et après une analyse ULTRA poussée faites par une centaines de scientifiques venant de la Silicon Valley, la meilleure correspondance te sera révélée !
Après avoir fait le thème révélant mon arme en cas d'apocalypse, je suis tombé sur le costume de huissiers de justice ! Plutôt pas mal non ? Et toi, quelle sera ton arme pour te défendre contre les zombies ?

## Support
* iOS 17.0

* Language: 
     - French
     - English (en cours)

## Installation
Télécharge l'app ici:
https://apps.apple.com/fr/app/qui-es-tu/id6740242586

Ou bien

1. Télécharge ce repo ou fork le.
2. Enregistre toi sur Firebase and télécharge ton propre GoogleService-info.plist.
3. Ajoute le au projet.
4. Enjoy !

## Vérification des images avant publication

Les images bitmap ont des entrées explicites 1x, 2x et 3x. Les trois entrées
réutilisent le fichier original ; les vues redimensionnent les images à l'affichage.
Pour vérifier les fichiers et les rendus présents dans une archive Release :

```sh
python3 scripts/verify-image-assets.py
python3 scripts/verify-image-assets.py "/chemin/Qui es tu.xcarchive/Products/Applications/Qui es tu.app/Assets.car"
```

Pour un catalogue réduit à un appareil, ajouter `--scale 2` ou `--scale 3`.
Exécuter aussi les tests `AssetPresenceTests` en Release avec
`ENABLE_TESTABILITY=YES` passé à `xcodebuild test` (pour les imports `@testable`).
Enfin, vérifier l'accueil et un résultat de quiz depuis le nouveau build TestFlight.

## Me contacter
- Email: lucasamelin14@gmail.com
- Linkedin: <a href="https://www.linkedin.com/in/lucas-amelin-3b8b85190/">Linkedin</a>

## License
[MIT](https://choosealicense.com/licenses/mit/)
