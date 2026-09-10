# Dépôt en bêta sur le Connect IQ Store

Marche à suivre pour l'envoi du **10/09/2026**, version **1.0.0**, en bêta. Le
contenu de la version est dans [CHANGELOG.md](../CHANGELOG.md), les textes des
fiches dans [store/fiches-store.md](../store/fiches-store.md).

**Deux paquets, donc deux fiches.** Le champ de données et l'application sont
deux applications distinctes pour le store, avec chacune son identifiant, son
icône et sa description. Elles avancent d'un même pas — même code partagé, même
numéro de version — mais s'envoient séparément.

---

## 1. Avant d'ouvrir le formulaire

### La clé de signature, d'abord

`developer_key.der` est à la racine du projet, exclue du dépôt Git. **Garmin lie
définitivement une application publiée à la clé qui l'a signée.** Perdue, aucune
mise à jour n'est possible : il faut redéposer sous une nouvelle fiche, et les
utilisateurs déjà installés ne suivent pas.

Copiez-la ailleurs — un gestionnaire de mots de passe, un disque externe, un
coffre chiffré — **avant** le premier envoi. Un `git clone` ne la sauvegardera
pas, c'est précisément le but.

### Ce qui doit être vrai

| Vérification | Commande | Attendu |
|---|---|---|
| Les 26 binaires compilent | `bash app/build.sh` | 13 lignes, aucun ECHEC |
| Les tests passent sur quatre profils | `bash app/build.sh test-all` | 58 / 58 sur 530, MTB, 1040, 1050 |
| Types stricts | `monkeyc … -d edge530 -l 2` | BUILD SUCCESSFUL |
| Icônes à la bonne taille | `python tools/check-icons.py` | les 13 cibles conformes |
| Langues portées | `python tools/i18n/langues-supportees.py --declarees` | 13 langues, toutes portées |
| Modèles compatibles | `bash tools/check-ble-devices.sh` | 13 OUI, et le manifeste les déclare |
| Aucun code de démonstration | `grep -ac "62%  Dipped 2" app/bin/*.prg` | 0 partout |
| Aucune surcouche de diagnostic | `grep -rn "debug = true" app/ widget/ shared/` | rien |

Puis les paquets. **Pour une bêta, ce n'est pas `package`** — voir le chapitre
suivant :

```bash
bash app/build.sh package-beta
```

Ils sortent dans `dist/`, suffixés `-beta`. Contrôle du contenu, sans matériel :

```bash
7z l dist/bike-light-control-beta.iq | grep -c fit_contributions
```

Dix-neuf : un par référence matérielle, plus un global. Le paquet de
l'application, lui, n'en a aucun et c'est normal — elle n'enregistre rien dans
le fichier d'activité.

---

## 2. Le formulaire, fiche par fiche

L'envoi se fait sur <https://apps.garmin.com/en-US/developer/upload>, avec le
compte Garmin. Le tableau de bord a déménagé sur `apps-developer.garmin.com` ;
si un lien s'y perd, passer par « Submit an App » depuis
<https://developer.garmin.com/connect-iq/submit-an-app/>.

L'ordre du formulaire est imposé : **on téléverse d'abord le `.iq`**, le store le
valide, et ce n'est qu'ensuite qu'on saisit description, captures et détails.
Préparer les textes avant d'ouvrir la page fait gagner un aller-retour.

**Cocher « Beta App ».**

### Une bêta porte un identifiant d'application différent

C'est la documentation de Garmin qui l'impose :

> « To use this feature, you will need to create an alternate app id in your
> manifest using a UUID creator. […] Note that the app will have a separate store
> identifier from your final app, and URLs to the beta will not be visible
> outside of your account. »

Sans cela, la bêta et la version publique seraient la même application aux yeux
du store, et l'une écraserait l'autre. `bash app/build.sh package-beta` s'en
charge : il dérive le manifeste, y remplace l'identifiant, construit, et remet
le manifeste d'origine en place — une trappe garantit la restauration même en
cas d'échec.

Les deux identifiants de bêta sont fixés dans `app/build.sh` :

| | Production | Bêta |
|---|---|---|
| Champ de données | `91b65bef…a01a25` | `f24f796a…25b8b9` |
| Application | `596b5745…2400f1` | `91538709…98a374` |

**Une bêta n'est visible que de son auteur.** Garmin avait annoncé une seconde
phase permettant d'ouvrir une bêta à des testeurs désignés ; elle n'a jamais vu
le jour. Concrètement : la fiche de bêta sert à *vous* — à vérifier les réglages
dans Garmin Connect, les champs FIT et les deux noms, ce que ni le simulateur ni
une installation à la main ne montrent. Pour faire essayer l'application à
quelqu'un d'autre, il faut lui copier le `.prg` dans `GARMIN/Apps`, comme le
fait `tools/deploy-edge.sh`.

