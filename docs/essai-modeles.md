# Fiche d'essai — les 13 modeles compatibles

**Ce fichier est genere.** Tout ce qu'il affirme des appareils est relu dans les profils
du SDK installe localement, jamais dans la documentation en ligne. Le regenerer apres
une mise a jour du SDK ou du manifeste :

```bash
python tools/fiche-modeles.py
```

Pour l'Edge 830, une fiche detaillee existe deja : [essai-edge830.md](essai-edge830.md).
Celle-ci couvre les treize, et sert a decider **lesquels valent le deplacement**.

---

## 1. La question qui separe les modeles : la tape

Un champ de donnees ne recoit `onTap()` que si deux conditions sont reunies —
l'ecran est tactile, **et** aucune barre de controle systeme ne s'interpose. Les treize
cibles se rangent donc en trois classes, et elles ne s'utilisent pas de la meme facon.

### Tactile, **sans** barre de controle — 4 modeles

> Edge 830, Edge 1030, Edge 1030 Plus, Edge Explore

Rien ne devrait s'interposer : `onTap()` doit atteindre le champ de donnees, et le pilotage
manuel se faire sans quitter la page. **C'est l'hypothese a verifier en priorite** — si elle
tient, le champ se suffit a lui-meme sur ces modeles.

### Tactile, **avec** barre de controle — 5 modeles

> Edge 840, Edge 850, Edge 1040, Edge 1050, Edge Explore 2

La barre de controle systeme peut prendre la tape avant l'application. C'est ce qui a ete
constate sur l'Edge 1050, et c'est la raison d'etre du panneau compagnon. A confirmer sur les
autres.

### Boutons seuls, pas de tactile — 4 modeles

> Edge 530, Edge 540, Edge 550, Edge MTB

Aucune tape possible : un champ de donnees ne recoit pas d'evenement de touche. Le panneau
compagnon est **le seul** moyen de changer de mode a la main. Le curseur du panneau, lui, se
pilote aux boutons.

---

## 2. Les treize, en un tableau

| Modele | Ecran | Icone | Tape | Barre | Resume | Polices s/m/l | Champ | Panneau |
|---|---|---|---|---|---|---|---|---|
| Edge 530 | 246×322 | 35 px | non | aucune | non | 22/26/41 | 80 572 o | 93 484 o |
| Edge 540 | 246×322 | 35 px | non | 42 px | oui | 18/21/33 (vect.) | 71 308 o | 83 612 o |
| Edge 550 | 420×600 | 56 px | non | 89 px | oui | 36/40/65 (vect.) | 75 068 o | 87 356 o |
| Edge 830 | 246×322 | 35 px | oui | aucune | non | 22/26/41 | 80 572 o | 93 484 o |
| Edge 840 | 246×322 | 35 px | a verifier | 41 px | oui | 18/21/33 (vect.) | 71 308 o | 83 612 o |
| Edge 850 | 420×600 | 56 px | a verifier | 89 px | oui | 36/40/65 (vect.) | 75 068 o | 87 356 o |
| Edge 1030 | 282×470 | 36 px | oui | aucune | non | 26/29/48 | 80 636 o | 93 548 o |
| Edge 1030 Plus | 282×470 | 36 px | oui | aucune | non | 26/29/48 | 80 636 o | 93 548 o |
| Edge 1040 | 282×470 | 40 px | a verifier | 46 px | oui | 24/28/45 (vect.) | 71 996 o | 84 284 o |
| Edge 1050 | 480×800 | 68 px | a verifier | 93 px | oui | 41/46/75 (vect.) | 78 044 o | 90 332 o |
| Edge Explore | 240×400 | 36 px | oui | aucune | non | 14/16/26 | 71 356 o | 81 772 o |
| Edge Explore 2 | 240×400 | 36 px | a verifier | 46 px | oui | 14/16/26 | 71 388 o | 83 676 o |
| Edge MTB | 240×320 | 36 px | non | 42 px | oui | 15/17/27 (vect.) | 72 684 o | 84 972 o |

« Barre » est la hauteur que la barre de controle systeme retire au champ plein ecran.
« Resume » est la tuile du carrousel d'accueil : les modeles a « non » n'en ont pas, et
`getGlanceView()` y est simplement ignore. Les polices marquees *vect.* sont vectorielles —
le SDK les donne en pourcentage de la largeur d'ecran, converties ici en pixels.

