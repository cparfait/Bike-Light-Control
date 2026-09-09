# Compatibilité des compteurs Edge

**Vérifié le 08/09/2026 contre le SDK Connect IQ 9.2.0 installé localement**, et non d'après
la documentation en ligne : pour chaque profil d'appareil, on cherche la présence effective
des méthodes du rôle central BLE (`setScanState`, `registerProfile`) dans sa définition d'API
(`<appareil>.api.debug.xml`).

## Résultat

| Modèle | Profil SDK | Central BLE | CIQ | Data field |
|---|---|---|---|---|
| Edge 530 | `edge530` | ✅ | 3.3.1 | 128 Ko |
| Edge 540 / 540 Solar | `edge540` | ✅ | 6.0.0 | 128 Ko |
| Edge 550 | `edge550` | ✅ | 6.0.0 | 128 Ko |
| Edge 830 | `edge830` | ✅ | 3.3.1 | 128 Ko |
| Edge 840 / 840 Solar | `edge840` | ✅ | 6.0.0 | 128 Ko |
| Edge 850 | `edge850` | ✅ | 6.0.0 | 128 Ko |
| Edge 1030 | `edge1030` | ✅ | 3.2.5 | 128 Ko |
| Edge 1030 Plus | `edge1030plus` | ✅ | 3.3.1 | 128 Ko |
| Edge 1040 / 1040 Solar | `edge1040` | ✅ | 6.0.0 | 128 Ko |
| **Edge 1050** *(cible)* | `edge1050` | ✅ | 6.0.0 | 128 Ko |
| Edge Explore | `edgeexplore` | ✅ | 3.1.3 | 128 Ko |
| Edge Explore 2 | `edgeexplore2` | ✅ | 5.1.0 | 128 Ko |
| Edge MTB | `edgemtb` | ✅ | 6.0.0 | 128 Ko |
| Edge 1030 Bontrager | `edge1030bontrager` | ❌ | 3.3.1 | 128 Ko |
| Edge 820 | `edge820` | ❌ | 2.4.1 | 128 Ko |
| Edge 520 Plus | `edge520plus` | ❌ | 3.1.3 | 128 Ko |
| Edge 520 | `edge_520` | ❌ | 2.4.1 | 32 Ko |
| Edge 1000 | `edge_1000` | ❌ | 2.4.1 | 128 Ko |
| Edge 130 / 130 Plus | `edge130`, `edge130plus` | ❌ | 3.1–3.2 | 32 Ko |

**13 modèles cibles.** Les exclus n'ont pas l'API : ce n'est pas une limite de développement,
le module n'existe pas sur ces appareils. C'est aussi la raison pour laquelle les feux Varia
passent par ANT+, que les anciens Edge savent piloter.

### Deux surprises

**L'Edge 1030 Bontrager est exclu alors que l'Edge 1030 standard est compatible.** Même
génération, même version Connect IQ, mais sa définition d'API ne contient aucune méthode du
rôle central. À ne pas annoncer comme supporté.

**La compilation ne filtre pas.** Un data field déclarant la permission `BluetoothLowEnergy`
compile sans erreur pour l'Edge 820 ou l'Edge 130, qui ne savent pourtant pas l'exécuter.
Le compilateur ne rejette que l'`minApiLevel` (seuls `edge_520` et `edge_1000` échouent à
`3.1.0`). **La liste des `<iq:product>` du manifeste doit donc être écrite à la main** à
partir du tableau ci-dessus ; on ne peut pas compter sur le compilateur pour la valider.

## Mémoire

Uniforme sur les 13 cibles : **128 Ko en data field**, 1 Mo en application, 64 Ko en glance
(sur les modèles CIQ 5+ uniquement). Aucune disparité à gérer, contrairement à ce qu'on
pouvait craindre : un code qui tient sur un Edge 1050 tient sur un Edge 530.

## Tactile

**Le SDK n'expose pas cette caractéristique dans les profils d'appareil** — ni dans
`compiler.json`, ni dans `simulator.json`. C'est une propriété d'exécution, à lire via
`System.getDeviceSettings().isTouchScreen`.

Conséquence de conception : ne pas brancher à la compilation, mais **au runtime**. Le data
field propose le changement de mode par `onTap()` si l'écran est tactile, et se limite à
l'affichage plus l'automatisme sinon — le pilotage manuel passant alors par le widget
compagnon. Un seul binaire, pas de variantes par modèle.

Rappel : `onTap()` ne fonctionne qu'avec la classe `DataField` complète, jamais avec
`SimpleDataField`.

## Comment refaire cette vérification

Après chaque mise à jour du SDK, ou pour vérifier un modèle sorti depuis :

```bash
bash tools/check-ble-devices.sh
```
