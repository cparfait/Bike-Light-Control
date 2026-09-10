# Commande d'éclairage vélo — application Connect IQ

Pilotage d'une lampe iGPSPORT depuis un compteur Garmin Edge. **Deux binaires** partageant le
même code protocolaire.

| | |
|---|---|
| Data field | `app/` — tourne pendant l'activité : affichage, automatismes, tape pour changer de mode |
| Widget | `widget/` — pilotage manuel à l'arrêt, et sur les Edge à boutons |
| Code partagé | `shared/` — protocole, couche BLE, automatismes, page de pilotage |
| Langues | 13, suivant la langue du compteur — voir « Traductions » |
| Cibles | 13 modèles Edge — voir [compatibilite-edge.md](compatibilite-edge.md) |
| Noms publiés | « Bike Light Control » (champ de données) et « Bike Light Panel » (application) |
| Taille en release | 46 à 61 Ko par binaire, pour un budget de 128 Ko en data field |
| Tests | 58 tests unitaires, `bash app/build.sh test` |

## Pourquoi un data field

Un data field est le seul type d'app Connect IQ qui **tourne pendant l'enregistrement de
l'activité**. C'est indispensable ici : l'ajustement selon la vitesse (F5) et l'extinction
synchronisée (F6) n'ont de sens qu'en roulant. Un widget, lui, ne survit pas au démarrage du
chrono.

L'objection classique — « un data field ne peut pas recevoir d'entrée utilisateur » — ne tient
pas sur Edge : `onTap()` y fonctionne, à condition d'étendre `DataField` et non
`SimpleDataField`. Le changement de mode manuel (F4) est donc possible dans le data field
lui-même sur les modèles tactiles.

Reste deux cas qu'un data field ne couvre pas, et c'est la raison d'être du **widget
compagnon** :

- sur les Edge à boutons (530, 540), `onTap()` ne se déclenche jamais — sans widget, aucun
  pilotage manuel n'est possible ;
- **hors activité**, aucun data field ne tourne, alors qu'on veut pouvoir allumer la lampe
  avant de partir.

