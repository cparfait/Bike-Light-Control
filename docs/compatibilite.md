# Compatibilité des appareils Garmin

**Vérifié contre le SDK Connect IQ 9.2.0 installé localement**, et non d'après la
documentation en ligne. La liste des `<iq:product>` des deux manifestes est **générée** à
partir de ces profils :

```bash
python tools/gen-targets.py
```

Le tableau du bas de cette page se refait avec l'option `markdown`, la liste du manifeste avec
`manifest`, les groupes d'icônes du jungle avec `jungle`, les variantes de vignette avec
`glance`. **Rien de tout cela ne se recopie à la main.**

---

## Les quatre critères

Tous relus dans le profil de l'appareil, jamais dans une page de documentation ou un fil de
forum.

| Critère | Où on le lit | Pourquoi il est nécessaire |
|---|---|---|
| Rôle central BLE | `setScanState` et `registerProfile` dans `<appareil>.api.debug.xml` | sans lui, aucune lampe ne peut être ni trouvée ni pilotée |
| Types `datafield` **et** `watchApp` | `appTypes` de `compiler.json` | le projet livre les deux binaires, et ils avancent ensemble |
| Champ de données ≥ 128 Ko | `memoryLimit` du type `datafield` | le binaire en fait environ 90 ; les boîtiers à 32 Ko ne le chargeraient pas |
| Connect IQ ≥ 3.1.0 | `connectIQVersion` des `partNumbers` | c'est le `minApiLevel` des manifestes |

**Le premier critère est un piège, et c'est lui qui a motivé tout l'outillage.** Chercher la
chaîne `BluetoothLowEnergy` ne sert à rien : *tous* les appareils la contiennent. Seule la
présence effective des méthodes du rôle central distingue ceux qui savent scanner et se
connecter. `tools/check-ble-devices.sh` applique exactement le même test, appareil par
appareil, et sert à contrôler le générateur.

**La compilation ne filtre pas non plus.** Un data field déclarant `BluetoothLowEnergy`
compile sans erreur pour un Edge 820, qui ne sait pourtant pas l'exécuter. Le compilateur ne
rejette que le `minApiLevel`. La liste ne peut donc pas être déduite d'un build réussi — mais
un build **raté** l'amende : c'est `bash app/build.sh` qui a le dernier mot.

---

## Ce que la liste couvre

**103 cibles**, dont les 13 compteurs Edge d'origine et 86 cadrans ronds.

| Famille | Modèles | Remarque |
|---|---|---|
| Edge | 13 | les cibles historiques du projet, seules éprouvées sur matériel |
| fenix / epix / tactix / quatix / MARQ | 40 environ | du fenix 5 Plus au fenix 9 Pro |
| Forerunner | 20 environ | à partir du 245 Music |
| Venu / vívoactive | 12 | dont les deux Venu 4 |
| Descent / D2 / Approach / Instinct AMOLED | 15 environ | mêmes plateformes, autres boîtiers |
| GPSMAP, Montana | 2 | des portables, pas des montres, mais ils remplissent les quatre critères |

### Les exclus, et pourquoi

| Modèle | Ce qui manque |
|---|---|
| Edge 1030 Bontrager | pas de rôle central, alors que l'Edge 1030 standard l'a — même génération, même version CIQ |
| Edge 820, 520 Plus, 1000 | pas de rôle central |
| Edge 130 / 130 Plus, Edge 520 | pas de rôle central, et 32 Ko de champ |
| fenix 3, 5, 6 non-Pro, vívoactive 3/4, Venu 1, venu sq | pas de rôle central, ou champ trop petit |

**L'Edge 1030 Bontrager reste la surprise du lot.** Même matériel apparent que l'Edge 1030, et
sa définition d'API ne contient aucune méthode du rôle central. À ne pas annoncer comme
supporté.

---

## Écrans

Deux formes seulement sur les 103 cibles — **rectangle** (17) et **disque** (86). Aucun
« semi-round » ni « semi-octagon » ne passe les critères, ce qui évite un troisième cas à
traiter dans la mise en page.

Neuf diamètres de cadran : 218, 240, 260, 280, 360, 390, 416, 454 et 466 px. Six formats
rectangulaires : 240x320, 240x400, 246x322, 282x470, 420x600, 480x800.

