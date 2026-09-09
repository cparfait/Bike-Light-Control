using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.Lang;
using Toybox.System;
using Toybox.FitContributor;
using Toybox.Application;
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
        // Le tactile n'est pas exposé dans les profils du SDK : c'est une
        // propriété d'exécution. Un seul binaire pour les 13 modèles.
        var settings = System.getDeviceSettings();
        _touch = (settings has :isTouchScreen) && settings.isTouchScreen;

        _fitMode = createField("light_mode", 0, FitContributor.DATA_TYPE_UINT8,
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

        // Un champ FIT non renseigne laisse un trou dans l'enregistrement : on
        // ecrit a chaque seconde, en retombant sur « eteint » et 0 % tant que la
        // lampe n'a rien dit.
        if (_fitMode != null) {
            var m = _lamp.status.mode;
            _fitMode.setData(m == null ? LC.BLM_LIGHT_OFF : m);
        }
        if (_fitBattery != null) {
            var b = _lamp.status.batteryPct;
            _fitBattery.setData(b == null ? 0 : b);
        }

        _timerRunning = running;
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
        if (!_lamp.isReady()) { return false; }
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
                _lamp.setMode(action);
                _lamp.status.mode = action;
                _panel.selectedCategory = LC.categoryOf(action);
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
                _panel.selectedCategory = cat;
                var modes = LC.modesInCategory(cat, _lamp.declaredModes());
                if (modes.size() > 0) {
                    _auto.setEnabledManually(false);
                    var m = modes[0] as Lang.Number;
                    _lamp.setMode(m);
                    _lamp.status.mode = m;
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
        _lamp.setMode(next);
        _lamp.status.mode = next;
        return true;
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
            _panel.draw(dc);
            return;
        }

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
        if (!_lamp.isReady() || _lamp.isIdentifying()) {
            _drawWaiting(dc, w, h, fg);
            return;
        }

        var battery = _lamp.status.batteryPct;
        var alert = _auto.isBatteryLow(battery);

        // Valeur principale : le pourcentage de batterie de la lampe.
        //
        // Le nombre et son unité sont dessinés séparément. Les polices
        // `FONT_NUMBER_*` de Garmin — celles qui donnent aux champs natifs leurs
        // gros chiffres — **ne contiennent pas le caractère `%`**. Mesurer
        // « 54% » d'un bloc les écartait donc toutes, et la case retombait sur
        // une police de texte bien plus petite que ses voisines. C'est visible
        // à l'oeil sur une page de données : notre valeur était deux fois plus
        // petite que la vitesse ou l'heure d'à côté.
        // Connectee mais batterie pas encore annoncee : « -- » plutot qu'un
        // mot d'etat, qui ferait croire a un probleme alors que tout va bien.
        var value = (battery == null) ? "--" : battery.format("%d");
        var unit = (battery == null) ? null : "%";

        // Ligne secondaire : l'erreur si la liaison a échoué, sinon le mode et
        // l'autonomie. Un mode inconnu s'affiche « -- », jamais « Off ».
        var mode = _lamp.status.mode;
        var off = (mode != null && mode == LC.BLM_LIGHT_OFF);
        var detail;
        if (_lamp.lastError != null && !_lamp.isReady()) {
            detail = _lamp.lastError;
        } else {
            detail = (mode == null) ? "--" : _modeText(mode, w);
            // Eteint en manuel : la tape suivante rend la main a l'automatisme.
            // Le dire, sinon personne ne le devine.
            if (off && !_auto.enabled) {
                detail += "  > " + Labels.of(Rez.Strings.BadgeAuto);
            }
            // Lampe eteinte : l'autonomie affichee serait celle d'avant
            // l'extinction, donc fausse. Mieux vaut ne rien montrer.
            var left = _lamp.status.remainingMinutes;
            if (!off && left != null && left > 0 && w > 150) {
                detail += "  " + _duration(left);
            }
        }

        // Choix des polices : la plus grande qui tienne en largeur et en hauteur.
        var unitFont = Graphics.FONT_XTINY;
        var unitW = (unit == null) ? 0 : dc.getTextWidthInPixels(unit, unitFont);
        var valueFont = _fitFont(dc, value, w - unitW, h * 55 / 100, unit != null);
        var detailFont = _fitFont(dc, detail, w, h * 25 / 100, false);

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

        // Même rouge que la jauge de la page complète : les deux affichages
        // doivent parler d'une seule voix (F7).
        dc.setColor(alert ? LC.UI_ALERT : fg, Graphics.COLOR_TRANSPARENT);
        if (unit == null) {
            dc.drawText(mid, y, valueFont, value, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // L'unité est calée en haut du nombre, comme dans les champs
            // natifs : c'est ce qui donne le « 54 % » avec le pour-cent en
            // exposant plutôt qu'aligné sur la base des chiffres.
            var numW = dc.getTextWidthInPixels(value, valueFont);
            var x0 = mid - (numW + unitW) / 2;
            dc.drawText(x0, y, valueFont, value, Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(x0 + numW, y, unitFont, unit, Graphics.TEXT_JUSTIFY_LEFT);
        }
        y += vh;

        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, y, detailFont, detail, Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Attente de la lampe, dans une case de page de données.
    //!
    //! Même règle que la page complète : la police est mesurée sur le **plus
    //! long** des messages, pas sur celui qu'on affiche, sinon le texte change
    //! de corps à chaque étape. Une seule ligne, centrée ; l'étiquette
    //! « LAMPE - AUTO » disparaît, elle ne veut rien dire sans lampe.
    private function _drawWaiting(dc as Graphics.Dc, w as Lang.Number,
                                  h as Lang.Number, fg as Lang.Number) as Void {
        var message = _lamp.stateMessage();
        var reference = LampManager.longestStateMessage();
        var font = _fitFont(dc, reference, w, h * 60 / 100, false);

        var hint = _lamp.stateHint();

        var fh = dc.getFontHeight(font);
        var hintFont = Graphics.FONT_XTINY;
        var hh = (hint == null) ? 0 : dc.getFontHeight(hintFont);
        // La précision ne s'affiche que si elle ne rogne pas le message : dans
        // un huitième d'écran, mieux vaut la sacrifier.
        if (h < fh + hh + 4) { hint = null; hh = 0; }

        var y = (h - fh - hh) / 2;
        if (y < 0) { y = 0; }

        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, y, font, message, Graphics.TEXT_JUSTIFY_CENTER);
        if (hint != null) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, y + fh, hintFont, hint, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    //! Modes parcourus par la tape sur une case : l'echelle d'intensite, puis
    //! les effets declares par la lampe. Un flash desactive dans la lampe y
    //! figure aussi : `LampManager.setMode()` l'active au passage.
    private function _cycle() as Lang.Array {
        var out = _auto.ladder().slice(0, null);
        var flashes = LC.modesInCategory(LC.CAT_FLASH, _lamp.declaredModes());
        for (var i = 0; i < flashes.size(); i++) {
            if (out.indexOf(flashes[i]) < 0) { out.add(flashes[i]); }
        }
        return out;
    }

    //! Plus grande police dont le texte tienne dans la place disponible.
    //! Le texte tronqué est le défaut le plus visible d'un data field mal fait.
    //! `numeric` autorise les polices `FONT_NUMBER_*`, réservées aux chiffres :
    //! elles n'ont ni lettres ni signe de pourcentage, et les employer pour du
    //! texte donnerait des caractères manquants.
    private function _fitFont(dc as Graphics.Dc, text as Lang.String,
                              maxWidth as Lang.Number,
                              maxHeight as Lang.Number,
                              numeric as Lang.Boolean) as Graphics.FontDefinition {
        var fonts = numeric ? [
            Graphics.FONT_NUMBER_THAI_HOT,
            Graphics.FONT_NUMBER_HOT,
            Graphics.FONT_NUMBER_MEDIUM,
            Graphics.FONT_NUMBER_MILD,
            Graphics.FONT_LARGE,
            Graphics.FONT_MEDIUM,
            Graphics.FONT_SMALL,
            Graphics.FONT_TINY,
            Graphics.FONT_XTINY
        ] : [
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
