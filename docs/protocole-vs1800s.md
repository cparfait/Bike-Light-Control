# Protocole BLE — lampes iGPSPORT (VS1800S)

**Statut : structure du protocole établie par analyse statique. Valeurs de terrain à confirmer.**

| | |
|---|---|
| Source | APK iGPSPORT `com.qiwu.worldwide.ride` **v8.06.42** (Play Store, extrait le 08/09/2026) |
| Matériel | VS1800S, **firmware V1.08**, adresse BLE se terminant par `C7:C6` |
| Méthode | Extraction des constantes protobuf du `.dex` (`tools/dump-proto-enums.py`) |
| Rapports bruts | `captures/proto-20260908-010029/enums.md`, `captures/apk-20260908-005641/rapport.md` |
| Version du document | 1.0 |

## Niveau de confiance — à lire avant d'utiliser ce document

Ce qui suit vient du **code généré de l'app elle-même**, pas d'une déduction sur des trames
observées. Les noms et les valeurs numériques sont donc exacts *tels que l'app les connaît*.

Trois réserves, à lever avec la lampe en main :

1. **Quel UUID exactement** parmi quatre variantes (§2).
2. **L'encodage de l'extinction** (`BLM_LIGHT_OFF` = 0, valeur par défaut omise par
   protobuf), et si `blt_message_format` circule seul ou encapsulé (§4).
3. **Ce que la VS1800S supporte réellement** parmi les 43 modes du catalogue : c'est
   spécifique au modèle, et la lampe l'annonce à l'exécution via `BLS_MODE_SUP`.

Rien ici ne remplace la capture HCI ; en revanche elle devient une **vérification** au lieu
d'un déchiffrage.

---

## 0 bis. Confirmations par l'interface de l'app (08/09/2026)

Relevé sur l'app iGPSPORT avec la VS1800S connectée, **firmware V1.08** :

| Écran de l'app | Ce que ça confirme |
|---|---|
| Six modes : croisement faible/moyen/élevé, route faible/moyen/élevé | **L'échelle `BEAM_LADDER` du code est exacte** : `BLM_LBEAM_L/M/HSTEADY` (12/11/10) et `BLM_HBEAM_L/M/HSTEADY` (9/8/7) |
| « Éditer pour activer plus de modes » ; trois icônes de clignotant grisées | Le mécanisme `BLS_MODE_ENABLE` / `blt_mode_sup.enable` : des modes existent mais sont désactivés |
| Batterie **49 %**, autonomie **5 h 25** | Valeurs attendues à la capture : `batPct` = 49 (`0x31`), `leftTime` = 325 si l'unité est la minute |
| Mode courant « Feu de croisement faible » | `curMode` = 12 |
| État « Lié » | La lampe est connectée sans bonding SMP (confirmé par `dumpsys`) |

**Écran « Configuration de la fonction intelligente »** — c'est la table `BLE_LIGHT_CONFIG_SUP`
telle que la voit l'utilisateur :

| Libellé dans l'app | Constante probable | État observé |
|---|---|---|
| Commutateur synchrone de code Meter light | `BLCS_RIDE_SYNC` (1) ou `BLCS_SYNC_OFF` (5) | désactivé |
| Lumière intelligente | `BLCS_AUTO_LIGHT` (3) | désactivé |
| **Luminosité en fonction de la vitesse** | **`BLCS_LUMEN_VARY` (9)** | **désactivé** |
| Auto Veille + temps d'attente 2 min | `BLCS_AUTO_SLEEP` (4) | activé |
| Luminosité faible stationnaire + temps 2 min | `BLCS_AUTO_LOW` (13) | activé |
| Mode basse consommation | `BLCS_INTELL_SAVING` (16) | activé |

Deux enseignements importants :

**La fonction visée par O6/F5 existe bel et bien** et porte un nom sans ambiguïté :
« Luminosité en fonction de la vitesse ». Elle est **désactivée** par défaut. C'est donc bien
`BLCS_LUMEN_VARY` qu'il faut activer à l'étape K du scénario de capture, puis rouler.

**Les deux réglages à minuterie valident le schéma protobuf.** Le message
`PeripheralLight$auto_low_cfg` extrait de l'APK contient exactement `status` et `timeOut` — ce
qui correspond trait pour trait à « Luminosité faible stationnaire » et son curseur de délai.
Le décodage du schéma est donc corroboré par l'interface, indépendamment de toute capture.

> **Une mise à jour firmware V1.13 est proposée.** Ne pas l'appliquer avant la capture : on
> documente d'abord le firmware qu'on a. Le §7 du cahier des charges prévoit justement de
> versionner le protocole observé — ce sera l'occasion de vérifier si la mise à jour le change.

---

## 0 ter. Ce que dit le manuel constructeur (VS1800S, notice 2025-02-13)

Récupéré sur le téléphone, `captures/doc/VS1800S-manuel.pdf`. Il tranche plusieurs points
que ni l'APK ni la capture ne pouvaient éclairer.

### L'extinction ne se commande pas depuis l'application

> « Appui long de 1,5 s sur le bouton pour allumer, appui long de 1,5 s pour éteindre. »

C'est le **seul** moyen documenté d'éteindre la lampe. L'application ne propose que le choix
du mode — ce qui explique qu'aucun bouton d'extinction n'y soit trouvable, et pourquoi
l'extinction n'apparaît dans aucune capture.

Conséquence : `LightProtocol.turnOff()`, qui envoie `curMode = BLM_LIGHT_OFF`, reste une
**hypothèse non vérifiée**. La valeur existe dans l'énumération et un compteur iGS s'en sert
peut-être, mais rien ne le prouve. À trancher par l'essai sur l'Edge.