**Un disque n'est pas un petit rectangle.** Les quatre coins d'un rectangle inscrit tombent
hors de la dalle, et la largeur utilisable dépend de la hauteur où l'on se trouve.
`shared/PanelLayout.mc` calcule donc une corde par bande de la page plutôt qu'une colonne
unique : inscrire la page dans le carré central aurait coûté la moitié du cadran. Le chemin
rectangulaire, lui, est inchangé au pixel près — `_half()` y rend toujours la même
demi-colonne, et les 1 925 combinaisons du test d'origine passent sans modification.

La forme est lue **à l'exécution** (`LampPanel.isRound()`), comme le tactile, et non choisie à
la compilation : un seul binaire, pas de variante par modèle. Deux conditions et non une —
un champ de données sur une montre ronde reçoit un rectangle découpé par le système, dans
lequel la géométrie est celle d'un Edge.

## Mémoire

128 Ko en champ de données sur les Edge, 256 Ko sur la plupart des montres ; 1 Mo en
application. Aucune disparité à gérer : un code qui tient sur un Edge 1050 tient partout
ailleurs.

## Tactile

**Le SDK n'expose pas cette caractéristique dans `compiler.json`.** C'est une propriété
d'exécution, à lire via `System.getDeviceSettings().isTouchScreen`.

Conséquence de conception : ne pas brancher à la compilation, mais **au runtime**. Le champ de
données propose le changement de mode par `onTap()` si l'écran est tactile, et se limite à
l'affichage plus l'automatisme sinon — le pilotage manuel passant alors par l'application
compagnon.

Rappel : `onTap()` ne fonctionne qu'avec la classe `DataField` complète, jamais avec
`SimpleDataField`.

---

## Ce qui est éprouvé, et ce qui ne l'est pas

**Deux appareils sur cent trois ont fait tourner ce code sur du matériel :**

| Appareil | Date | Ce que cela établit |
|---|---|---|
| Edge 1050 | depuis le début | la cible de développement ; écran rectangulaire, tactile |
| Venu 4 41 mm | 20/09/2026 | déclaré fonctionnel après installation manuelle |

**Ce que le Venu 4 prouve** est important et limité. Important : le rôle central BLE marche
sur une plateforme montre, le protocole VS1800S ne dépend pas du matériel, et la mise en page
inscrite dans le disque tient sur un vrai cadran — ce que ni le simulateur ni un test unitaire
ne pouvaient trancher.

**Limité** : « fonctionnel » n'est pas la grille d'essai. Les trois points qui bloquent une
sortie publique — reconnexion après une mise en veille de la lampe en cours de sortie,
extinction à l'arrêt du chronomètre après un mode choisi à la main, sortie d'activité sans
arrêter le chronomètre — demandent chacun un geste précis pendant une sortie, et rien ne dit
qu'ils aient été faits. Voir `docs/depot-beta.md`, chapitre 4.

Les 101 autres appareils sont compatibles au sens des quatre critères et compilent, ce qui
n'est pas la même chose qu'avoir été essayés. La fiche `docs/essai-modeles.md` dit ce que
chacun apporterait ; `docs/essai-edge830.md` est la grille d'essai à remplir, et elle vaut
telle quelle pour une montre.

Pour installer sur un appareil sans passer par le store :

```bash
bash tools/deploy-device.sh venu445mm
```

---

## Refaire la vérification

Après chaque mise à jour du SDK :

```bash
python tools/gen-targets.py
```

puis, si la liste a bougé :

```bash
python tools/gen-targets.py --manifest
python tools/gen-targets.py --jungle
python tools/gen-targets.py --glance
python tools/make-icons.py
python tools/check-icons.py
bash app/build.sh
```

Les deux scripts de contrôle restent utiles pour inspecter un modèle précis, avec le même
critère que le générateur mais un affichage appareil par appareil :

```bash
bash tools/check-ble-devices.sh venu4
bash tools/check-app-types.sh fenix8
```

---

## Le tableau complet

Généré par `python tools/gen-targets.py --markdown`.

