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

## [1.0.0-beta] — 10/09/2026

Première version déposée sur le Connect IQ Store, en bêta.

Numéro à saisir dans le formulaire de dépôt : **1.0.0**. Le manifeste ne porte
pas de version — le store la demande à chaque envoi, et c'est ici qu'on garde la
trace de ce qu'elle contenait.

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
