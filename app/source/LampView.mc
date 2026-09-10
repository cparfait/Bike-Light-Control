using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.Lang;
using Toybox.System;
using Toybox.FitContributor;
using Toybox.Application;
using Toybox.Attention;
using LightConstants as LC;

//! Data field : affiche l'état de la lampe et applique les automatismes.
//!
//! On étend `DataField` et non `SimpleDataField` : c'est la seule classe qui
//! reçoit `onTap()`, indispensable au changement de mode manuel sur les Edge à
//! écran tactile (docs/compatibilite-edge.md).
class LampView extends WatchUi.DataField {

    private var _lamp as LampManager;
    private var _auto as AutoController;
    private var _speed as Lang.Float = 0.0;
    //! Trois dernieres mesures de vitesse, pour la moyenne glissante de
    //! `_smoothed()`. Trois et pas plus : au-dela, la lampe reagirait avec un
    //! retard visible en haut d'une bosse.
    private var _speedSamples as Lang.Array = [0.0, 0.0, 0.0];
    private var _timerRunning as Lang.Boolean = false;
    private var _touch as Lang.Boolean = false;

    //! Vrai une fois l'alerte de batterie faible jouee, pour ne la jouer
    //! qu'une fois par passage sous le seuil.
    private var _lowAlerted as Lang.Boolean = false;

    //! Niveau FIT des modes hors echelle d'intensite — flashs, effets, modes
    //! personnalises. Au-dessus de tout cran, pour que la courbe les distingue.
    static const FIT_LEVEL_OTHER = 9;

    // Champs enregistres dans le FIT : le mode et la batterie de la lampe
    // apparaissent alors dans Garmin Connect, alignes sur la trace GPS. C'est
    // ce qui permet, apres coup, de comprendre pourquoi la lampe s'est comportee
    // comme elle l'a fait a tel endroit du parcours.
    private var _fitMode as FitContributor.Field or Null = null;
    private var _fitBattery as FitContributor.Field or Null = null;

    //! Panneau complet, partagé avec l'application compagnon. N'est utilisé que
    //! si le champ occupe assez de place ; sinon on garde l'affichage à deux
    //! lignes, qui reste lisible dans une case d'un sixième d'écran.
    private var _panel as LampPanel;