| Modèle | Profil SDK | Écran | CIQ | Champ | Icône |
|---|---|---|---|---|---|
| Approach® S50 | `approachs50` | 390x390 round | 5.1.0 | 256 Ko | 56 px |
| Approach® S70 42mm | `approachs7042mm` | 390x390 round | 5.1.0 | 256 Ko | 60 px |
| Approach® S70 47mm | `approachs7047mm` | 454x454 round | 5.1.0 | 256 Ko | 70 px |
| D2™ Air X10 | `d2airx10` | 416x416 round | 5.0.0 | 256 Ko | 70 px |
| D2™ Mach 1 | `d2mach1` | 416x416 round | 5.2.0 | 256 Ko | 60 px |
| D2™ Mach 2 | `d2mach2` | 454x454 round | 5.2.0 | 128 Ko | 65 px |
| D2™ Mach 2 Pro | `d2mach2pro` | 454x454 round | 6.0.0 | 128 Ko | 65 px |
| Descent™ G2 | `descentg2` | 390x390 round | 5.1.0 | 256 Ko | 60 px |
| Descent™ Mk2 / Mk2i | `descentmk2` | 280x280 round | 3.4.5 | 128 Ko | 40 px |
| Descent™ Mk2 S | `descentmk2s` | 240x240 round | 3.4.5 | 128 Ko | 40 px |
| Descent™ Mk3 43mm / Mk3i 43mm | `descentmk343mm` | 390x390 round | 5.1.0 | 256 Ko | 60 px |
| Descent™ Mk3i 51mm | `descentmk351mm` | 454x454 round | 5.1.0 | 256 Ko | 60 px |
| Edge® 1030 | `edge1030` | 282x470 rectangle | 3.2.5 | 128 Ko | 36 px |
| Edge® 1030 Plus | `edge1030plus` | 282x470 rectangle | 3.3.1 | 128 Ko | 36 px |
| Edge® 1040 / 1040 Solar | `edge1040` | 282x470 rectangle | 6.0.0 | 128 Ko | 40 px |
| Edge® 1050 | `edge1050` | 480x800 rectangle | 6.0.0 | 128 Ko | 68 px |
| Edge® 530 | `edge530` | 246x322 rectangle | 3.3.1 | 128 Ko | 35 px |
| Edge® 540 / 540 Solar | `edge540` | 246x322 rectangle | 6.0.0 | 128 Ko | 35 px |
| Edge® 550 | `edge550` | 420x600 rectangle | 6.0.0 | 128 Ko | 56 px |
| Edge® 830 | `edge830` | 246x322 rectangle | 3.3.1 | 128 Ko | 35 px |
| Edge® 840 / 840 Solar | `edge840` | 246x322 rectangle | 6.0.0 | 128 Ko | 35 px |
| Edge® 850 | `edge850` | 420x600 rectangle | 6.0.0 | 128 Ko | 56 px |
| Edge® Explore | `edgeexplore` | 240x400 rectangle | 3.1.3 | 128 Ko | 36 px |
| Edge® Explore 2 | `edgeexplore2` | 240x400 rectangle | 5.1.0 | 128 Ko | 36 px |
| Edge® MTB | `edgemtb` | 240x320 rectangle | 6.0.0 | 128 Ko | 36 px |
| Enduro™ 3 | `enduro3` | 280x280 round | 6.0.2 | 128 Ko | 40 px |
| epix™ (Gen 2) / quatix® 7 Sapphire | `epix2` | 416x416 round | 5.2.0 | 256 Ko | 60 px |
| epix™ Pro (Gen 2) 42mm | `epix2pro42mm` | 390x390 round | 5.2.0 | 256 Ko | 60 px |
| epix™ Pro (Gen 2) 47mm / quatix® 7 Pro | `epix2pro47mm` | 416x416 round | 5.2.0 | 256 Ko | 60 px |
| epix™ Pro (Gen 2) 51mm / D2™ Mach 1 Pro / tactix® 7 – AMOLED Edition | `epix2pro51mm` | 454x454 round | 5.2.0 | 256 Ko | 60 px |
| fēnix® 5 Plus | `fenix5plus` | 240x240 round | 3.2.8 | 128 Ko | 40 px |
| fēnix® 5S Plus | `fenix5splus` | 240x240 round | 3.2.8 | 128 Ko | 40 px |
| fēnix® 5X Plus | `fenix5xplus` | 240x240 round | 3.2.8 | 128 Ko | 40 px |
| fēnix® 6 Pro / 6 Sapphire / 6 Pro Solar / 6 Pro Dual Power / quatix® 6 | `fenix6pro` | 260x260 round | 3.4.2 | 128 Ko | 40 px |
| fēnix® 6S Pro / 6S Sapphire / 6S Pro Solar / 6S Pro Dual Power | `fenix6spro` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| fēnix® 6X Pro / 6X Sapphire / 6X Pro Solar / tactix® Delta Sapphire / Delta Solar / Delta Solar - Ballistics Edition / quatix® 6X / 6X Solar / 6X Dual Power | `fenix6xpro` | 280x280 round | 3.4.2 | 128 Ko | 40 px |
| fēnix® 7 / quatix® 7 | `fenix7` | 260x260 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7 Pro | `fenix7pro` | 260x260 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7 Pro - Solar Edition (no Wi-Fi) | `fenix7pronowifi` | 260x260 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7S | `fenix7s` | 240x240 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7S Pro | `fenix7spro` | 240x240 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7X / tactix® 7 / quatix® 7X Solar / Enduro™ 2 | `fenix7x` | 280x280 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7X Pro | `fenix7xpro` | 280x280 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 7X Pro - Solar Edition (no Wi-Fi) | `fenix7xpronowifi` | 280x280 round | 5.2.0 | 256 Ko | 40 px |
| fēnix® 8 43mm | `fenix843mm` | 416x416 round | 6.0.2 | 128 Ko | 60 px |
| fēnix® 8 47mm / 51mm / tactix® 8 47mm / 51mm / quatix® 8 47mm / 51mm | `fenix847mm` | 454x454 round | 6.0.2 | 128 Ko | 65 px |
| fēnix® 8 Pro 47mm / 51mm / MicroLED / quatix® 8 Pro 47mm / 51mm | `fenix8pro47mm` | 454x454 round | 6.0.2 | 128 Ko | 65 px |
| fēnix® 8 Solar 47mm | `fenix8solar47mm` | 260x260 round | 6.0.2 | 128 Ko | 40 px |
| fēnix® 8 Solar 51mm / tactix® 8 Solar 51mm | `fenix8solar51mm` | 280x280 round | 6.0.2 | 128 Ko | 40 px |
| fēnix® 9 43mm | `fenix943mm` | 416x416 round | 6.0.3 | 128 Ko | 60 px |
| fēnix® 9 47mm / 51mm | `fenix947mm` | 454x454 round | 6.0.3 | 128 Ko | 65 px |
| fēnix® 9 Pro 43mm | `fenix9pro43mm` | 416x416 round | 6.0.3 | 128 Ko | 60 px |
| fēnix® 9 Pro 47mm | `fenix9pro47mm` | 454x454 round | 6.0.3 | 128 Ko | 65 px |
| fēnix® 9 Pro 51mm | `fenix9pro51mm` | 466x466 round | 6.0.3 | 128 Ko | 65 px |
| fēnix® 9 Pro Solar 47mm | `fenix9prosolar47mm` | 260x260 round | 6.0.3 | 128 Ko | 40 px |
| fēnix® 9 Pro Solar 51mm | `fenix9prosolar51mm` | 280x280 round | 6.0.3 | 128 Ko | 40 px |
| fēnix® E | `fenixe` | 416x416 round | 6.0.2 | 128 Ko | 60 px |
| Forerunner® 165 | `fr165` | 390x390 round | 5.2.0 | 256 Ko | 54 px |
| Forerunner® 165 Music | `fr165m` | 390x390 round | 5.2.0 | 256 Ko | 54 px |
| Forerunner® 170 | `fr170` | 390x390 round | 6.0.0 | 256 Ko | 54 px |
| Forerunner® 170 Music | `fr170m` | 390x390 round | 6.0.0 | 256 Ko | 54 px |
| Forerunner® 245 Music | `fr245m` | 240x240 round | 3.3.1 | 128 Ko | 40 px |
| Forerunner® 255 | `fr255` | 260x260 round | 5.2.0 | 256 Ko | 40 px |
| Forerunner® 255 Music | `fr255m` | 260x260 round | 5.2.0 | 256 Ko | 40 px |
| Forerunner® 255s | `fr255s` | 218x218 round | 5.2.0 | 256 Ko | 40 px |
| Forerunner® 255s Music | `fr255sm` | 218x218 round | 5.2.0 | 256 Ko | 40 px |
| Forerunner® 265 | `fr265` | 416x416 round | 5.2.0 | 256 Ko | 60 px |
| Forerunner® 265s | `fr265s` | 360x360 round | 5.2.0 | 256 Ko | 60 px |
| Forerunner® 570 42mm | `fr57042mm` | 390x390 round | 6.0.2 | 256 Ko | 54 px |
| Forerunner® 570 47mm | `fr57047mm` | 454x454 round | 6.0.2 | 256 Ko | 65 px |
| Forerunner® 70 | `fr70` | 390x390 round | 6.0.0 | 256 Ko | 54 px |
| Forerunner® 745 | `fr745` | 240x240 round | 3.3.1 | 128 Ko | 40 px |
| Forerunner® 945 | `fr945` | 240x240 round | 3.3.1 | 128 Ko | 40 px |
| Forerunner® 945 LTE | `fr945lte` | 240x240 round | 3.4.3 | 128 Ko | 40 px |
| Forerunner® 955 / Solar | `fr955` | 260x260 round | 5.2.0 | 256 Ko | 40 px |
| Forerunner® 965 | `fr965` | 454x454 round | 5.2.0 | 256 Ko | 65 px |
| Forerunner® 970 | `fr970` | 454x454 round | 6.0.2 | 128 Ko | 65 px |
| GPSMAP® H1 / H1i Plus | `gpsmaph1` | 282x470 rectangle | 5.0.0 | 128 Ko | 32 px |
| Instinct® 3 AMOLED 45mm | `instinct3amoled45mm` | 390x390 round | 6.0.2 | 128 Ko | 60 px |
| Instinct® 3 AMOLED 50mm | `instinct3amoled50mm` | 416x416 round | 6.0.2 | 128 Ko | 60 px |
| Instinct® Crossover AMOLED | `instinctcrossoveramoled` | 390x390 round | 6.0.2 | 128 Ko | 38 px |
| MARQ® (Gen 2) Athlete / Adventurer / Captain / Golfer / Carbon Edition / Commander - Carbon Edition | `marq2` | 390x390 round | 5.2.0 | 256 Ko | 60 px |
| MARQ® (Gen 2) Aviator | `marq2aviator` | 390x390 round | 5.2.0 | 256 Ko | 60 px |
| MARQ® Adventurer | `marqadventurer` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Athlete | `marqathlete` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Aviator | `marqaviator` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Captain / MARQ® Captain: American Magic Edition | `marqcaptain` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Commander | `marqcommander` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Driver | `marqdriver` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Expedition | `marqexpedition` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| MARQ® Golfer | `marqgolfer` | 240x240 round | 3.4.2 | 128 Ko | 40 px |
| Montana® 7 Series | `montana7xx` | 480x800 rectangle | 3.2.1 | 128 Ko | 60 px |
| Venu® 2 | `venu2` | 416x416 round | 5.0.0 | 256 Ko | 70 px |
| Venu® 2 Plus | `venu2plus` | 416x416 round | 5.0.0 | 256 Ko | 70 px |
| Venu® 2S | `venu2s` | 360x360 round | 5.0.0 | 256 Ko | 61 px |
| Venu® 3 | `venu3` | 454x454 round | 5.2.0 | 256 Ko | 70 px |
| Venu® 3S | `venu3s` | 390x390 round | 5.2.0 | 256 Ko | 70 px |
| Venu® 4 41mm | `venu441mm` | 390x390 round | 6.0.2 | 256 Ko | 54 px |
| Venu® 4 45mm / D2™ Air X15 | `venu445mm` | 454x454 round | 6.0.2 | 256 Ko | 65 px |
| Venu® Sq 2 Music | `venusq2m` | 320x360 rectangle | 5.0.0 | 256 Ko | 40 px |
| Venu® X1 | `venux1` | 448x486 rectangle | 6.0.2 | 256 Ko | 65 px |
| vívoactive® 5 | `vivoactive5` | 390x390 round | 5.2.0 | 256 Ko | 56 px |
| vívoactive® 6 | `vivoactive6` | 390x390 round | 6.0.2 | 256 Ko | 54 px |

**103 cibles.**
