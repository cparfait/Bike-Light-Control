# Fiches du Connect IQ Store

Deux paquets, donc **deux fiches distinctes**. Les textes ci-dessous sont prêts à coller dans
le formulaire de dépôt.

Le titre ne contient ni « Edge » ni « iGPSPORT » : depuis 2025, l'équipe du store traite tout
usage d'une marque Garmin dans un titre comme une infraction, noms de produits compris, et
« iGPSPORT » appartient à un tiers. L'accord développeur autorise en revanche à **mentionner la
compatibilité** dans la description — c'est ce que font les deux textes.

**Les descriptions nomment donc la marque et le modèle dès la première ligne.** Elles disaient
auparavant « pilote une lampe vélo Bluetooth », ce qui était faux sur deux plans : l'application
ne détecte aucune lampe d'une autre marque — son filtre de scan cherche un service Nordic UART
et un nom en « VS… » ou « TL… » — et seule la VS1800S a été essayée sur du matériel. Un
utilisateur venu avec une Varia ou une Lezyne n'aurait rien trouvé du tout, et l'aurait écrit
dans son avis. Un titre générique impose une description précise.

| | Champ de données | Application |
|---|---|---|
| Paquet | `dist/bike-light-control.iq` | `dist/bike-light-panel.iq` |
| Titre (en) | Bike Light Control | Bike Light Panel |
| Titre (fr) | Commande éclairage vélo | Panneau éclairage vélo |
| Titre (de) | Fahrradlicht Steuerung | Fahrradlicht Panel |
| Titre (es) | Control de Luz de Bici | Panel de Luz de Bici |
| Titre (it) | Controllo Luce Bici | Pannello Luce Bici |
| Titre (pt) | Controlo de Luz de Bici | Painel de Luz de Bici |
| Titre (nl) | Fietslicht Bediening | Fietslicht Paneel |
| Titre (pl) | Sterowanie Lampką Roweru | Panel Lampki Roweru |
| Titre (ru) | Управление велофарой | Панель велофары |
| Titre (ja) | バイクライト コントロール | バイクライト パネル |
| Titre (ko) | 자전거 라이트 제어 | 자전거 라이트 패널 |
| Titre (zh-CN) | 自行车灯控制 | 自行车灯面板 |
| Titre (zh-TW) | 自行車燈控制 | 自行車燈面板 |
| Icône 500×500 | `store/app-icon-500.png` | `store/widget-icon-500.png` |
| Type | Data field | Device app |

Produire les paquets :

```bash
bash app/build.sh package
```

**Version à saisir dans le formulaire : 1.0.0**, en bêta. Le manifeste n'en
porte pas ; `CHANGELOG.md` en garde la trace.

---

## Champ de données — description

**Anglais**

> Controls an **iGPSPORT VS1800S** bike light from your bike computer, during the ride.
>
> **Read this first.** This is not a generic Bluetooth light controller. It speaks the iGPSPORT
> protocol, and it will not find or drive lights from any other brand — Garmin Varia, Bontrager,
> Lezyne, Knog and the rest are out of reach, whatever their Bluetooth support.
>
> Developed and tested on a VS1800S, and on that model only. Other iGPSPORT lights — VS1200,
> VS800, VS500, and the TL30 and TL50 rear lights — stand a fair chance of working: the app asks
> the light for its type and its list of modes instead of assuming, and adapts to the answer. But
> none of them has been tried on real hardware. Treat them as untested, not as supported.
>
> The light follows your speed: dim when stopped or climbing, full beam on a fast descent.
> Thresholds are yours to set. Battery running low? The field caps the brightness so the light
> lasts to the end of the ride, and turns it off when you stop the timer — not when you pause at
> a red light.
>
> Riding in daylight? Turn off "switch light on when ride starts" and the light stays as you
> left it until you ask for it.
>
> Light level and light battery are recorded in the activity file, so you can see them on the
> chart in Garmin Connect afterwards.
>
> Speed thresholds are set in km/h. The light's Bluetooth protocol has no authentication: any
> device in range could drive it, whichever app is used — that is a property of the light.
>
> Several lights around? The app picks the closest one, and that light blinks twice at
> connection so you can see it is yours. If it is not, switch to the next one from the settings.
>
> **The field never searches on its own.** A Bluetooth scan is the most expensive thing an app
> can do to your bike computer's battery, and the light stays in the drawer on most rides. So the
> field waits for you: tap it on a touch screen, press Lap on a model with buttons. The search is
> time-boxed — no light nearby, no scan draining the ride. A setting can start it with the timer
> instead, off by default.
>
> On a touch screen, tap the field to pick a mode by hand. Tap once more when the light is off
> to hand control back to the automatic adjustment.
>
> Thresholds and settings are adjustable from Garmin Connect, and from the bike computer itself.
> Speeds are in km/h.
>
> Not affiliated with, or endorsed by, iGPSPORT. The protocol was worked out independently; the
> name is used only to say which lights this drives.
>
> Companion app "Bike Light Panel" available separately, for controlling the light before you
> set off and on models without a touch screen.