#### Mais « éteinte » ne veut pas dire radio coupée — observé le 09/09/2026

**Relevé sur l'Edge 1050, avec la lampe éteinte par l'appui long de 1,5 s : le compteur la
détecte toujours.** La lampe continue donc d'émettre son advertising alors que son faisceau et
son témoin sont éteints, et qu'elle est « éteinte » au sens du manuel.

C'était l'hypothèse inverse qui figurait ici, déduite du manuel et jamais vérifiée. L'appui long
coupe l'éclairage, pas la partie radio.

Deux conséquences, de signe opposé :

- **Bonne** : la lampe reste joignable. Un compteur peut donc la retrouver, et probablement la
  rallumer, sans qu'on touche au bouton. C'est aussi ce qui rend la reconnexion après veille
  plausible — voir le tableau des comportements automatiques ci-dessous.
- **À surveiller** : l'application se connecte alors à une lampe que l'utilisateur vient
  d'éteindre **volontairement**, et l'identification la fait clignoter. Elle est censée la
  remettre ensuite dans l'état où elle l'a trouvée (`_restoreMode`), mais cet état est lu sur la
  lampe — or le manuel signale une **mémoire de mode**, la lampe reprenant son mode précédent au
  rallumage.

#### Ce que l'essai a donné ensuite — le point dur

Trois observations, le même jour, sur l'Edge 1050 :

1. **La lampe éteinte est redétectée** tant qu'on reste sur la page de pilotage. Le compteur s'y
   reconnecte de lui-même.
2. **Le bouton physique ne répond plus** une fois le compteur connecté. Seule l'application
   parvient encore à allumer la lampe.
3. **La page affiche un mode alors que la lampe n'éclaire pas.**

La troisième est la plus lourde de conséquences, et elle confirme la crainte ci-dessus :
`LightStatus` ne porte **aucun champ « allumée / éteinte »**, seulement un `mode`. Si une lampe
éteinte annonce son mode mémorisé au lieu de `BLM_LIGHT_OFF`, alors rien dans le protocole tel
qu'on le connaît ne permet de distinguer :

> « lampe allumée en feu de croisement » de « lampe éteinte qui se souvient du feu de croisement ».

L'application affiche donc un mode qui n'éclaire pas, et l'identification, en remettant la lampe
dans ce mode « d'avant », la **rallume** — ce qui explique l'observation n° 2 vue de
l'utilisateur : la lampe s'allume sans qu'il ait touché au bouton.

**Ce qu'il reste à établir**, et qui décide de la correction :

- ~~La valeur brute de `curMode` annoncée par une lampe éteinte au bouton.~~ **Tranché le
  09/09/2026 : c'est `12` (`BLM_LBEAM_LSTEADY`), son mode mémorisé — pas `0`.** La lampe ne dit
  donc rien de son extinction, et il faut bien chercher un autre indicateur : un champ de
  `blt_light_self` non encore exploité, ou l'autonomie restante qui vaudrait alors zéro.
  C'est cette seconde piste que la surcouche affiche désormais (`r=`).
- Si le bouton physique est réellement neutralisé par la connexion BLE, ou s'il ne l'est
  qu'en état éteint — auquel cas c'est le comportement normal d'un appui court sur une lampe
  hors tension.

La surcouche de diagnostic de `LampPanel` affiche `m=<mode brut>`, `r=<autonomie restante, en
minutes>` et `id` pendant l'identification, précisément pour trancher ces points sans matériel de
capture. Elle s'active par `panel.debug = true` dans la vue concernée.

**Contournement retenu, faute de pouvoir lire l'état.** L'application compagnon pose elle-même le
mode dès qu'elle trouve la lampe — le cran le plus faible, `BLM_LBEAM_LSTEADY` — au lieu de croire
ce que la lampe annonce. À partir de là, elle sait ce qu'elle a demandé, et l'affichage redevient
vrai. Réglable par `lightOnStart` ; voir `LampManager._lightUp()`.

Et puisque éteindre depuis le compteur coupe le faisceau sans couper la radio, la page affiche
cinq secondes un rappel après chaque extinction demandée à la main : l'appui long sur le bouton
reste le seul geste qui arrête réellement la lampe.

### Pour F6, la lampe a sa propre fonction

> « Arrêt synchronisé : lorsque l'appareil est connecté au compteur, il s'éteint simultanément
> avec le compteur. » — **désactivé par défaut**, à activer dans l'app, et « supporté par
> certains compteurs seulement ».

C'est `BLCS_SYNC_OFF` (5). Voie plus sûre que d'envoyer un mode « éteint » : c'est le mécanisme
prévu par le constructeur. À activer une fois via `setSmartConfig`.

### L'ajustement selon la vitesse est fait par la lampe, pas par le compteur

> « Sur la base de la luminosité du mode courant, la luminosité augmente **linéairement** avec
> la vitesse, jusqu'au maximum que l'éclairage peut fournir. »

La lampe n'a pas de capteur de vitesse : quelque chose doit donc **lui pousser la vitesse**.
Ce message n'a pas encore été identifié — il ne fait pas partie du service 106.

Cela ne remet pas en cause notre implémentation : l'Edge change de **mode** selon la vitesse,
là où la lampe module *dans* un mode. Six crans discrets plutôt qu'une rampe continue. Les
deux approches peuvent même coexister.

### Trois comportements automatiques à connaître

