# Phase 1 — Procédure de capture BLE (iGPSPORT VS1800S)

> Objectif : obtenir **un seul** log HCI exploitable, dans lequel chaque trame peut être
> rattachée sans ambiguïté à une action précise faite dans l'app iGPSPORT.
>
> Le point critique n'est pas la capture (c'est mécanique) mais **le scénario** : un log de
> 20 minutes d'utilisation libre est quasi indéchiffrable, un log de 10 minutes d'actions
> isolées et horodatées se dépouille en une soirée.

---

## 0. Point important avant de commencer

Le journal HCI snoop est capturé **à la frontière hôte/contrôleur**, c'est-à-dire *au-dessus*
de la couche liaison. Conséquence : si la lampe utilise le chiffrement BLE standard
(appairage SMP + link-layer encryption), **cela ne gêne en rien la capture** — vous verrez
les trames ATT en clair.

Le risque « protocole chiffré » du §7 du cahier des charges ne se matérialise donc que si
iGPSPORT a ajouté un chiffrement **applicatif** par-dessus ATT (payloads chiffrés à la clé
dérivée d'un handshake). C'est plus rare sur ce type de produit, et ça se détecte tout de
suite : les payloads d'un même mode rejoué deux fois seront différents (voir §5, test de
déterminisme). C'est précisément pour ça que le scénario impose de rejouer certaines actions.

---

## 1. Matériel et pré-requis

| Élément | Détail |
|---|---|
| Téléphone | Android, options développeur activables. **Éviter Samsung One UI récent** si possible (chemin du log verrouillé) ; un Pixel / Xiaomi / OnePlus est plus simple. |
| App | iGPSPORT installée, lampe **déjà appairée et fonctionnelle** avant la capture |
| Lampe | VS1800S **chargée à ~50–80 %** (voir note §5, étape B) |
| PC | `adb` — déjà installé ici (`C:\Program Files\platform-tools\adb.exe`, v36.0.0) |
| PC | Wireshark ≥ 4.0 — <https://www.wireshark.org/download.html> |
| Optionnel | nRF Connect for Mobile (Nordic), sur le même téléphone ou un second |

Vérifier que le téléphone est bien vu :

```bash
adb devices
```

Si la liste est vide : activer le **débogage USB** dans les options développeur, rebrancher,
et accepter la boîte de dialogue « Autoriser le débogage USB » sur le téléphone.

---

## 2. Activer le journal HCI snoop

1. **Paramètres → À propos du téléphone** → taper 7 fois sur **Numéro de build**.
2. **Paramètres → Système → Options pour les développeurs**.
3. Activer **« Activer le journal de trace Bluetooth HCI »**
   (*Enable Bluetooth HCI snoop log*). Sur certains ROM c'est une liste déroulante :
   choisir **Enabled** / **Filtered = disabled**, surtout pas « Filtered ».
4. **Désactiver puis réactiver le Bluetooth.**
   → Étape obligatoire et systématiquement oubliée : le fichier de log n'est ouvert qu'au
   redémarrage de la pile Bluetooth. Sans ce cycle off/on, la capture sera vide.
5. Redémarrer le téléphone si le ROM l'exige (Android 12+ le demande parfois).

Contrôle rapide que le log tourne :

```bash
adb shell "ls -l /sdcard/btsnoop_hci.log /data/misc/bluetooth/logs/btsnoop_hci.log 2>/dev/null"
```

Si rien ne sort, ce n'est pas grave : sur Android 8+ le fichier est dans une zone protégée
et ne sera récupérable que via `bugreport` (§4). Le seul vrai contrôle, c'est la taille du
fichier extrait à la fin.

---

## 3. Hygiène de capture

Le log HCI capture **tout** le Bluetooth du téléphone. Pour éviter de noyer la lampe :

- Couper le Wi-Fi (pas indispensable mais réduit le bruit sur certaines puces combo).
- **Déconnecter / éteindre tous les autres périphériques BLE** : montre, écouteurs,
  capteurs, voiture, balances. Idéalement, oublier temporairement les écouteurs.
- Fermer les apps qui scannent en fond (Garmin Connect, Strava, Google Fit, Find My Device).
- Mode avion **non**, on a besoin du BT ; mais mode « Ne pas déranger » pour éviter les
  notifications qui réveillent une montre.

Puis **redémarrer le Bluetooth une dernière fois** juste avant l'étape 5 pour repartir d'un
log propre.

---

## 4. Récupérer le log