**Français**

> Pilote une lampe velo **iGPSPORT VS1800S** depuis le compteur, pendant la sortie.
>
> **A lire avant d'installer.** Ce n'est pas un pilote de lampe Bluetooth generique. L'application
> parle le protocole iGPSPORT, et elle ne trouvera ni ne pilotera aucune lampe d'une autre
> marque — Garmin Varia, Bontrager, Lezyne, Knog et les autres sont hors de portee, quel que soit
> leur Bluetooth.
>
> Developpee et essayee sur une VS1800S, et sur ce seul modele. Les autres lampes iGPSPORT —
> VS1200, VS800, VS500, et les feux arriere TL30 et TL50 — ont de bonnes chances de fonctionner :
> l'application demande a la lampe son type et sa liste de modes au lieu de supposer, et s'adapte
> a la reponse. Mais aucune n'a ete essayee sur du materiel reel. A considerer comme non
> verifiees, pas comme prises en charge.
>
> La lampe suit la vitesse : faible a l'arret et en cote, plein faisceau en descente. Les seuils
> se reglent. Batterie basse ? Le champ plafonne l'intensite pour que la lampe tienne jusqu'au
> bout, et l'eteint a l'arret du chrono — pas a la pause d'un feu rouge.
>
> Vous roulez de jour ? Decochez « allumer la lampe au depart » et la lampe reste comme vous
> l'avez laissee jusqu'a ce que vous la demandiez.
>
> Le niveau et la batterie de la lampe sont enregistres dans le fichier d'activite : ils
> apparaissent ensuite sur le graphique dans Garmin Connect.
>
> Les seuils de vitesse se reglent en km/h. Le protocole Bluetooth de la lampe n'a aucune
> authentification : tout appareil a portee peut la piloter, quelle que soit l'application —
> c'est une propriete de la lampe.
>
> Plusieurs lampes autour de vous ? L'application retient la plus proche, et celle-ci clignote
> deux fois a la connexion pour que vous la reconnaissiez. Si ce n'est pas la bonne, on passe a
> la suivante depuis les reglages.
>
> **Le champ ne cherche jamais la lampe tout seul.** Un scan Bluetooth est ce qui coute le plus
> cher a la batterie du compteur, et la lampe reste au tiroir la plupart des sorties. Le champ
> attend donc un geste : une tape sur un ecran tactile, le bouton Lap sur un modele a boutons. La
> recherche est bornee dans le temps — pas de lampe a portee, pas de scan qui vide la sortie. Un
> reglage permet de la lancer au depart du chrono, decoche par defaut.
>
> Sur ecran tactile, une tape sur le champ change de mode a la main. Une tape de plus, lampe
> eteinte, rend la main a l'ajustement automatique.
>
> Les seuils et les reglages se modifient depuis Garmin Connect, et depuis le compteur lui-meme.
> Les vitesses sont en km/h.
>
> Sans lien avec iGPSPORT, ni aval de sa part. Le protocole a ete etabli de facon independante ;
> le nom ne sert qu'a dire quelles lampes sont pilotees.
>
> Application compagnon « Panneau eclairage velo » disponible separement, pour piloter la lampe
> avant de partir et sur les modeles sans ecran tactile.

## Application — description

**Anglais**

> Control panel for an **iGPSPORT VS1800S** bike light, outside the ride.
>
> **Read this first.** This is not a generic Bluetooth light controller. It speaks the iGPSPORT
> protocol, and it will not find or drive lights from any other brand.
>
> Developed and tested on a VS1800S, and on that model only. Other iGPSPORT lights — VS1200,
> VS800, VS500, TL30, TL50 — stand a fair chance of working, since the app asks the light for its
> type and its modes rather than assuming, but none has been tried on real hardware.
>
> Pick a mode by category — steady beam, flash, off — and see the battery level and the
> remaining runtime. The light's own automations (light sensor, auto sleep, dim when stopped)
> are readable and adjustable from here, without reaching for your phone.
>
> Works on models with a touch screen and on models with buttons: on the latter, the up and down
> keys move a cursor and the Menu key opens the settings.
>
> Companion to the "Bike Light Control" data field, which handles the ride itself.
>
> Not affiliated with, or endorsed by, iGPSPORT. The protocol was worked out independently; the
> name is used only to say which lights this drives.

