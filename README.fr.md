<div align="center">

<img src="store/app-icon-500.png" width="120" alt="Commande éclairage vélo">

# Commande d'éclairage vélo

**Piloter une lampe iGPSPORT depuis un compteur Garmin Edge — en roulant.**

[![Connect IQ](https://img.shields.io/badge/Connect%20IQ-9.2.0-007cc3)](https://developer.garmin.com/connect-iq/)
[![Monkey C](https://img.shields.io/badge/Monkey%20C-Toybox%203.1%2B-5c4b8a)](https://developer.garmin.com/connect-iq/monkey-c/)
[![Modèles Edge](https://img.shields.io/badge/mod%C3%A8les%20Edge-13-005f8c)](docs/compatibilite-edge.md)
[![Langues](https://img.shields.io/badge/langues-13-2e7d32)](#les-13-langues-et-pourquoi-pas-les-36)
[![Tests](https://img.shields.io/badge/tests%20unitaires-55-2e7d32)](app/source-test)
[![Licence](https://img.shields.io/badge/licence-MIT-black)](LICENSE)

[English](README.md) · **Français**

</div>

---

La lampe et le compteur sont à dix centimètres l'un de l'autre sur le même cintre, et s'ignorent.
iGPSPORT fournit une application téléphone pour commander la lampe ; le téléphone est dans la
poche arrière. Ce projet comble l'écart : l'Edge parle directement à la lampe en Bluetooth LE,
monte le faisceau quand on accélère, le baisse quand on ralentit, et éteint tout à l'arrêt du
chronomètre.

Le protocole Bluetooth n'était publié nulle part. Il a été reconstitué par analyse statique de
l'application Android iGPSPORT, puis **confirmé à l'octet près par capture HCI sur la lampe
réelle** : le code reproduit exactement les 19 commandes distinctes émises par l'app du
constructeur. Le relevé complet est dans [docs/protocole-vs1800s.md](docs/protocole-vs1800s.md).

## Ce qui est éprouvé, et ce qui ne l'est pas

- **Développé et éprouvé sur une VS1800S, et sur ce seul modèle.** Rien n'y est codé en dur pour
  autant : l'app demande à la lampe son type et sa liste de modes, et s'adapte à la réponse. Les
  VS500, VS800, VS1200 et les feux arrière TL30/TL50 ont donc de bonnes chances de fonctionner,
  mais aucun n'a été essayé. Ce sont des modèles **non vérifiés**, pas des modèles pris en charge.
- **Ce n'est pas un pilote de lampe Bluetooth générique.** Le protocole est celui d'iGPSPORT. Une
  Varia, une Lezyne ou n'importe quelle autre marque ne sera même pas détectée — le filtre de scan
  cherche un service Nordic UART et un nom en `VS…` ou `TL…`.
- **Un seul Edge a roulé avec : l'Edge 1050.** Les douze autres compilent, passent la suite de
  tests au simulateur et voient leur mise en page vérifiée contre les profils du SDK, mais aucun
  n'a encore été monté sur un cintre. L'Edge 830 est le prochain — voir
  [docs/essai-edge830.md](docs/essai-edge830.md).

## Ce que ça fait

| | |
|---|---|
| 🔆 **Faisceau selon la vitesse** | L'intensité suit l'allure, à seuils réglables et avec hystérésis, pour ne pas osciller entre deux modes à vitesse stable. |
| 🔋 **Repli sur batterie faible** | L'intensité est plafonnée pour que la lampe tienne jusqu'au bout de la sortie, au lieu de mourir au 40e kilomètre. |
| ⏱ **Extinction à l'arrêt, pas à la pause** | La lampe s'éteint quand on arrête le chronomètre. Au feu rouge, elle reste allumée. |
| 👆 **Reprise en main** | Une tape sur le champ fait défiler les modes, la page complète permet d'en choisir un. La tape suivante rend la main à l'automatisme. |
| ▶️ **Recherche à la demande** | Le champ cherche la lampe quand on tape dessus, jamais tout seul. Sur les modèles à boutons, le bouton Lap fait la même chose, et un réglage décoché par défaut peut lancer la recherche avec le chrono. Dans les deux cas elle est bornée : sans lampe, pas de scan qui vide la batterie sur toute la sortie. |
| 📈 **Enregistrement FIT** | Le mode et la batterie de la lampe partent dans le fichier FIT et apparaissent dans Garmin Connect. |
| 🎯 **Identification de la lampe** | Avec plusieurs lampes autour, la plus proche est retenue — et **clignote deux fois** pour se désigner. Une sortie de secours passe à la suivante. |
| 📱 **Application compagnon** | Un panneau de pilotage hors activité : allumer avant de partir, régler les automatismes de la lampe, consulter la tuile de résumé. |
| 🌍 **13 langues** | Suit la langue du compteur, sans réglage à chercher. |

## Deux paquets, un seul code

| | Champ de données | Application |
|---|---|---|
| Nom | **Bike Light Control** | **Bike Light Panel** |
| Tourne | pendant l'activité | hors activité, et sur les Edge à boutons |
| Paquet | `dist/bike-light-control.iq` | `dist/bike-light-panel.iq` |
| Budget mémoire | 128 Ko | 1 Mo |
| Taille en release | 71 à 81 Ko sur les 13 cibles | 82 à 94 Ko |

Les deux partagent `shared/` — protocole, couche BLE, automatismes, page de pilotage — et
avancent d'un même pas dans un unique [CHANGELOG.md](CHANGELOG.md).

## Modèles Edge compatibles

**13 modèles Edge** exposent le rôle central BLE aux apps tierces. La liste a été établie en
interrogeant les définitions d'API des profils du SDK 9.2.0 installés localement, pas la
documentation en ligne — détail et méthode dans
[docs/compatibilite-edge.md](docs/compatibilite-edge.md) :

> Edge 530 · 540 · 550 · 830 · 840 · 850 · 1030 · 1030 Plus · 1040 · **1050** ·
> Explore · Explore 2 · MTB

Exclus faute d'API : Edge 130 / 130 Plus, 520, 520 Plus, 820, 1000, et — c'est le piège —
l'**Edge 1030 Bontrager**, alors que l'Edge 1030 standard est compatible.

Deux pièges de plateforme à retenir :

- **Le compilateur ne valide pas la permission BLE.** Un data field la déclarant compile sans
  erreur pour un Edge 820 ou un Edge 130. La liste des `<iq:product>` du manifeste doit être
  écrite à la main d'après le tableau vérifié.
- **Le tactile n'est pas exposé dans les profils du SDK** : c'est une propriété d'exécution
  (`System.getDeviceSettings().isTouchScreen`). Le pilotage par `onTap()` se branche donc au
  runtime, pas à la compilation — un seul binaire pour les 13 modèles.

Mémoire uniforme sur les 13 cibles : 128 Ko en data field, 1 Mo en application. Un code qui tient
sur un 1050 tient sur un 530.

## Construire

```bash
bash app/build.sh
```

Construit les deux binaires en release pour les 13 cibles. Le script localise seul le JDK et le
SDK Connect IQ. Autres entrées : `edge1050` (un seul appareil), `debug`, `package` (les `.iq` du
store).

```bash
bash app/build.sh test-all
```

Lance les 58 tests unitaires sur **quatre profils** — 530, MTB, 1040, 1050 — et non sur le seul
1050. Les tests de mise en page parcourent les six formats d'écran quel que soit le profil, mais
le reste du binaire s'exécute sur celui du simulateur : une suite qui ne tourne que sur un 1050
ne prouve rien des douze autres. `bash app/build.sh test` pour le 1050 seul.

Deux contrôles croisent le code avec les profils du SDK plutôt qu'avec la documentation :

```bash
python tools/check-icons.py
```

### Voir l'interface sans lampe

Le simulateur n'a pas de pile Bluetooth : l'application y restait sur
« Recherche », et rien de la page de pilotage ne s'affichait. Un build de
démonstration remplit l'état de la lampe avec ce qu'une VS1800S déclare
réellement :

```bash
bash app/build.sh sim
```

```bash
bash tools/sim-captures.sh
```

Un PNG par format d'écran, dans `captures/sim/`. Il a trouvé quatre défauts
d'affichage dès le premier passage, qu'aucun Edge 1050 ne pouvait montrer —
détail dans [docs/application.md](docs/application.md).

```bash
python tools/i18n/langues-supportees.py --declarees
```

### Prérequis

| | |
|---|---|
| SDK Connect IQ | 9.2.0, avec les profils des appareils Edge |
| JDK | Temurin 21 LTS (11+ convient) |
| Python | 3.x, pour l'outillage de `tools/` |
| Clé développeur | `developer_key.der` — personnelle, **jamais commitée**, voir `.gitignore` |

## Essayer sans la lampe

Toute la chaîne se valide sans matériel. nRF Connect sur Android sait jouer un serveur GATT :
l'Edge se connecte alors à une VS1800S factice, et scan, appairage, abonnement, écritures et
notifications se vérifient. Recette pas à pas dans
[docs/essai-sans-lampe.md](docs/essai-sans-lampe.md).

## Les 13 langues, et pourquoi pas les 36

Anglais, français, allemand, espagnol, italien, portugais, néerlandais, polonais, russe,
japonais, coréen, chinois simplifié et traditionnel.

Le SDK associe à chaque **référence matérielle** un jeu de polices, et les 13 modèles totalisent
18 références : celles dites « ww » portent les langues européennes, les références APAC portent
le japonais, le coréen et le chinois. Aucune langue hors l'anglais n'est donc portée par les 18 —
ce n'est pas un problème, une langue absente retombe sur l'anglais.

Ce qui décide, c'est la taille. Chaque langue déclarée grossit le binaire, qu'elle serve ou non
sur la référence compilée, et un champ de données dispose de 128 Ko :

| Langues déclarées | Champ de données | Application |
|---|---|---|
| 2 | 56 620 o | 61 372 o |
| **13** | **82 668 o** | **94 956 o** |
| 36 (toutes celles du SDK) | 113 180 o | 134 284 o |

Mesures sur Edge 1050, **avec le jeu d'icônes précédent** : ce qui compte ici est l'écart entre
les lignes, qui ne tient qu'aux langues. Les 36 langues ne laissent rien pour le tas. Les 13
retenues sont celles portées par au moins 12 références sur 18 ; les huit dernières — arabe,
bulgare, estonien, letton, lituanien, roumain, turc, ukrainien — ne le sont que par **une seule**.

## Le protocole en un paragraphe

La lampe parle **protobuf** (variante *lite*) sur une liaison BLE de type Nordic UART, avec un
CRC-8 en fin de trame. L'app du constructeur n'est pas obfusquée sur ces classes : sont donc
documentés les 43 modes d'éclairage et leurs valeurs, les 10 services, les 4 opérations, les 22
automatismes et le schéma complet des messages avec numéros de champ. Il n'existe pas de
bibliothèque protobuf pour Connect IQ, alors l'encodage *varint* est écrit à la main dans
[shared/Protobuf.mc](shared/Protobuf.mc) — quelques dizaines de lignes. Schéma complet et sept
points restant à confirmer sur matériel : [docs/protocole-vs1800s.md](docs/protocole-vs1800s.md).

## Arborescence

```
shared/                             protocole, couche BLE, automatismes, page de pilotage
app/                                champ de données — « Bike Light Control »
  build.sh                          construction des deux binaires, tests et paquets
  source/                           point d'entrée, vue, écriture FIT
  source-test/                      58 tests unitaires
  resources/fit/                    déclaration des champs FIT pour Garmin Connect
  resources-icon-*/                 icône de lanceur, une par taille d'écran (35 à 68 px)
widget/                             application — « Bike Light Panel »
store/                              icônes 500×500 et textes des fiches du Connect IQ Store
docs/
  protocole-vs1800s.md              le protocole — livrable de la Phase 1
  compatibilite-edge.md             modèles Edge compatibles, vérifiés contre le SDK
  application.md                    architecture de l'app et décisions de conception
  essai-sans-lampe.md               tester avec une fausse lampe (nRF Connect)
  essai-edge830.md                  fiche d'essai sur Edge 830
  essai-modeles.md                  fiche des 13 modèles — générée depuis les profils SDK
  audit-publication.md              audit de publiabilité sur le store
  phase1-procedure-capture-ble.md   procédure de capture BLE + méthode Wireshark
  phase1-journal-capture.md         feuille de relevé à remplir pendant la manip
tools/
  check-icons.py                    icônes croisées avec les profils SDK des 13 cibles
  fiche-modeles.py                  écrit docs/essai-modeles.md depuis les profils SDK
  i18n/                             traductions : une table JSON par langue
  make-icons.py                     dessine les icônes de lanceur et celles du store
  deploy-edge.sh                    installe les deux binaires sur un Edge branché en USB
  pull-btsnoop.sh                   récupération du journal HCI depuis le téléphone
  scan-apk.py, dump-proto-*.py      analyse de l'APK, sans Java
captures/                           rapports d'analyse (logs et APK bruts exclus — .gitignore)
```

## Où en est le projet

| | |
|---|---|
| Protocole BLE | ✅ schéma complet, confirmé par capture HCI |
| Implémentation en Monkey C | ✅ 58 tests, dont 12 sur les octets réels de la capture |
| Compilation des 13 cibles | ✅ dans le budget, 13 langues comprises |
| Edge 1050, sur l'appareil | ✅ connexion et pilotage fonctionnels — champ, application et tuile validés |
| Interface | ✅ mise en page vérifiée sur les 6 formats d'écran |
| Edge 830 et les 11 autres | 🟡 pas encore essayés sur matériel |
| Reconnexion après veille de la lampe | 🟡 corrigée dans le code, pas encore observée sur matériel |
| Connect IQ Store | 🟡 bloquants levés → [docs/audit-publication.md](docs/audit-publication.md) |

Le cahier des charges de référence et les écarts assumés sont dans
[cahier-des-charges-igpsport-garmin.md](cahier-des-charges-igpsport-garmin.md).

## Références

- [`Toybox.BluetoothLowEnergy`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy.html) ·
  [`BleDelegate`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy/BleDelegate.html)
- [Connect IQ — Device Reference](https://developer.garmin.com/connect-iq/device-reference/)
- [VS1800S — page produit iGPSPORT](https://www.igpsport.com/product/vs1800s)
- [Reverse Engineering BLE Devices](https://reverse-engineering-ble-devices.readthedocs.io/en/latest/protocol_reveng/00_protocol_reveng.html) ·
  [Domyos EL500 — rétro-ingénierie GATT](https://jcjc-dev.com/2023/03/19/reversing-domyos-el500-elliptical/) ·
  [Reverse Engineering Cheap BLE Devices](https://www.alexwhittemore.com/reverse-engineering-cheap-ble-devices/)

## Licence

[MIT](LICENSE), avec réserve sur les marques et sur `captures/`. Sans lien avec Garmin ni
iGPSPORT, et sans leur aval. « Garmin », « Edge », « Connect IQ » et « iGPSPORT » appartiennent à
leurs propriétaires respectifs.