Méthode recommandée, fonctionne sans root sur la grande majorité des appareils :

```bash
bash tools/pull-btsnoop.sh
```

Le script tente dans l'ordre : chemins directs sur `/sdcard`, puis extraction depuis un
`adb bugreport`. Il dépose le résultat dans `captures/<horodatage>/btsnoop_hci.log`.

Manuellement, l'équivalent est :

```bash
adb bugreport captures/bugreport.zip
```

puis extraire de l'archive le fichier `FS/data/misc/bluetooth/logs/btsnoop_hci.log`
(parfois `btsnoop_hci.log.last` — prendre les deux si présents).

> **Ne récupérez le log qu'après avoir désactivé le Bluetooth** en fin de scénario : ça force
> le vidage du tampon d'écriture. Un log récupéré « à chaud » perd souvent les dernières
> secondes.

---

## 5. Le scénario de capture

Imprimez ou ouvrez [phase1-journal-capture.md](phase1-journal-capture.md) et **notez l'heure
(mm:ss) et le libellé exact affiché par l'app** à chaque étape. Sans ce journal, le log est
inexploitable.

Règles à respecter :

- **Une action, puis 10 secondes d'immobilité.** Les silences créent des trous visibles dans
  le log qui servent de repères pour recaler vos notes.
- **Ne touchez à rien d'autre** pendant les pauses (pas de scroll dans l'app, pas de retour
  à l'écran d'accueil).
- Suivez l'ordre ci-dessous : il est construit pour permettre une analyse différentielle
  (deux trames qui ne diffèrent que par un octet identifient ce champ).

### Déroulé

| # | Action | Ce qu'on cherche à isoler |
|---|---|---|
| **A** | Lampe éteinte. Lancer l'app. Allumer la lampe (bouton physique). Laisser l'app se connecter seule. | Découverte GATT complète, handshake initial éventuel |
| **B** | Attendre l'affichage du niveau de batterie. **Noter le % exact affiché.** | Caractéristique batterie + encodage de la valeur |
| **C** | Passer en **feu de croisement, niveau 1**. Attendre 10 s. | Trame de commande « mode » |
| **D** | Niveau 2. 10 s. Puis niveau 3. 10 s. | Champ luminosité (analyse différentielle sur C/D) |
| **E** | **Revenir au niveau 1.** 10 s. | **Test de déterminisme** : trame identique à C ⇒ pas de chiffrement applicatif ni de compteur. Trame différente ⇒ compteur, nonce ou checksum dynamique. |
| **F** | Passer en **feu de route** (haut faisceau), chaque niveau, 10 s entre chaque. | Champ « faisceau » vs champ « niveau » |
| **G** | Mode **flash / clignotant**, chaque variante, 10 s. | Table des modes |
| **H** | **Éteindre la lampe depuis l'app.** 10 s. Rallumer depuis l'app. 10 s. | Commande on/off (F6 du cahier des charges) |
| **I** | **Appuyer sur le bouton physique** de la lampe pour changer de mode. 10 s. | **Notifications montantes** — c'est ce qui permettra F3 (lecture du mode courant). Si rien ne remonte ici, l'affichage d'état sur l'Edge sera dégradé. |
| **J** | Ne rien faire pendant **60 secondes**, app à l'écran. | Keep-alive, notifications périodiques de batterie |
| **K** | **Configuration de la fonction intelligente → activer « Luminosité en fonction de la vitesse »**. 10 s. | Commande d'activation, attendue : `BLS_SMT_CONFIG` + `BLCS_LUMEN_VARY (9)`. ⚠️ À l'arrêt, ne révèle *pas* le mécanisme — voir §5 bis |
| **L** | Désactiver ce même réglage. 10 s. | La même trame avec `BSCS_CFG_OFF` — analyse différentielle immédiate |
| **K2** | Basculer aussi **« Lumière intelligente »**, puis la remettre. 10 s entre chaque. | Identifie `BLCS_AUTO_LIGHT (3)` par différence avec K |
| **M** | Fermer l'app (swipe). 10 s. Éteindre la lampe (bouton). 10 s. | Déconnexion propre, éventuelle commande de fin de session |
| **N** | **Désactiver le Bluetooth du téléphone.** | Vidage du tampon de log |

Durée totale ≈ 8–12 minutes.

**Note sur l'étape B** : capturer avec une batterie ni pleine ni vide est délibéré. À 100 %
on ne distingue pas `0x64` (=100 en pourcentage) d'un octet de statut ; à ~65 % la valeur
`0x41` saute aux yeux et lève l'ambiguïté immédiatement.

