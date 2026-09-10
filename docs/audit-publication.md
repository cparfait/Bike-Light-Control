# Audit de l'application — publication et compatibilité Edge

**Date : 09/09/2026.** Audit complet du code (`shared/`, `app/`, `widget/`), des manifestes,
des ressources, de la documentation et du paquet `dist/`, confronté au SDK Connect IQ 9.2.0
installé localement (`connectiq-sdk-win-9.2.0-2026-06-09`) et aux règles publiques du Connect
IQ Store.

---

## 0. Suites données — 09/09/2026

L'audit a été traité le jour même. Ce chapitre dit ce qui a changé ; le reste du document
reste le constat d'origine, non réécrit, pour qu'on puisse le relire tel quel.

| Point | État | Ce qui a été fait |
|---|---|---|
| §4.1 extinction sur pause | ✅ corrigé | `AutoController.onRideState()` distingue les trois états du chrono ; 5 tests |
| §4.2 champs FIT invisibles | ✅ corrigé | `app/resources/fit/fit-contributions.xml`, vérifié dans le paquet |
| §4.3 nom et icônes identiques | ✅ corrigé | « Bike Light Control » et « Bike Light Panel », icônes distinctes |
| §4.4 icône unique en 68×68 | ✅ corrigé | 5 tailles générées par `tools/make-icons.py`, plus les icônes 500×500 |
| §4.5 reconnexion non éprouvée | 🟡 code corrigé, matériel à faire | profils enregistrés une seule fois, désappairage avant rescan |
| §5 extinction perdue à la fermeture | ✅ corrigé | `LampManager.shutdown()` écrit sans passer par la file |
| §5 filtre de scan trop large | ✅ corrigé | motif « deux lettres + chiffre », et mémoire des appareils écartés |
| §5 échelles comparées par taille | ✅ corrigé | comparaison élément par élément ; 1 test |
| §5 curseur figé | ✅ corrigé | `LampPanel.hideCursor()`, appelé par le champ de données |
| §5 documentation dérivée | ✅ corrigé | `docs/application.md` et `README.md` remis en phase |
| §5 projet hors git | ✅ corrigé | dépôt initialisé, captures et manuel constructeur exclus |

Vérifications refaites après correction :

| Vérification | Résultat |
|---|---|
| `bash app/build.sh` — 13 cibles, deux binaires | 26 / 26 réussies, 46 à 61 Ko |
| `bash app/build.sh test` | 50 / 50 tests (39 avant) |
| Compilation Edge 530 en types stricts (`-l 2`), les deux binaires | aucun avertissement |
| `fit_contributions.json` dans les deux paquets | présent, libellés traduits |

Deux évolutions demandées après l'audit, hors de son périmètre mais dans le même passage :
l'écran de connexion, réduit à un mot d'étape et une ligne de précision au lieu de trois textes
de tailles différentes ; et l'identification de la lampe, qui clignote à la connexion pour se
désigner quand plusieurs se trouvent à portée. Détail dans `docs/application.md`.

**Reste à faire avant la publication publique**, dans l'ordre :

1. Éprouver la reconnexion sur le matériel : lampe mise en veille en cours de sortie (§4.5).
2. Publier en bêta, et vérifier depuis Garmin Connect les réglages, les champs FIT et les deux
   noms. Textes de fiche prêts dans `store/fiches-store.md`.
3. Obtenir un retour d'un modèle autre que le 1050 — un Edge 830 est prévu, voir §0 bis.

Deux points de l'audit sont volontairement laissés en l'état :

- **Le budget mémoire n'est toujours pas mesuré.** La taille du `.prg` n'est pas celle du tas,
  et rien dans le SDK ne la donne hors exécution.
- **Les identifiants du manifeste** gardent leur ancienne forme : changer un identifiant
  d'application couperait le lien avec les réglages déjà enregistrés. Les noms de classe, eux,
  ont été renommés le 10/09 (`IgEdgeWidget` → `PanelApp`).

---

## 0 ter. Troisième passage — 10/09/2026

Audit en profondeur du code, de l'énergie, de l'ergonomie et de la sécurité, corrigé le jour
même. Le constat détaillé est dans le CHANGELOG ; l'essentiel :

