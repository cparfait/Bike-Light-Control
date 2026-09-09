# Cahier des charges

## Intégration de la lampe iGPSPORT VS1800S avec l'écosystème Garmin Edge via une application Connect IQ

---

## 1. Contexte

La lampe avant **iGPSPORT VS1800S** (1800 lumens) communique en Bluetooth Low Energy (BLE) avec l'application mobile iGPSPORT et les compteurs de la même marque (iGS630, iGS800...). Elle n'offre aucune intégration native avec les compteurs **Garmin Edge**, qui utilisent principalement le protocole ANT+ Light Network pour piloter des feux tiers (Varia, Giant Recon, Magene...).

L'objectif du projet est de développer une **application Connect IQ** (widget ou data field) permettant de :
- afficher l'état de la lampe (niveau de batterie, mode actif) sur l'écran d'un Edge Garmin ;
- piloter les modes de la lampe (haut/bas faisceau, luminosité) depuis le compteur ;
- reproduire, dans la mesure du possible, les automatismes déjà présents dans l'app iGPSPORT (allumage/extinction, ajustement selon la vitesse).

Il n'existe aujourd'hui aucune passerelle officielle ni communautaire connue entre les feux iGPSPORT et Garmin Connect IQ.

---

## 2. Objectifs du projet

| # | Objectif | Priorité |
|---|----------|----------|
| O1 | Identifier et documenter le protocole BLE (GATT) de la VS1800S | Must have |
| O2 | Développer une app Connect IQ capable de se connecter à la lampe en BLE | Must have |
| O3 | Afficher l'état de la lampe (batterie, mode) sur l'écran de l'Edge | Must have |
| O4 | Permettre le changement de mode/luminosité depuis l'Edge | Should have |
| O5 | Reproduire l'allumage/extinction automatique synchronisé avec le compteur | Should have |
| O6 | Reproduire l'ajustement de luminosité selon la vitesse | Could have |
| O7 | Rendre l'app générique pour supporter d'autres modèles iGPSPORT (VS800S, VS1200S) | Could have |
| O8 | Publier l'app sur le Connect IQ Store ou la partager en open source | Could have |

---

## 3. Périmètre

### Inclus
- Rétro-ingénierie du protocole BLE de la VS1800S.
- Développement d'une application Connect IQ en Monkey C.
- Tests sur au moins un modèle d'Edge compatible BLE central (voir §6).
- Documentation technique du protocole et du code.

### Exclus
- Modification ou reverse engineering du firmware interne de la lampe.
- Support des lampes arrière (TL30) — à envisager dans une V2 si le projet aboutit.
- Portage sur montres Garmin (Fenix, Forerunner) — l'usage cible est un compteur Edge.
- Garantie de compatibilité si iGPSPORT modifie son protocole via une mise à jour firmware.

---

## 4. Phases du projet

### Phase 1 — Rétro-ingénierie du protocole BLE (bloquante)
Objectif : comprendre comment l'app iGPSPORT communique avec la lampe.

**Tâches :**
1. Capturer le trafic BLE entre un smartphone Android et la VS1800S (HCI snoop log) pendant un appairage et plusieurs changements de mode.
2. Analyser les logs avec Wireshark pour identifier :
   - les services et caractéristiques GATT exposés,
   - les UUID utilisés,
   - le format des trames envoyées/reçues (mode, luminosité, batterie).
3. Décompiler ou inspecter l'APK de l'app iGPSPORT (analyse statique) pour retrouver, si besoin, la logique d'encodage des commandes.
4. Vérifier si les échanges sont chiffrés ou en clair.
5. Documenter le protocole trouvé (tableau services/caractéristiques/valeurs).

**Livrable :** document de référence du protocole BLE (aucune garantie de résultat — voir §8, risques).

### Phase 2 — Développement de l'application Connect IQ
1. Mise en place de l'environnement (SDK Connect IQ, VS Code + extension Monkey C, simulateur).
2. Implémentation de la connexion BLE centrale depuis l'app (`Toybox.BluetoothLowEnergy`).
3. Implémentation de la lecture des caractéristiques (batterie, mode).
4. Implémentation de l'écriture des commandes (changement de mode/luminosité).
5. Interface utilisateur minimale (data field ou widget affichant l'état, écran de sélection de mode).
6. Gestion des erreurs (perte de connexion, lampe hors tension, échec de pairing).

**Livrable :** application Connect IQ fonctionnelle (fichier `.prg`/`.iq`), code source.

### Phase 3 — Tests
1. Tests unitaires en simulateur (mock du périphérique BLE si possible).
2. Tests terrain sur au moins un Edge réel et la VS1800S.
3. Tests de robustesse : perte de signal, redémarrage de la lampe, batterie faible.
4. Test de non-régression sur l'app mobile iGPSPORT (vérifier qu'elle continue de fonctionner en parallèle).