    function initialize(lamp as LampManager, auto as AutoController) {
        DataField.initialize();
        _lamp = lamp;
        _auto = auto;
        _panel = new LampPanel(lamp, auto);
        // Un data field ne recoit jamais d'evenement de touche, meme plein
        // ecran : le curseur des modeles a boutons y serait immobile.
        _panel.hideCursor();
        // Surcouche de diagnostic, eteinte. Le drapeau existe dans les DEUX
        // binaires : il ne vivait que dans l'application compagnon, et la page
        // pleine du champ de donnees — celle qu'on regarde en roulant —
        // n'affichait donc rien. Voir docs/protocole-vs1800s.md.
        _panel.debug = false;
        // Le tactile n'est pas exposé dans les profils du SDK : c'est une
        // propriété d'exécution. Un seul binaire pour les 13 modèles.
        var settings = System.getDeviceSettings();
        _touch = (settings has :isTouchScreen) && settings.isTouchScreen;

        // Le niveau d'intensite, pas le numero de mode. L'enumeration brute
        // donnait 12, 11, 10, 9, 8, 7 pour les six crans croissants d'une
        // VS1800S : une courbe qui descend quand la lampe monte, illisible.
        // Ici 0 est eteint, 1 le cran le plus faible, et ainsi de suite.
        _fitMode = createField("light_level", 0, FitContributor.DATA_TYPE_UINT8,
            { :mesgType => FitContributor.MESG_TYPE_RECORD });
        _fitBattery = createField("light_battery", 1, FitContributor.DATA_TYPE_UINT8,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "%" });
    }

    //! Appelé à chaque seconde d'activité. Sert aussi de battement au
    //! gestionnaire BLE, qui n'embarque volontairement pas de minuteur.
    //!
    //! La relecture des réglages n'est **pas** ici : le SDK ne déclare
    //! `onSettingsChanged` que sur `AppBase`, et une méthode de ce nom écrite
    //! sur la vue ne serait jamais appelée. Voir `LampApp.onSettingsChanged()`.
    function compute(info as Activity.Info) as Void {
        _lamp.tick();
        _auto.setSupportedModes(_lamp.status.supportedModes, _lamp.status.lightType);

        _speed = _smoothed(info.currentSpeed);

        // Pause et arret sont deux choses differentes : la pause automatique
        // se declenche a chaque feu rouge, et eteindre la lampe la est
        // exactement le contraire de ce qu'il faut faire. Voir
        // AutoController.onRideState().
        var ride = AutoController.rideStateOf(info.timerState);
        var running = (ride == AutoController.RIDE_RUNNING);

        // Si le reglage le demande — il est decoche par defaut — le chrono qui
        // part, ou repart apres une pause ou un arret, lance la recherche
        // quand rien n'est en cours. C'est le seul geste qui existe sur un Edge
        // a boutons, et c'est ce qui y retrouve une lampe perdue pendant un
        // arret au cafe : la recherche est bornee (LampManager.SCAN_MAX_S), la
        // reprise la relance.
        if (running && !_timerRunning && _lamp.isIdle()
                && AutoController.searchOnStart(false)) {
            _lamp.start();
        }

        var mode = _auto.onRideState(ride, _lamp.status.mode);
        if (mode == null && running) {
            mode = _auto.modeForSpeed(_speed, _lamp.status.batteryPct, _lamp.status.mode);
        }
        if (mode != null && _lamp.isReady()) {
            _lamp.setMode(mode);
            // Anticipation optimiste : évite de renvoyer la même commande à la
            // seconde suivante, avant que la lampe n'ait notifié son nouvel état.
            _lamp.status.mode = mode;
        }

        // Rien n'est ecrit tant que la lampe n'a rien dit. Un 0 % « par
        // defaut » passait pour une mesure dans Garmin Connect, et un trou dans
        // la courbe est la seule facon honnete de dire « pas de lampe ».
        var m = _lamp.status.mode;
        if (_fitMode != null && m != null) {
            _fitMode.setData(_fitLevel(m));
        }
        var b = _lamp.status.batteryPct;
        if (_fitBattery != null && b != null) {
            _fitBattery.setData(b);
        }
        _alertLowBattery(b);

        _timerRunning = running;
    }

    //! Niveau d'intensite ecrit dans le FIT : 0 eteint, puis le cran dans
    //! l'echelle de la lampe a partir de 1, et une valeur a part pour ce qui
    //! n'est pas un cran.
    private function _fitLevel(mode as Lang.Number) as Lang.Number {
        if (mode == LC.BLM_LIGHT_OFF) { return 0; }
        var ladder = _auto.ladder();
        for (var i = 0; i < ladder.size(); i++) {
            if (ladder[i] == mode) { return i + 1; }
        }
        return FIT_LEVEL_OTHER;
    }

    //! Un signal sonore, une fois, au passage sous le seuil de batterie (F7).
    //!
    //! La couleur seule ne suffisait pas : de nuit, personne ne regarde la case
    //! au moment precis ou elle passe au rouge. Rejoue seulement si la charge
    //! est remontee nettement au-dessus du seuil — une lampe rechargee entre
    //! deux sorties — et jamais pendant que la lampe est absente.
    private function _alertLowBattery(pct as Lang.Number or Null) as Void {
        if (pct == null) { return; }
        if (_auto.isBatteryLow(pct)) {
            if (_lowAlerted) { return; }
            _lowAlerted = true;
            if (Attention has :playTone) {
                try { Attention.playTone(Attention.TONE_ALERT_LO); } catch (e) { }
            }
        } else if (!_auto.isBatteryLow(pct - 5)) {
            _lowAlerted = false;
        }
    }

    //! Moyenne des trois dernières secondes de vitesse.
    //!
    //! `Activity.Info.currentSpeed` est la vitesse **instantanée** : sur route
    //! dégradée ou en sortie de virage, elle saute d'un ou deux km/h d'une
    //! seconde à l'autre. L'hystérésis de `AutoController` absorbe le
    //! papillonnage autour d'un seuil, mais pas le bruit de la mesure
    //! elle-même — et un seul échantillon aberrant suffit à faire changer la
    //! lampe de cran, ce qui se voit sur la route.
    private function _smoothed(speed as Lang.Float or Null) as Lang.Float {
        var v = (speed == null) ? 0.0 : speed;
        _speedSamples[0] = _speedSamples[1];
        _speedSamples[1] = _speedSamples[2];
        _speedSamples[2] = v;
        return ((_speedSamples[0] as Lang.Float)
              + (_speedSamples[1] as Lang.Float)
              + (_speedSamples[2] as Lang.Float)) / 3.0;
    }

    //! Changement de mode manuel : on avance d'un cran dans l'échelle, et on
    //! repasse à l'extinction après le mode le plus fort.
    function onTap(evt as WatchUi.ClickEvent) as Lang.Boolean {
        // Au repos, la page n'est qu'un bouton : la tape lance la recherche.
        // A tester avant `isReady()`, qui rendait `false` et laissait le geste
        // sans effet.
        if (_lamp.isIdle()) { _lamp.start(); return true; }
        if (!_lamp.isReady()) { return false; }
        // Liaison faite mais bilan initial pas encore revenu : la page affiche
        // « Connexion », pas ses tuiles. On avale la tape — sans quoi elle
        // retombait sur le cycle a l'aveugle et posait un mode juste avant que
        // `LampManager` ne pose le sien. Voir LampManager.isSettling().
        if (_lamp.isSettling()) { return true; }
        // Pendant l'identification, une tape veut dire « c'est bon, j'ai vu » :
        // on abrege et on remet la lampe comme on l'a trouvee. La tape etait
        // auparavant avalee sans effet, ce qui faisait de cet ecran une
        // question sans reponse — il n'y avait qu'a attendre.
        if (_lamp.isIdentifying()) { _lamp.cancelIdentify(); return true; }

        // Panneau affiché : on applique le bouton touché plutôt que de faire
        // défiler les modes à l'aveugle.
        if (_panel.hitBoxes.size() > 0) {
            var p = evt.getCoordinates();
            var action = _panel.actionAt(p[0], p[1]);
            if (action != null && action >= 0) {
                _auto.setEnabledManually(false);
                _apply(action);
                _panel.chooseCategory(LC.categoryOf(action));
                return true;
            }
            if (action != null && action == LampPanel.ACTION_AUTO) {
                // Le badge est le seul moyen de rendre la main à l'ajustement
                // selon la vitesse sans passer par l'extinction.
                _auto.setEnabledManually(!_auto.enabled);
                return true;
            }
            if (action != null && action <= LampPanel.ACTION_CATEGORY) {
                var cat = LampPanel.ACTION_CATEGORY - action;
                _panel.chooseCategory(cat);
                var modes = _lamp.modesFor(cat);
                if (modes.size() > 0) {
                    _auto.setEnabledManually(false);
                    _apply(modes[0] as Lang.Number);
                }
                return true;
            }
            // Panneau affiché et tape à côté de toute tuile — sur le libellé du
            // mode, par exemple : on ne fait rien. Sans ce retour, on retombait
            // sur le cycle de la petite case, et toucher le texte faisait
            // défiler les modes.
            return true;
        }

        // Le cycle parcourt l'echelle d'intensite, puis les flashs que la lampe
        // declare, puis l'extinction. L'echelle seule — celle de l'automatisme —
        // ne contient que les faisceaux : les deux flashs de la VS1800S etaient
        // injoignables depuis une case de page de donnees.
        var ladder = _cycle();
        var current = _lamp.status.mode;

        // Le cycle se referme sur l'automatique : une tape de plus quand la
        // lampe est eteinte rend la main a l'ajustement selon la vitesse. Sans
        // ca, un seul geste condamnait au manuel jusqu'a la fin de l'activite.
        if (!_auto.enabled && current != null && current == LC.BLM_LIGHT_OFF) {
            _auto.setEnabledManually(true);
            return true;
        }

        // Toute autre action manuelle suspend l'ajustement : sinon la seconde
        // suivante le remettrait à sa valeur, et le geste paraîtrait ignoré.
        _auto.setEnabledManually(false);

        var next = ladder[0];
        if (current != null) {
            var idx = -1;
            for (var i = 0; i < ladder.size(); i++) {
                if (ladder[i] == current) { idx = i; }
            }
            if (idx < 0) {
                next = ladder[0];
            } else if (idx >= ladder.size() - 1) {
                next = LC.BLM_LIGHT_OFF;
            } else {
                next = ladder[idx + 1];
            }
        }
        _apply(next);
        return true;
    }

    //! Applique un mode demande par un geste.
    //!
    //! L'ecriture part, et l'etat local suit sans attendre la notification de la
    //! lampe : l'ecran doit repondre au doigt. Le rappel « pensez a l'eteindre au
    //! bouton » n'est plus declenche ici — il depend de l'etat, pas du geste, et
    //! vit dans `LampPanel._drawOffNotice()`.
    private function _apply(mode as Lang.Number) as Void {
        _lamp.setMode(mode);
        _lamp.status.mode = mode;
    }

    // ---- Affichage ---------------------------------------------------------

    //! Un data field peut occuper toute la page comme un huitième d'écran. La
    //! mise en page se calcule donc à partir de la hauteur réelle et de la
    //! hauteur des polices, jamais à partir de constantes en pixels — la version
    //! précédente dessinait la seconde ligne à deux pixels du bord, moitié hors
    //! de l'écran.
    function onUpdate(dc as Graphics.Dc) as Void {
        // Plein écran : on affiche le panneau complet, avec ses catégories et
        // ses niveaux. C'est la même mise en page que l'application compagnon.
        if (LampPanel.fits(dc.getWidth(), dc.getHeight())) {
            // Au repos, la page complete se passe de consigne : son bouton
            // encadre dit deja « Detecter ». Sauf si la recherche part avec le
            // chrono — ca, le bouton ne le dit pas.
            if (_lamp.isIdle()) {
                _panel.idleHint = AutoController.searchOnStart(false)
                    ? Labels.of(Rez.Strings.MsgIdleHintTimer) : null;
            }
            _panel.draw(dc);
            return;
        }

        // Affichage a deux lignes : le panneau n'est plus a l'ecran, ses zones
        // tactiles ne valent plus rien. Sans cet oubli, une case revenue du
        // plein ecran gardait les zones d'avant, et `onTap()` y cherchait une
        // tuile au lieu de faire defiler les modes — la case ne repondait plus.
        _panel.clearHitBoxes();

        var bg = getBackgroundColor();
        var fg = (bg == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        dc.setColor(bg, bg);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var mid = w / 2;

        // Liaison en cours : un seul texte, une seule taille.
        //
        // La case affichait auparavant l'etape en gros caracteres, avec une
        // police recalculee sur chaque mot : « Recherche » s'ecrivait deux fois
        // plus petit que « OK », et une ligne « -- » completait le tout. Trois
        // informations pour dire une seule chose.
        if (!_lamp.isReady() || _lamp.isSettling() || _lamp.isIdentifying()) {
            _drawWaiting(dc, w, h, fg);
            return;
        }

        var battery = _lamp.status.batteryPct;
        var alert = _auto.isBatteryLow(battery);
        var mode = _lamp.status.mode;
        var off = (mode != null && mode == LC.BLM_LIGHT_OFF);

        // **Le mode est la valeur principale, le pourcentage la note en bas.**
        //
        // C'etait l'inverse, et c'etait l'inverse du besoin : la charge de la
        // lampe se consulte une fois avant de partir, le mode se verifie a
        // chaque fois qu'on baisse les yeux — c'est lui qui dit si on eblouit la
        // voiture d'en face. Un « 54 » en gros caracteres au-dessus d'un
        // « Croisement 1 » minuscule faisait lire le mauvais des deux, et le mot
        // qui compte etait justement celui qu'on ne pouvait pas dechiffrer.
        //
        // Corollaire : plus de police `FONT_NUMBER_*`. Elles donnent aux champs
        // natifs leurs gros chiffres, mais n'ont **pas de lettres** — elles ne
        // savent ecrire ni « Croisement 1 » ni « Off ».
        var value;
        if (_lamp.lastError != null && !_lamp.isReady()) {
            value = _lamp.lastError;
        } else {
            // Mode inconnu : « -- », jamais « Off ». La lampe n'a pas encore
            // repondu, ce n'est pas la meme chose qu'une lampe eteinte.
            value = (mode == null) ? "--" : _modeText(mode, w);
        }

        // Ligne secondaire : la charge, puis l'autonomie quand la place le
        // permet. Connectee mais batterie pas encore annoncee : « -- » plutot
        // qu'un mot d'etat, qui ferait croire a un probleme alors que tout va
        // bien.
        // Plus de « > AUTO » accroche derriere la charge. Il voulait dire « une
        // tape de plus rend la main a l'ajustement automatique » ; colle apres
        // un pourcentage, il se lisait comme une precision sur la batterie, et
        // il apparaissait puis disparaissait sans qu'on sache ce qui l'appelait.
        // Le titre de la case dit deja AUTO ou MANUEL, en toutes lettres et a
        // sa place.
        var detail = (battery == null) ? "--" : battery.format("%d") + " %";
        // Lampe eteinte : l'autonomie affichee serait celle d'avant
        // l'extinction, donc fausse. Mieux vaut ne rien montrer.
        var left = _lamp.status.remainingMinutes;
        if (!off && left != null && left > 0 && w > 150) {
            detail += "  " + _duration(left);
        }

        // Choix des polices : la plus grande qui tienne en largeur et en hauteur.
        // La part de hauteur suit la nouvelle hierarchie — la moitie au mode, un
        // quart au reste.
        var valueFont = _fitFont(dc, value, w, h * 50 / 100);
        var detailFont = _fitFont(dc, detail, w, h * 25 / 100);

        var vh = dc.getFontHeight(valueFont);
        var dh = dc.getFontHeight(detailFont);
        var labelFont = Graphics.FONT_XTINY;
        var lh = dc.getFontHeight(labelFont);

        // L'étiquette n'apparaît que si elle ne mange pas la valeur : sur un
        // champ d'un huitième d'écran, mieux vaut la sacrifier.
        var showLabel = (h > vh + dh + lh + 6);
        var total = vh + dh + (showLabel ? lh : 0);
        var y = (h - total) / 2;
        if (y < 0) { y = 0; }

        if (showLabel) {
            // « AUTO » ou « MANUEL » : c'est un etat, pas une alerte — donc pas
            // d'orange, qui ferait croire a un probleme. Et le mot ne vaut que
            // pour l'ajustement de l'application : les automatismes internes de
            // la lampe, eux, continuent quoi qu'il arrive.
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(mid, y, labelFont,
                        Labels.of(_auto.enabled ? Rez.Strings.DfAuto : Rez.Strings.DfManual),
                        Graphics.TEXT_JUSTIFY_CENTER);
            y += lh;
        }

        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, y, valueFont, value, Graphics.TEXT_JUSTIFY_CENTER);
        y += vh;

        // Le rouge suit la charge, et donc la ligne du bas : c'est le meme rouge
        // que la jauge de la page complete, les deux affichages doivent parler
        // d'une seule voix (F7).
        dc.setColor(alert ? LC.UI_ALERT : fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, y, detailFont, detail, Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Attente de la lampe, dans une case de page de données.
    //!
    //! Même règle que la page complète : la police est mesurée sur le **plus
    //! long** des messages, pas sur celui qu'on affiche, sinon le texte change
    //! de corps à chaque étape.
    //!
    //! **Le titre est là, comme sur les cases voisines.** Il n'y était pas :
    //! « LAMPE - AUTO » ne veut rien dire sans lampe, et on l'avait donc
    //! supprimé de cet écran. Sauf qu'une case sans titre au milieu de cases qui
    //! en ont une ne se lit pas comme une case sobre, elle se lit comme une case
    //! cassée — on ne sait plus de quoi elle parle. C'est « Lampe » tout court
    //! qu'il fallait écrire, dans la police des titres et rien d'autre.
    private function _drawWaiting(dc as Graphics.Dc, w as Lang.Number,
                                  h as Lang.Number, fg as Lang.Number) as Void {
        // **Au repos, la consigne tient lieu de valeur.** La case affichait
        // « Detecter » en gros, et la consigne en dessous, en tout petit — donc
        // le mot qui ne dit rien etait le seul lisible, et celui qui dit quoi
        // faire etait illisible. Une case de page de donnees n'a pas la place
        // des deux : on garde celui qui sert.
        var idle = _lamp.isIdle();
        var message = idle ? _idleHint() : _lamp.stateMessage();
        var reference = idle ? message : LampManager.longestStateMessage();
        var font = _fitFont(dc, reference, w, h * 60 / 100);

        var hint = idle ? null : _lamp.stateHint();

        var fh = dc.getFontHeight(font);
        var hintFont = Graphics.FONT_XTINY;
        var hh = (hint == null) ? 0 : dc.getFontHeight(hintFont);
        // La précision ne s'affiche que si elle ne rogne pas le message : dans
        // un huitième d'écran, mieux vaut la sacrifier.
        if (h < fh + hh + 4) { hint = null; hh = 0; }

        // Même police, même gris et même règle de place que l'affichage normal :
        // les deux écrans de cette case doivent avoir le même titre au même
        // endroit, sinon il saute d'une ligne quand la lampe répond.
        var labelFont = Graphics.FONT_XTINY;
        var lh = dc.getFontHeight(labelFont);
        var showLabel = (h > fh + hh + lh + 6);

        var y = (h - fh - hh - (showLabel ? lh : 0)) / 2;
        if (y < 0) { y = 0; }

        if (showLabel) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, y, labelFont, Labels.of(Rez.Strings.LightGeneric),
                        Graphics.TEXT_JUSTIFY_CENTER);
            y += lh;
        }

        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, y, font, message, Graphics.TEXT_JUSTIFY_CENTER);
        if (hint != null) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, y + fh, hintFont, hint, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    //! Ce qu'il faut faire pour lancer la recherche, en trois mots.
    //!
    //! **Sans nommer le geste.** « Appuyer » couvre la tape comme le bouton
    //! Lap, et c'est ce qui permet une seule phrase pour les treize modeles.
    //! Deux versions ont essaye de nommer le geste juste, chacune ratant d'un
    //! cote : « toucher » promettait un geste sans effet sur les compteurs dont
    //! la barre de controle prend la tape, et « appui Lap » ne dit rien a qui
    //! n'a pas le nom du bouton en tete. La machinerie qui choisissait entre
    //! les deux, appareil par appareil, a disparu avec elles.
    private function _idleHint() as Lang.String {
        return Labels.of(AutoController.searchOnStart(false)
            ? Rez.Strings.MsgIdleHintTimer : Rez.Strings.MsgIdleHint);
    }

    //! Le bouton Lap : le seul geste qu'un champ de donnees recoive **sur les
    //! treize modeles**.
    //!
    //! Un champ ne recoit aucun appui de bouton, sauf celui-ci, que le systeme
    //! transmet a tous les champs quand un tour est marque. Au repos il lance la
    //! recherche, pendant la recherche il l'arrete.
    //!
    //! **Il valait auparavant pour les seuls modeles sans tactile**, au motif
    //! qu'ailleurs la tape suffisait. Elle ne suffit pas : sur un Edge 1050, la
    //! barre de controle du systeme intercepte la tape avant le champ — c'est
    //! la raison d'etre de l'application compagnon, et c'est constate sur
    //! l'appareil. Le champ y annoncait donc un bouton qu'aucun geste ne pouvait
    //! presser : « Detecter », et rien ne se passait. Le meme trou guette les
    //! 840, 850, 1040 et Explore 2, qui ont eux aussi une barre de controle.
    //!
    //! Deux effets de bord, assumes l'un et l'autre : l'appui marque aussi un
    //! tour dans l'activite — c'est son role — et un tour marque sans lampe a
    //! portee lance une recherche. Celle-ci est bornee a cinq minutes, puis rend
    //! la main ; un second appui l'abrege.
    function onTimerLap() as Void {
        if (_lamp.isIdle()) { _lamp.start(); return; }
        if (_lamp.state == LampManager.STATE_SCANNING) { _lamp.stop(); }
    }

    //! Modes parcourus par la tape sur une case : l'echelle d'intensite, les
    //! effets declares par la lampe, puis ses modes personnalises. Un mode
    //! desactive dans la lampe y figure aussi : `LampManager.setMode()`
    //! l'active au passage.
    //!
    //! **Les modes perso en font partie.** Ils manquaient, et c'est exactement
    //! ceux-la qu'on ne veut pas rater : ce sont les seuls que l'utilisateur a
    //! regles lui-meme dans l'application iGPSPORT. Les laisser hors du cycle,
    //! c'est les rendre injoignables depuis une case de page de donnees — le
    //! panneau complet, lui, les proposait deja dans sa categorie « Perso ».
    private function _cycle() as Lang.Array {
        var out = _auto.ladder().slice(0, null);
        var extra = [LC.CAT_FLASH, LC.CAT_CUSTOM];
        for (var c = 0; c < extra.size(); c++) {
            var modes = _lamp.modesFor(extra[c] as Lang.Number);
            for (var i = 0; i < modes.size(); i++) {
                if (out.indexOf(modes[i]) < 0) { out.add(modes[i]); }
            }
        }
        return out;
    }

    //! Plus grande police dont le texte tienne dans la place disponible.
    //! Le texte tronqué est le défaut le plus visible d'un data field mal fait.
    //!
    //! Que des polices de texte : les `FONT_NUMBER_*` de Garmin, celles qui
    //! donnent aux champs natifs leurs gros chiffres, **n'ont pas de lettres**.
    //! La case n'affiche plus un nombre en valeur principale mais un nom de
    //! mode — elles n'ont plus rien à y écrire.
    private function _fitFont(dc as Graphics.Dc, text as Lang.String,
                              maxWidth as Lang.Number,
                              maxHeight as Lang.Number) as Graphics.FontDefinition {
        var fonts = [
            Graphics.FONT_LARGE,
            Graphics.FONT_MEDIUM,
            Graphics.FONT_SMALL,
            Graphics.FONT_TINY,
            Graphics.FONT_XTINY
        ];
        for (var i = 0; i < fonts.size(); i++) {
            var f = fonts[i];
            if (dc.getFontHeight(f) <= maxHeight
                    && dc.getTextWidthInPixels(text, f) <= maxWidth - 4) {
                return f;
            }
        }
        return Graphics.FONT_XTINY;
    }

    //! Libellé de mode adapté à la largeur disponible.
    private function _modeText(mode as Lang.Number, width as Lang.Number) as Lang.String {
        return (width > 200) ? LC.modeLabel(mode) : LC.modeShort(mode);
    }

    //! Autonomie : au-delà d'une heure, « 5h15 » est plus lisible que « 315 min ».
    private function _duration(minutes as Lang.Number) as Lang.String {
        if (minutes < 60) { return minutes.format("%d") + Labels.of(Rez.Strings.UnitMin); }
        return (minutes / 60).format("%d") + "h" + (minutes % 60).format("%02d");
    }
}