---

## 3. Presque rien ne se recoupe

Deux modeles qui partagent ecran, icone, polices, classe de tape et tuile de resume
montrent exactement la meme chose — en essayer un dispenserait de l'autre. On esperait
ramener les treize a une poignee de cas. **Ce n'est pas ce qui sort du SDK.**

Les treize donnent **12 cas distincts**, et un seul regroupement : Edge 1030 et Edge 1030 Plus.

La raison est que Garmin fait varier les caracteristiques une par une d'un modele a l'autre. Le
530 et l'830 partagent tout sauf le tactile ; le 540 et le 840 tout sauf le tactile ; l'Explore
et l'Explore 2 tout sauf la barre de controle et la tuile de resume. Chaque modele differe donc
d'au moins un axe qui change ce qu'on voit a l'ecran, et il n'existe pas de raccourci : c'est
l'ordre de priorite du chapitre suivant qui tranche, pas une equivalence.

| Cas | Modeles | Ce qu'il apporte |
|---|---|---|
| 1 | Edge 1050 | 480×800 · icone 68 px · tape sous barre · polices vectorielles |
| 2 | Edge 550 | 420×600 · icone 56 px · boutons seuls · polices vectorielles |
| 3 | Edge 850 | 420×600 · icone 56 px · tape sous barre · polices vectorielles |
| 4 | Edge 1030, Edge 1030 Plus | 282×470 · icone 36 px · tape directe · polices bitmap 26/29/48 · sans tuile de resume |
| 5 | Edge 1040 | 282×470 · icone 40 px · tape sous barre · polices vectorielles |
| 6 | Edge 530 | 246×322 · icone 35 px · boutons seuls · polices bitmap 22/26/41 · sans tuile de resume |
| 7 | Edge 540 | 246×322 · icone 35 px · boutons seuls · polices vectorielles |
| 8 | Edge 830 | 246×322 · icone 35 px · tape directe · polices bitmap 22/26/41 · sans tuile de resume |
| 9 | Edge 840 | 246×322 · icone 35 px · tape sous barre · polices vectorielles |
| 10 | Edge Explore | 240×400 · icone 36 px · tape directe · polices bitmap 14/16/26 · sans tuile de resume |
| 11 | Edge Explore 2 | 240×400 · icone 36 px · tape sous barre · polices bitmap 14/16/26 |
| 12 | Edge MTB | 240×320 · icone 36 px · boutons seuls · polices vectorielles · **sans composition alpha** |

---

## 4. Dans quel ordre, si on ne peut pas tout avoir

1. **Edge 830** — Le seul modele **tactile sans barre de controle** a portee. Il tranche
   l'hypothese de la tape, et couvre en meme temps l'ecran 246×322, les polices bitmap, l'icone 35
   px et l'absence de tuile de resume.

2. **Edge 530** — Le cas **boutons seuls** : le panneau compagnon y est le seul pilotage
   manuel, et son curseur doit se deplacer aux touches. Meme ecran que l'830, donc la mise en page
   y est deja acquise.

3. **Edge 1040** — **Polices vectorielles de taille intermediaire** et icone 40 px, unique au
   catalogue. Barre de controle presente.

4. **Edge Explore 2** — Le plus petit jeu de polices bitmap du catalogue — 14/16/26 px. C'est
   la que les libelles risquent le plus d'etre tronques.

5. **Edge MTB** — Le **seul sans composition alpha**, et le plus petit ecran. Deja couvert par
   le simulateur, mais l'icone y merite un coup d'oeil.

L'Edge 1050 n'y figure pas : c'est celui qu'on a, et tout ce qu'il pouvait montrer l'a
deja ete.

---

## 5. Le protocole, le meme sur tous

```bash
bash app/build.sh <appareil>
bash tools/deploy-edge.sh <appareil>
```

Puis **redemarrer l'Edge** : il consomme les fichiers de `GARMIN/Apps` au demarrage, il
est normal qu'ils y disparaissent. Garder le `.prg.debug.xml` du meme build, c'est lui
qui traduit les adresses d'un journal de plantage (`bash tools/pull-ciq-log.sh`).

