# Journal de capture — session du ____/____/________

> À remplir **pendant** la manip, pas après. Sans les heures, le log HCI n'est pas exploitable.
> Une horloge à la seconde sous les yeux (celle du téléphone fait l'affaire).

## Contexte de la session

| Champ | Valeur |
|---|---|
| Téléphone (modèle / version Android) | |
| Version de l'app iGPSPORT | |
| Version firmware de la lampe (écran principal de l'app) | |
| **Niveau de batterie affiché au début** | ________ % |
| **Autonomie annoncée au début** | ______ h ______ min |
| Autres périphériques BLE laissés actifs | |
| Heure de référence au démarrage (hh:mm:ss) | |
| Adresse MAC de la lampe (si connue) | |

---

## Session 1 — scénario statique

| # | Action | Heure (mm:ss) | Libellé **exact** affiché par l'app | Observations |
|---|---|---|---|---|
| A | Allumage lampe + connexion auto | | | |
| B | Lecture batterie | | ________ % | |
| C | Croisement niveau 1 | | | |
| D | Croisement niveau 2 | | | |
| D | Croisement niveau 3 | | | |
| E | **Retour croisement niveau 1** | | | *test de déterminisme* |
| F | Route (haut faisceau) niveau 1 | | | |
| F | Route niveau 2 | | | |
| F | Route niveau 3 | | | |
| G | Flash / clignotant — variante 1 | | | |
| G | Flash / clignotant — variante 2 | | | |
| H | Extinction depuis l'app | | | |
| H | Rallumage depuis l'app | | | |
| I | **Bouton physique** sur la lampe | | mode obtenu : | l'app suit-elle ? ☐ oui ☐ non |
| J | Repos 60 s, ne rien toucher | | — | |
| K | Activer « Luminosité en fonction de la vitesse » | | | |
| L | Désactiver « Luminosité en fonction de la vitesse » | | | |
| K2 | Activer « Lumière intelligente » | | | |
| K2 | Désactiver « Lumière intelligente » | | | |
| M | Fermeture de l'app | | — | |
| M | Extinction lampe (bouton) | | — | |
| N | Bluetooth du téléphone désactivé | | — | |

Modes supplémentaires proposés par l'app et non listés ci-dessus (en ajouter autant que
nécessaire, toujours avec 10 s de pause entre chaque) :

| Mode | Heure (mm:ss) | Libellé exact |
|---|---|---|
| | | |
| | | |
| | | |

---

## Session 2 — mode automatique / vitesse

Méthode employée : ☐ A, en roulant ☐ B, position fictive (mock location)

Mode auto activé et confirmé actif dans l'app avant le départ : ☐ oui

| Palier | Vitesse visée | Heure début (mm:ss) | Heure fin (mm:ss) | Vitesse réellement affichée | La lampe a-t-elle changé d'intensité ? |
|---|---|---|---|---|---|
| 1 | **arrêt, 0 km/h** | | | | |
| 2 | ~8 km/h | | | | |
| 3 | ~20 km/h | | | | |
| 4 | ~35 km/h | | | | |
| 5 | **arrêt, 0 km/h** | | | | |
| 6 | accélération franche | | | | |
| 7 | freinage franc | | | | |

Observations libres (à quel moment précis l'intensité a-t-elle changé ? y a-t-il une
hystérésis, un délai ?) :

```



```

---

## Session 3 — arbre GATT (nRF Connect)

App iGPSPORT **forcée à l'arrêt** avant de commencer : ☐ oui

| Champ | Valeur |
|---|---|
| Nom annoncé (advertising) | |
| Adresse MAC | |
| Manufacturer Data de l'advertising (hex) | |
| Nombre de services découverts | |
| Captures d'écran de l'arbre GATT enregistrées dans `captures/` | ☐ |
| Service `0x180F` (Battery) présent ? | ☐ oui ☐ non |
| Service `0x180A` (Device Information) présent ? | ☐ oui ☐ non |
| Service Nordic UART (`6E400001-…`) présent ? | ☐ oui ☐ non |

Valeurs lues (`Read`) sur les caractéristiques lisibles :

| Handle / UUID | Valeur hex | Interprétation supposée |
|---|---|---|
| | | |
| | | |
| | | |

---

## Fichiers produits

- [ ] `captures/<horodatage>/btsnoop_hci.log` — session 1
- [ ] `captures/<horodatage>/btsnoop_hci.log` — session 2 (vitesse)
- [ ] Captures d'écran nRF Connect
- [ ] Ce journal, rempli
