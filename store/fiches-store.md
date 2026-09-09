# Fiches du Connect IQ Store

Deux paquets, donc **deux fiches distinctes**. Les textes ci-dessous sont prêts à coller dans
le formulaire de dépôt.

Le titre ne contient ni « Edge » ni « iGPSPORT » : depuis 2025, l'équipe du store traite tout
usage d'une marque Garmin dans un titre comme une infraction, noms de produits compris, et
« iGPSPORT » appartient à un tiers. L'accord développeur autorise en revanche à **mentionner la
compatibilité** dans la description — c'est ce que font les deux textes.

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

---

## Champ de données — description

**Anglais**

> Controls a Bluetooth bike light from your bike computer, during the ride.
>
> The light follows your speed: dim when stopped or climbing, full beam on a fast descent.
> Thresholds are yours to set. Battery running low? The field caps the brightness so the light
> lasts to the end of the ride, and turns it off when you stop the timer — not when you pause at
> a red light.
>
> Riding in daylight? Turn off "switch light on when ride starts" and the light stays as you
> left it until you ask for it.
>
> Light mode and light battery are recorded in the activity file, so you can see them on the
> chart in Garmin Connect afterwards.
>
> Several lights around? The app picks the closest one, and that light blinks twice at
> connection so you can see it is yours. If it is not, switch to the next one from the settings.
>
> On a touch screen, tap the field to pick a mode by hand. Tap once more when the light is off
> to hand control back to the automatic adjustment.
>
> Works with Bluetooth lights from iGPSPORT (VS1800S, VS1200, VS800, VS500, TL30, TL50). The
> app asks the light what it can do rather than assuming, so a model that is not listed here
> may well work too. Not affiliated with, or endorsed by, iGPSPORT.
>
> Companion app "Bike Light Panel" available separately, for controlling the light before you
> set off and on models without a touch screen.

**Français**

> Pilote une lampe velo Bluetooth depuis le compteur, pendant la sortie.
>
> La lampe suit la vitesse : faible a l'arret et en cote, plein faisceau en descente. Les seuils
> se reglent. Batterie basse ? Le champ plafonne l'intensite pour que la lampe tienne jusqu'au
> bout, et l'eteint a l'arret du chrono — pas a la pause d'un feu rouge.
>
> Vous roulez de jour ? Decochez « allumer la lampe au depart » et la lampe reste comme vous
> l'avez laissee jusqu'a ce que vous la demandiez.
>
> Le mode et la batterie de la lampe sont enregistres dans le fichier d'activite : ils
> apparaissent ensuite sur le graphique dans Garmin Connect.
>
> Plusieurs lampes autour de vous ? L'application retient la plus proche, et celle-ci clignote
> deux fois a la connexion pour que vous la reconnaissiez. Si ce n'est pas la bonne, on passe a
> la suivante depuis les reglages.
>
> Sur ecran tactile, une tape sur le champ change de mode a la main. Une tape de plus, lampe
> eteinte, rend la main a l'ajustement automatique.
>
> Compatible avec les lampes Bluetooth iGPSPORT (VS1800S, VS1200, VS800, VS500, TL30, TL50).
> L'application interroge la lampe au lieu de supposer : un modele absent de cette liste a de
> bonnes chances de fonctionner aussi. Sans lien avec iGPSPORT.
>
> Application compagnon « Panneau eclairage velo » disponible separement, pour piloter la lampe
> avant de partir et sur les modeles sans ecran tactile.

## Application — description

**Anglais**

> Control panel for a Bluetooth bike light, outside the ride.
>
> Pick a mode by category — steady beam, flash, off — and see the battery level and the
> remaining runtime. The light's own automations (light sensor, auto sleep, dim when stopped)
> are readable and adjustable from here, without reaching for your phone.
>
> Works on models with a touch screen and on models with buttons.
>
> Companion to the "Bike Light Control" data field, which handles the ride itself.
>
> Works with Bluetooth lights from iGPSPORT (VS1800S, VS1200, VS800, VS500, TL30, TL50). Not
> affiliated with, or endorsed by, iGPSPORT.

**Français**

> Panneau de pilotage d'une lampe velo Bluetooth, hors activite.
>
> Choix du mode par categorie — faisceau, flash, extinction — avec le niveau de batterie et
> l'autonomie restante. Les automatismes de la lampe (capteur de luminosite, veille automatique,
> luminosite reduite a l'arret) se lisent et se reglent depuis le compteur, sans sortir le
> telephone.
>
> Fonctionne sur les modeles tactiles comme sur ceux a boutons.
>
> Complement du champ de donnees « Commande eclairage velo », qui prend le relais pendant la
> sortie.
>
> Compatible avec les lampes Bluetooth iGPSPORT (VS1800S, VS1200, VS800, VS500, TL30, TL50).
> Sans lien avec iGPSPORT.

---

## Avant de deposer

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
- [ ] Au moins une capture d'ecran par fiche. Le panneau plein ecran sur un 1050 est le plus
      parlant ; une seconde capture du champ dans une page a six cases montre l'autre usage.
- [ ] Aucune permission reseau n'est demandee : pas de politique de confidentialite a fournir.
- [ ] Verifier que le paquet contient bien la declaration des champs FIT :
      `7z l dist/bike-light-control.iq | grep fit_contributions`
- [ ] La revue Garmin prend quelques jours. En attendant, la fiche est invisible mais
      l'application reste installable par son auteur.