**Français**

> Panneau de pilotage d'une lampe velo **iGPSPORT VS1800S**, hors activite.
>
> **A lire avant d'installer.** Ce n'est pas un pilote de lampe Bluetooth generique. L'application
> parle le protocole iGPSPORT, et ne trouvera aucune lampe d'une autre marque.
>
> Developpee et essayee sur une VS1800S, et sur ce seul modele. Les autres lampes iGPSPORT —
> VS1200, VS800, VS500, TL30, TL50 — ont de bonnes chances de fonctionner, l'application
> interrogeant la lampe sur son type et ses modes au lieu de supposer, mais aucune n'a ete
> essayee sur du materiel reel.
>
> Choix du mode par categorie — faisceau, flash, extinction — avec le niveau de batterie et
> l'autonomie restante. Les automatismes de la lampe (capteur de luminosite, veille automatique,
> luminosite reduite a l'arret) se lisent et se reglent depuis le compteur, sans sortir le
> telephone.
>
> Fonctionne sur les modeles tactiles comme sur ceux a boutons : sur ces derniers, haut et bas
> deplacent un curseur, et la touche Menu ouvre les reglages.
>
> Complement du champ de donnees « Commande eclairage velo », qui prend le relais pendant la
> sortie.
>
> Sans lien avec iGPSPORT, ni aval de sa part. Le protocole a ete etabli de facon independante ;
> le nom ne sert qu'a dire quelles lampes sont pilotees.

---

## Avant de deposer

- [ ] **La surcouche de diagnostic est hors du binaire** tant que les deux jungles gardent
      `base.excludeAnnotations = debug`. Verifier : `grep -n excludeAnnotations app/monkey.jungle
      widget/monkey.jungle` doit rendre `debug` deux fois, et `grep -rn "debug = true" widget/ app/
      shared/` ne rien rendre.
- [ ] **Sauvegarder `developer_key.der` hors de cette machine.** Garmin lie definitivement une
      application publiee a la cle qui l'a signee. Perdue, plus aucune mise a jour n'est
      possible : il faut redeposer sous une nouvelle fiche, et les utilisateurs deja installes
      ne suivent pas. La cle est exclue du depot — un `git clone` ne la sauvegarde donc pas.
- [ ] Noter le numero de version depose dans `CHANGELOG.md` : le manifeste n'en porte pas, il se
      saisit dans le formulaire, et rien d'autre n'en garde la trace.
- [ ] Les titres ci-dessus sont ceux affiches **sur le compteur** ; ils viennent des tables de
      `tools/i18n/`. Le formulaire du store a ses propres champs par langue : y coller les memes
      titres, sans quoi la fiche et l'appareil ne diront pas la meme chose.
- [ ] Les descriptions longues n'existent qu'en anglais et en francais. Le store accepte une
      fiche par langue ; a defaut il retombe sur l'anglais, ce qui reste acceptable.
- [ ] Publier d'abord en **beta** : c'est la seule facon de verifier les champs FIT et les
      reglages depuis Garmin Connect, que le simulateur ne rend pas.
- [x] **Captures d'ecran : prises, retenues et rangees dans `store/screenshots/`.** Aux pixels
      exacts de chaque appareil, sans gabarit autour, produites par
      `bash tools/sim-captures.sh` puis `tools/sim-crop.py`.

      | Fiche | Fichier | Appareil | Ce qu'on y voit |
      |---|---|---|---|
      | Champ de donnees | `control-1-edge1050.png` | 1050, 480x800 | la page complete, badge AUTO |
      | Champ de donnees | `control-2-edge1030.png` | 1030, 282x470 | la meme, ecran moyen |
      | Champ de donnees | `control-3-edge830.png` | 830, 246x322 | le plus petit format |
      | Champ de donnees | `control-4-edge550.png` | 550, 420x600 | polices vectorielles |
      | Application | `panel-1-edge1030.png` | 1030 | la page, avec l'acces aux reglages |
      | Application | `panel-2-edge830.png` | 830 | la meme, petit ecran |
      | Application | `panel-3-edge530.png` | 530 | modele a boutons, curseur visible |
      | Application | `panel-4-glance-edge1050.png` | 1050 | la vignette de resume |

      Les regenerer apres toute retouche d'interface : elles ne se mettent pas a jour seules.
- [ ] Aucune permission reseau n'est demandee : pas de politique de confidentialite a fournir.
- [ ] Verifier que le paquet contient bien la declaration des champs FIT :
      `7z l dist/bike-light-control.iq | grep fit_contributions`
- [ ] La revue Garmin prend quelques jours. En attendant, la fiche est invisible mais
      l'application reste installable par son auteur.