| Point | Gravité | Ce qui a été fait |
|---|---|---|
| Le champ ne cherchait la lampe que sur une tape : jamais sur 530, 540, 550, MTB | bloquant | recherche au départ et à chaque reprise du chrono, réglage `searchOnStart` dans Garmin Connect |
| L'extinction à l'arrêt était ignorée après un geste manuel | bloquant | `onRideState()` traite l'arrêt avant le test sur `enabled` ; 2 tests |
| Le filet `shutdown()` avait une branche impossible (trame de 28 octets) | bloquant | branche retirée, limite documentée : la garantie est l'arrêt du chrono |
| Recherche BLE jamais bornée | énergie | plafond `SCAN_MAX_S`, retour au repos |
| Scan actif pendant le menu de l'application | énergie | le battement survit à `onHide` |
| Mesures de texte répétées à chaque image | énergie | caches de police dans `LampPanel` |
| Abonnement batterie sans `_busy` : collision GATT | BLE | `_busy` tenu jusqu'à `onDescriptorWrite` |
| Pas de chien de garde sur `_busy` | BLE | `BUSY_MAX_S` |
| Tampon de réception sans resynchronisation | BLE | `headerValid()` avant lecture de la longueur ; 1 test |
| Caractéristiques ou CCCD absents : état figé | BLE | `_abandon()` écarte et relance |
| File de fragments jetés au milieu d'une trame | BLE | file de trames entières |
| « Autre lampe » avec une seule lampe : condamnée | ergonomie | rejets oubliés après deux fenêtres vides |
| Annulation de l'identification avant le clignotement sans effet | ergonomie | `cancelIdentify()` marque l'identification faite |
| Réglages sans effet dans l'application compagnon | ergonomie | seuils et extinction retirés du menu |
| Batterie faible : couleur seule | ergonomie | un signal sonore au passage du seuil |
| FIT : 0 % par défaut, mode brut illisible | FIT | rien tant que la lampe n'a pas répondu ; niveau d'intensité au lieu du numéro de mode |
| Surcouche de diagnostic compilée en release | code | annotation `debug` exclue par les jungles |
| Badge anglais « MAN », compte de tests périmé | détail | « MANUAL », 58 tests |

Ce qui n'a **pas** été fait, et pourquoi : le découpage de `LampManager` en scan / identification
/ GATT. Il rendrait la machine à états testable sans pile BLE, mais c'est un chantier à part, et
la profondeur de pile documentée dans `LampPanel` invite à la prudence.

---

## 0 bis. Second passage — 09/09/2026, après-midi

Une relecture complète après les correctifs du matin, faite en recompilant et en ouvrant le
paquet plutôt qu'en relisant les notes. Elle a trouvé un défaut que le premier passage avait
manqué, et qui aurait faussé l'essai du mode automatique.

### Le défaut manqué : les réglages n'étaient jamais relus

`LampView.onSettingsChanged()` n'était **jamais appelée**. Le SDK 9.2.0 ne déclare
`onSettingsChanged` que sur `AppBase` — vérifié dans `bin/api.debug.xml`, un seul
`parent="AppBase"` et rien d'autre. `LampApp` ne l'implémentait pas. Une méthode portant ce nom
sur la vue est simplement une méthode de plus : le compilateur ne dit rien, le système ne
l'appelle pas.

Conséquence : tout réglage modifié depuis Garmin Connect restait sans effet jusqu'au
redémarrage du champ de données. Le genre de défaut qu'on ne diagnostique pas — on croit avoir
mal réglé, on recommence, rien ne change.

Corrigé dans `LampApp.onSettingsChanged()`. La correction naïve introduisait une régression :
`loadSettings()` réécrit `enabled` depuis la propriété, si bien qu'un changement de seuil aurait
réactivé l'ajustement qu'une tape venait de suspendre — la lampe repartant seule au cran
suivant. D'où `AutoController._manualHold`, et les deux entrées `setEnabledManually()` /
`setEnabledFromSettings()`. Deux tests couvrent les deux sens.

### Les autres suites données

| Point | Ce qui a été fait |
|---|---|
| Allumage systématique au départ | réglage `lightOnStart`, décochable pour les sorties de jour ; 2 tests |
| Vitesse instantanée bruitée | moyenne glissante sur 3 s dans `LampView._smoothed()` |
| Deux crans sur six inatteignables | arrondi au plus proche au lieu de la troncature ; 1 test. Quatre paliers ne peuvent pas couvrir six crans — deux restent manuels, c'est assumé |
| Projet non commité | dépôt initialisé, premier commit |
| Licence absente | `LICENSE` — MIT, avec réserve explicite sur les marques et sur `captures/` |
| Pas de trace des versions | `CHANGELOG.md`, 1.0.0 en préparation |
| Documentation dérivée | `README.md` et `docs/application.md` remis en phase (55 tests, tailles réelles) |