### A l'arret

- [ ] Les **deux icones** dans la liste des applications : fond bleu nuit plein, **aucun
      coin noir visible**, et le panneau se distingue du champ par son cadre orange.
- [ ] Les **deux noms**, dans la langue du compteur, accents compris.
- [ ] Le **panneau s'ouvre** et trouve la lampe. En combien de secondes ?
- [ ] La lampe **clignote deux fois** a la connexion pour se designer.
- [ ] La page de pilotage **remplit l'ecran** : ni bande noire, ni libelle tronque.
- [ ] **Changer de mode** dans chaque categorie ; la lampe suit-elle ?
- [ ] Le **menu des reglages** lit et modifie les automatismes de la lampe.

### Le champ de donnees

- [ ] **Plein ecran** : la page de pilotage s'y affiche entiere.
- [ ] **La tape** — voir le §1 pour ce qui est attendu sur ce modele. Noter precisement :
      rien ne se passe / le mode change / autre chose s'ouvre.
- [ ] Le champ **dans une page a 2, 4 puis 6 cases** : le pourcentage reste-t-il lisible,
      et de la meme taille que les champs natifs voisins ?
- [ ] L'etiquette **« LAMPE - AUTO »** apparait, et s'efface sur les petites cases.

### En roulant

- [ ] **Depart du chrono** : la lampe s'allume au premier cran.
- [ ] **La vitesse fait changer de mode** — seuils par defaut 8, 18 et 30 km/h.
- [ ] **Pause a un feu rouge : la lampe RESTE allumee.** C'etait le defaut le plus grave
      de l'audit.
- [ ] **Arret du chrono : la lampe s'eteint**, si le reglage est actif.
- [ ] **La lampe mise en veille puis rallumee en route.** Chemin jamais eprouve sur aucun
      materiel : le champ se reconnecte-t-il seul, et en combien de temps ?
- [ ] **Rien ne rame** : le champ est rafraichi chaque seconde et porte toute la pile BLE.

### Apres

- [ ] Dans **Garmin Connect**, les courbes du mode et de la batterie de la lampe. C'est le
      seul moyen de valider les contributions FIT ; le simulateur ne les rend pas.
- [ ] `bash tools/pull-ciq-log.sh`, meme si tout s'est bien passe.

---

## 6. Ce qu'il faut regarder en plus, modele par modele

### Edge 530 — 246×322, icone 35 px

- Pas de tape possible : verifier que le **curseur du panneau se deplace aux boutons** (lap,
  start, up, down) et que le champ de donnees n'affiche aucun curseur.
- **Pas de tuile de resume** : l'application doit rester atteignable par la liste des
  applications, sans erreur.
- **2 references materielles** : selon l'exemplaire, les langues disponibles different
  (europeennes ou asiatiques). Noter la langue du compteur.
- **Parmi les binaires les plus lourds des treize** (80 572 o, contre 71 308 o pour le plus
  leger) : c'est le cas memoire le plus tendu. Un champ noir ou un plantage est a signaler
  comme tel, pas a mettre sur le compte de la lampe.

### Edge 540 — 246×322, icone 35 px

- Pas de tape possible : verifier que le **curseur du panneau se deplace aux boutons** (lap,
  start, up, down) et que le champ de donnees n'affiche aucun curseur.

### Edge 550 — 420×600, icone 56 px

- Pas de tape possible : verifier que le **curseur du panneau se deplace aux boutons** (lap,
  start, up, down) et que le champ de donnees n'affiche aucun curseur.

### Edge 830 — 246×322, icone 35 px

- **La tape sur le champ doit fonctionner** : ni barre de controle, ni ecran non tactile pour
  l'en empecher. Si elle ne marche pas, la barre n'est pas la vraie cause du probleme constate
  sur le 1050.
- **Pas de tuile de resume** : l'application doit rester atteignable par la liste des
  applications, sans erreur.
- **2 references materielles** : selon l'exemplaire, les langues disponibles different
  (europeennes ou asiatiques). Noter la langue du compteur.
- **Parmi les binaires les plus lourds des treize** (80 572 o, contre 71 308 o pour le plus
  leger) : c'est le cas memoire le plus tendu. Un champ noir ou un plantage est a signaler
  comme tel, pas a mettre sur le compte de la lampe.