**Livrable :** rapport de tests, liste des bugs connus.

### Phase 4 — Publication / diffusion
1. Rédaction de la documentation utilisateur.
2. Choix du mode de diffusion : sideload personnel, partage GitHub, ou soumission au Connect IQ Store.
3. Mise en place d'un espace de retour (issues GitHub) si diffusion communautaire.

**Livrable :** app publiée ou partagée + documentation.

---

## 5. Spécifications fonctionnelles

| ID | Fonction | Description |
|----|----------|--------------|
| F1 | Appairage BLE | L'app détecte et se connecte à la VS1800S depuis l'Edge |
| F2 | Lecture batterie | Affichage du % de batterie restant sur l'écran |
| F3 | Lecture mode courant | Affichage du mode actif (haut/bas faisceau, luminosité) |
| F4 | Changement de mode | Sélection manuelle du mode depuis l'Edge |
| F5 | Mode auto vitesse | Ajustement automatique de la luminosité selon la vitesse (optionnel, Phase 2+) |
| F6 | Extinction synchronisée | Extinction de la lampe à l'arrêt de l'activité sur l'Edge |
| F7 | Alerte batterie faible | Notification sur l'écran si batterie < seuil configurable |

---

## 6. Contraintes techniques

- **Langage :** Monkey C (SDK Connect IQ ≥ 3.2, requis pour l'API BLE centrale).
- **Compatibilité matérielle :** vérifier que le modèle d'Edge cible supporte le rôle **BLE central personnalisé** (tous les Edge ne l'exposent pas aux apps tierces — à valider modèle par modèle avant de démarrer).
- **Protocole radio :** BLE uniquement (la VS1800S n'est pas ANT+, contrairement à Varia/Giant/Magene).
- **Chiffrement éventuel :** si le protocole de la lampe est chiffré ou signé, le projet peut être bloqué en Phase 1 — prévoir ce risque dans le planning.
- **Environnement de dev :** SDK Connect IQ, simulateur Garmin, VS Code + extension Monkey C, compte développeur Garmin (gratuit) si publication visée.
- **Outils de capture BLE :** téléphone Android avec option développeur "HCI snoop log" activable, Wireshark, éventuellement nRF Connect pour exploration manuelle des services GATT.

---

## 7. Risques et points de vigilance

| Risque | Impact | Mitigation |
|--------|--------|-----------|
| Protocole BLE chiffré/obfusqué | Bloquant | Étudier en priorité en Phase 1 avant d'investir en développement |
| API Connect IQ BLE non disponible sur le modèle d'Edge visé | Bloquant | Vérifier la compatibilité du modèle avant de démarrer |
| Mise à jour firmware iGPSPORT changeant le protocole | Maintenance récurrente | Documenter et versionner le protocole observé |
| Temps de rétro-ingénierie sous-estimé | Retard planning | Prévoir une phase d'exploration non bornée avant de figer un planning de développement |
| Usage non prévu par le fabricant (garantie, support) | Risque limité | Projet à usage personnel/communautaire, pas de modification du firmware de la lampe |

---

## 8. Livrables finaux

1. Document de rétro-ingénierie du protocole BLE de la VS1800S.
2. Code source de l'application Connect IQ (dépôt Git).
3. Application compilée et testée.
4. Documentation utilisateur (installation, usage, limitations connues).
5. Rapport de tests.

---

## 9. Planning indicatif

| Phase | Durée estimée* |
|-------|----------------|
| Phase 1 — Rétro-ingénierie | 1 à 4 semaines (dépend fortement du protocole) |
| Phase 2 — Développement | 2 à 6 semaines |
| Phase 3 — Tests | 1 à 2 semaines |
| Phase 4 — Publication | 1 semaine |

*Estimation grossière pour un développeur solo travaillant sur son temps libre ; à ajuster selon disponibilité et résultats de la Phase 1.

---

## 10. Prochaine étape immédiate

➡️ Démarrer la **Phase 1** : capturer un log BLE (HCI snoop) pendant une session d'appairage et de changement de mode entre un smartphone Android et la VS1800S, avant tout engagement sur le développement de l'app.
