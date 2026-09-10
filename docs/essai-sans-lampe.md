# Essayer l'application sans la lampe

Le simulateur Connect IQ ne simule pas de périphérique BLE : la couche radio ne peut être
exercée que sur un vrai compteur. Mais rien n'oblige à ce que l'autre bout soit la vraie lampe.

**nRF Connect for Mobile sait jouer un serveur GATT.** En y déclarant le service Nordic UART
de la lampe, votre téléphone devient une VS1800S factice, et l'Edge 1050 s'y connecte comme
au vrai matériel. Toute la chaîne se valide : scan, détection de la variante d'UUID,
enregistrement du profil, appairage, abonnement aux notifications, écriture des commandes,
lecture des réponses.

Ce qui n'est **pas** validé ainsi : que la vraie lampe accepte ces trames. C'est l'objet de la
capture HCI.

---

## 1. Déclarer la fausse lampe dans nRF Connect

Sur le téléphone, onglet **Configure GATT server** (menu latéral) → **Add service**.

**Service** — UUID :

```
6E400001-B5A3-F393-E0A9-E50E24DCCA9E
```

*(la variante `…9E` est le Nordic UART standard ; l'app accepte aussi `6E`, `7E` et `8E`)*

**Caractéristique 1 — TX, ce que l'Edge écrit**

| Champ | Valeur |
|---|---|
| UUID | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` |
| Properties | **Write**, **Write Without Response** |
| Write permission | Allowed |

**Caractéristique 2 — RX, ce que la lampe notifie**

| Champ | Valeur |
|---|---|
| UUID | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` |
| Properties | **Notify** |
| Descriptor | **Client Characteristic Configuration** (`0x2902`) |

> Le descripteur `0x2902` n'est pas optionnel : sans lui l'Edge ne peut pas s'abonner, et
> l'application restera bloquée à « Connexion ».

Puis onglet **Advertiser** → nouvelle configuration :

- **Complete Local Name** : `VS1800S`
- **Complete list of 128-bit Service UUIDs** : le service ci-dessus
- **Connectable** et **Discoverable** activés

Démarrer l'advertising.

> L'annonce du service dans l'advertising est **indispensable** : c'est ainsi que
> `LampManager` identifie la lampe et déduit la variante d'UUID. Une annonce qui ne porte que
> le nom sera ignorée.

## 2. Installer l'application sur l'Edge

```bash
bash app/build.sh edge1050
```

Brancher l'Edge en USB, puis copier `app/bin/edge1050.prg` dans le dossier `GARMIN/Apps` du
compteur. Débrancher, ajouter le champ **Bike Light Control** à un écran de données d'un profil
vélo.

## 3. Ce qu'on doit observer

Démarrer une activité sur l'Edge. Dans l'ordre :

| Étape | Sur l'Edge | Dans nRF Connect |
|---|---|---|
| 1 | « Recherche » | l'advertising est en cours |
| 2 | « Connexion » | une connexion entrante apparaît |
| 3 | « OK » puis `--` | le CCCD passe à `01 00` (abonnement) |
| 4 | — | **quatre écritures** arrivent sur la caractéristique TX |

Les quatre trames attendues, dans cet ordre :

```
08 00 10 01      identite de la lampe
08 01 10 01      modes supportes
08 02 10 01      mode courant
08 06 10 01      batterie
```

Si vous les voyez toutes les quatre, **le socle est validé** : encodage, connexion, file
d'écritures, tout fonctionne.

## 4. Répondre, pour valider la lecture

Dans nRF Connect, sur la caractéristique RX, envoyer une notification avec la valeur :

```
08 06 10 02 7A 02 68 41
```

Le data field doit afficher **65 %**. C'est la trame de test
`parseBatteryNotification` du jeu de tests, jouée pour de vrai.

Autres réponses utiles :

| Valeur à notifier | Effet attendu sur l'écran |
|---|---|
| `08 06 10 02 7A 02 68 41` | batterie 65 % |
| `08 06 10 02 7A 02 68 0F` | batterie 15 %, affichage en rouge |
| `08 02 10 02 6A 02 08 0C` | mode « Croisement - » |
| `08 02 10 02 6A 02 08 07` | mode « Route + » |
| `08 02 10 02 6A 00` | mode « Off » |
| `08 00 10 02 2A 02 08 00` | la lampe se déclare **feu arrière** |

La dernière est intéressante : après elle, l'échelle de modes doit basculer sur les intensités
simples, et le cycle tactile ne doit plus proposer de haut/bas faisceau.

## 5. Valider les automatismes

Sans rouler, l'Edge 1050 permet de simuler une activité ; à défaut, un tour de pâté de maisons
suffit. Ce qu'on vérifie :

- **Au démarrage du chrono**, une commande de mode part immédiatement (allumage doux).
- **En accélérant**, les modes montent — et ne redescendent pas au moindre ralentissement,
  grâce à l'hystérésis.
- **À l'arrêt du chrono**, la trame d'extinction `08 02 10 03 6A 00` part.
- **Une tape sur le champ** (Edge tactile) change le mode et fait apparaître `M ` devant le
  libellé : l'automatisme est suspendu jusqu'à la fin de l'activité.

## 6. Limites de l'exercice

Ce montage ne dit rien de :

- la **variante d'UUID** réellement exposée par la VS1800S ;
- l'**encodage de l'extinction** — c'est vous qui décidez ici ce que la fausse lampe accepte ;
- une éventuelle **authentification** à la connexion ;
- le fait que la lampe n'accepte **qu'une connexion centrale** à la fois.

Ces quatre points restent à confirmer par la capture HCI, procédure dans
[phase1-procedure-capture-ble.md](phase1-procedure-capture-ble.md).
