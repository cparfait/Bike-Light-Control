# Essai sur Edge 830

Fiche à emporter. L'Edge 830 est le second modèle physique du projet, après le 1050, et il
couvre précisément ce que celui-ci ne peut pas montrer.

L'appareil appartient à quelqu'un d'autre : le §5 dit comment ne rien laisser derrière soi.

---

## 1. Pourquoi l'830 vaut mieux qu'un autre modèle

| Ce que l'830 a de différent | Ce que ça permet de vérifier |
|---|---|
| Écran 246×322, contre 480×800 | la mise en page sur le format des 530, 540, 830, 840 |
| Polices **bitmap** 22 / 26 / 41 px | le choix de police, jamais éprouvé hors polices vectorielles |
| Icône de lanceur **35 px** | la refonte d'icône à sa plus petite taille |
| **Pas de barre de contrôle système** | le champ plein écran dispose de toute la hauteur |
| Champ de données **tactile** malgré tout | **le point capital, voir ci-dessous** |
| **Pas de tuile de résumé** (`glance`) | que l'application reste atteignable sans elle |
| Binaire de **80 572 o**, le plus gros des 13 | le cas mémoire le plus tendu du projet |

### Le point capital : la tape sur le champ de données

Sur l'Edge 1050, la barre de contrôle système intercepte la tape avant l'application. C'est la
raison d'être de l'application compagnon — sans elle, on ne pouvait pas changer de mode à la
main. Cette limite n'a jamais été observée ailleurs, et elle a été prise pour une règle générale.

Or le profil SDK de l'830 dit deux choses :

- `display.isTouch` vaut **True** — l'écran est tactile ;
- `layouts[0].datafields.isTouchable` vaut **True** — les champs de données y reçoivent la tape ;
- `controlBarSupport` vaut **None** — il n'y a **aucune barre de contrôle** pour l'intercepter.

Autrement dit : sur un 830, `onTap()` devrait fonctionner directement sur le champ, et le
pilotage manuel devrait se faire sans quitter la page de données. Si c'est confirmé, ce n'est pas
un détail — cela veut dire que le champ de données se suffit à lui-même sur les 830 et 840, et
que la documentation doit cesser de présenter le compagnon comme indispensable.

Si c'est infirmé, c'est tout aussi utile : la barre de contrôle n'est alors pas la vraie cause,
et il faut chercher ailleurs.

### Le cas mémoire

Le binaire de l'830 fait **80 572 octets**, contre 78 044 pour le 1050 : c'est le plus lourd des
treize, avec celui du 1030. Le budget d'un champ de données est de 128 Ko, et la taille du `.prg`
n'est pas celle du tas — ce dernier n'a jamais été mesuré. Si le projet doit manquer de mémoire
quelque part, c'est ici. Un plantage ou un champ qui reste noir sont donc à signaler comme tels,
pas à mettre sur le compte de la lampe.

---

## 2. Avant de partir

```bash
bash app/build.sh edge830
```

À emporter : la lampe, le câble USB, et de quoi noter. Prévoir aussi le trajet de nuit ou au
crépuscule — la moitié des observations ne veut rien dire en plein jour.

Utile : régler l'830 **en français** avant de commencer. Les chaînes françaises viennent d'être
réaccentuées, et l'830 est le premier appareil à polices bitmap où on pourra le vérifier — les
« é », « è », « à » et « É » majuscule sont ceux à regarder.

---

## 3. Installation

```bash
bash tools/deploy-edge.sh edge830
```

Puis **redémarrer l'Edge** : il consomme les fichiers de `GARMIN/Apps` au démarrage, il est
normal qu'ils y disparaissent ensuite.

Garder `app/bin/edge830.prg.debug.xml` : c'est lui, et lui seul, qui traduit les adresses d'un
éventuel journal de plantage (`bash tools/pull-ciq-log.sh`).

---

## 4. Ce qu'il faut regarder, dans l'ordre

Cocher au fur et à mesure ; une observation notée sur place vaut dix souvenirs.

### À l'arrêt, sans rouler

- [ ] **Les deux icônes dans la liste des applications.** Fond bleu nuit plein, **pas de coin
      noir visible** — c'est le défaut qu'on vient de corriger, et 35 px est le cas le plus dur.
      Les deux se distinguent-elles ? Le panneau porte un cadre orange, le champ non.