---

## 5 bis. Capture dédiée au mode « ajustement selon la vitesse »

Cette fonction est la seule du cahier des charges (**O6 / F5**) qu'un scénario statique ne
peut pas documenter, et c'est aussi celle dont dépend le plus le confort d'usage. Elle mérite
sa propre capture.

### Pourquoi une capture séparée

La VS1800S n'a **ni GPS ni accéléromètre**. Si sa luminosité s'ajuste à la vitesse, il n'y a
que deux architectures possibles, et elles n'impliquent pas du tout le même travail en Phase 2 :

| Hypothèse | Ce qu'on verra dans le log | Conséquence pour l'app Connect IQ |
|---|---|---|
| **(1) Le téléphone décide** — il lit sa propre vitesse GPS et envoie les mêmes commandes de mode qu'en manuel | En roulant : des trames **identiques à celles des étapes C–G**, émises aux changements d'allure uniquement | **Le meilleur cas de loin.** Aucune connaissance protocolaire supplémentaire n'est requise : l'Edge connaît déjà sa vitesse (`Activity.getActivityInfo().currentSpeed`) et n'a qu'à réutiliser les commandes de mode déjà décodées. F5 devient quasi gratuit, et *mieux* qu'avec l'app iGPSPORT — la vitesse d'un Edge (capteur de vitesse ou GPS de compteur) est plus fiable que celle d'un GPS de smartphone en poche. |
| **(2) La lampe décide** — le téléphone lui pousse périodiquement la vitesse, la lampe applique ses propres seuils | En roulant : une trame **périodique** (typiquement toutes les 1 à 5 s) dont **un champ varie de façon monotone avec l'allure** | Il faut décoder l'encodage de la vitesse (unité, échelle, endianness). Faisable, mais c'est un champ supplémentaire à valider. En contrepartie, les seuils restent gérés par la lampe. |

Un troisième cas est possible : le mode auto n'existe tout simplement pas côté vitesse, et ne
concerne que la luminosité ambiante (capteur de lumière embarqué). Dans ce cas, aucune trame
n'accompagne les variations d'allure, et **F5 est à implémenter intégralement côté Edge** —
ce qui reste faisable, puisque cela revient au cas (1).

### Option A — capture en roulant (la plus fidèle)

Téléphone en poche ou sur le cintre, app iGPSPORT ouverte au premier plan, lampe allumée et
**mode auto activé**. Le journal HCI continue de tourner sans le PC.

1. Noter l'heure de départ à la seconde près.
2. **Arrêt complet, 60 s** (repère de référence à 0 km/h).
3. Rouler **très lentement**, ~8 km/h, 60 s.
4. Rouler à ~20 km/h, 60 s.
5. Rouler à ~35 km/h si possible, 60 s.
6. **Arrêt complet, 60 s.**
7. Une accélération franche puis un freinage franc, pour créer une transition nette.
8. Rentrer, désactiver le Bluetooth, récupérer le log (§4).

Les paliers de 60 s sont volontairement longs : ils permettent de repérer une trame
périodique et de corréler la valeur d'un octet à un palier de vitesse connu. Notez les
vitesses **telles qu'affichées par l'app ou un compteur**, pas au ressenti.

### Option B — sans sortir, en simulant la vitesse

Si le mode auto de l'app s'appuie sur le GPS du téléphone (le plus probable), on peut le
tromper sans bouger :

1. Installer une app de position fictive (*mock location*), par ex. « Lockito ».
2. **Options développeur → Sélectionner l'application de position fictive** → la choisir.
3. Y créer un trajet avec des paliers de vitesse (0 / 8 / 20 / 35 km/h), le rejouer pendant
   que l'app iGPSPORT tourne au premier plan avec le mode auto actif.
4. Récupérer le log.

Moins fidèle (certaines apps ignorent les positions fictives), mais rejouable à volonté et
sans météo. **Si l'option B ne produit aucune trame, cela ne prouve rien** — il faut alors
faire l'option A avant de conclure.

### Ce qu'il faut en extraire

À reporter dans la section 5 de [protocole-vs1800s.md](protocole-vs1800s.md) :

