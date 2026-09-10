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
- Les deux consignes de repos sont raccourcies dans les treize langues — « Lap
  pour chercher », « toucher pour chercher ». La plus longue sert de référence
  pour choisir la police de toute la ligne de précision : une consigne bavarde
  rapetissait « lampe trouvée » et « 3 lampes à proximité » avec elle.

### Corrigé — vu dans le simulateur

Quatre défauts d'affichage qu'aucun essai sur Edge 1050 ne pouvait montrer, et
que le mode démonstration (`bash app/build.sh sim`) a rendus visibles :

- **La vignette de résumé écrivait en blanc sur blanc.** Les sept thèmes de
  vignette ont une zone de contenu blanche sur un Edge MTB et sombre sur un
  1050 : le texte blanc y était donc invisible sur la moitié des modèles, et la
  tuile paraissait vide. Elle porte maintenant son propre fond, une pastille
  sombre, lisible quel que soit le thème choisi.
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