Le découpage est celui qu'a retenu
[SmartBikeLights](https://github.com/maca88/SmartBikeLights) pour les feux ANT+, et il a fait
ses preuves.

Connect IQ impose un binaire par type d'application. Plutôt qu'un *barrel* — de l'outillage
pour peu de gain — les deux projets pointent simplement leur `sourcePath` sur le répertoire
`shared/`. Une seule vérité protocolaire, deux binaires.

Conséquence à connaître : Connect IQ isole les réglages par binaire. Le seuil de batterie se
configure donc séparément pour le data field et pour le widget.

## Structure

```
shared/                 code commun aux deux binaires
  Protobuf.mc           encodage/décodage varint et sous-messages
  Crc8.mc               CRC-8/MAXIM, les deux contrôles de l'en-tête
  LightConstants.mc     UUID, numéros de champ, énumérations, échelles d'intensité
  LightProtocol.mc      construction des trames, lecture des réponses
  LampManager.mc        connexion BLE, machine à états, file d'écritures
  AutoController.mc     automatismes vitesse / arrêt / batterie faible
  PanelLayout.mc        géométrie de la page, vérifiable sans écran
  LampPanel.mc          page de pilotage, commune aux deux binaires

app/                    data field
  manifest.xml          13 produits, permissions BLE et FitContributor
  build.sh              construction des deux binaires, et tests
  resources/settings/   seuils de vitesse, seuil batterie, extinction auto
  source/
    LampApp.mc          point d'entrée
    LampView.mc         affichage, entrée tactile, écriture dans le FIT
  source-test/
    ProtocolTest.mc     58 tests unitaires

widget/                 widget compagnon
  manifest.xml          mêmes 13 produits
  source/
    PanelApp.mc         application, résumé, gestion des boutons et du tactile
    LampControlView.mc  enveloppe de vue autour du panneau partagé
    SettingsMenu.mc     menu des réglages
```

## Quatre limites de Connect IQ découvertes à l'exécution

Ni l'analyse de l'APK ni la capture BLE ne pouvaient les révéler : elles ne viennent pas de
la lampe mais de la plateforme Garmin. Toutes ont fait échouer un essai réel.

### `Toybox.Timer` est inutilisable dans un data field

L'application levait une exception non rattrapée dès l'abonnement aux notifications, et
affichait le logo Connect IQ. Le journal `GARMIN/Apps/LOGS/CIQ_LOG.YML` donnait l'adresse
fautive, et la table de symboles produite par le compilateur (`.prg.debug.xml`) l'a traduite :
les deux lignes qui créaient un `Timer`.

Le timer servait à interroger l'autonomie chaque minute. Il était superflu : `compute()` est
appelé une fois par seconde par le système. On compte les battements, et on interroge tous les
trois cents — cinq minutes. Ce rappel est presque superflu : la lampe notifie
spontanément son autonomie à chaque changement de mode. `LampManager.tick()` est appelé par le
data field comme par le widget — aucune dépendance à un minuteur.

**Comment relire un plantage** : brancher l'Edge et lancer `bash tools/pull-ciq-log.sh`. Il
récupère `Garmin/Apps/LOGS/CIQ_LOG.YML` et traduit chaque `pc` en fichier et ligne grâce à
`<appareil>.prg.debug.xml`. Ce fichier de symboles est produit même en construction `-r`,
mais il correspond à **cette** construction : le conserver avec le binaire déployé
(`bash tools/deploy-edge.sh` installe les deux binaires sur l'Edge branché).

### Les écritures BLE sont limitées à 20 octets

> « Support for long writes is not implemented. » — documentation de `Characteristic.requestWrite`

Une écriture plus longue est refusée, et l'application affichait « ecriture refusee ». Or les
trames de la lampe font 26 à 32 octets.

Côté téléphone, le MTU négocié est de 247 octets et l'app iGPSPORT envoie ses trames d'un
bloc : rien dans la capture ne laissait présager la contrainte. `LampManager.send()` découpe
donc chaque trame en fragments de 20 octets, écrits l'un après l'autre. C'est exactement la
taille que la lampe emploie pour ses propres notifications — elle est faite pour ça.

### La tuile de résumé ne voit presque rien du reste de l'application

La tuile restait **noire et vide** sur l'Edge 1050, sans message à l'écran. Le journal de
l'appareil a tranché, en deux temps.

**Premier plantage :**

```
Error: Illegal Access (Out of Bounds)
Details: "Class not available to 'Glance'"
```

Un résumé s'exécute dans un contexte séparé, doté de **64 Ko** — la moitié d'un champ de
données, un seizième d'une application — et il n'a accès qu'à une petite partie du code. Or
`onStart()` est appelé **aussi quand le système ne veut que la tuile**, et il y montait
`LampManager`, donc toute la pile BLE. Le montage se fait désormais dans `getInitialView()`,
c'est-à-dire seulement si l'utilisateur ouvre vraiment la page.

**Second plantage, après cette correction :**

```
Error: Illegal Access (Out of Bounds)
Details: "Could not access symbol '008000a1'"
Stack:
  - pc: 0x100000f8
```

L'adresse, passée dans `widget/bin/edge1050.prg.debug.xml`, donnait `IgEdgeWidget.mc:120` — le fichier s'appelle `PanelApp.mc` depuis :
l'appel `Labels.of(Rez.Strings.LightGeneric)`. **L'annotation `(:glance)` sur le module
`Labels` n'avait pas suffi.**

La tuile ne dépend donc plus de rien. La page range dans le stockage **deux chaînes déjà
composées et déjà traduites** — un titre et un résumé — et la tuile se contente de les
afficher. Ni `LightConstants`, ni `Labels`, ni table de ressources. Contrepartie assumée :
après un changement de langue du compteur, la tuile garde les anciens mots jusqu'à la
prochaine ouverture de la page.

Accessoirement, la tuile ne pourrait de toute façon pas interroger la lampe : un scan BLE
demande plusieurs secondes là où une tuile se dessine instantanément. Elle montre le dernier
état relevé par la page, et sert surtout de raccourci vers elle — sur Edge, l'autre chemin
oblige à quitter son profil d'activité.

Elle ne peint plus non plus son fond en noir : le système dessine un dégradé derrière chaque
tuile, et la nôtre tranchait au milieu des autres.

**La leçon de méthode** : les deux causes étaient invisibles au compilateur et au simulateur.
Ce qui les a données, c'est `GARMIN/Apps/LOGS/CIQ_LOG.YML` relu avec la table de symboles du
build déployé. Garder cette table avec le binaire n'est pas une précaution théorique.

### Une application n'a pas de battement : il faut le lui donner

Sur l'Edge 1050, la page de pilotage restait sur « Recherche » et **aucune tuile ne répondait**,
alors que le champ de données, lui, se connectait sans peine. Deux hypothèses se disputaient
— un décalage entre le dessin et le toucher, ou une liaison jamais établie — et ni le
simulateur ni le journal de plantage ne tranchaient. Une ligne de diagnostic à l'écran l'a
fait en une lecture :

```
480x707  z=8  ko  t=248,304>-101
```

La tape au centre de « Route » avait trouvé Route (`-101`) : les coordonnées étaient justes.
`480x707` disait au passage que la barre de contrôle du 1050 prend 93 pixels, ce que la
définition SDK confirme (`controlBar.height`). Le coupable était `ko` : **pas de liaison**.

La raison est structurelle. Le champ de données reçoit `compute()` chaque seconde, et c'est
lui qui appelle `LampManager.tick()` et fait avancer la machine à états. Une application,
elle, n'est rappelée que sur événement : `onUpdate()` tournait une fois à l'ouverture, puis au
rythme des tapes. La liaison n'avançait pas, l'écran ne se redessinait pas, et la page
ignorait les tapes hors liaison — par conception. `LampControlView` a donc son propre
`Timer` à la seconde. `Toybox.Timer` est proscrit dans un data field ; il est parfaitement
légitime dans une application.

Le même essai a révélé un second défaut, plus sournois : « les boutons ne correspondent
pas ». Sur un Edge tactile, le système peut traduire une tape en **sélection**, et
`onSelect()` — écrit pour les modèles à boutons — appliquait la zone désignée par le curseur,
c'est-à-dire celle de la tape **précédente**. Chaque geste appliquait la tuile d'avant. La
sélection au curseur n'existe plus que sur les modèles sans écran tactile.

La surcouche de diagnostic est conservée dans `LampPanel`, inactive (`debug = false`).

## Décisions de conception

### Les trames sont vérifiées contre la capture, pas contre mon raisonnement

Huit tests comparent la sortie du code aux octets **réellement émis par l'app iGPSPORT**,
relevés dans la capture HCI. Ce ne sont pas des valeurs recalculées de tête : si le code
cesse de les reproduire, c'est le code qui a tort. C'est ce qui a permis de valider d'un coup
l'en-tête de transport, les deux CRC et l'encodage protobuf.

### Protobuf écrit à la main

Il n'existe pas de bibliothèque protobuf pour Connect IQ. `Protobuf.mc` n'implémente que ce
dont le protocole a besoin : les varints et les sous-messages. Les autres types de fil sont
**refusés** plutôt qu'ignorés — un type inattendu rend impossible de savoir de combien avancer
dans la trame, et continuer décalerait tout le reste sans qu'on s'en aperçoive.

Même logique pour `parse()` : une trame malformée retourne `null`, jamais un résultat partiel.
Un résultat partiel serait affiché comme un état valide de la lampe.

### Distinguer « absent » de « zéro »

Protobuf n'émet pas les champs valant leur valeur par défaut. Un champ absent vaut donc 0 — il
ne signifie pas « inconnu ». `LightStatus` garde ses champs à `null` tant que la lampe n'a rien
dit, et l'affichage montre `--` plutôt que `0 %`. C'est la différence entre « la batterie est
vide » et « je ne sais pas encore ».

Le cas limite est l'extinction : `BLM_LIGHT_OFF` vaut 0, donc un sous-message `curMode` **vide**
signifie « éteint ». C'est traité explicitement dans `parseStatus`.

### Reconnaissance de la lampe au scan

L'app iGPSPORT connaît quatre variantes du service, ne différant que par le dernier octet
(`…DCCA6E`, `7E`, `8E`, `9E`). La capture HCI a tranché : la VS1800S expose la variante `9E`,
qui est donc la seule enregistrée (`SERVICE_UUID`). Un profil sur les trois autorisés.

La lampe **n'annonce pas ce service** dans son advertising : elle y met un marqueur
(`ADVERT_MARKER_UUID`) qu'on ne trouve nulle part dans l'app Android. C'est ce marqueur qui
sert de premier critère, et le nom de filet pour les modèles qui n'en annonceraient pas.

Le filtre sur le nom est étroit à dessein. Chercher « VS » ou « TL » n'importe où acceptait la
moitié des capteurs d'une salle : un cardio-fréquencemètre, un feu d'une autre marque. On exige
le motif d'une référence iGPSPORT — deux lettres puis un chiffre — ou le nom de marque complet.
Et tout appareil connecté qui s'avère ne pas exposer le service est **mémorisé** : sans cette
liste, il était appairé, rejeté, retrouvé au scan suivant, et la recherche tournait en boucle
sans jamais atteindre la vraie lampe.

### On choisit la lampe la plus proche, et elle le confirme en clignotant

Deux lampes répondent au même moment — un départ de groupe, un garage à vélos, deux vélos dans
le même couloir. La version précédente se connectait à la **première vue**, ce qui revenait à
tirer au sort. Et rien à l'écran ne pouvait dire laquelle avait répondu : deux exemplaires du
même modèle s'annoncent tous les deux « VS1800S ».

Deux réponses, l'une après l'autre :

1. **La plus proche gagne.** Dès qu'une lampe est repérée, on écoute trois secondes de plus, on
   collecte les candidates, et on retient celle dont le signal est le plus fort — sur un vélo,
   la lampe posée à un mètre du compteur. Un signal très fort au premier coup abrège l'attente :
   inutile de faire patienter quand il n'y a aucun doute.
2. **La lampe se désigne elle-même.** À la connexion, elle clignote deux fois, et l'écran
   affiche « Celle-ci ? » avec un pictogramme qui s'allume au même rythme. C'est le lien entre
   ce qu'on voit sur le guidon et ce qu'on lit sur le compteur, et aucune ligne de texte ne
   pourrait le remplacer. Si plusieurs lampes ont répondu, la précision le dit : « 3 lampes à
   proximité ».

Le clignotement a deux garde-fous. Il n'a lieu qu'**une fois par session**, et **jamais chrono
démarré** : faire clignoter le phare de quelqu'un qui roule de nuit, à chaque reconnexion après
une mise en veille, serait dangereux. La règle est dans `LampManager`, pas chez l'appelant : le
widget ne saurait pas qu'une activité tourne.

La lampe est remise dans l'état où on l'a trouvée. Le clignotement n'est lancé qu'une fois le
bilan initial écoulé, c'est-à-dire une fois que la lampe a dit son mode courant — sinon on la
rendrait éteinte à quelqu'un qui l'avait allumée à la main.

Si ce n'est pas la bonne lampe, « Changer de lampe » dans les réglages l'écarte et relance la
recherche ; la suivante clignote à son tour. L'appareil écarté est retenu **par son identité**
(`ScanResult.isSameDevice`), jamais par son nom : écarter « VS1800S » écarterait aussi celle
qu'on cherche.

### Un mot pour l'étape, une ligne pour son sens

Pendant la connexion, trois textes se disputaient la page : un bandeau, un état dans un coin, un
mode « -- » au centre. Trois tailles différentes, et un vocabulaire de protocole — « Liaison »,
« Abonnement ». Personne ne pouvait en tirer où on en était.

La page n'affiche plus qu'un écran d'attente tant que la lampe n'est pas là :

| | Mot d'étape | Précision |
|---|---|---|
| Recherche | Recherche | de votre lampe |
| Connexion | Connexion | lampe trouvée |
| Identification | Celle-ci ? | votre lampe clignote |
| Sans Bluetooth | Bluetooth | indisponible |

Trois règles, et elles comptent plus que les mots eux-mêmes :

- **L'abonnement aux notifications n'est plus une étape.** C'est un détail de protocole,
  l'utilisateur n'a rien à y faire, et il portait un mot que personne ne comprenait. Deux
  étapes, pas quatre.
- **La police est mesurée sur le plus long des mots d'étape, jamais sur celui du moment.** Sans
  cela, « Connexion » s'écrivait plus gros que « Recherche », et le texte changeait de corps à
  chaque étape. Les quatre mots font la même longueur à une lettre près, ce qui n'est pas un
  hasard : c'est ce qui les fait tenir en `FONT_LARGE` sur les 13 cibles.
- **Une phrase entière était impossible.** « Recherche de votre lampe » sur un Edge 1050 tombait
  en police minuscule au milieu de beaucoup de noir. D'où les deux niveaux.

Le champ de données, lui, n'a pas la place : il n'affiche que le mot d'étape, et la précision
seulement si la case est assez haute. Même règle de police, même vocabulaire.

Le bandeau de la page, une fois connecté, a perdu son mot d'état : la pastille verte dit la
même chose, et sans police supplémentaire.

### Les profils GATT ne s'enregistrent qu'une fois

`registerProfile` est un appel de démarrage : la documentation demande de déclarer là « all of
the Profiles that will be used in the application », en plafonne le nombre à trois, et n'offre
aucune opération inverse. Or `start()` est rappelé à chaque déconnexion — une lampe qui passe
en veille puis se réveille en cours de sortie, c'est le cas courant. Un drapeau
(`_profilesRegistered`) garantit un seul enregistrement pour toute la vie de l'application ;
la reconnexion, elle, se contente de désappairer l'ancien appareil et de relancer le scan.

### File d'écritures

Connect IQ n'autorise **qu'une opération GATT en vol à la fois**. Deux écritures émises coup
sur coup se perdent silencieusement. `LampManager` sérialise donc les envois : une trame part,
la suivante attend `onCharacteristicWrite`. La file est plafonnée à 16 fragments — au-delà,
c'est que la lampe ne répond plus, et les plus anciens sont abandonnés plutôt que d'accumuler.

Une exception : l'extinction de fin d'application. `turnOff()` puis `stop()` ne marchait pas —
`requestWrite` est asynchrone, et `unpairDevice` coupait la liaison avant que la trame ne parte.
La lampe restait allumée après la sortie, et le défaut est silencieux : on ne le voit qu'en
rentrant. `shutdown()` vide la file, écrit la trame directement sans attendre l'acquittement en
cours, et laisse au système le soin de fermer la liaison.

### La pause n'éteint pas, l'arrêt éteint

`Activity.Info.timerState` a quatre valeurs, et les confondre coûtait cher : tout ce qui
n'était pas `TIMER_STATE_ON` était traité comme une fin de sortie. Avec la pause automatique,
**chaque feu rouge éteignait la lampe de nuit** — au moment précis où un cycliste immobile a le
plus besoin d'être vu, et à rebours de ce que promet le libellé du réglage, « éteindre la lampe
à l'arrêt de l'activité ».

`AutoController.rideStateOf()` traduit donc l'état du chrono en trois cas, et
`onRideState()` les traite séparément :

| État du chrono | Effet sur la lampe |
|---|---|
| `TIMER_STATE_ON` | premier cran de l'échelle, au départ seulement, si le réglage l'autorise |
| `TIMER_STATE_PAUSED` | **rien** — la lampe reste comme elle est |
| `TIMER_STATE_STOPPED`, `TIMER_STATE_OFF` | extinction, si le réglage est actif |

Reprendre après une pause ne renvoie pas non plus d'allumage doux : la lampe n'a pas bougé, et
un mode choisi à la main ne doit pas être annulé par un redémarrage de chrono. Sept tests
couvrent ces transitions.

### L'allumage au départ n'est pas systématique

Le compteur ne sait pas s'il fait nuit. Allumer à chaque démarrage de chrono vidait la lampe sur
une sortie de trois heures en plein après-midi, sans que personne ne le demande. Le réglage
« allumer la lampe au départ de l'activité » (`lightOnStart`, actif par défaut) le rend
décochable : qui roule de jour le coupe une fois pour toutes, qui veut être vu de jour le
laisse.

Une condition sur l'heure du lever et du coucher du soleil serait plus fine, mais elle demande
la position et une table éphéméride : un réglage à deux états rend le même service pour
quelques octets.

### Les réglages sont relus par l'application, pas par la vue

Le SDK ne déclare `onSettingsChanged` que sur **`AppBase`**. Une méthode de ce nom écrite sur la
vue — c'est là qu'elle était — n'est jamais appelée, et rien ne le signale : le nom est libre,
le compilateur ne voit qu'une méthode de plus. Les seuils saisis depuis Garmin Connect
restaient donc sans effet jusqu'au redémarrage du champ, ce qui ne se diagnostique pas : on
croit avoir mal réglé.

La relecture est désormais dans `LampApp.onSettingsChanged()`. Un verrou l'accompagne :

`AutoController._manualHold` retient qu'une tape a suspendu l'ajustement. Sans lui, la relecture
déclenchée par **n'importe quel** changement de réglage — un seuil de vitesse, par exemple —
réactiverait l'automatisme qu'une tape venait de couper, et la lampe repartirait toute seule au
cran suivant. Le geste sur le guidon est plus récent que le réglage : c'est lui qui gagne.
Changer le réglage `autoEnabled` lui-même lève le verrou, puisque c'est un geste plus explicite
encore.

### La vitesse est lissée sur trois secondes

`Activity.Info.currentSpeed` est la vitesse **instantanée** : sur route dégradée ou en sortie de
virage, elle saute d'un ou deux km/h d'une seconde à l'autre. L'hystérésis absorbe le
papillonnage autour d'un seuil, mais pas le bruit de la mesure elle-même, et un seul échantillon
aberrant suffit à faire changer la lampe de cran. `LampView._smoothed()` en fait la moyenne sur
trois secondes — pas davantage, sinon la lampe réagirait avec un retard visible en haut d'une
bosse.

### Quatre paliers pour six crans : l'arrondi compte

Trois seuils délimitent quatre paliers de vitesse, projetés sur une échelle qui compte six crans
sur une VS1800S. La division entière — `band * maxIndex / steps` — donnait 0, 1, 3, 5 : entre 8
et 18 km/h, la lampe restait sur son avant-dernier cran le plus faible alors que le milieu de
l'échelle est ce qu'on veut là. L'arrondi au plus proche donne 0, 2, 3, 5.

Il faut le dire clairement : **quatre paliers ne peuvent pas couvrir six crans.** Deux resteront
hors de portée de l'automatisme et accessibles à la main seulement. Y remédier demanderait cinq
seuils au lieu de trois, donc cinq réglages dans Garmin Connect — un mauvais échange.

### Les champs FIT ont besoin d'une ressource, pas seulement de `createField()`

`createField("light_level", 0, …)` écrit bien la donnée dans le fichier d'activité, mais Garmin
Connect l'ignore tant qu'aucune ressource `fitContributions` ne la décrit : le libellé, l'unité,
la couleur de la courbe et la présence dans le résumé viennent de là, pas du FIT. Le piège est
entièrement silencieux — l'application compile, s'installe, enregistre, et le graphique
n'apparaît jamais.

Le fichier est `app/resources/fit/fit-contributions.xml`, et les `id` y répondent un pour un à
ceux passés à `createField()`. Deux détails qui coûtent une compilation chacun : `unitLabel` est
**obligatoire** sur chaque `fitField`, et le nom d'application ne supporte pas l'apostrophe.

Cela se vérifie dans le paquet, sans matériel :

```bash
7z l dist/bike-light-control.iq | grep fit_contributions
```

Le simulateur, lui, ne rend pas cette partie : seule une installation depuis le store, le mode
bêta compris, montre le résultat dans Garmin Connect.

### Une icône par taille d'écran

Les 13 cibles attendent cinq tailles d'icône de lanceur : 35, 36, 40, 56 et 68 pixels. Une
image unique est redimensionnée par le compilateur **sans aucun avertissement**, et 68 px
ramenés à 35 donnent une image floue là où l'écran est déjà petit.

`tools/make-icons.py` dessine donc l'icône vectoriellement, la rend huit fois trop grande et la
réduit en Lanczos, une fois par taille. Le jungle associe chaque appareil à son dossier
(`resources-icon-35` et suivants) ; `resources/drawables/` n'existe plus, deux définitions du
même identifiant entrant en conflit.

### L'icône est opaque et pleine, bord à bord

C'est la convention de Garmin lui-même : **toutes les icônes de lanceur des exemples du SDK sont
des carrés pleins**, sans coin arrondi et sans canal alpha, coin et centre de la même couleur.

La première version faisait l'inverse — un rectangle à coins arrondis, quasi-noir, sur fond
transparent — et le résultat était mauvais sur l'appareil : les coins retombaient en noir au
lieu de disparaître, et le carré sombre se détachait du menu au lieu de s'y fondre. L'Edge MTB
réglait la question à lui seul : `alphaBlendingSupport` vaut `False` dans son profil, il ne sait
pas composer une transparence.

Le fond est donc le bleu nuit de l'icône du store, opaque, et le même dessin sert aux deux :
la fiche et le compteur montrent la même image. Accessoirement, un PNG opaque sans canal alpha
pèse moins — l'Edge 1050 est passé de 82 668 à 78 044 octets.

Trois détails de dessin, tous appris à l'écran :

- **Les trois rayons du faisceau partent du bord du disque, à écart constant, et ont la même
  longueur.** Les faire aller jusqu'à un même rayon depuis le centre donnait un trait du milieu
  visiblement plus court que les deux obliques.
- **Le panneau porte un cadre plein, pas un liseré arrondi.** À 35 px le liseré tombait sous le
  pixel et ne laissait qu'un halo sale ; l'épaisseur du cadre est calculée pour faire au moins
  deux pixels à la plus petite taille.
- **Le dessin se cale à l'intérieur du cadre**, sinon le panneau aurait une lampe plus petite
  que le champ de données, pour la même taille d'icône.

Sans la différence de cadre, les deux binaires étaient indistinguables dans la liste des
applications du compteur, où ils se suivent.

### Hystérésis sur la vitesse

`AutoController` change de mode à 8, 18 et 30 km/h, avec **0,6 m/s de recouvrement**. Sans
cette marge, rouler pile sur un seuil ferait clignoter la lampe entre deux modes à chaque
rafale de vent. Le seuil descendant n'est pas le seuil montant.

Toute action manuelle **désactive l'automatisme** (`_auto.enabled = false`). Sinon la seconde
suivante remettrait le mode calculé et le geste de l'utilisateur paraîtrait ignoré.

### Paliers de vitesse répartis sur toute l'échelle

Trois seuils délimitent quatre paliers, mais l'échelle d'une lampe à faisceau compte six
crans. Faire correspondre le palier *n* au cran *n* rendrait **les deux modes les plus
puissants inatteignables** par l'automatisme — un défaut qu'un test a révélé après coup.

Les paliers sont donc répartis sur toute l'échelle : le palier le plus haut atteint toujours
le cran le plus fort, quelle que soit la longueur de l'échelle. L'hystérésis s'applique au
palier de vitesse, pas au cran d'intensité.

### Anticipation optimiste

Après avoir envoyé un changement de mode, `LampView` met immédiatement à jour `status.mode`
sans attendre la notification de la lampe. Sans ça, `compute()` renverrait la même commande à
chaque seconde jusqu'à ce que la lampe confirme.

## La page de pilotage

Un seul composant de dessin, `shared/LampPanel.mc`, sert le data field en plein écran et
l'application compagnon. Une correction profite aux deux ; il n'y a pas deux mises en page à
faire converger.

De haut en bas : le bandeau d'état (type de lampe, liaison, réglages), la batterie et
l'autonomie, le mode courant en toutes lettres, la rangée des catégories, celle des niveaux.

### La mise en page se calcule sur la largeur, pas sur la hauteur

Les 13 cibles couvrent **six formats d'écran** — 240×320, 240×400, 246×322, 282×470, 420×600,
480×800 — et un data field peut n'en occuper qu'une fraction. Rien n'est donc exprimé en
pixels : les tuiles se dimensionnent sur **la largeur disponible** — une tuile un peu plus
haute que large se touche bien et laisse la place à son libellé — et la hauteur ne fait que
les étirer, entre 1,15 et 1,85 fois leur largeur.

La version précédente n'avait pas de borne haute : les deux rangées se partageaient toute la
hauteur restante, ce qui donnait sur un 1050 des pavés de trois cents pixels pour trois crans
d'intensité.

### Deux rangées de catégories quand l'écran est haut

Une borne haute seule ne suffisait pas : sur les 480×800 d'un 1050, cinq tuiles alignées font
83 pixels de large, et la moitié de la page reste noire. Les catégories se replient donc sur
**deux rangées** dès que la hauteur le permet — trois par rangée, soit 144 pixels de large au
lieu de 83. L'icône respire, le libellé complet tient, et la page se remplit.

Une rangée incomplète est centrée : cinq catégories sur trois colonnes donnent 3 + 2, et les
deux du bas se placent au milieu plutôt que de laisser un trou à droite.

Sur les écrans étroits — Edge Explore, MTB, 530 en champ réduit — le calcul retombe de
lui-même sur une seule rangée : le repli n'est pas conditionné à un modèle mais à la place.

### La géométrie se vérifie sans écran

`shared/PanelLayout.mc` calcule toute la mise en page à partir de six nombres : largeur,
hauteur, nombre de catégories, nombre de niveaux, et trois hauteurs de police que l'appelant
mesure sur son `Dc`. `LampPanel` ne fait que dessiner ce qu'elle décide.

La séparation n'est pas cosmétique. Elle permet à un test unitaire de passer la mise en page
sur **1 925 combinaisons** — les six formats d'écran, les découpes de champ assez grandes
pour que la page s'affiche, cinq jeux de polices allant de 14/16/26 pixels sur un Edge
Explore à 41/46/75 sur un 1050, et de deux à six catégories selon ce que déclare la lampe —
en vérifiant à chaque fois qu'aucune rangée ne sort de l'écran, qu'aucune ne chevauche sa
voisine et qu'aucune tuile n'est de taille nulle.

C'est ce qui manquait : la mise en page était réglée sur un Edge 1050 et constatée sur photo.
Les tailles d'écran et les hauteurs de police viennent des définitions du SDK
(`Devices/<appareil>/simulator.json`), pas d'une estimation.

La suite de tests tourne aussi sur d'autres profils que le 1050, dont des modèles sans écran
tactile :

```bash
bash app/build.sh test edge530
```

### Les icônes tiennent dans un carré, et c'est vérifiable

Elles sont dessinées en primitives : rien à embarquer, et elles s'adaptent à toutes les
tailles d'écran. La contrainte est que **chacune tienne dans `[cx ± r] × [cy ± r]`**. Ce
n'est pas une remarque de style : le réflecteur du faisceau était posé en `cx - r` avec des
rayons jusqu'à `cx + 2r`, soit une icône trois fois plus large que son rayon, qui empiétait
sur la tuile voisine.

Le symbole d'extinction est tracé avec `drawArc` plutôt qu'en masquant le haut d'un cercle
avec un rectangle de la couleur du fond : ce rectangle restait visible dès que la tuile
changeait de fond, c'est-à-dire précisément quand la lampe était éteinte.

### Trois états, une seule couleur d'accent

La catégorie **allumée** est pleine, celle qu'on **consulte** est seulement cerclée, les
autres restent sombres. Remplir la sélection comme l'état actif — un bleu et un liseré blanc
dans la version précédente — obligeait à comparer deux tuiles pour savoir laquelle éclairait.

L'accent ambre est de la même famille que la rampe d'intensité de `LC.intensityColor()` : le
libellé du mode courant a exactement la teinte de sa tuile. Seule l'extinction sort de la
famille chaude, en gris franc — un accent chaud dirait « ça éclaire ».

La rangée des niveaux est une jauge et non six pavés colorés : chaque tuile porte un trait
d'autant plus long que le cran est fort, et seul le mode en cours est peint en plein. La
rangée se lit comme une échelle croissante, y compris du coin de l'œil.

Le thème vit dans `LightConstants` (`UI_*`), en valeurs RVB libres plutôt qu'en `COLOR_*` du
SDK : les 13 cibles affichent 16 bits par pixel, et `COLOR_DK_GRAY` rendait presque blanc sur
un écran de compteur en plein jour.

### Le fond reste noir même en thème clair

Un data field hérite du thème choisi par l'utilisateur. La page de pilotage l'ignore : elle
se consulte surtout de nuit, et un fond blanc à hauteur de guidon éblouit. L'affichage à deux
lignes, lui — celui d'un champ étroit — respecte le thème comme n'importe quel data field.

### Deux commandes qui manquaient

- **Le badge `AUTO` / `MANU`.** Toute action manuelle coupe l'ajustement selon la vitesse,
  et rien ne le disait. Pire, le rétablir demandait d'éteindre la lampe puis de retaper —
  et c'était impossible depuis l'application compagnon. Le badge affiche l'état et le
  bascule.
- **Le curseur des modèles à boutons.** Sur un Edge 530, `onNextPage()` déplaçait une
  sélection qui n'était jamais dessinée : la page paraissait ne pas répondre. Le curseur est
  maintenant tracé autour de la zone visée, uniquement sur les modèles sans tactile
  (`isTouchScreen`, propriété d'exécution).

La roue dentée, elle, n'est dessinée que par l'application compagnon : un data field n'a pas
le droit d'empiler une vue, la roue y était un bouton qui ne menait nulle part.

## Voir la page dans le simulateur

Le simulateur n'a **pas de pile Bluetooth**. `Ble.setScanState()` n'y trouve
jamais rien, la machine à états reste sur « Recherche », et le seul écran qu'on
puisse y regarder est celui de l'attente : toute la page — bandeau, jauge, mode
courant, catégories, crans — n'était visible que sur un appareil avec une vraie
lampe au bout. Autant dire sur un seul modèle, le 1050.

Le **mode démonstration** remplit `LampManager.status` avec ce qu'une VS1800S
déclare réellement, et pose l'état à « prête ». Le panneau ne sait pas d'où
vient l'état qu'il affiche : le dessin est exactement celui d'une lampe
connectée.

```bash
bash app/build.sh sim               # application compagnon, Edge 1050
bash app/build.sh sim app edge530   # champ de données, sur un autre profil
```

Il vit dans `shared/LampDemo.mc`, sous l'annotation `demo`. Les deux jungles
l'excluent (`base.excludeAnnotations = debug;demo`) ; `sim.jungle`, empilé
par-dessus, l'inclut et exclut `nodemo` à sa place. **Aucun binaire de
diffusion ne le contient** — vérifiable sur le paquet :

```bash
grep -ac "62%  Dipped 2" widget/bin/edge1050.prg    # 0
```

### Les captures

```bash
bash tools/sim-captures.sh                    # un modèle par format d'écran
bash tools/sim-captures.sh app edge530        # le champ de données, sur un 530
```

Les images vont dans `captures/sim/`, exclu du dépôt. Elles servent à deux
choses : vérifier la mise en page sur les six formats sans posséder treize
compteurs, et produire les captures que le Connect IQ Store exige par fiche.

`tools/sim-shot.ps1` capture la fenêtre par `PrintWindow` et non par une copie
de l'écran : la fenêtre n'a pas besoin d'être au premier plan, et la capture ne
vole pas le focus de celui qui travaille à côté. Le repli par copie d'écran
n'existe que pour les fenêtres qui ignorent `PrintWindow`.

### Ce que le simulateur a trouvé du premier coup

Quatre défauts qu'aucun essai sur Edge 1050 ne pouvait montrer :

| Défaut | Cause |
|---|---|
| Vignette de résumé **blanche sur blanc** | la zone de contenu des thèmes de vignette est blanche sur un MTB, sombre sur un 1050 |
| Vignette **vide** avant la première ouverture | rien n'était écrit tant qu'aucun relevé n'existait |
| Libellé du mode en **police minuscule** sur 1030, 1030 Plus, Explore | police choisie sur la largeur seule, puis rabattue sur la plus petite |
| Roue dentée lue comme un **soleil** | dents fines et longues, anneau mince |

C'est l'argument pour le garder : ces quatre-là étaient invisibles au
compilateur, aux tests de géométrie — qui vérifient des rectangles, pas des
couleurs — et à l'appareil dont on dispose.

### Ce qu'il ne remplace pas

Le Bluetooth, donc la connexion, la reconnexion et le protocole. Et le rendu
réel d'une dalle : le simulateur dessine sur un écran d'ordinateur, pas sur un
transflectif en plein soleil.

## Langues

Connect IQ ne propose pas de sélecteur de langue par application : **une app parle celle du
compteur**. Le système choisit le jeu de ressources au démarrage, et il n'y a rien à régler
dans Garmin Connect.

```
shared/resources/strings/          anglais — repli pour toute langue non fournie
shared/resources-fre/strings/      français
app/resources{,-fre}/strings/      titres de réglages du champ de données
widget/resources{,-fre}/strings/   menu des réglages, sur le compteur
```

Le mécanisme est celui du SDK (`base.lang.fre = resources-fre`, voir `bin/default.jungle`) :
les dossiers sont découverts automatiquement dès que la langue est déclarée au manifeste. Les
deux jungles y ajoutent le répertoire partagé, pour la même raison que `sourcePath` pointe sur
`shared/` — les deux binaires doivent afficher exactement les mêmes mots.

**L'anglais est le jeu par défaut, le français la variante.** C'est l'inverse de ce qu'on
écrirait spontanément sur un projet francophone, mais c'est le seul ordre correct : un Edge
configuré en suédois doit tomber sur l'anglais, pas sur du français.

Auparavant, tous les libellés étaient écrits en dur dans le Monkey C. Le manifeste déclarait
pourtant `fre` **et** `eng` — il promettait un anglais qui n'existait pas, et un utilisateur
anglophone aurait eu « Croisement », « Eteint » et « Seuil de batterie faible ».

### Le cache de `Labels`

`loadResource()` relit la table de ressources à chaque appel. La page de pilotage demande une
quinzaine de chaînes par rafraîchissement et se redessine plusieurs fois par seconde : sans
cache, ce sont des milliers de lectures par minute sur un processeur qui est déjà le facteur
limitant. `shared/Labels.mc` mémorise à la demande — une page qui n'affiche jamais les modes
« flash » ne paie jamais leurs libellés.

Une ressource manquante y retourne une chaîne vide plutôt que de lever une exception : un
écran incomplet reste préférable à un plantage de nuit, sur un vélo.

## Le widget

Écran plein affichant la page de pilotage décrite plus haut. Les commandes :

| Geste | Effet |
|---|---|
| Tape sur une tuile | applique directement le mode, ou ouvre la catégorie à son cran le plus faible |
| Tape sur le badge | bascule `AUTO` / `MANU` |
| Haut / bas | déplace le curseur d'une zone à l'autre, sur les modèles à boutons |
| Sélection | applique la zone visée par le curseur |
| Menu | ouvre les réglages, comme la roue dentée |

Une catégorie s'ouvre toujours sur **son cran le plus faible** : personne n'a envie d'éblouir
quelqu'un en touchant une icône.

L'application n'affiche pas le badge `AUTO` / `MANU` : Connect IQ isole l'état de chaque
binaire, et l'ajustement selon la vitesse ne tourne que dans le champ de données. Un badge
qui y bascule un drapeau sans effet serait un mensonge.

### Repasser de manuel à automatique

Toute action manuelle coupe l'ajustement selon la vitesse. Pour le rétablir :

| Où | Geste |
|---|---|
| Champ de données plein écran | toucher le badge `MANU` |
| Champ de données en case | taper jusqu'à « Éteint », puis **une tape de plus** — la case l'annonce : `Eteint > AUTO` |

La tape sur une case parcourt l'échelle d'intensité, puis les flashs que la lampe déclare, puis
l'extinction, puis l'automatique. Un flash désactivé dans la lampe y figure aussi : le
sélectionner l'active.

Deux choix délibérés, différents du data field :

- **Le widget n'éteint pas la lampe en le quittant.** L'utilisateur vient précisément
  d'allumer avant de partir rouler. Seule la connexion est libérée, pour que le data field ou
  le téléphone puisse la reprendre.
- **L'échelle ne boucle pas.** Arrivé au maximum on y reste, plutôt que de retomber au
  minimum — et au rallumage on reprend le cran le plus faible, jamais le plein phare.

## Traductions

Treize langues : anglais, français, allemand, espagnol, italien, portugais, néerlandais,
polonais, russe, japonais, coréen, chinois simplifié et traditionnel.

**Les fichiers `resources-<langue>/strings/strings.xml` sont générés.** La vérité est dans
`tools/i18n/<langue>.json`, une table par langue couvrant les trois jeux de ressources —
`shared`, `app`, `widget`. Après modification :

```bash
python tools/i18n/generate.py
```

Le script refuse d'écrire tant que les identifiants ne correspondent pas un pour un à ceux de
l'anglais. Ce contrôle n'est pas décoratif : un identifiant manquant compile sans erreur et
manque à l'exécution, sur les seuls appareils configurés dans cette langue — autant dire jamais
chez soi, toujours chez l'utilisateur.

L'anglais et le français restent écrits à la main : ils portent les commentaires de maintenance,
que le générateur ne produit pas.

### Le jeu de polices se choisit à la fabrication de l'appareil, pas à la compilation

Le SDK associe chaque **référence matérielle** à un jeu de polices. Les 13 modèles totalisent 18
références : les « ww » portent les langues européennes, les APAC portent le japonais, le coréen,
le chinois et le thaï. Un Edge 1030 européen n'affichera jamais de japonais, quoi qu'on déclare.
Aucune langue hors l'anglais n'est donc portée par les 18 références, et c'est sans conséquence :
une langue absente retombe sur l'anglais.

```bash
python tools/i18n/langues-supportees.py --declarees
```

### Ce qui limite le nombre de langues, c'est le budget mémoire

Chaque langue déclarée grossit le binaire, qu'elle serve ou non sur la référence compilée. Un
champ de données dispose de 128 Ko :

| Langues déclarées | Champ de données | Application |
|---|---|---|
| 2 | 56 620 o | 61 372 o |
| **13** | **82 668 o** | **94 956 o** |
| 36 — toutes celles du SDK | 113 180 o | 134 284 o |
Mesures sur Edge 1050, **avec le jeu d'icônes précédent** : ce qui compte ici est l'écart entre
les lignes, qui ne tient qu'aux langues. Depuis la refonte des icônes en PNG opaques, le même
binaire à 13 langues pèse 78 044 o. Sur les 13 cibles, le champ de données va de 71 308 à
80 636 octets, l'application de 81 772 à 93 548.

Les 36 langues ne laissent rien pour le tas. Les 13 retenues sont celles portées par au moins 12
références sur 18 ; les huit écartées — arabe, bulgare, estonien, letton, lituanien, roumain,
turc, ukrainien — ne le sont que par **une seule**.

### Le français était écrit sans accents

Les trois fichiers français étaient en ASCII pur : « Eteindre », « reglages »,
« caracteristiques ». Rien ne l'imposait — les références qui portent le français portent aussi
les diacritiques latines — et cela se voyait à l'écran. Rétabli par `tools/i18n/accents-fre.py`,
idempotent, qui remplace par identifiant et jamais par mot : « Route » est à la fois une
catégorie et un préfixe de mode.

## Ce qui n'est verifie que sur un Edge 1050

La question se pose a chaque reglage d'affichage : est-ce accorde au 1050, ou aux treize ?
Voici l'etat exact.

Verifie sur les 13 cibles, contre les profils du SDK et non contre la documentation :

| Point | Comment |
|---|---|
| Taille d'icone par appareil | `tools/check-icons.py` — manifeste, profil SDK, jungle et PNG croises |
| Opacite des icones, quatre coins identiques | idem |
| Formats d'ecran | les six formats du test correspondent un pour un a `resolution` des 13 profils |
| Mise en page de la page complete | 1 925 combinaisons : 6 formats, 4 decoupes de champ, 5 jeux de polices, 2 a 6 categories |
| Langues portees par chaque reference | `tools/i18n/langues-supportees.py` |
| Compilation | 26 binaires, et types stricts sur un Edge 530 — pas sur le 1050 |
| Suite de tests | `bash app/build.sh test-all` : 530, MTB, 1040, 1050 |

**Ce qui reste propre au 1050 : le materiel.** C'est le seul exemplaire physique disponible, et
aucun simulateur ne remplace un essai avec une vraie lampe. Un retour d'un modele a boutons
reste la derniere piece manquante avant une sortie publique.

Deux details valent d'etre notes, parce qu'ils ont failli passer pour des verites generales :

- **Le tableau des tailles d'icone venait d'un fil de forum.** Il se trouve qu'il etait juste,
  mais il n'etait pas verifie. `tools/check-icons.py` le relit desormais dans `compiler.json`.
- **`monkeydo` rend un code de retour non nul meme quand la suite passe.** Le mode `test-all`
  lit donc le verdict dans la sortie ; s'y fier autrement declarait les quatre profils en echec
  alors que les 58 tests etaient au vert.

## Construire

```bash
bash app/build.sh
```

```bash
bash app/build.sh test
```

```bash
bash app/build.sh edge1050
```

Le script localise seul le JDK et le SDK. Il faut une clé développeur à la racine du projet ;
si elle manque, il indique comment la générer.

**Toujours construire en release (`-r`) pour la diffusion** : les symboles de débogage font
passer le binaire de 16 Ko à 110 Ko, ce qui n'est plus anodin face aux 128 Ko d'un data field.
Utiliser `-O 2` et non `-O z` : sur ce code, l'optimisation « taille » produit un binaire plus
gros.

## Compatibilité avec le reste de la gamme

L'application ne connaît aucun modèle de lampe. Elle demande à celle qu'elle trouve **ce
qu'elle est** et **ce qu'elle sait faire**, puis s'y adapte :

| Requête | Réponse | Usage |
|---|---|---|
| `BLS_LIGHT_CFG` + `GET` | `blt_light_self.lightType` | avant, arrière, frontale, gauche, droite |
| `BLS_MODE_SUP` + `GET` | liste répétée de `blt_mode_sup.mode` | modes réellement disponibles |

`LightConstants.ladderFor()` construit alors l'échelle d'intensité utilisée par l'automatisme
et par le cycle tactile :

- **Lampe avant à haut et bas faisceau** (VS1200S, VS1800S) → six crans, du croisement bas au
  plein phare.
- **Lampe avant à intensité simple** (VS500, VS800) → les crans `LOW`/`MID`/`HIGH`/`SUPERHIGH`
  qu'elle déclare.
- **Feu arrière** (TL30, TL50) → intensités simples ; on ne cherche pas de faisceau chez lui.
- **Aucune réponse encore reçue** → échelle haut/bas faisceau par défaut, le cas d'usage visé.

Les seuils de vitesse se répartissent sur le nombre de crans réellement disponibles : une
lampe à quatre modes n'ignore pas le seuil haut, elle l'atteint plus tôt.

**Conséquence pratique : il n'est pas nécessaire de posséder chaque modèle pour le supporter.**
Un modèle non testé sera piloté correctement s'il répond à ces deux requêtes comme la VS1800S.

Deux réserves honnêtes :

1. **Deux familles de messages coexistent** dans l'app iGPSPORT (`PeripheralLightApp` et
   `PeripheralLight`, voir protocole §3). Si un modèle ancien ne parle que la seconde, il
   faudra ajouter ce dialecte. Rien dans l'analyse statique n'indique lequel parle quoi.
2. **Une seule lampe à la fois.** Piloter simultanément un phare et un feu arrière suppose deux
   connexions BLE : c'est prévu par la plateforme (`getAvailableConnectionCount()`) et le même
   profil GATT sert aux deux, mais la machine à états de `LampManager` gère un seul appareil.
   C'est un chantier à part entière, pas un réglage.

## Ce qui reste à faire

| # | Sujet | Dépend de la lampe |
|---|---|---|
| 1 | Confirmer l'encodage de l'extinction sur la lampe réelle | oui |
| 2 | Piloter un phare **et** un feu arrière simultanément (deux connexions BLE) | oui, deux appareils |
| 3 | Essai de bout en bout contre une fausse lampe — voir [essai-sans-lampe.md](essai-sans-lampe.md) | non |
| 4 | Voir la page sur un écran réel autre qu'un 1050 — sur le 1050, tout est validé | non |
| 5 | Publication sur le Connect IQ Store (objectif O8) — voir [depot-beta.md](depot-beta.md) | oui |

Le point 2 est le principal écart connu : l'application gère une lampe à la fois.

Le point 4 est une **vérification visuelle**, pas une inconnue : la géométrie est prouvée sur
les six formats d'écran par les tests, mais les hauteurs de police des appareils à polices
vectorielles (550, 850, 1040, 1050) sont encadrées et non relevées — le SDK n'en donne qu'une
taille relative. Un coup d'œil sur un 530 ou un Explore lèverait le dernier doute.
