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

## [Non publié] — 1.0.0

Première version déposée sur le Connect IQ Store, en bêta.

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
- Français et anglais, suivant la langue du compteur.

### Notes

- La reconnexion après mise en veille de la lampe est corrigée dans le code mais
  n'a pas encore été éprouvée sur le matériel.
- Un seul modèle a été essayé physiquement : l'Edge 1050.