Le jour de la sortie publique : `bash app/build.sh package`, sans rien cocher.
Les identifiants de production reprennent leur place, et c'est une **nouvelle
fiche** — la bêta ne se transforme pas en version publique.

### Champ de données — « Bike Light Control »

| Champ | Valeur |
|---|---|
| Fichier | `dist/bike-light-control-beta.iq` |
| Type | Data field |
| Version | 1.0.0 |
| Icône de la fiche | `store/app-icon-500.png` |
| Captures | `store/screenshots/control-*.png` |
| Titres et descriptions | [store/fiches-store.md](../store/fiches-store.md) |

### Application — « Bike Light Panel »

| Champ | Valeur |
|---|---|
| Fichier | `dist/bike-light-panel-beta.iq` |
| Type | Device app |
| Version | 1.0.0 |
| Icône de la fiche | `store/widget-icon-500.png` |
| Captures | `store/screenshots/panel-*.png` |
| Titres et descriptions | [store/fiches-store.md](../store/fiches-store.md) |

### Trois points où l'on se trompe

- **Le titre ne doit contenir ni « Edge » ni « iGPSPORT ».** Depuis 2025,
  l'équipe du store traite tout usage d'une marque Garmin dans un titre comme
  une infraction, noms de produits compris, et « iGPSPORT » appartient à un
  tiers. La compatibilité se dit dans la description — c'est ce que font les
  textes préparés, dès la première ligne.
- **Les titres du formulaire doivent reprendre ceux du compteur.** Ils viennent
  des tables de `tools/i18n/` ; une fiche qui nomme l'application autrement que
  l'appareil sème le doute.
- **Aucune permission réseau n'est demandée**, donc aucune politique de
  confidentialité à fournir. Ne pas en inventer une.

---

## 3. Après l'envoi

Choisir **bêta** et non public. La fiche n'est alors visible que de son auteur,
et de personne d'autre — voir le chapitre précédent.

La revue Garmin est annoncée sous **72 heures**, jours fériés mis à part. Aucun
profil ANT+ n'est déclaré ici, donc pas de certification supplémentaire — elle
ajouterait 48 heures. Pendant ce temps la fiche est invisible, mais
l'application reste installable par son auteur.

En cas de refus, l'équipe en donne le motif par courriel et la fiche reste
modifiable : on corrige et on renvoie.

**Ce que seul le mode bêta permet de vérifier**, et que ni le simulateur ni un
sideload ne montrent :

1. Les **réglages dans Garmin Connect** : les sept du champ de données
   apparaissent-ils, traduits, avec leurs bornes ?
2. Les **champs FIT** : après une sortie, le niveau de la lampe et sa batterie
   apparaissent-ils sur le graphique de Garmin Connect, et la batterie dans le
   résumé ?
3. Les **deux noms**, distincts, dans la liste des applications du compteur
   comme dans Garmin Connect.

---

## 4. Ce qui reste à éprouver sur le matériel

Ces trois points sont corrigés dans le code et **jamais observés sur un
compteur**. Ils ne bloquent pas une bêta — c'est même à cela qu'elle sert — mais
ils bloquent une sortie publique.

| À faire | Pourquoi ça compte |
|---|---|
| Lampe mise en veille en cours de sortie, puis réveillée | la reconnexion est le cas le plus courant, et le chemin n'a jamais tourné en vrai |
| Un mode choisi à la main, puis arrêt du chronomètre | la lampe doit s'éteindre : c'est le correctif du 10/09, testé unitairement seulement |
| Quitter l'activité sans arrêter le chronomètre | le filet d'extinction n'est pas garanti là, faute de pouvoir écrire 28 octets d'un coup |

Et un modèle autre que l'Edge 1050, idéalement à boutons : c'est le seul
exemplaire physique du projet. La fiche d'essai de l'Edge 830 est prête dans
[essai-edge830.md](essai-edge830.md), et [essai-modeles.md](essai-modeles.md)
dit ce que chacun des treize apporterait.

---

## 5. Si la question de la monétisation se pose

Elle ne se pose pas pour une bêta, et rien dans le code n'est à préparer. Mais
elle se décide mieux tôt que tard : passer une application gratuite en payante
retire la fiche le temps d'une nouvelle revue, et **oblige les utilisateurs déjà
installés à l'acheter** pour continuer à s'en servir. Surtout, une application
monétisée n'est vendue que sur une partie de la gamme : **cinq de nos treize
modèles en seraient exclus**, dont l'Edge 530 et l'Edge 830.

Le détail, chiffres et conditions compris, est dans
[monetisation.md](monetisation.md).