### Edge 840 — 246×322, icone 35 px

- La barre de controle occupe **41 px** en bas du champ plein ecran : la page doit
  s'accommoder de la hauteur restante (281 px).

### Edge 850 — 420×600, icone 56 px

- La barre de controle occupe **89 px** en bas du champ plein ecran : la page doit
  s'accommoder de la hauteur restante (511 px).

### Edge 1030 — 282×470, icone 36 px

- **La tape sur le champ doit fonctionner** : ni barre de controle, ni ecran non tactile pour
  l'en empecher. Si elle ne marche pas, la barre n'est pas la vraie cause du probleme constate
  sur le 1050.
- **Pas de tuile de resume** : l'application doit rester atteignable par la liste des
  applications, sans erreur.
- **2 references materielles** : selon l'exemplaire, les langues disponibles different
  (europeennes ou asiatiques). Noter la langue du compteur.
- **Parmi les binaires les plus lourds des treize** (80 636 o, contre 71 308 o pour le plus
  leger) : c'est le cas memoire le plus tendu. Un champ noir ou un plantage est a signaler
  comme tel, pas a mettre sur le compte de la lampe.

### Edge 1030 Plus — 282×470, icone 36 px

- **La tape sur le champ doit fonctionner** : ni barre de controle, ni ecran non tactile pour
  l'en empecher. Si elle ne marche pas, la barre n'est pas la vraie cause du probleme constate
  sur le 1050.
- **Pas de tuile de resume** : l'application doit rester atteignable par la liste des
  applications, sans erreur.
- **2 references materielles** : selon l'exemplaire, les langues disponibles different
  (europeennes ou asiatiques). Noter la langue du compteur.
- **Parmi les binaires les plus lourds des treize** (80 636 o, contre 71 308 o pour le plus
  leger) : c'est le cas memoire le plus tendu. Un champ noir ou un plantage est a signaler
  comme tel, pas a mettre sur le compte de la lampe.

### Edge 1040 — 282×470, icone 40 px

- La barre de controle occupe **46 px** en bas du champ plein ecran : la page doit
  s'accommoder de la hauteur restante (424 px).
- **2 references materielles** : selon l'exemplaire, les langues disponibles different
  (europeennes ou asiatiques). Noter la langue du compteur.

### Edge 1050 — 480×800, icone 68 px

- La barre de controle occupe **93 px** en bas du champ plein ecran : la page doit
  s'accommoder de la hauteur restante (707 px).

### Edge Explore — 240×400, icone 36 px

- **La tape sur le champ doit fonctionner** : ni barre de controle, ni ecran non tactile pour
  l'en empecher. Si elle ne marche pas, la barre n'est pas la vraie cause du probleme constate
  sur le 1050.
- **Pas de tuile de resume** : l'application doit rester atteignable par la liste des
  applications, sans erreur.
- **Le plus petit jeu de polices du catalogue** (14/16/26 px) : c'est ici que les libelles
  risquent le plus d'etre tronques.

### Edge Explore 2 — 240×400, icone 36 px

- La barre de controle occupe **46 px** en bas du champ plein ecran : la page doit
  s'accommoder de la hauteur restante (354 px).
- **Le plus petit jeu de polices du catalogue** (14/16/26 px) : c'est ici que les libelles
  risquent le plus d'etre tronques.

### Edge MTB — 240×320, icone 36 px

- Pas de tape possible : verifier que le **curseur du panneau se deplace aux boutons** (lap,
  start, up, down) et que le champ de donnees n'affiche aucun curseur.
- **Pas de composition alpha** : c'est le modele qui condamne toute transparence dans
  l'icone. La regarder de pres.

---

## 7. Sur un appareil qui n'est pas le sien

Les deux applications s'enlevent depuis l'Edge : liste des applications, appui long,
supprimer. A defaut, effacer les `.prg` de `GARMIN/Apps` en USB. Les reglages Connect IQ
partent avec l'application, et rien n'est envoye nulle part — **aucune permission reseau**
n'est demandee.

Prevenir en revanche que **la lampe appairee a l'Edge ne l'est plus au telephone** : une
lampe BLE de ce type n'accepte qu'une seule connexion centrale a la fois. Refaire
l'appairage telephone apres coup.