### Ce qui a été vérifié et n'appelle aucune action

- **Le paquet contient bien les contributions FIT** : `7z l dist/bike-light-control.iq` montre un
  `fit_contributions.json` par appareil, plus un global. 18 codes appareils pour 13 produits,
  ce qui est normal — plusieurs références matérielles portent le même nom commercial.
- **Les propriétés du widget non exposées dans `settings.xml` ne sont pas un défaut.** Une
  première lecture y avait vu du remplissage : ce sont les valeurs écrites par le menu embarqué
  (`SettingsMenu`), et une propriété doit être déclarée pour être persistée. Le
  `settings.json` du paquet, lui, ne reprend que ce que `settings.xml` déclare.
- **Compilation en types stricts (`-l 2`), les deux binaires, Edge 530** : aucun avertissement,
  après comme avant les modifications.

### Ce qui reste, et que le code ne peut pas régler

1. **Sauvegarder `developer_key.der` hors de cette machine.** C'est le point le plus grave de
   toute la liste, et le seul irréversible. Garmin lie définitivement une application publiée à
   la clé qui l'a signée : perdue, aucune mise à jour n'est possible — il faut redéposer sous
   une nouvelle fiche, et les utilisateurs installés ne suivent pas. La clé est correctement
   exclue du dépôt ; c'est justement pour cela qu'un `git clone` ne la sauvegardera pas.
2. **Les captures d'écran du store.** `store/` ne contient que les deux icônes 500×500. Au moins
   une capture par fiche est exigée, et le simulateur suffit à les produire.
3. **L'essai de la reconnexion après veille**, sur le matériel.
4. **Un retour d'un modèle autre que le 1050**, idéalement à boutons. Un essai sur **Edge 830**
   est prévu ; fiche à emporter dans [essai-edge830.md](essai-edge830.md). L'830 couvre l'écran
   246×322, les polices bitmap, l'icône 35 px, l'absence de barre de contrôle et de tuile de
   résumé, et l'un des deux binaires les plus lourds des treize (80 572 o).

   Pour les douze autres, [essai-modeles.md](essai-modeles.md) — générée depuis les profils du
   SDK — dit ce que chacun apporte. Elle établit surtout que **les treize ne se recoupent
   presque pas** : 12 cas distincts, un seul regroupement (1030 et 1030 Plus). Il n'y a donc pas
   de modèle unique qui vaudrait pour les autres, et l'ordre de priorité y remplace l'idée
   d'équivalence.

---

## 1. Verdict

**L'application n'est pas encore publiable sur le Connect IQ Store, mais elle en est proche.**
*(Constat du matin. Les cinq points bloquants ont été traités depuis — voir §0.)*

Le socle technique est sain : les 26 binaires compilent sans avertissement, y compris en
vérification de types stricte ; les 39 tests unitaires passent dans le simulateur ; la
géométrie de la page est prouvée sur les six formats d'écran des 13 cibles. Ce qui bloque tient
en cinq points précis (§4), dont un défaut de sécurité d'usage et un risque de rejet par Garmin
sur le nom.

### Vérifications faites pendant l'audit

| Vérification | Résultat |
|---|---|
| `bash app/build.sh` — data field + widget, 13 cibles | 26 / 26 réussies |
| Taille des binaires en release | 41 à 57 Ko (budget 128 Ko en data field) |
| `bash app/build.sh test` — simulateur Edge 1050 | 39 / 39 tests |
| Compilation Edge 530 avec `-l 2` (types stricts), data field et widget | aucun avertissement |
| Tailles d'écran des 13 profils SDK | identiques à celles des tests |
| Contenu du paquet `dist/iG-Edge-app.iq` | 13 `.prg` + `debug.xml` + `settings.json`, **pas de `fit_contributions.json`** |
| Journal `captures/CIQ_LOG.YML` | 6 plantages le 08/09, tous au même `pc` (le `Timer`, corrigé depuis) |

Tailles produites par cible (octets) :

| Appareil | Data field | Widget |
|---|---|---|
| edge530 | 49 340 | 54 988 |
| edge540 | 41 436 | 46 396 |
| edge550 | 47 100 | 52 060 |
| edge830 | 49 340 | 54 988 |
| edge840 | 41 436 | 46 396 |
| edge850 | 47 100 | 52 060 |
| edge1030 | 49 484 | 55 132 |
| edge1030plus | 49 484 | 55 132 |
| edge1040 | 42 492 | 47 452 |
| edge1050 | 51 564 | 56 524 |
| edgeexplore | 49 484 | 55 132 |
| edgeexplore2 | 41 580 | 46 540 |
| edgemtb | 41 580 | 46 540 |