- [ ] **Les deux noms** : « Commande éclairage vélo » et « Panneau éclairage vélo » en français.
      Accents compris.
- [ ] **L'application compagnon s'ouvre** depuis la liste des applications. L'830 n'a pas de
      tuile de résumé : elle ne doit pas manquer, ni faire échouer l'ouverture.
- [ ] **La connexion à la lampe** : « Recherche » puis « Connexion », puis la page de pilotage.
      Combien de secondes ?
- [ ] **La lampe clignote deux fois** à la connexion pour se désigner.
- [ ] **La page de pilotage remplit l'écran** — pas de bande noire en bas ni sur les côtés. C'est
      le format 246×322, le second plus petit.
- [ ] **Les libellés ne sont pas tronqués** en polices bitmap. Regarder surtout les catégories et
      les noms de mode longs.
- [ ] **Changer de mode depuis le panneau**, dans chaque catégorie. La lampe suit-elle ?
- [ ] **Le menu des réglages** : les automatismes de la lampe s'y lisent et s'y modifient.

### Le champ de données

- [ ] **Le champ plein écran.** Sans barre de contrôle, il a toute la hauteur : la page de
      pilotage doit s'y afficher entière.
- [ ] **★ La tape sur le champ plein écran change-t-elle de mode ?** C'est LA question de cette
      séance. Noter précisément : rien ne se passe / le mode change / autre chose s'ouvre.
- [ ] **La tape sur une tuile précise** de la page — la bonne tuile répond-elle ?
- [ ] **Le champ dans une page à 2, 4 puis 6 cases.** Le pourcentage de batterie reste-t-il
      lisible ? Est-il de la même taille que les champs natifs voisins, ou visiblement plus petit ?
- [ ] **L'étiquette « LAMPE - AUTO »** apparaît-elle, et disparaît-elle bien sur les petites
      cases au profit de la valeur ?

### En roulant

- [ ] **Départ du chrono** : la lampe s'allume-t-elle au premier cran ?
- [ ] **La vitesse fait changer le mode.** Aux seuils par défaut : 8, 18 et 30 km/h.
- [ ] **Pause du chrono à un feu rouge : la lampe doit RESTER allumée.** C'était le défaut le
      plus grave de l'audit.
- [ ] **Arrêt du chrono : la lampe s'éteint** (si le réglage est actif).
- [ ] **★ La lampe mise en veille puis rallumée en cours de sortie.** Chemin jamais éprouvé sur
      aucun matériel. Le champ se reconnecte-t-il seul, et en combien de temps ?
- [ ] **Une tape suspend l'ajustement** — l'étiquette passe à « MANUEL ». Une tape de plus, lampe
      éteinte, doit rendre la main à l'automatique.
- [ ] **Rien ne rame.** Le champ est rafraîchi une fois par seconde et porte toute la pile BLE.

### Après

- [ ] **Dans Garmin Connect** : la courbe du mode de la lampe et celle de sa batterie
      apparaissent-elles sur l'activité ? C'est le seul moyen de valider les contributions FIT,
      et le simulateur ne le rend pas.
- [ ] **Journal de plantage**, même si tout s'est bien passé :

```bash
bash tools/pull-ciq-log.sh
```

---

## 5. Ne rien laisser sur l'appareil d'un ami

Les deux applications s'enlèvent depuis l'Edge lui-même : liste des applications, appui long sur
l'entrée, supprimer. À défaut, brancher en USB et effacer les `.prg` correspondants de
`GARMIN/Apps`.

Les réglages Connect IQ enregistrés disparaissent avec l'application. Aucune donnée n'est envoyée
nulle part : l'application ne demande **aucune permission réseau**.

Une lampe appairée à l'Edge ne l'est plus au téléphone — une lampe BLE de ce type n'accepte
qu'une seule connexion centrale. Prévenir, et refaire l'appairage au téléphone après coup.

---

## 6. Ce qu'on en fera

Un retour d'un modèle autre que le 1050 est le dernier point bloquant avant le passage en
public — voir [audit-publication.md](audit-publication.md). L'830 coche en plus la case
« modèle à écran plus petit et polices bitmap ».

Reporter les résultats dans l'audit, et les deux points marqués ★ dans
[application.md](application.md) : ils changeraient tous deux la description du produit.