| Fonction | Comportement | Incidence |
|---|---|---|
| **Veille automatique** | après **120 s** à l'arrêt, feu et témoin s'éteignent ; réveil au mouvement ou au bouton | **activée par défaut** — l'app peut croire la lampe éteinte alors qu'elle dort |
| **Protection batterie basse** | sous **20 %**, la lampe réduit d'elle-même la luminosité | notre propre plafonnement est au même seuil : les deux peuvent se superposer |
| **Mémoire de mode** | au rallumage, la lampe reprend le mode précédent | l'état initial n'est pas prévisible, il faut le lire |

### Les modes désactivés par défaut sont nommés

Le manuel liste comme « désactivés par défaut, à activer dans l'app » : **flash diurne**,
**flash nocturne**, et **personnalisés 1, 2 et 3**. Cela correspond exactement à ce que la
capture a montré : modes 4 et 5 listés sans drapeau d'activation, et modes 64, 65, 66.

---

## 0 quater. Pourquoi le menu « Feux » natif du compteur ne sert à rien ici

Vérifié sur l'Edge 1050 le 08/09/2026 : **la VS1800S n'apparaît pas** dans la recherche de
feux du menu natif. Elle n'est pas ANT+.

Ce menu pilote le **réseau de feux ANT+** de Garmin — celui des Varia, Bontrager et Giant
Recon. La définition d'API de l'Edge 1050 confirme qu'il repose sur `AntPlus.LightNetwork`
et `AntPlus.BikeLight`.

Deux obstacles indépendants, et chacun suffirait :

1. **La lampe ne parle pas ANT+.** Tout son protocole passe par un service BLE de type
   Nordic UART.
2. **Connect IQ ne permet pas d'inscrire un périphérique BLE dans le réseau ANT+.** L'API
   laisse une application observer et piloter les feux **déjà présents** dans ce réseau ; rien
   ne permet d'y enregistrer un appareil étranger.

Autrement dit, même une implémentation parfaite du protocole iGPSPORT ne peuplerait pas le
menu natif. C'est une limite de la plateforme, et c'est précisément la raison d'être de ce
projet.

---

## 1. Résultat majeur : le protocole n'est ni chiffré ni propriétaire-opaque

C'est du **protobuf** (Google Protocol Buffers, variante *lite*), sérialisé sur une liaison
BLE de type UART. L'app n'est pas obfusquée sur ces classes : les noms Kotlin/Java sont
intacts.

**Conséquence directe sur le §7 du cahier des charges : le risque « protocole chiffré ou
obfusqué », classé bloquant, est levé.** Il reste possible qu'une couche d'authentification
existe à la connexion — c'est le seul point à surveiller — mais le format des messages, lui,
est entièrement lisible.

---

## 2. Transport BLE

> ### Établi par capture HCI le 08/09/2026 — VS1800S, firmware V1.08
>
> **Le Nordic UART standard `…9E` est bien le transport.** J'avais conclu l'inverse en ne
> voyant que l'advertising : la lampe **n'annonce pas** son service NUS. Elle annonce
> `A238C112-8136-52A9-364B-D61AC015024E`, un marqueur qui n'existe nulle part dans l'APK et
> qui ne sert qu'au repérage. Le service réel n'apparaît qu'après connexion.
>
> Conséquence pratique : **on ne peut pas filtrer le scan sur l'UUID du service.** Il faut
> repérer la lampe par le nom annoncé ou par ce marqueur, puis se connecter.

### Table GATT relevée sur la VS1800S

| Handles | Service | Rôle |
|---|---|---|
| 1–7 | `1800` Generic Access | |
| 8–11 | `1801` Generic Attribute | |
| 12–22 | `180A` Device Information | dont `2A26` version firmware (handle 18) |
| 23–27 | **`180F` Battery Service** | **`2A19` handle 25, Read + Notify** |
| 28–36 | **`6E400001-…9E` Nordic UART** | le canal de commande |
| 37–45 | `9EFB0001-E814-62FA-D308-82E2A63901E8` | second canal, non utilisé par l'app |

| Handle | Caractéristique | Propriétés | Usage |
|---|---|---|---|
| **33** | `6E400002-…9E` | Write / WriteNoResp | **TX — central vers lampe** |
| **30** | `6E400003-…9E` | Notify | **RX — lampe vers central** |
| 31 | CCCD du RX | — | **à écrire `01 00` pour recevoir** |
| 35 | `6E400004-…9E` | Write / Notify | quatrième caractéristique, inutilisée |
| **25** | `2A19` Battery Level | Read / Notify | **F2 par le chemin standard** |
| 26 | CCCD de la batterie | — | à écrire `01 00` |