La taille d'un `.prg` n'est pas la mémoire consommée à l'exécution : le budget de 128 Ko
s'applique au tas. Il n'a pas été mesuré ; le fonctionnement constaté sur le 1050, dont la
limite est la même que sur le 530, est le seul indice.

---

## 2. Compatibilité avec les Edge récents

### Le manifeste est correct pour la gamme actuelle

Les Edge 550, 850, MTB et 1050 (génération 2024-2025) sont déclarés dans les deux manifestes.
Le type `watch-app` pour l'application compagnon est le bon choix : les profils SDK confirment
que les modèles récents (540, 550, 840, 850, 1040, 1050, Explore 2, MTB) n'ont plus de type
`widget`, seulement des `glance`. Les Edge 530, 830, 1030, 1030 Plus et Explore n'ont pas de
glance ; le système ignore simplement `getGlanceView()`.

Le futur **Edge 1060** n'est pas annoncé officiellement à la date de l'audit (dépôt
réglementaire repéré, aucun profil dans le SDK). Rien à ajouter.

### Les écrans sont adaptés

Les six formats relevés dans `Devices/<appareil>/simulator.json` correspondent exactement à
ceux de `PANEL_SIZES` dans les tests :

| Format | Appareils |
|---|---|
| 240×320 | MTB |
| 240×400 | Explore, Explore 2 |
| 246×322 | 530, 540, 830, 840 |
| 282×470 | 1030, 1030 Plus, 1040 |
| 420×600 | 550, 850 |
| 480×800 | 1050 |

Barre de contrôle système, qui réduit la hauteur utile d'un data field plein écran : 42 px
(540, MTB), 41 (840), 46 (1040, Explore 2), 89 (550, 850), 93 (1050). Aucune sur 530, 830,
1030, 1030 Plus, Explore.

**Polices.** Les appareils à polices vectorielles donnent leur taille en pourcentage de la
largeur d'écran dans le SDK. Converties en pixels (small / medium / large) :

| Appareil | small | medium | large |
|---|---|---|---|
| Edge MTB | 15 | 17 | 27 |
| Edge 540 / 840 | 18 | 21 | 33 |
| Edge 1040 | 24 | 27 | 45 |
| Edge 550 / 850 | 36 | 40 | 65 |
| Edge 1050 | 41 | 46 | 75 |

Les cinq jeux de `PANEL_FONTS` (14/16/26, 22/26/41, 26/29/48, 33/37/60, 41/46/75) encadrent
bien ces valeurs. Les appareils à polices bitmap (530, 830, 1030, Explore) sont relevés tels
quels.

**Réserve :** le curseur blanc destiné aux modèles à boutons (`_showCursor` dans
`shared/LampPanel.mc`) est aussi dessiné dans le data field plein écran des 530, 540 et MTB, où
aucune touche ne permet de le déplacer. Cosmétique, mais visible.

### Un seul appareil essayé physiquement

L'Edge 1050, firmware 32.20, Connect IQ 6.0.2 (d'après `CIQ_LOG.YML`). Les 12 autres reposent
sur le SDK et les tests. Acceptable pour une bêta, pas pour une sortie publique directe.

---

## 3. Bluetooth et automatismes — état du code

Ce qui est solide :

- Protocole reproduit à l'octet près sur les trames de la capture HCI (tests `frame*` et
  `parseReal*`).
- Fragmentation des écritures à 20 octets, réassemblage des notifications, une seule
  opération GATT en vol, file plafonnée.
- Scan par intermittence (15 s / 45 s) pour ménager la batterie du compteur.
- Aucun `Timer` dans le data field ; battement fourni par `compute()`.
- Glance isolée du reste de l'application, sans dépendance à `Labels` ni au protocole.
- Chaînes toutes externalisées, français et anglais synchronisés (mêmes identifiants).

Ce qui ne l'est pas : voir §4 et §5.

---

## 4. Points bloquants avant publication

### 4.1 La lampe s'éteint à chaque arrêt du chrono, pas seulement en fin de sortie

