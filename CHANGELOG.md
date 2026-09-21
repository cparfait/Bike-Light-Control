# Journal des versions

Le Connect IQ Store demande un numéro de version à chaque envoi ; le manifeste
n'en porte pas, il se saisit dans le formulaire de dépôt. C'est ici qu'on garde
la trace de ce que contenait chaque numéro.

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
numérotation [SemVer](https://semver.org/lang/fr/).

Les deux binaires — champ de données « Bike Light Control » et application
« Bike Light Panel » — partagent ce journal et avancent d'un même pas : ils
partagent `shared/`, et deux numéros divergents seraient ingérables.

---

## [1.0.0] — 21/09/2026

**Première version publique**, déposée le 21/09/2026. Deux fiches **nouvelles**
sur le Connect IQ Store, sous les identifiants de production — une bêta ne se
transforme pas, c'est la documentation de Garmin qui l'impose. Les deux fiches
de bêta restent à côté, et servent désormais à éprouver la suite.

| Fiche | Identifiant de boutique | Catégorie |
|---|---|---|
| Commande éclairage vélo | `a93139d1-9678-4f03-aa00-f9812586f53d` | Cyclisme |
| Panneau éclairage vélo | `df24ed0a-4d09-477a-95e1-eb2c2494617c` | Outils |

Les catégories diffèrent parce que le store n'offre pas les mêmes à un champ de
données et à une application : « Cyclisme » n'existe pas pour une Device App.

Revue Garmin annoncée sous trois jours. Treize langues avec leurs titres
traduits sur chaque fiche, descriptions anglaise et française, gratuite, aucune
collecte de données, aucun profil ANT+.

Aucun changement de code depuis la 0.3 : même binaire, autre identifiant. Ce qui
change, c'est ce qu'on sait de lui.

### Un point non résolu

**Garmin annonce « La vérification de la signature a échoué »** sur les deux
envois de production, alors que les envois de bêta affichaient « Signature :
vérifiée ». La clé est pourtant la même, intacte et lisible.

L'explication la plus vraisemblable est qu'un identifiant jamais publié n'a
aucune clé enregistrée à laquelle se comparer — les bêtas, elles, étaient
connues depuis le 10/09. Ce n'est qu'une hypothèse. Si la revue échoue, c'est la
première piste ; et **la clé `developer_key.der` doit être sauvegardée hors du
dépôt**, faute de quoi aucune mise à jour ne sera possible.

### Les trois points bloquants sont levés

Ils étaient corrigés dans le code et **jamais observés sur du matériel**. C'est
ce qui a tenu le projet en bêta, et c'est fait — sur un Venu 4 41 mm, le
21/09/2026 :

| Point | Pourquoi il comptait |
|---|---|
| Lampe mise en veille en cours de sortie, puis rallumée | la reconnexion est le cas le plus courant, et le chemin n'avait jamais tourné en vrai |
| Un mode choisi à la main, puis arrêt du chronomètre | la lampe doit s'éteindre : correctif du 10/09, éprouvé en test unitaire seulement |
| Quitter l'activité sans arrêter le chronomètre | le filet d'extinction n'y était pas garanti, faute de pouvoir écrire 28 octets d'un coup |

### Ce que la sortie publique ne dit pas

**Deux appareils sur cent trois ont fait tourner ce code** : l'Edge 1050 et un
Venu 4 41 mm. Les 101 autres remplissent les quatre critères et compilent, ce
qui n'est pas la même chose. Les descriptions du store le disent, et doivent
continuer à le dire.

---

## [0.3] — 21/09/2026

**Déposée en bêta le 21/09/2026**, les deux fiches, validées par Garmin :
`0.3 (interne 3)`, 89 Ko pour le champ de données et 93 pour l'application.

Une seule correction, et elle ne pouvait pas attendre : **elle ne se voit que
sur une montre**, c'est-à-dire sur les 88 appareils que la 0.2 vient d'ouvrir.

### Corrigé

- **La vignette de résumé écrivait ses deux textes l'un sur l'autre.** Le titre
  était posé à gauche et la valeur à droite, en FONT_TINY, **sans que rien ne
  vérifie qu'ils tiennent côte à côte**. Sur la tuile large d'un Edge ils ne se
  touchaient jamais, et le défaut est resté invisible tant que les cibles
  étaient des compteurs ; sur le cadran d'une montre, deux fois plus étroit,
  « Light Front » et « 62 % Dipped 2 » se chevauchaient franchement.

  On mesure désormais. Deux recours, dans cet ordre : la police descend d'un
  cran, puis le titre est rogné — jamais la valeur, car le titre répète le nom
  que le système écrit déjà sur la tuile, alors que la charge et le mode ne sont
  écrits que là. Rogné sous cinq caractères le titre disparaît : « Lig » ne vaut
  pas mieux que rien, et la valeur passe alors au centre. La marge latérale
  double aussi — sur un cadran, la tuile est un trapèze dont les coins hauts
  suivent la courbure du verre, et un texte calé au bord finissait sur le
  biseau.

  Vérifié en capture sur un Venu 4 45 mm. Sur un Edge, la logique d'ajustement
  ne se déclenche pas, la tuile y étant assez large ; **seule la marge change**,
  de quelques pixels, et cela n'a pas été rephotographié.

### Ce que la 0.2 avait déjà livré

Tout le reste — les 103 appareils, la page inscrite dans le disque, le
générateur de cibles — est arrivé avec la 0.2 de la veille, ci-dessous. La 0.3
ne fait que réparer ce que la première série de captures sur cadran a révélé.

Les captures de montre ont par ailleurs été ajoutées aux deux fiches du store
le 21/09 : page de pilotage et vignette sur Venu 4, champ plein écran sur un
cadran de 466 px, et le repli à deux lignes sur le plus petit cadran de la
gamme.

---

## [0.2] — 20/09/2026

**Déposée en bêta le 20/09/2026**, les deux fiches, sous les identifiants de
bêta. Garmin a validé les deux paquets — signature et contenu vérifiés — et
reconnaît les deux Venu 4 dans la liste des appareils compatibles.

Les paquets passent de 1,4 à 12,4 Mo : 156 références matérielles au lieu de 19.
Le binaire par appareil, lui, reste sous les 128 Ko du champ de données — 89 Ko
pour le champ, 93 pour l'application.

**Attention aux deux icônes de couverture, qui ne sont pas interchangeables :**
`store/app-icon-500.png` pour le champ de données, sans cadre ;
`store/widget-icon-500.png` pour le panneau, avec le cadre orange. Le cadre est
la seule chose qui distingue les deux fiches — les poser à l'envers, ou poser la
même sur les deux, rend les applications indiscernables.

Les onze onglets de langue autres que l'anglais et le français n'ont pas été
repris : ils ne portent qu'une copie du texte anglais, et les descriptions
publiques seront recréées depuis `store/fiches-store.md` le jour de la sortie.

### Ajouté

- **De 13 à 103 appareils.** Le projet ne visait que les compteurs Edge. Il
  couvre désormais toute la gamme Garmin qui remplit les quatre critères
  nécessaires — rôle central BLE, types `datafield` et `watchApp`, 128 Ko de
  champ de données, Connect IQ 3.1.0 : 13 Edge, 86 cadrans ronds, et deux
  portables. Le détail et la méthode sont dans
  [docs/compatibilite.md](docs/compatibilite.md).

  Point de départ : un Venu 4, qu'on voulait simplement ajouter. Ses deux
  profils remplissaient les critères sans rien changer au protocole — restait
  l'écran.

- **La page de pilotage épouse les cadrans ronds.** `shared/PanelLayout.mc`
  calculait une colonne de contenu unique, ce qui vaut pour un rectangle et
  seulement pour lui : sur un disque, les quatre coins tombent hors de la dalle.
  Chaque bande de la page réclame maintenant **sa propre corde**, celle de sa
  hauteur. Inscrire la page dans le carré central aurait été plus simple et
  aurait coûté la moitié du cadran ; sur un Venu 4, la grille des catégories
  gagne un cinquième de largeur par rapport à cette solution, et passe à deux
  rangées de trois tuiles au lieu de cinq tuiles de 35 px.

  **Le chemin rectangulaire est inchangé, au pixel près.** `_half()` rend
  toujours la même demi-colonne quand l'écran n'est pas rond, et les 1 925
  combinaisons du test d'origine passent sans avoir été retouchées.

- **La forme de l'écran est lue à l'exécution**, comme le tactile l'était déjà —
  `LampPanel.isRound()`, deux conditions et non une : un champ de données sur
  une montre ronde reçoit un rectangle découpé par le système, et c'est bien la
  géométrie rectangulaire qu'il faut y appliquer. Un seul binaire, pas de
  variante par modèle.

- **`tools/gen-targets.py`**, qui établit la liste des cibles depuis les profils
  du SDK et écrit le bloc `<iq:product>` des manifestes, les groupes d'icônes
  des jungles, les variantes de vignette et le tableau de la documentation. À
  treize Edge, une liste à la main se relisait ; à cent trois appareils et douze
  tailles d'icône, elle serait fausse dès la prochaine mise à jour du SDK.

- **Un test de confinement dans le disque** : les neuf diamètres de la gamme, du
  218 px au 466, sur les cinq jeux de polices et de deux à six catégories. Il
  vérifie qu'aucun coin de bande ne sort du cadran — la seule erreur que l'œil ne
  rattrape pas, puisqu'une tuile invisible au bord de la dalle reste tactile.
  La suite passe à 59 tests, et `test-all` à cinq profils dont un cadran rond.

### Modifié

- `tools/deploy-edge.sh` devient `tools/deploy-device.sh` et **ne reconnaît plus
  l'appareil à son nom**. Il cherchait `Edge*` en USB, et ne voyait donc pas une
  montre branchée ; il retient maintenant le premier appareil MTP qui expose un
  dossier `GARMIN/Apps`, en essayant tous ses volumes.
- **`deploy-device.sh` vérifie désormais que la copie a abouti.** `CopyHere` est
  asynchrone et ne rend aucune erreur sur un appareil MTP : le script dormait
  dix secondes puis annonçait « redémarrer l'appareil » sans avoir rien
  contrôlé. C'est arrivé le 20/09 sur le Venu 4 — les deux `.prg` n'étaient pas
  dans `GARMIN/Apps`, et la première copie passait pour une réussite. Il attend
  maintenant de **voir** les deux fichiers, jusqu'à une minute, et sort en
  erreur sinon.
- `tools/sim-captures.sh` couvre les neuf diamètres ronds, et attend 22 s au
  lieu de 12 avant la capture.
- `docs/compatibilite-edge.md` devient `docs/compatibilite.md`.
- `tools/make-icons.py` ne porte plus sa table de tailles : il la prend du même
  scanner. Douze tailles au lieu de cinq, de 32 à 70 px.

### Fait sur le store le 20/09/2026

- Les deux paquets bêta téléversés en 0.2, validés par Garmin.
- Descriptions anglaise et française reprises sur les deux fiches : elles
  annonçaient des compteurs de vélo dès la première ligne, ce qui n'était plus
  vrai. Elles disent maintenant les montres, et ce que la page devient sur un
  cadran rond.
- Un texte « Nouveautés » dans les deux langues, qui dit aussi ce qui **n'a
  pas** été éprouvé — c'est le genre de précision qu'une bêta doit porter.
- **L'icône de couverture du champ de données**, enfin corrigée : elle portait
  encore le cadre orange, celui qui distingue le panneau. Article hérité de
  la 0.1, clos.
- Les descriptions ont dû être renvoyées une fois. Le formulaire du store rend
  **chaque saut de ligne simple comme un changement de paragraphe**, et les
  textes de `store/fiches-store.md` sont retaillés à 95 colonnes pour se lire
  dans un éditeur : collés tels quels, ils se sont affichés coupés en plein
  milieu des phrases. L'avertissement est maintenant en tête de ce fichier.

### Éprouvé sur matériel

**Le 20/09/2026, un Venu 4 41 mm a fait tourner les deux binaires et a été
déclaré fonctionnel.** Installation manuelle par `tools/deploy-device.sh`.
C'est le deuxième appareil physique du projet, et le premier écran rond : le
rôle central BLE marche donc sur une plateforme montre, le protocole VS1800S ne
dépend pas du matériel, et la mise en page inscrite dans le disque tient sur un
vrai cadran. Ni le simulateur ni un test unitaire ne pouvaient trancher ces
trois points.

### Ce qui n'a pas changé, et qu'il faut garder en tête

**Cent un de ces cent trois appareils n'ont jamais fait tourner ce code.**
Remplir les quatre critères et compiler n'est pas avoir été essayé.

Et « fonctionnel » n'est pas la grille d'essai : les trois points qui bloquent
une sortie publique demandent chacun un geste précis pendant une sortie, et
restent à confirmer — voir [docs/depot-beta.md](docs/depot-beta.md),
chapitre 4.

---

## [0.1] — 10/09/2026

Première version déposée sur le Connect IQ Store, en bêta.

**Numéro saisi dans le formulaire : 0.1.** Le manifeste ne porte pas de version
— le store la demande à chaque envoi, et c'est ici qu'on garde la trace de ce
qu'elle contenait.

Zéro plutôt qu'un, et à dessein : douze des treize modèles n'ont jamais fait
tourner ce code sur du matériel, et trois correctifs de ce jour n'ont été
éprouvés qu'en test unitaire. Le 1.0.0 est réservé à la sortie publique, quand
la reconnexion et l'extinction auront été vues sur un compteur.

Une seule contrainte pour la suite : un numéro ne peut que monter. 0.1 → 0.2 →
1.0.0 convient ; revenir en arrière serait refusé.

### Ajouté

- Pilotage d'une lampe Bluetooth iGPSPORT depuis un Edge, sur 13 modèles.
- Ajustement automatique de l'intensité selon la vitesse, à seuils réglables,
  avec hystérésis.
- Repli sur batterie faible : l'intensité est plafonnée pour que la lampe tienne
  jusqu'à la fin de la sortie.
- Extinction à l'arrêt du chronomètre — et **pas** à la pause.
- Réglage « allumer la lampe au départ de l'activité », décochable pour les
  sorties de jour.
- Enregistrement du mode et de la batterie de la lampe dans le fichier FIT,
  visibles dans Garmin Connect.
- Choix manuel du mode par tape sur le champ, ou depuis la page complète.
- Identification de la lampe : la plus proche est retenue et clignote deux fois
  à la connexion. Sortie de secours pour passer à la suivante.
- Application compagnon : panneau de pilotage hors activité, réglages des
  automatismes de la lampe, tuile de résumé.
- 13 langues, suivant la langue du compteur : anglais, français, allemand, espagnol,
  italien, portugais, néerlandais, polonais, russe, japonais, coréen, chinois simplifié et
  traditionnel.

### Corrigé — audit du 10/09/2026

- Le champ de données ne cherchait la lampe que sur une tape, donc jamais sur
  les Edge à boutons (530, 540, 550, MTB). Un réglage « chercher la lampe au
  départ du chrono », **décoché par défaut**, lance la recherche au départ et
  à chaque reprise du chrono. La tape reste le geste normal : chercher sans
  qu'on l'ait demandé, c'est allumer une lampe qu'on ne voulait pas utiliser.
- **Le bouton Lap lance la recherche depuis le champ de données, sur les treize
  modèles.** Il ne valait d'abord que pour les modèles sans tactile, au motif
  qu'ailleurs la tape suffisait — elle ne suffit pas : sur un Edge 1050 la barre
  de contrôle du système intercepte la tape avant le champ, qui annonçait donc
  un bouton qu'aucun geste ne pouvait presser. C'est le seul appui qu'un champ
  reçoive ; il marque aussi un tour.
- La case du champ de données n'écrit plus « Détecter » en gros au-dessus d'une
  consigne illisible : au repos, la consigne **est** la valeur affichée.
- **La case ne peint plus son fond.** Le compteur dessine le sien — sur un Edge
  1050, un dégradé bleu nuit qui traverse la page — et `clear()` posait
  par-dessus un rectangle noir plat : au milieu de cinq cases fondues dans le
  dégradé, la nôtre était une tache.
- **Le titre de la case est le pictogramme de phare, plus le mot « Lampe ».**
  Le mot était écrit dans la plus petite police du jeu et en gris foncé, quand
  les cases voisines annoncent « DISTANCE » ou « VITESSE MOY. » en blanc et deux
  fois plus gros. Le dessin se lit à toutes les tailles, et dans toutes les
  langues — deux chaînes traduites de moins.
- **La consigne de repos ne nomme plus le geste : « Appuyer pour détecter ».**
  Elle couvre ainsi la tape comme le bouton Lap, en une seule phrase pour les
  treize modèles. Deux versions ont essayé de nommer le geste juste, chacune
  ratant d'un côté : « toucher » promettait un geste sans effet sur les
  compteurs dont la barre de contrôle prend la tape, et « appui Lap » ne dit
  rien à qui n'a pas le nom du bouton en tête.
- La page complète se passe de consigne au repos : son bouton encadré porte
  déjà le mot « Détecter ». Elle n'en affiche une que lorsque la recherche part
  avec le chronomètre, ce que le bouton ne dit pas.
- L'icône de l'application compagnon est désormais le **pictogramme de phare**,
  celui de ses propres tuiles, au lieu de la lampe de poche du champ de données
  à un cadre près. Deux dessins distincts se reconnaissent mieux qu'un cadre
  dans une liste où les deux applications se suivent. La plus longue sert de référence
  pour choisir la police de toute la ligne de précision : une consigne bavarde
  rapetissait « lampe trouvée » et « 3 lampes à proximité » avec elle.

### Corrigé — vu dans le simulateur

Quatre défauts d'affichage qu'aucun essai sur Edge 1050 ne pouvait montrer, et
que le mode démonstration (`bash app/build.sh sim`) a rendus visibles :

- **La vignette de résumé écrivait en blanc sur blanc.** Le fond de tuile du
  système n'a pas la même clarté d'un Edge à l'autre — mesuré sur les huit
  modèles qui ont une vignette, seul l'Edge MTB est clair — et aucune couleur
  de texte ne convient au blanc comme au noir. L'encre est donc choisie **à la
  compilation**, un fichier par variante associé aux appareils par le jungle,
  exactement comme la taille de l'icône de lanceur.

  Une première correction peignait un fond opaque sous le texte. Elle réglait
  le cas du MTB et en créait un autre : sur un Edge 1050, une boîte grise posée
  au milieu de la tuile bleu nuit du système, dont elle effaçait le thème. La
  vignette ne peint plus rien : le système a déjà dessiné sa tuile.
- **La vignette était vide avant la première ouverture de la page.** Elle
  affiche désormais le nom de l'application à défaut de relevé.
- **Le libellé du mode tombait en police minuscule** sur les Edge 1030, 1030
  Plus et Explore : la police était choisie sur la seule largeur, puis rabattue
  sur la plus petite du jeu dès qu'elle ne tenait pas en hauteur.
- **La roue dentée des réglages se lisait comme un soleil**, c'est-à-dire comme
  une commande de luminosité, sur une page qui pilote une lampe. Épaissie, elle
  passait sur un Edge 1050 mais redevenait un soleil sur un 530, où son rayon
  tombe à dix pixels : c'est maintenant trois barres, le symbole que le compteur
  emploie lui-même pour ouvrir un menu.
- **Le champ de données n'avait pas de vue de réglages, et le système la
  demande.** `AppBase.getSettingsView()` ne concerne que les cadrans et les
  champs de données, et n'était pas implémenté : quand le compteur — ou le
  simulateur — réclamait les réglages du champ, l'application tombait sur
  l'écran Connect IQ, sans un mot. Le champ a maintenant son menu embarqué, avec
  les réglages, les libellés et les valeurs par défaut de la fiche Garmin
  Connect. Voir `app/source/FieldSettings.mc`.
- **Les libellés des interrupteurs passaient sous le commutateur** sur un Edge
  530 : `Menu2` ne rogne pas le texte, il dessine le commutateur par-dessus.
  « Brightness by speed » se lisait « Brightness by sp ». Huit libellés
  raccourcis, dans les treize langues ; l'explication reste entière sur la ligne
  du dessous, qui occupe toute la largeur.

### Modifié — lisibilité de la page

- Le pourcentage de charge sort de la jauge : à gauche, dans la police de
  l'autonomie, et de la couleur de la charge. Il était écrit dans la barre, en
  corps quatorze sur un Edge 1050.
- Le libellé du mode courant prend moins de hauteur, au profit des tuiles : son
  plafond passe de 1,8 fois la grande police à 1,5 fois la moyenne.
- L'extinction à l'arrêt du chrono était ignorée après un changement de mode
  manuel : la lampe restait allumée. Elle s'applique quel que soit le mode, et
  le mode manuel ne survit plus à l'arrêt.
- La recherche BLE est bornée à cinq minutes, puis revient au repos ; elle ne
  cyclait auparavant jusqu'à la fin de l'activité.
- File d'écritures : plus de collision GATT sur l'abonnement batterie, chien de
  garde sur une écriture sans acquittement, trames entières plutôt que
  fragments, resynchronisation du tampon de réception sur CRC d'en-tête,
  reprise après caractéristiques ou descripteur absents.
- « Autre lampe » avec une seule lampe à portée ne la condamne plus : les
  appareils écartés sont oubliés après deux fenêtres d'écoute vides.
- Une tape avant le clignotement d'identification l'annule vraiment.
- FIT : le niveau d'intensité remplace le numéro de mode, et rien n'est écrit
  tant que la lampe n'a pas répondu.
- Alerte sonore, une fois, au passage sous le seuil de batterie.
- L'application compagnon ne propose plus les réglages qui n'y avaient aucun
  effet (seuils de vitesse, ajustement, extinction à l'arrêt).
- `IgEdgeWidget` renommé `PanelApp`.

### Notes

- La reconnexion après mise en veille de la lampe est corrigée dans le code mais
  n'a pas encore été éprouvée sur le matériel.
- Le filet d'extinction à la fermeture de l'application n'est pas garanti : la
  trame fait 28 octets et Connect IQ n'en écrit que 20 à la fois. La garantie
  est l'arrêt du chrono.
- Un seul modèle a été essayé physiquement : l'Edge 1050.
