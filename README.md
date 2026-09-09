# Commande d'éclairage vélo — lampe iGPSPORT ↔ compteur Garmin Edge

Data field Connect IQ pilotant une lampe **iGPSPORT** depuis un compteur **Garmin Edge**.
Développé pour la VS1800S, mais sans rien coder en dur : l'app demande à la lampe son type et
ses modes, et s'adapte — VS500, VS800, VS1200, feux arrière TL30/TL50 inclus. Cahier des charges de référence : `cahier-des-charges-igpsport-garmin.md`.

**Phase 1 close, Phase 2 engagée.** Le protocole a été établi par analyse statique de
l'app Android puis **confirmé par capture HCI sur la lampe réelle** : le code reproduit à
l'octet près les 19 commandes distinctes émises par l'app iGPSPORT.
L'application compile pour les 13 modèles Edge cibles et ses 55 tests unitaires passent.
Reste à confronter le tout à la vraie lampe.

---

## Où en est le projet

| Élément | Statut |
|---|---|
| Compatibilité BLE des Edge (risque « bloquant » §7) | ✅ **levé** — voir ci-dessous |
| Outillage de capture et d'analyse | ✅ prêt (`tools/`) |
| Analyse statique de l'APK iGPSPORT | ✅ **faite** — v8.06.42 |
| Protocole BLE de la lampe | ✅ **schéma complet** → [docs/protocole-vs1800s.md](docs/protocole-vs1800s.md) |
| Risque « protocole chiffré » (§7) | ✅ **levé** — protobuf en clair, app non obfusquée |
| Capture HCI | ✅ **faite** le 08/09/2026 — transport et CRC établis |
| App Connect IQ | 🟡 **socle fonctionnel** → [docs/application.md](docs/application.md) |
| Protocole implémenté en Monkey C | ✅ 55 tests, dont 12 sur les octets réels de la capture |
| Compilation 13 cibles | ✅ 70 à 79 Ko en release, 13 langues comprises (budget 128 Ko) |
| Essai de l'app sur l'Edge 1050 | ✅ **connexion et pilotage fonctionnels**, data field, application et tuile de résumé validés sur l'appareil le 09/09/2026 |
| Interface | ✅ **refondue** — mise en page vérifiée sur les 6 formats d'écran des cibles |
| Langues | ✅ **13 langues**, suivant la langue du compteur — voir ci-dessous |
| Champs FIT dans Garmin Connect | ✅ ressource `fitContributions` présente dans le paquet |
| Plusieurs lampes à proximité | ✅ la plus proche est retenue, et **clignote** pour se désigner |
| Icônes | ✅ une par taille d'écran (35 à 68 px), opaques bord à bord comme celles du SDK, plus les 500×500 du store |
| Réglages modifiés depuis Garmin Connect | ✅ relus en cours d'activité, sans écraser un choix manuel |
| Allumage au départ | ✅ décochable — le compteur ne sait pas s'il fait nuit |
| Licence et journal des versions | ✅ `LICENSE` (MIT) et `CHANGELOG.md` |
| Publiabilité sur le Connect IQ Store | 🟡 bloquants levés → [docs/audit-publication.md](docs/audit-publication.md) |

Compteur cible confirmé : **Edge 1050**.

### Les 13 langues, et pourquoi pas les 36

Anglais, français, allemand, espagnol, italien, portugais, néerlandais, polonais, russe,
japonais, coréen, chinois simplifié et traditionnel.

Le SDK associe à chaque **référence matérielle** un jeu de polices, et les 13 modèles
totalisent 18 références : celles dites « ww » portent les langues européennes, les références
APAC portent le japonais, le coréen et le chinois. Aucune langue hors l'anglais n'est donc
portée par les 18 — ce n'est pas un problème, une langue absente retombe sur l'anglais.

Ce qui décide, c'est la taille. Chaque langue déclarée grossit le binaire, qu'elle serve ou non
sur la référence compilée, et un champ de données dispose de 128 Ko :

| Langues déclarées | Champ de données | Application |
|---|---|---|
| 2 | 56 620 o | 61 372 o |
| **13** | **82 668 o** | **94 956 o** |
| 36 (toutes celles du SDK) | 113 180 o | 134 284 o |
Mesures sur Edge 1050, **avec le jeu d'icônes précédent** : ce qui compte ici est l'écart entre
les lignes, qui ne tient qu'aux langues. Depuis la refonte des icônes en PNG opaques, le même
binaire à 13 langues pèse 78 044 o. Sur les 13 cibles, le champ de données va de 71 308 à
80 636 octets, l'application de 81 772 à 93 548.

Les 36 langues ne laissent rien pour le tas. Les 13 retenues sont celles portées par au moins
12 références sur 18 ; les huit dernières — arabe, bulgare, estonien, letton, lituanien,
roumain, turc, ukrainien — ne le sont que par **une seule**.

```bash
python tools/i18n/langues-supportees.py --declarees
```