`app/source/LampView.mc:123` : tout état autre que `Activity.TIMER_STATE_ON` est passé à
`AutoController.onTimerState(false)`, qui renvoie `BLM_LIGHT_OFF` si `syncOff` est actif. Avec
la pause automatique, **chaque feu rouge éteint la lampe de nuit**, alors que c'est le moment
où un cycliste immobile a le plus besoin d'être vu. Le libellé du réglage promet pourtant
« Éteindre la lampe à l'arrêt de l'activité ».

Correction : distinguer `TIMER_STATE_PAUSED` de `TIMER_STATE_STOPPED`, ou ne déclencher
l'extinction qu'à l'arrêt explicite, ou la réserver à `onStop`.

### 4.2 Les champs FIT n'apparaîtront pas dans Garmin Connect

`createField("light_mode", 0, …)` et `createField("light_battery", 1, …)` écrivent bien les
données, mais **aucune ressource `fitContributions` n'existe**, et le paquet `.iq` ne contient
pas de `fit_contributions.json`. Sans elle, Garmin Connect ignore les champs : libellé, unité,
couleur du graphe et affichage dans le résumé viennent de ce fichier, pas du FIT. Les chaînes
`FitMode` et `FitBattery` sont déjà écrites dans `app/resources*/strings/strings.xml` et jamais
référencées.

Il manque, dans `app/resources/`, un fichier du type :

```xml
<fitContributions>
    <fitField id="0" displayInChart="true" sortOrder="0" precision="0"
              chartTitle="@Strings.FitMode" dataLabel="@Strings.FitMode"
              displayInActivitySummary="false" fillColor="#FFAA00"/>
    <fitField id="1" displayInChart="true" sortOrder="1" precision="0"
              chartTitle="@Strings.FitBattery" dataLabel="@Strings.FitBattery"
              unitLabel="%" displayInActivitySummary="true" fillColor="#00C060"/>
</fitContributions>
```

Un exemple complet est dans le SDK : `samples/MoxyField/resources/resources.xml`. Les `id` doivent
correspondre à ceux passés à `createField()`. Cela ne se vérifie qu'avec une installation depuis
le store (bêta suffit), ou avec l'outil `monkeygraph`.

### 4.3 Le nom « iG-Edge » risque un rejet

Depuis 2025, l'équipe du store considère tout usage d'une marque Garmin comme une infraction
sans autorisation écrite, noms de produits compris ; un cadran a été rejeté pour contenir
« Epix ». **« Edge » est une marque déposée Garmin**, et « iG » évoque iGPSPORT, dont le nom est
aussi une marque tierce. L'accord développeur autorise à *mentionner la compatibilité* dans la
description, pas à reprendre la marque dans le titre.

De plus, **les deux binaires portent le même nom et la même icône** : indistinguables dans le
store, dans Garmin Connect et dans la liste des applications du compteur.

Correction : un nom neutre par binaire (par exemple « Bike Light Control » pour le champ de
données et « Bike Light Panel » pour l'application), et la compatibilité iGPSPORT / VS1800S
décrite dans le texte de présentation.

### 4.4 L'icône de lanceur est unique, en 68×68

C'est la taille attendue par le seul Edge 1050. Les autres cibles attendent :

| Taille | Appareils |
|---|---|
| 35×35 | 530, 540, 830, 840 |
| 36×36 | 1030, 1030 Plus, Explore, Explore 2, MTB |
| 40×40 | 1040 |
| 56×56 | 550, 850 |
| 68×68 | 1050 |

Le compilateur redimensionne en silence (aucun avertissement observé), avec une perte de
netteté sur les petits écrans. Le SDK permet des répertoires de ressources qualifiés par
appareil (`resources-edge530/`, etc.) ou par famille. Le store demande par ailleurs une **icône
500×500 séparée**, sRGB, sans fond noir ni transparent, sans texte, sans élément de marque
Garmin.

### 4.5 Le chemin de reconnexion n'a pas été éprouvé

Après une déconnexion, `shared/LampManager.mc:285` rappelle `start()`, qui **ré-enregistre
les deux profils GATT à chaque fois**. La documentation présente `registerProfile` comme un
appel unique au démarrage (« define all of the Profiles that will be used in the application »),
limité à trois, sans fonction inverse. Le comportement d'un second enregistrement du même UUID
sur un vrai Edge n'est pas documenté. L'ancien `_device` n'est pas non plus désappairé avant le
nouveau scan.

Une lampe qui passe en veille puis se réveille en cours de sortie est **le cas courant**, et il
n'a pas été observé sur le matériel.

Correction : un drapeau `_profilesRegistered`, l'enregistrement une seule fois, et
`unpairDevice` sur l'ancien appareil avant de relancer le scan.

---

## 5. Défauts secondaires

- **L'extinction à la fermeture du data field est probablement perdue.**
  `app/source/LampApp.mc:26` met l'écriture en file puis coupe la connexion à la ligne
  suivante ; `requestWrite` est asynchrone.
- **Le filtre de scan est trop large.** `_looksLikeLamp()` accepte tout appareil dont le nom
  contient « VS » ou « TL ». Un appareil voisin est appairé, rejeté faute de service, puis
  retrouvé au scan suivant : boucle sans fin, sans mémoire des appareils déjà écartés.
- **`AutoController.setSupportedModes()` ne compare que les tailles d'échelle**
  (`shared/AutoController.mc:113`). Deux échelles différentes de même longueur ne déclenchent
  pas la mise à jour.
- **Curseur figé** dans le data field plein écran des modèles à boutons (voir §2).
- **La documentation a dérivé du code.** `docs/application.md` décrit encore une détection de
  variante d'UUID que le code ne fait plus (UUID Nordic UART fixe + marqueur d'advertising),
  une file plafonnée à 8 au lieu de 16, une interrogation toutes les 60 s au lieu de 300, 38
  tests au lieu de 39, des binaires de 32 à 42 Ko au lieu de 41 à 57.