- Y a-t-il des trames pendant les paliers de vitesse stable ? Si non → cas (1).
- Si oui : période d'émission, handle utilisé, et **valeur du payload à chaque palier**.
  Avec quatre paliers connus (0 / 8 / 20 / 35), l'encodage se déduit presque toujours
  directement : chercher un champ 8 ou 16 bits proportionnel. Tester les unités usuelles —
  km/h entier, km/h ×10, m/s ×100, cm/s.
- Les commandes envoyées en mode auto sont-elles **les mêmes** que celles des étapes C–G ?
  C'est le test qui tranche entre (1) et (2).

### Retombée sur le cahier des charges

Quelle que soit l'issue, **F5 est réalisable sur l'Edge** : la vitesse y est disponible en
permanence via l'API `Toybox.Activity`, sans dépendre de la lampe. Le cas (1) rend la
fonction presque gratuite une fois les commandes de mode connues. Sur cette base, F5 mérite
d'être remonté de « Could have » à **« Should have »** dans le cahier des charges — c'est
même l'argument principal de l'app face à un simple pilotage manuel.

---

### Complément fortement recommandé : nRF Connect

Après avoir récupéré le log, faites une seconde session, **app iGPSPORT fermée et forcée à
l'arrêt** :

1. nRF Connect → Scan → repérer la lampe (nom du type `VS1800S`, `iGPSPORT…`).
2. **Noter l'adresse MAC** et le contenu des données d'advertising (Manufacturer Data).
3. Connect → **capture d'écran de l'arbre GATT complet** : chaque service, chaque
   caractéristique, ses propriétés (Read / Write / Write No Response / Notify / Indicate).
4. Tenter un `Read` sur toute caractéristique lisible et noter les valeurs.

L'arbre GATT de nRF Connect vous donne la **structure** en 2 minutes, lisiblement, là où le
log HCI vous donne la **sémantique**. Les deux sont complémentaires — ne sautez pas celui-ci,
il fait gagner des heures de dépouillement.

> La lampe n'accepte très probablement **qu'une seule connexion centrale à la fois**. Si
> nRF Connect ne voit pas la lampe ou n'arrive pas à se connecter, c'est que l'app iGPSPORT
> est encore connectée en arrière-plan : forcer l'arrêt de l'app, voire redémarrer la lampe.

---

## 6. Dépouillement dans Wireshark

Ouvrir `captures/<horodatage>/btsnoop_hci.log` (Wireshark reconnaît le format nativement).

### 6.1 Identifier la lampe

Repérer d'abord son adresse. Filtre sur les rapports d'advertising :

```
bthci_evt.le_meta_subevent == 0x02
```

Chercher dans les résultats le nom du périphérique (colonne Info, ou champ
`btcommon.eir_ad.entry.device_name`). Noter la **BD_ADDR**.

Puis n'afficher que le trafic de la lampe :

```
bluetooth.addr == aa:bb:cc:dd:ee:ff
```

*(remplacer par la MAC relevée — à partir d'ici, garder ce filtre combiné avec les suivants
par `&&`)*

### 6.2 Extraire la table GATT

Le raccourci qui évite tout travail manuel :

> **Statistics → Bluetooth ATT Server Attributes**

Wireshark reconstruit la table complète handle → UUID → nom à partir des réponses de
découverte. C'est cette table qu'il faut recopier dans
[protocole-vs1800s.md](protocole-vs1800s.md), section 2.

Si la fenêtre est vide (découverte absente du log), reconstruire à la main :

```
btatt.opcode == 0x11 || btatt.opcode == 0x09 || btatt.opcode == 0x05
```

| Opcode | Signification |
|---|---|
| `0x11` | Read By Group Type Response → **services primaires** |
| `0x09` | Read By Type Response → **déclarations de caractéristiques** (UUID + handle de valeur + propriétés) |
| `0x05` | Find Information Response → **descripteurs** (dont les CCCD 0x2902) |

### 6.3 Isoler le trafic utile

```
btatt.opcode == 0x12 || btatt.opcode == 0x52 || btatt.opcode == 0x1b || btatt.opcode == 0x1d || btatt.opcode == 0x0b
```

| Opcode | Sens | Signification |
|---|---|---|
| `0x12` | ⬆ téléphone → lampe | Write Request (commande, avec accusé) |
| `0x52` | ⬆ téléphone → lampe | Write Command (commande, sans accusé) |
| `0x1b` | ⬇ lampe → téléphone | **Handle Value Notification** — état, batterie |
| `0x1d` | ⬇ lampe → téléphone | Indication |
| `0x0b` | ⬇ lampe → téléphone | Read Response |