### Ce que l'analyse statique a donné

Le protocole de la lampe est du **protobuf** (variante *lite*) sur une liaison BLE de type
Nordic UART. L'app n'est pas obfusquée sur ces classes. Sont désormais documentés : les
43 modes d'éclairage avec leurs valeurs, les 10 services, les 4 opérations, les 22
automatismes, le schéma complet des messages avec numéros de champ, et les trames binaires
correspondantes.

Autrement dit, la capture HCI n'a plus à *découvrir* le protocole — elle a à le **confirmer**
sur sept points listés au §10 du document de protocole.

### Compatibilité matérielle — vérifiée contre le SDK

**13 modèles Edge** exposent le rôle central BLE aux apps tierces. Liste établie en
interrogeant les définitions d'API des profils du SDK 9.2.0 installés localement, pas la
documentation en ligne — détail et méthode dans
[docs/compatibilite-edge.md](docs/compatibilite-edge.md) :

> Edge 530 · 540 · 550 · 830 · 840 · 850 · 1030 · 1030 Plus · 1040 · **1050** ·
> Explore · Explore 2 · MTB

Exclus faute d'API : Edge 130 / 130 Plus, 520, 520 Plus, 820, 1000, et — c'est le piège —
l'**Edge 1030 Bontrager**, alors que l'Edge 1030 standard est compatible.

Deux pièges à retenir pour la Phase 2 :

- **Le compilateur ne valide pas la permission BLE.** Un data field la déclarant compile sans
  erreur pour un Edge 820 ou un Edge 130. La liste des `<iq:product>` du manifeste doit être
  écrite à la main d'après le tableau vérifié.
- **Le tactile n'est pas exposé dans les profils du SDK** : c'est une propriété d'exécution
  (`System.getDeviceSettings().isTouchScreen`). Le pilotage manuel par `onTap()` se branche
  donc au runtime, pas à la compilation — un seul binaire pour les 13 modèles.

Mémoire uniforme sur les 13 cibles : 128 Ko en data field, 1 Mo en application. Un code qui
tient sur un 1050 tient sur un 530.

Autres contraintes de plateforme :

- **3 profils GATT enregistrables au maximum** (`registerProfile`) — un seul nous suffit.
- **L'appairage ne persiste pas d'une instance d'application à l'autre.**

### Environnement de développement

| | |
|---|---|
| SDK Connect IQ | 9.2.0 ✅ installé |
| JDK | Temurin 21 LTS ✅ installé |
| Profils Edge | ✅ 20 profils téléchargés |
| Clé développeur | ✅ `developer_key.der` (hors dépôt, voir `.gitignore`) |
| Chaîne vérifiée | ✅ compilation réussie d'un data field BLE pour les 13 cibles |

---

## Construire l'application

```bash
bash app/build.sh
```

```bash
bash app/build.sh test
```

Le script localise seul le JDK et le SDK. Détail de l'architecture et des décisions de
conception dans [docs/application.md](docs/application.md).

---

## Ce qui attend la lampe

Sept points du protocole restent à **confirmer** — plus à découvrir — listés au §10 de
[docs/protocole-vs1800s.md](docs/protocole-vs1800s.md). Les deux qui touchent le code :

1. **La reconnexion après veille.** La lampe qui s'endort puis se réveille en cours de sortie
   est le cas courant, et il n'a pas encore été observé sur le matériel. Le code enregistre
   désormais ses profils GATT une seule fois et désappaire avant de relancer le scan.
2. **L'encodage de l'extinction.** `BLM_LIGHT_OFF` valant 0, protobuf omet le champ et le
   sous-message part vide. Si la capture montre le contraire, basculer
   `LightProtocol.FORCE_EXPLICIT_OFF` à `true`.

Il est possible de tester **sans la lampe**, dès maintenant : nRF Connect sur Android sait
jouer un serveur GATT. L'Edge se connecte alors à une VS1800S factice et toute la chaîne se
valide — scan, appairage, abonnement, écritures, notifications. Recette pas à pas dans
[docs/essai-sans-lampe.md](docs/essai-sans-lampe.md).

---

## Démarrer

1. Lire [docs/phase1-procedure-capture-ble.md](docs/phase1-procedure-capture-ble.md) **en
   entier** avant de brancher quoi que ce soit — l'étape la plus souvent ratée (cycle
   Bluetooth off/on) est au §2.
2. Ouvrir [docs/phase1-journal-capture.md](docs/phase1-journal-capture.md) et le remplir
   pendant la manip. C'est ce qui rend le log exploitable.
3. Récupérer le journal :

```bash
bash tools/pull-btsnoop.sh
```

   puis, pour la seconde session (mode automatique / vitesse) :

```bash
bash tools/pull-btsnoop.sh vitesse
```

4. Dépouiller dans Wireshark en suivant le §6 de la procédure, et reporter les résultats
   dans [docs/protocole-vs1800s.md](docs/protocole-vs1800s.md).