- **Le projet n'est pas sous git.** Un `.gitignore` existe mais aucun dépôt. Le dossier
  `captures/` contient un APK tiers et des bugreports Android complets : **à exclure
  absolument** si la diffusion se fait en open source (objectif O8 du cahier des charges).

---

## 6. Ce que le store demandera

- Compte développeur Garmin et clé de signature (présente, hors dépôt).
- Le paquet `.iq` produit par `bash app/build.sh package` — format 7z, c'est celui attendu ;
  un paquet par binaire, donc **deux fiches store**.
- Pas d'attribut `version` dans le manifeste : normal, la version se saisit à l'envoi (les
  exemples du SDK n'en ont pas non plus).
- Icône 500×500, au moins une capture d'écran par fiche, description.
- Aucune permission réseau : pas de politique de confidentialité exigée.
- La revue Garmin prend quelques jours ; en attendant, la fiche est invisible mais l'app est
  installable par son auteur.
- Mode **bêta** disponible : fiche visible de l'auteur et des testeurs désignés seulement. C'est
  la seule façon de vérifier les `fitContributions` et les réglages depuis Garmin Connect.

---

## 7. Ordre recommandé

1. Corriger l'extinction sur pause (§4.1), ajouter `fitContributions` (§4.2), choisir un nom
   neutre par binaire (§4.3), fournir les icônes par appareil et l'icône store (§4.4).
2. Éprouver la reconnexion sur le 1050 avec la lampe mise en veille, et déplacer
   l'enregistrement des profils dans un appel unique (§4.5).
3. Traiter les défauts secondaires (§5), remettre la documentation en phase, initialiser git
   avec `captures/` exclu.
4. Publier en **bêta** sur le store. Vérifier depuis Garmin Connect : réglages, champs FIT,
   noms distincts.
5. Passer en public après retour d'au moins un autre modèle que le 1050, idéalement un modèle
   à boutons (530, 540 ou MTB) et un à polices vectorielles de taille intermédiaire (1040).

---

## Références

- [Politique marques Garmin, forum développeurs (mai 2025)](https://forums.garmin.com/developer/connect-iq/f/discussion/413172/policies-have-changed-regarding-the-use-of-original-garmin-watchface-designs-future-watchfaces-can-not-use-the-original-designs-anymore)
- [Accord développeur Connect IQ](https://developer.garmin.com/downloads/connect-iq/sdks/agreement.html)
- [Brand guidelines Connect IQ (icônes)](https://developer.garmin.com/brand-guidelines/connect-iq/)
- [App Review Guidelines](https://developer.garmin.com/connect-iq/app-review-guidelines/)
- [`fitContributions`, forum développeurs](https://forums.garmin.com/developer/connect-iq/f/discussion/403043/scratching-my-head-with-fitcontributions)
- [Tailles d'icône de lanceur, forum développeurs](https://forums.garmin.com/developer/connect-iq/f/discussion/732/proper-size-for-launcher_icon-for-apps)
- [Module `Toybox.BluetoothLowEnergy`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy.html)
- [Edge 1060, dépôt réglementaire (the5krunner)](https://the5krunner.com/2026/06/02/garmin-edge-1060-regulatory-filing/)