Ajouter les colonnes utiles : clic droit sur un champ → *Apply as Column* pour
`btatt.handle` et `btatt.value`. Vous obtenez une vue tabulaire directement recopiable dans
la grille de dépouillement.

Astuce : *File → Export Packet Dissections → As CSV* avec le filtre d'affichage actif, pour
travailler la liste des trames dans un tableur.

### 6.4 Vérifier le chiffrement (§7 du cahier des charges)

- Appairage SMP présent ? → filtre `btsmp`
- Chiffrement liaison activé ? → `bthci_evt.code == 0x08` (Encryption Change)

Rappel du §0 : **ni l'un ni l'autre ne bloque l'analyse**. Le verdict se lit à l'étape E du
scénario :

| Observation à l'étape E | Conclusion |
|---|---|
| Trame **identique** à celle de l'étape C | Protocole en clair et déterministe → **feu vert Phase 2** |
| Trame différente d'un ou deux octets seulement | Compteur de séquence ou checksum → analysable, prévoir +2 à 5 jours |
| Trame **entièrement différente** | Chiffrement applicatif → passer par l'analyse de l'APK avant tout développement |

### 6.5 Décoder le format des trames

Une fois les payloads en main, les hypothèses à tester dans l'ordre (par fréquence sur ce
type de matériel) :

1. **Trame courte non structurée** : 1 à 3 octets, du type `[cmd][valeur]`.
2. **Trame à en-tête** : `[préambule][longueur][commande][données…][checksum]`.
   Préambules classiques : `0xAA`, `0x55`, `0xA5`, `0x5A`, `0xFE`.
3. **Checksum** : tester dans l'ordre XOR de tous les octets précédents, somme tronquée à
   8 bits, somme + 1, CRC-8. Se vérifie sur deux trames connues.
4. **Texte ASCII** : certains modules exposent un service type UART et acceptent des
   commandes textuelles. Si les payloads sont dans la plage `0x20–0x7E`, c'est la piste.

Services à repérer en priorité dans l'arbre GATT :

| UUID | Ce que c'est | Intérêt |
|---|---|---|
| `0x180F` / `0x2A19` | Battery Service / Battery Level | **F2 gratuit** — 1 octet = pourcentage, standard |
| `0x180A` | Device Information | Version firmware, utile pour §7 (versionner le protocole) |
| `6E400001-B5A3-F393-E0A9-E50E24DCCA9E` | Nordic UART Service | Très fréquent. TX `…0002` (write), RX `…0003` (notify) |
| `0xFFE0` / `0xFFE1` | Module TI CC254x | Idem, transport transparent |
| `0xFFF0`, `0xFD..`, UUID 128 bits maison | Service propriétaire | Le cœur du protocole |

Si `0x180F` est présent, **F2 (lecture batterie) est acquis dès maintenant**, indépendamment
du reste : c'est un profil standard, directement exploitable par `Toybox.BluetoothLowEnergy`.
C'est le premier résultat à vérifier, car il sécurise à lui seul un des trois « Must have ».

---

## 7. Livrable de la phase

Remplir [protocole-vs1800s.md](protocole-vs1800s.md) et archiver dans `captures/` :

- `btsnoop_hci.log`
- le journal de capture rempli (heures + libellés app)
- les captures d'écran nRF Connect de l'arbre GATT
- l'export CSV du filtre §6.3

Ces quatre éléments suffisent à reprendre l'analyse plus tard, ou à la confier à quelqu'un
d'autre, sans refaire la manip.

---

## 8. Si ça ne marche pas

| Symptôme | Cause probable / remède |
|---|---|
| `btsnoop_hci.log` absent ou vide | Cycle Bluetooth off/on non fait après activation de l'option. Recommencer §2.4. |
| Log présent mais aucune trame ATT | Option réglée sur « Filtered ». La passer sur « Enabled ». |
| Fichier introuvable sur `/sdcard` | Normal sur Android 8+. Passer par `adb bugreport` (§4). |
| Log énorme, illisible | Hygiène §3 non appliquée : trop de périphériques BLE actifs. Refaire. |
| Samsung récent, chemin verrouillé | Composer `*#9900#` → *Run dumpstate/logcat* → *Copy to sdcard*, puis récupérer le dossier `log`. |
| Trames présentes mais aucune ne correspond aux actions | Vérifier que le filtre MAC cible bien la lampe et pas la montre. Retirer le filtre et re-chercher l'advertising. |