---

## Arborescence

```
LICENSE                             MIT, avec réserve sur les marques et sur captures/
CHANGELOG.md                        journal des versions déposées sur le store
docs/
  phase1-procedure-capture-ble.md   procédure de capture + méthode de dépouillement Wireshark
  phase1-journal-capture.md         feuille de relevé à remplir pendant la manip
  protocole-vs1800s.md              livrable de la Phase 1 — schéma du protocole
  compatibilite-edge.md             modèles Edge compatibles, vérifiés contre le SDK
  application.md                    architecture de l'app et décisions de conception
  essai-sans-lampe.md               tester l'app avec une fausse lampe (nRF Connect)
  audit-publication.md              audit du 09/09/2026 : publiabilité, compatibilité Edge
shared/                             protocole, couche BLE, automatismes, page de pilotage
app/                                data field « Bike Light Control »
  build.sh                          construction des deux binaires, tests et paquets
  source/                           point d'entrée, vue, écriture FIT
  source-test/                      55 tests unitaires
  resources/fit/                    déclaration des champs FIT pour Garmin Connect
  resources-icon-*/                 icône de lanceur, une par taille d'écran
widget/                             application « Bike Light Panel », pilotage manuel
store/                              icônes 500×500 des fiches du Connect IQ Store
tools/
  i18n/                             traductions : une table JSON par langue
    generate.py                     écrit les resources-<langue>/ à partir des tables
    langues-supportees.py           langues portées par chaque référence, d'après le SDK
    accents-fre.py                  rétablissement des accents français
  pull-btsnoop.sh                   récupération du journal HCI depuis le téléphone
  pull-apk.sh                       extraction de l'APK iGPSPORT depuis le téléphone
  scan-apk.py                       repérage des UUID et mots-clés dans l'APK — sans Java
  dump-proto-enums.py               énumérations protobuf (modes, services, opérations)
  dump-proto-schema.py              schéma des messages : numéros et types de champ
  check-ble-devices.sh              appareils Garmin exposant le rôle central BLE
  deploy-edge.sh                    installe les deux binaires sur un Edge branché en USB
  make-icons.py                     dessine les icônes de lanceur et celles du store
  pull-ciq-log.sh                   récupère le journal de plantage et traduit les adresses
  _adb.sh                           sélection d'appareil, commune aux scripts adb
captures/                           logs, exports CSV, captures d'écran nRF Connect, APK
```

---

## Écarts assumés par rapport au cahier des charges

- **Phase 3, test n°4** — « vérifier que l'app mobile iGPSPORT continue de fonctionner en
  parallèle » : très probablement irréalisable, une lampe BLE de ce type n'acceptant qu'une
  seule connexion centrale à la fois. Edge connecté ⇒ téléphone déconnecté. Le critère est à
  reformuler en « bascule propre entre les deux ». À confirmer en §7 du document de
  protocole.
- **F5 / O6 (ajustement selon la vitesse)** — classé « Could have », mérite d'être remonté à
  « Should have ». L'Edge dispose de sa propre vitesse via `Toybox.Activity`, plus fiable que
  le GPS d'un smartphone en poche ; et si l'app iGPSPORT calcule elle-même les changements de
  mode côté téléphone (hypothèse la plus probable, à trancher en §5 bis de la procédure), la
  fonction ne demande **aucune** connaissance protocolaire au-delà des commandes de mode.
  C'est l'argument principal de l'app face à un pilotage purement manuel.
- **Risque « protocole chiffré » (§7)** — **levé.** Le protocole est du protobuf en clair et
  l'app n'est pas obfusquée sur les classes concernées. Accessoirement, le journal HCI étant
  capturé au-dessus de la couche liaison, un chiffrement BLE standard n'aurait de toute façon
  pas empêché de lire les trames ATT.
- **Phase 2 — encodage protobuf en Monkey C.** Il n'existe pas de bibliothèque protobuf pour
  Connect IQ ; il faudra écrire l'encodage *varint* à la main. Quelques dizaines de lignes,
  mais ce n'était pas prévu au planning.

---

## Références

- [Module `Toybox.BluetoothLowEnergy`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy.html)
- [`BleDelegate`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy/BleDelegate.html)
- [Connect IQ — Device Reference](https://developer.garmin.com/connect-iq/device-reference/)
- [VS1800S — page produit iGPSPORT](https://www.igpsport.com/product/vs1800s)
- [Reverse Engineering BLE Devices (méthodologie)](https://reverse-engineering-ble-devices.readthedocs.io/en/latest/protocol_reveng/00_protocol_reveng.html)
- [Domyos EL500 — exemple complet de rétro-ingénierie GATT](https://jcjc-dev.com/2023/03/19/reversing-domyos-el500-elliptical/)
- [Reverse Engineering Cheap BLE Devices (heuristiques)](https://www.alexwhittemore.com/reverse-engineering-cheap-ble-devices/)