**La batterie est donc lisible de deux façons** : par le service standard `0x180F`, notifié
spontanément (valeur observée `0x30` = 48 %, conforme aux 49 % affichés par l'app), ou par le
protocole propriétaire. La première est plus simple et ne demande aucun décodage.

MTU négocié : **247 octets**. Les notifications restent pourtant fragmentées par 20 octets.

### Trame de transport — établie et vérifiée

Chaque message est précédé d'un **en-tête de 20 octets**. Sur les écritures, en-tête et charge
utile tiennent dans un seul PDU ; sur les notifications, la charge utile suit en fragments.

```
octet  0     : 01           type — 01 données, 02 accusé, 03 résultat
octet  1     : service      identifiant de service (= champ 1 du protobuf)
octet  2     : sous-service (= champ 3 du protobuf)
octet  3     : FF
octet  4     : opération    (= champ 2 du protobuf)
octets 5-6   : FF FF
octet  7     : 00           (porte le mode dans les trames de résultat, type 03)
octet  8     : longueur de la charge utile
octet  9     : CRC-8/MAXIM de la charge utile
octet 10     : 01
octets 11-18 : FF × 8
octet 19     : CRC-8/MAXIM des octets 0 à 18
------------ : charge utile protobuf (blt_message_format)
```

**CRC-8/MAXIM** : polynôme 0x31 réfléchi (0x8C en implémentation par décalage à droite),
init 0x00, entrée et sortie réfléchies, pas de XOR final. C'est le CRC Dallas/1-Wire.

Vérification : sur les 44 trames capturées, l'octet 19 est correct **44 fois sur 44**, et
reconstruire une trame complète à partir du service, du sous-service, de l'opération et de la
charge utile redonne **exactement** les octets d'origine.

### Trois types de trame

L'octet 0 de l'en-tête distingue trois natures de message. Seul le type 01 porte une charge
utile protobuf ; les deux autres tiennent entièrement dans leurs 20 octets.

| Type | Sens | Contenu | Octet 8 |
|---|---|---|---|
| **01** | les deux | en-tête + charge utile protobuf | longueur de la charge utile |
| **02** | lampe → central | accusé de réception d'une écriture | `0x00` |
| **03** | lampe → central | **état spontané**, valeur inscrite dans l'en-tête | `0xFF` |

> ⚠️ **Piège d'implémentation.** L'octet 8 vaut `0xFF` dans une trame d'état. Le lire comme
> une longueur fait attendre 255 octets qui n'arriveront jamais, et bloque définitivement le
> réassemblage. C'est exactement le bug qu'avait mon code avant cette capture.

### Trames d'état (type 03) — c'est ainsi que la lampe signale le bouton

Quand l'utilisateur appuie sur le bouton physique, la lampe émet spontanément une trame de
type 03. **C'est ce qui permet à l'Edge d'afficher l'état réel plutôt que le dernier ordre
envoyé** — l'objectif F3 est donc pleinement atteignable.

| Sous-service | Emplacement de la valeur | Format |
|---|---|---|
| **2** `BLS_MODE_CUR` | **octet 7** | le mode, sur un octet |
| **5** `BLS_LEFT_TIME` | **octets 11 à 14** | minutes, 32 bits petit-boutiste |

Relevé pendant les appuis sur le bouton, la correspondance mode / autonomie est cohérente
avec le tableau du manuel — plus le mode est puissant, plus l'autonomie est courte :

| Mode | Libellé | Autonomie annoncée |
|---|---|---|
| 12 | croisement faible | 295 min |
| 9 | route faible | 140 min |
| 8 | route moyen | 110 min |
| 7 | route élevé | 80 min |

Modes vus dans ces trames : 4, 5, 7, 8, 9, 10, 11, 12 et 64. Les 26 trames de type 02 et 03
capturées ont toutes un CRC d'en-tête correct.

### Services observés dans l'octet 1

| Valeur | Sous-services vus | Interprétation |
|---|---|---|
| 101 (`0x65`) | 31 | poignée de main initiale — la lampe répond son nom `VS1800S` et `IGPSPORT` |
| 131 (`0x83`) | 1 | numéro de série (`6300775…`) |
| **106 (`0x6A`)** | 1 à 5 | **protocole d'éclairage — c'est celui qui nous intéresse** |

Pour le service 106, le sous-service est exactement le `BLE_LIGHT_SERVICE` de §5, et
l'opération vaut **1 pour écrire** et **2 pour lire ou notifier**.

---

### Hypothèse initiale, conservée pour mémoire


La bibliothèque `com.igpsport.blelib` et les UUID suivants sont dans le même fichier
`classes8.dex`, ce qui les associe sans ambiguïté :

| UUID | Rôle |
|---|---|
| `6e400001-b5a3-f393-e0a9-e50e24dcca9e` | Nordic UART Service (NUS), variante standard |
| `6e400001-b5a3-f393-e0a9-e50e24dcca8e` | variante `…8e` |
| `6e400001-b5a3-f393-e0a9-e50e24dcca7e` | variante `…7e` |
| `6e400001-b5a3-f393-e0a9-e50e24dcca6e` | variante `…6e` |

Pour chaque variante, le schéma NUS s'applique :

| Caractéristique | Suffixe | Sens | Propriété |
|---|---|---|---|
| Service | `…0001-…` | — | — |
| **TX** | `…0002-…` | central → lampe (commandes) | Write / Write No Response |
| **RX** | `…0003-…` | lampe → central (état, batterie) | Notify — **CCCD `0x2902` à activer** |

> **À trancher avec la lampe :** laquelle des quatre variantes la VS1800S expose. C'est une
> vérification de 30 secondes dans nRF Connect (§5 de la procédure de capture), pas un
> travail de rétro-ingénierie. L'hypothèse de travail est que les variantes distinguent des
> familles de périphériques (lampe / radar / capteur / compteur).

**Faux positif à écarter :** les UUID `a6ed04xx-` et `a6ed07xx-d344-460a-8075-b9e8ec90d71b`
apparaissent dans `classes7.dex`, qui contient le SDK **Garmin FIT**. Ils concernent la
communication avec les appareils Garmin, pas la lampe.

Services standard également référencés par la bibliothèque, à vérifier sur la lampe :
`0x180F` Battery Service / `0x2A19` Battery Level, `0x180A` Device Information (dont
`0x2A26` Firmware Revision — utile pour versionner le protocole observé, §7 du cahier des
charges).

---

## 3. Deux jeux de messages coexistent

| Famille | Préfixes | Interprétation |
|---|---|---|
| **`PeripheralLightApp`** | `BLM_` `BLS_` `BLT_` `BLO_` `BLCS_` | Dialogue **app ↔ lampe**. 43 modes, 10 services. Riche et récent. |
| `PeripheralLight` | `PLM_` `PLS_` `PLT_` `PLCS_` | Jeu plus ancien / plus pauvre (8 modes). Probablement le dialogue **compteur ↔ lampe**, ou une génération antérieure. |

**C'est `PeripheralLightApp` qu'il faut viser** : l'Edge se substituera au téléphone comme
central BLE, donc il tiendra le rôle de l'app. Le jeu `PeripheralLight` est documenté en
annexe (§10) au cas où la VS1800S ne parlerait que celui-là — à confirmer à la capture.

---

## 4. Schéma protobuf complet

Numéros et types de champ décodés depuis les chaînes `newMessageInfo` de protobuf-lite
(`tools/dump-proto-schema.py`). Schéma complet : `captures/schema-20260908-010744/schema.md`.

### Enveloppe — `blt_message_format`

```protobuf
message blt_message_format {
  BLE_LIGHT_SERVICE serviceType    = 1;   // de quoi on parle
  BLE_LIGHT_OPERATE operateType    = 2;   // ce qu'on en fait
  BLE_LIGHT_SERVICE bltServiceType = 3;   // sous-service
  BLE_LIGHT_OPERATE bltOperateType = 4;   // sous-opération
  // charge utile : un seul champ renseigné, selon serviceType
  blt_light_self          lightSelf   =  5;
  repeated blt_mode_sup   modeSup     =  6;
  blt_cus_mode_get        cusModeGet  =  7;
  blt_cus_mode_arg        modeArg     =  8;
  repeated blt_smt_cfg    cfgSup      =  9;
  blt_smt_cfg             cfgSet      = 10;
  blt_mode_enable         modeSet     = 11;
  blt_cus_mode_cfg        customCfg   = 12;
  blt_light_mode_cur      curMode     = 13;
  blt_left_time           leftTime    = 14;
  blt_bat_pct             batPct      = 15;
  ride_cfg_msg_all        rideCfgAll  = 16;
  ride_cfg_msg            rideCfgSet  = 17;
}
```

### Charges utiles

```protobuf
message blt_light_mode_cur { BLE_LIGHT_MODE curMode = 1; }

message blt_bat_pct        { int32 batPct = 13; }   // oui, 13 — pas 1

message blt_left_time      { int64 time = 1; }      // autonomie restante

message blt_light_self     { BLE_LIGHT_TYPE lightType = 1;
                             int32          lightCnt  = 2; }

message blt_mode_sup       { BLE_LIGHT_MODE      mode     = 1;
                             BLE_LIGHT_MODE_TYPE modeType = 2;
                             bool                enable   = 3;
                             blt_mode_editable   editable = 4; }

message blt_mode_enable    { BLE_LIGHT_MODE mode   = 1;
                             bool           enable = 2; }

message blt_smt_cfg        { BLE_LIGHT_CONFIG_SUP config   = 1;
                             BLT_SMT_CFG_STATUS   status   = 2;
                             cfg_user_data        userData = 3; }
```

Le numéro **13** de `batPct` est contre-intuitif mais confirmé par le décodage
(`\x00\x01\x00\x00\r\r\x01\x00\x00\x00\r\x04` : un champ, borné à 13/13, type 4 = `int32`).

### Enveloppe externe — point ouvert

Le jeu `PeripheralLight` définit sa propre enveloppe :

```protobuf
message peripheral_light_format {
  PERIPHERAL_LIGHT_SERVICE serviceType    = 1;
  PERIPHERAL_LIGHT_OPERATE operateType    = 2;
  PERIPHERAL_LIGHT_SERVICE subServiceType = 3;
  PERIPHERAL_LIGHT_OPERATE subOperateType = 4;
  bytes                    message        = 5;
}
```

Reste à déterminer si `blt_message_format` part **tel quel** sur la caractéristique TX, ou
s'il est encapsulé dans une enveloppe générique de ce type. La capture HCI tranchera en une
trame.

---

## 4 bis. Trames prêtes à l'emploi

Encodage protobuf standard : chaque champ est précédé d'un octet de tag
`(numéro << 3) | type_de_fil`, avec type de fil `0` pour les varints (enum, int, bool) et
`2` pour les sous-messages (suivis de leur longueur).

**Lire le niveau de batterie** — `BLS_BAT_PCT` (6) + `BLO_OPERATE_GET` (1) :

```
08 06 10 01
```

**Lire le mode courant** — `BLS_MODE_CUR` (2) + `GET` (1) :

```
08 02 10 01
```

**Lire les modes supportés** — `BLS_MODE_SUP` (1) + `GET` (1) :

```
08 01 10 01
```

**Lire l'autonomie restante** — `BLS_LEFT_TIME` (5) + `GET` (1) :

```
08 05 10 01
```

**Passer en feu de croisement, intensité basse** — `BLS_MODE_CUR` (2) +
`BLO_OPERATE_ENABLE` (3) + `curMode { curMode = BLM_LBEAM_LSTEADY (12) }` :

```
08 02 10 03 6A 02 08 0C
 │  │  │  │  │  │  │  └─ BLM_LBEAM_LSTEADY = 12
 │  │  │  │  │  │  └──── tag champ 1 (curMode), varint
 │  │  │  │  │  └─────── longueur du sous-message : 2 octets
 │  │  │  │  └────────── tag champ 13 (curMode), sous-message
 │  │  │  └───────────── BLO_OPERATE_ENABLE = 3
 │  │  └──────────────── tag champ 2 (operateType)
 │  └─────────────────── BLS_MODE_CUR = 2
 └────────────────────── tag champ 1 (serviceType)
```

Les autres modes se déduisent en remplaçant le dernier octet par la valeur du §7 :
feu de route haute `07`, moyenne `08`, basse `09` ; croisement haute `0A`, moyenne `0B`,
basse `0C`.

**Éteindre** — `BLM_LIGHT_OFF` vaut **0**, or protobuf n'émet pas les champs à leur valeur
par défaut. La trame est donc vraisemblablement `08 02 10 03 6A 00` (sous-message vide), et
non `… 6A 02 08 00`. **À vérifier impérativement à la capture** : c'est le seul endroit du
protocole où l'encodage est ambigu.

**Activer un automatisme** (ex. `BLCS_LUMEN_VARY` = 9 à l'état `BSCS_CFG_ON` = 1),
hypothèse à confirmer sur le choix du champ `cfgSet` (10) :

```
08 04 10 03 52 04 08 09 10 01
```

> Toutes ces trames sont déduites du schéma, pas observées. Elles sont à confronter à la
> capture avant d'être écrites en dur dans le code.

---

## 5. Services — `BLE_LIGHT_SERVICE`

| Valeur | Constante | Usage | Fonction du cahier des charges |
|---|---|---|---|
| 0 | `BLS_LIGHT_CFG` | Configuration générale de la lampe | |
| 1 | `BLS_MODE_SUP` | **Modes supportés par ce modèle** | prérequis de F4 |
| 2 | `BLS_MODE_CUR` | **Mode courant** — lecture et écriture | **F3, F4** |
| 3 | `BLS_CUSTOME_MODE` | Modes personnalisés | |
| 4 | `BLS_SMT_CONFIG` | Configuration « intelligente » (automatismes) | **F5, F6** |
| 5 | `BLS_LEFT_TIME` | Autonomie restante, en minutes | bonus utile |
| 6 | `BLS_BAT_PCT` | **Niveau de batterie en %** | **F2, F7** |
| 7 | `BLS_MODE_ENABLE` | Activer/désactiver un mode dans la liste | |
| 8 | `BLS_CONFIG_RESPECTIVE` | Configuration par canal | |
| 9 | `BLS_RIDE_CFG` | Configuration liée au roulage (freinage…) | |

## 6. Opérations — `BLE_LIGHT_OPERATE`

| Valeur | Constante | Sens |
|---|---|---|
| 1 | `BLO_OPERATE_GET` | Lire (central → lampe) |
| 2 | `BLO_OPERATE_NTC` | Notification (lampe → central) |
| 3 | `BLO_OPERATE_ENABLE` | Activer / appliquer |
| 4 | `BLO_OPERATE_DISABLE` | Désactiver |

Séquences attendues :

- **Lire la batterie** → `serviceType = BLS_BAT_PCT (6)`, `operateType = BLO_OPERATE_GET (1)`
  → la lampe répond avec `batPct`.
- **Changer de mode** → `serviceType = BLS_MODE_CUR (2)`,
  `operateType = BLO_OPERATE_ENABLE (3)`, charge utile `curMode = <BLM_*>`.
- **Éteindre** → même chose avec `curMode = BLM_LIGHT_OFF (0)`.

## 7. Modes — `BLE_LIGHT_MODE`

Catalogue commun à toute la gamme. La VS1800S n'en supporte qu'un sous-ensemble, qu'elle
annonce via `BLS_MODE_SUP`.

| Valeur | Constante | Description |
|---|---|---|
| **0** | `BLM_LIGHT_OFF` | **Éteint** |
| 1 | `BLM_HIGH_ALWAYS` | Fixe, intensité haute |
| 2 | `BLM_MID_ALWAYS` | Fixe, intensité moyenne |
| 3 | `BLM_LOW_ALWAYS` | Fixe, intensité basse |
| 4 | `BLM_HIGH_BLINK` | Clignotant, haute |
| 5 | `BLM_LOW_BLINK` | Clignotant, basse |
| 6 | `BLM_GRADIENT` | Dégradé / respiration |
| **7** | `BLM_HBEAM_HSTEADY` | **Feu de route, fixe, haute** |
| **8** | `BLM_HBEAM_MSTEADY` | **Feu de route, fixe, moyenne** |
| **9** | `BLM_HBEAM_LSTEADY` | **Feu de route, fixe, basse** |
| **10** | `BLM_LBEAM_HSTEADY` | **Feu de croisement, fixe, haute** |
| **11** | `BLM_LBEAM_MSTEADY` | **Feu de croisement, fixe, moyenne** |
| **12** | `BLM_LBEAM_LSTEADY` | **Feu de croisement, fixe, basse** |
| 13 | `BLM_ROTATION` | Rotatif (lampes de roue) |
| 14 | `BLM_LEFT_TURN` | Clignotant gauche |
| 15 | `BLM_RIGHT_TURN` | Clignotant droit |
| 16 | `BLM_SUPERHIGH` | Intensité maximale |
| 17 | `BLM_SOS_WARNING` | SOS |
| 18 | `BLM_COMET_FLASH` | Flash « comète » |
| 19 | `BLM_WATERFALL_FLASH` | Flash « cascade » |
| 20 | `BLM_PINWHEEL` | Moulinet |
| 32–41 | `BLM_SPECIAL_1` … `_10` | Modes spéciaux constructeur |
| 64–75 | `BLM_CUSTOMIZE_1` … `_12` | Modes définis par l'utilisateur |

**Les six modes en gras sont ceux qui correspondent au haut et bas faisceau de la VS1800S**
(O4/F4 du cahier des charges), avec trois niveaux d'intensité chacun. C'est exactement la
matrice décrite dans la fiche produit.

## 8. Types de lampe — `BLE_LIGHT_TYPE`

| Valeur | Constante |
|---|---|
| 0 | `BLT_TAIL_LIGHT` |
| **1** | **`BLT_FRONT_LIGHT`** ← la VS1800S |
| 2 | `BLT_HEAD_LIGHT` |
| 3 | `BLT_LEFT_LIGHT` |
| 4 | `BLT_RIGHT_LIGHT` |

Le catalogue complet couvre aussi `TIRE`, `PACK`, `PEDAL`, `FRAME`, `SPOKE`, `RADAR`, `TURN`,
`FLASH` — d'où l'intérêt de l'objectif O7 (généricité) : le protocole est déjà générique, il
n'y a rien de spécifique à faire pour supporter les autres modèles iGPSPORT.

---

## 9. Automatismes et vitesse (O5, O6 / F5, F6)

Les automatismes ne sont pas des messages dédiés : ce sont des **interrupteurs** posés via
`BLS_SMT_CONFIG (4)`, avec un identifiant pris dans `BLE_LIGHT_CONFIG_SUP` et un état pris
dans `BLT_SMT_CFG_STATUS`.

**États** — `BLT_SMT_CFG_STATUS` : `BSCS_CFG_OFF` = 0, `BSCS_CFG_ON` = 1,
**`BSCS_CFG_FOL` = 2 (*follow* — la lampe suit le compteur)**.

**Automatismes disponibles** — `BLE_LIGHT_CONFIG_SUP` (extrait des 22 valeurs) :

| Valeur | Constante | Intérêt pour le projet |
|---|---|---|
| 1 | `BLCS_RIDE_SYNC` | Synchronisation avec l'activité |
| 3 | `BLCS_AUTO_LIGHT` | Allumage automatique |
| 4 | `BLCS_AUTO_SLEEP` | Mise en veille |
| 5 | `BLCS_SYNC_OFF` | **Extinction synchronisée → F6** |
| 8 | `BLCS_AUTO_START` | Allumage au démarrage |
| **9** | **`BLCS_LUMEN_VARY`** | **Luminosité variable → candidat n°1 pour F5** |
| 11 | `BLCS_HL_BEAM` | Gestion haut/bas faisceau |
| 13 | `BLCS_AUTO_LOW` | Passage automatique en bas faisceau |
| 15 | `BLCS_AUTO_LOWBAT` | Repli sur batterie faible |
| 16 | `BLCS_INTELL_SAVING` | Économie intelligente |
| 18 | `BLCS_AUTO_LOOP` | Cycle automatique de modes |
| 2 | `BLCS_BRAKE_LIGHT` | Feu stop (lampes arrière) |

Valeurs restantes : `BLCS_ROUTE` 0, `BLCS_TEAM_RIDE` 6, `BLCS_RADAR` 7, `BLCS_ANGEL_VARY` 10,
`BLCS_AUTO_TURN` 12, `BLCS_SLP_VARY` 14, `BLCS_KNOCK_TRANS` 17, `BLCS_STOP_FLASH` 19,
`BLCS_AD_WARN` 20, `BLCS_RADAR_WARN` 21.

### Ce que l'analyse statique ne tranche pas

**Aucun champ « vitesse » n'apparaît dans les messages de la lampe.** Il faut se méfier d'une
fausse piste : les champs `speCycle`, `speRatio`, `spe_lighten_ratio` et le message
`blt_spe_lightness` contiennent bien `spe`, mais leur contexte (`blt_cus_mode_cfg`,
`blt_cus_mode_modify`) indique **`spe` = *special*, pas *speed*** — ce sont les réglages de
cycle et de rapport cyclique des modes personnalisés.

Deux lectures restent donc ouvertes, et c'est exactement ce que la **session 2** du scénario
de capture (§5 bis de la procédure) doit départager :

- soit le central calcule et envoie des `BLS_MODE_CUR` au fil de l'allure (**cas 1** — F5
  devient presque gratuit sur l'Edge) ;
- soit la vitesse transite par un autre service, commun à tous les périphériques, non couvert
  par `PeripheralLightApp` (**cas 2**).

L'existence de l'état **`BSCS_CFG_FOL` (« follow »)** penche pour un modèle où la lampe
délègue la décision au compteur — donc plutôt le cas 1. À confirmer.

---

## 10. Ce qui reste à établir

| # | Point | Comment | Bloquant pour |
|---|---|---|---|
| 1 | Variante d'UUID exposée par la VS1800S | nRF Connect, 30 s | Connexion |
| 2 | Encodage de l'extinction (`BLM_LIGHT_OFF` = 0) | Capture HCI, étape H | F6 |
| 3 | Imbrication des enveloppes (`blt_message_format` seul ou encapsulé ?) | Capture HCI, une trame suffit | Encodage |
| 4 | Modes réellement supportés | Requête `BLS_MODE_SUP` à la connexion | Choix des modes à proposer |
| 5 | Séquence de connexion, authentification éventuelle | Capture HCI, session 1 | Connexion |
| 6 | Mécanisme de la vitesse | Capture HCI, session 2 | F5 |
| 7 | Connexion centrale unique ? | nRF Connect pendant que l'app est connectée | Test §3 n°4 |

**Tous ces points se règlent avec la lampe en main, en une seule séance de capture.**
L'analyse statique a livré ce qu'elle pouvait livrer.

---

## 11. Conséquences sur la Phase 2

**Il faudra encoder du protobuf en Monkey C.** Il n'existe pas de bibliothèque protobuf pour
Connect IQ. Ce n'est pas un obstacle sérieux : les messages sont minuscules et n'utilisent que
des entiers. Un encodeur *varint* + tags fait quelques dizaines de lignes, et le décodage des
notifications est symétrique. Il faut en revanche le prévoir dans le planning de la Phase 2,
qui l'ignorait.

Le budget Connect IQ est confortable : **une seule connexion**, **un seul profil GATT** à
enregistrer (le service NUS) sur les 3 disponibles, deux caractéristiques.

Mise à jour de la faisabilité annoncée au §5 du cahier des charges :

| ID | Fonction | Faisabilité |
|---|---|---|
| F1 | Appairage BLE | ✅ NUS standard, rien d'exotique |
| F2 | Lecture batterie | ✅ `BLS_BAT_PCT`, et probablement aussi `0x180F` standard |
| F3 | Lecture mode courant | ✅ `BLS_MODE_CUR` + notifications `BLO_OPERATE_NTC` |
| F4 | Changement de mode | ✅ `BLS_MODE_CUR` + `BLO_OPERATE_ENABLE` |
| F5 | Ajustement selon la vitesse | 🟡 mécanisme à confirmer, mais réalisable côté Edge dans tous les cas |
| F6 | Extinction synchronisée | ✅ `BLM_LIGHT_OFF`, ou `BLCS_SYNC_OFF` |
| F7 | Alerte batterie faible | ✅ découle de F2 |
| — | Autonomie restante | ✅ `BLS_LEFT_TIME` — bonus non prévu au cahier des charges |
| O7 | Autres modèles iGPSPORT | ✅ le protocole est déjà générique (`BLE_LIGHT_TYPE`) |

---

## 12. Annexe — jeu `PeripheralLight` (probablement compteur ↔ lampe)

**Modes** `PERIPHERAL_LIGHT_MODE` : `PLM_HIGH_ALWAYS` 1, `PLM_MID_ALWAYS` 2,
`PLM_LOW_ALWAYS` 3, `PLM_HIGH_BLINK` 4, `PLM_LOW_BLINK` 5, `PLM_GRADIENT` 6,
`PLM_CUSTOMIZE` 7, `PLM_LIGHT_OFF` 20.

**Services** `PERIPHERAL_LIGHT_SERVICE` : `PLS_LIGHT_TYPE` 1, `PLS_LIGHT_MODE_SUP` 6,
`PLS_LIGHT_CURRENT` 7, `PLS_LIGHT_CUSTOME` 8, `PLS_CUSTOME_SET` 9,
`PLS_LIGHT_AUTO_CONFIG` 14, `PLS_SLEEP_FOLLOW` 15, `PLS_AUTOLIGHT_FOLLOW` 16, `PLS_SYC_OFF` 17,
`PLS_REMAINING_TIME` 18, `PLS_LIGHT_CFG_SUP` 19.

**Types** `PERIPHERAL_LIGHT_TYPE` : `PLT_TAIL_LIGHT` 1, `PLT_FRONT_LIGHT` 2, `PLT_HEAD_LIGHT` 3,
`PLT_LEFT_LIGHT` 4, `PLT_RIGHT_LIGHT` 5, `PLT_TIRE_LIGHT` 6, `PLT_PACK_LIGHT` 7,
`PLT_PEDAL_LIGHT` 8, `PLT_FRAME_LIGHT` 9, `PLT_SPOKE_LIGHT` 10, `PLT_RADAR_LIGHT` 11.

**Config auto** `AUTO_CONFIG_TYPE` : `INVALID` 0, `FOLLOW` 1, `SELF` 2, `OFF` 3 — la lampe
suit le compteur, décide seule, ou n'a pas d'automatisme.

L'énumération complète des 173 types extraits est dans
`captures/proto-20260908-010029/enums.md`.

---

## 13. Grille de vérification à la capture

À remplir quand la lampe sera là — il ne s'agit plus de découvrir mais de **confirmer**.

| # | À vérifier | Attendu | Observé |
|---|---|---|---|
| 1 | UUID du service | une variante de `6e400001-b5a3-f393-e0a9-e50e24dcca?e` | |
| 1b | Adresse de la lampe | se termine par `C7:C6` (`VS1800S`) ; `C7:C7` est `VS1800S_U`, second mode d'annonce | |
| 2 | CCCD activé sur `…0003` avant les notifications | oui | |
| 3 | 1<sup>re</sup> requête après connexion | `BLS_MODE_SUP` ou `BLS_LIGHT_CFG` | |
| 4 | Handshake / authentification | aucun | |
| 5 | Batterie (étape B) | `BLS_BAT_PCT` → `batPct` = pourcentage affiché par l'app | |
| 5b | Autonomie | `BLS_LEFT_TIME` → `time` = minutes (325 pour 5 h 25) | |
| 6 | Croisement niveau 1 (étape C) | `curMode = 12` (`BLM_LBEAM_LSTEADY`) | |
| 7 | Rejeu du même mode (étape E) | trame **identique** | |
| 8 | Bouton physique (étape I) | notification `BLO_OPERATE_NTC` avec `BLS_MODE_CUR` | |
| 9 | Activation de « Luminosité en fonction de la vitesse » (étape K) | `BLS_SMT_CONFIG` + `BLCS_LUMEN_VARY (9)` + `BSCS_CFG_ON/FOL` | |
| 10 | Trames en roulant (session 2) | — | |
