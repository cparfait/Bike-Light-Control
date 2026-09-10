using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;
using LightConstants as LC;

//! Menu de réglages, sur le compteur.
//!
//! Il existe parce que les réglages d'application Connect IQ ne sont modifiables
//! que depuis Garmin Connect, et **pas pour une application installée à la
//! main**. Sans ce menu, les valeurs par défaut seraient figées jusqu'à
//! recompilation.
//!
//! Il couvre deux familles distinctes, et le libellé le dit :
//!
//! - les **automatismes de la lampe**, qui vivent dans son firmware et
//!   continuent de s'appliquer même sans compteur ;
//! - les **réglages de cette application** : allumage a la decouverte,
//!   recherche a l'ouverture, seuil de batterie.
//!
//! **Les seuils de vitesse et l'extinction a l'arret n'y sont plus.** Ils y
//! etaient, et n'avaient aucun effet : Connect IQ isole les reglages par
//! binaire, et l'ajustement selon la vitesse ne tourne que dans le champ de
//! donnees. Un reglage qu'on tourne sans que rien ne change est pire que pas
//! de reglage — ceux-la se font dans Garmin Connect, sur le champ.
module SettingsMenu {

    // Identifiants des entrées. Les automatismes reprennent la valeur BLCS_*
    // pour éviter une table de correspondance de plus.
    const ID_APP_BATTERY   = 1005;
    const ID_APP_ON_START  = 1010;
    const ID_APP_SEARCH    = 1011;
    const ID_SLEEP_DELAY   = 1006;
    const ID_MODES         = 1008;
    const ID_LOW_DELAY     = 1007;
    const ID_OTHER_LIGHT   = 1009;

    //! Delais proposes pour les temporisations de la lampe, en secondes.
    //! L'application iGPSPORT propose 2 minutes par defaut ; on encadre large.
    const DELAY_CHOICES = [30, 60, 120, 180, 300, 600];

    //! Construit le menu à partir de l'état réel de la lampe.
    function build(lamp as LampManager, auto as AutoController) as WatchUi.Menu2 {
        var menu = new WatchUi.Menu2({ :title => Labels.of(Rez.Strings.MenuTitle) });

        // --- Automatismes de la lampe ---------------------------------------
        // On ne propose que ceux que la lampe déclare supporter : afficher un
        // interrupteur sans effet serait pire que de ne rien afficher.
        var configs = lamp.status.configs;
        if (configs != null) {
            _addLampToggle(menu, configs, LC.BLCS_LUMEN_VARY,
                           Labels.of(Rez.Strings.LampLumenVary),
                           Labels.of(Rez.Strings.HintByLamp));
            _addLampToggle(menu, configs, LC.BLCS_AUTO_LIGHT,
                           Labels.of(Rez.Strings.LampAutoLight),
                           Labels.of(Rez.Strings.HintAutoOn));
            _addLampToggle(menu, configs, LC.BLCS_SYNC_OFF,
                           Labels.of(Rez.Strings.LampSyncOff),
                           Labels.of(Rez.Strings.HintFollowsTimer));
            _addLampToggle(menu, configs, LC.BLCS_AUTO_START,
                           Labels.of(Rez.Strings.LampAutoStart),
                           Labels.of(Rez.Strings.HintOnStart));
            _addLampToggle(menu, configs, LC.BLCS_AUTO_SLEEP,
                           Labels.of(Rez.Strings.LampAutoSleep),
                           Labels.of(Rez.Strings.HintAfterIdle));
            menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.SleepDelay),
                _delay("sleepDelay", 120), ID_SLEEP_DELAY, null));
            _addLampToggle(menu, configs, LC.BLCS_AUTO_LOW,
                           Labels.of(Rez.Strings.LampAutoLow), null);
            menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.LowDelay),
                _delay("lowDelay", 120), ID_LOW_DELAY, null));
        } else {
            menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.LampAutomations),
                Labels.of(Rez.Strings.HintNotConnected), -1, null));
        }

        // Activation des modes : les flashs et les personnalisés sont
        // désactivés d'usine, et tant qu'ils le sont ni l'application ni le
        // bouton de la lampe ne peuvent y basculer.
        if (lamp.status.modeStates != null) {
            menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.AvailableModes),
                _modeCount(lamp), ID_MODES, null));
        }

        // --- Réglages de l'application --------------------------------------
        // Attention : Connect IQ isole les réglages par binaire. Ceux-ci valent
        // pour cette page ; le data field a les siens, réglables depuis Garmin
        // Connect une fois l'application publiée.
        // Sortie de secours de l'identification : le clignotement a designe une
        // lampe qui n'est pas la sienne — deux velos cote a cote, deux VS1800S
        // portant le meme nom. On ecarte celle-la et on reprend la recherche.
        // N'a de sens qu'une fois connecte : sans liaison, on cherche deja.
        if (lamp.isReady()) {
            menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.MsgOtherLight),
                Labels.of(Rez.Strings.MsgOtherLightHint), ID_OTHER_LIGHT, null));
        }

        menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.AppSettings),
            Labels.of(Rez.Strings.HintSeparate), -1, null));
        menu.addItem(new WatchUi.ToggleMenuItem(Labels.of(Rez.Strings.OnAtStart),
            { :enabled => Labels.of(Rez.Strings.Yes), :disabled => Labels.of(Rez.Strings.No) },
            ID_APP_ON_START, _bool("lightOnStart", true), null));
        // Chercher la lampe des l'ouverture, ou attendre un geste. Le scan BLE
        // est ce qui coute le plus cher en batterie du compteur, et on ne roule
        // pas toujours avec sa lampe.
        menu.addItem(new WatchUi.ToggleMenuItem(Labels.of(Rez.Strings.SearchAuto),
            { :enabled => Labels.of(Rez.Strings.Yes), :disabled => Labels.of(Rez.Strings.No) },
            ID_APP_SEARCH, _bool("searchOnStart", false), null));

        menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.LowBattery),
            _num("lowBatteryPct", 20).format("%d") + " " + Labels.of(Rez.Strings.UnitPct), ID_APP_BATTERY, null));

        return menu;
    }

    function _addLampToggle(menu as WatchUi.Menu2, configs as Lang.Dictionary,
                                    id as Lang.Number, label as Lang.String,
                                    hint as Lang.String or Null) as Void {
        var state = configs.get(id);
        if (state == null) { return; }        // non supporté par cette lampe
        menu.addItem(new WatchUi.ToggleMenuItem(label,
            { :enabled => (hint == null) ? Labels.of(Rez.Strings.StateActive) : hint,
              :disabled => Labels.of(Rez.Strings.StateInactive) },
            id, state != LC.BSCS_CFG_OFF, null));
    }

    // ---- Accès aux réglages persistants ------------------------------------

    function _num(key as Lang.String, fallback as Lang.Number) as Lang.Number {
        try {
            var v = Application.Properties.getValue(key);
            if (v instanceof Lang.Number) { return v; }
        } catch (e) {
        }
        return fallback;
    }

    function _bool(key as Lang.String, fallback as Lang.Boolean) as Lang.Boolean {
        try {
            var v = Application.Properties.getValue(key);
            if (v instanceof Lang.Boolean) { return v; }
        } catch (e) {
        }
        return fallback;
    }

    //! « 6 actifs sur 11 » : on voit d'un coup qu'il y a des modes à activer.
    function _modeCount(lamp as LampManager) as Lang.String {
        var states = lamp.status.modeStates;
        if (states == null) { return ""; }
        var keys = states.keys();
        var on = 0;
        for (var i = 0; i < keys.size(); i++) {
            var v = states.get(keys[i]);
            if (v instanceof Lang.Boolean && v) { on++; }
        }
        return on.format("%d") + Labels.of(Rez.Strings.ActiveOutOf) + keys.size().format("%d");
    }

    //! Un délai se lit mieux en minutes dès qu'il dépasse la minute.
    function _delay(key as Lang.String, fallback as Lang.Number) as Lang.String {
        var s = _num(key, fallback);
        if (s < 60) { return s.format("%d") + " " + Labels.of(Rez.Strings.UnitSec); }
        return (s / 60).format("%d") + " " + Labels.of(Rez.Strings.UnitMin);
    }

    function save(key as Lang.String, value) as Void {
        try {
            Application.Properties.setValue(key, value);
        } catch (e) {
        }
    }
}


//! Réagit aux choix du menu. Les automatismes partent vers la lampe, les
//! réglages d'application vont dans les propriétés persistantes.
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _lamp as LampManager;
    private var _auto as AutoController;

    function initialize(lamp as LampManager, auto as AutoController) {
        Menu2InputDelegate.initialize();
        _lamp = lamp;
        _auto = auto;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (!(id instanceof Lang.Number)) { return; }

        // Interrupteurs.
        if (item instanceof WatchUi.ToggleMenuItem) {
            var on = item.isEnabled();
            if (id == SettingsMenu.ID_APP_ON_START) {
                SettingsMenu.save("lightOnStart", on);
                _auto.loadSettings();
                // Le reglage vaut pour la prochaine liaison. Le poser ici evite
                // de rouvrir la page pour qu'il prenne effet.
                _lamp.lightOnConnect = on;
            } else if (id == SettingsMenu.ID_APP_SEARCH) {
                SettingsMenu.save("searchOnStart", on);
            } else {
                // Tout le reste est un automatisme de la lampe : l'identifiant
                // est directement la constante BLCS_*.
                _lamp.setSmartConfig(id, on ? LC.BSCS_CFG_ON : LC.BSCS_CFG_OFF);
            }
            return;
        }

        // Valeurs numériques : une liste de choix vaut mieux qu'un sélecteur
        // au doigt sur un guidon.
        if (id == SettingsMenu.ID_OTHER_LIGHT) {
            // Retour a la page : c'est la que le clignotement de la lampe
            // suivante se verra.
            _lamp.forgetCurrentLamp();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else if (id == SettingsMenu.ID_MODES) {
            _pushModes(item);
        } else if (id == SettingsMenu.ID_SLEEP_DELAY) {
            _pushDelay(Labels.of(Rez.Strings.SleepDelay), "sleepDelay", LC.BLCS_AUTO_SLEEP, item);
        } else if (id == SettingsMenu.ID_LOW_DELAY) {
            _pushDelay(Labels.of(Rez.Strings.LowDelay), "lowDelay", LC.BLCS_AUTO_LOW, item);
        } else if (id == SettingsMenu.ID_APP_BATTERY) {
            _pushChoices(Labels.of(Rez.Strings.LowBattery), "lowBatteryPct",
                         [10, 15, 20, 25, 30, 40], Labels.of(Rez.Strings.UnitPct), item);
        }
    }

    //! Un interrupteur par mode déclaré, dans l'ordre des catégories.
    function _pushModes(parent as WatchUi.MenuItem) as Void {
        var states = _lamp.status.modeStates;
        if (states == null) { return; }
        var menu = new WatchUi.Menu2({ :title => Labels.of(Rez.Strings.AvailableModes) });

        // Parcours par categorie : la liste brute des identifiants serait
        // illisible, et l'ordre des cles d'un dictionnaire est arbitraire.
        for (var c = 0; c < LC.CATEGORY_ORDER.size(); c++) {
            var cat = LC.CATEGORY_ORDER[c] as Lang.Number;
            if (cat == LC.CAT_OFF) { continue; }
            var modes = LC.modesInCategory(cat, null);
            for (var i = 0; i < modes.size(); i++) {
                var m = modes[i] as Lang.Number;
                var st = states.get(m);
                if (!(st instanceof Lang.Boolean)) { continue; }  // non declare
                menu.addItem(new WatchUi.ToggleMenuItem(LC.modeLabel(m),
                    { :enabled => Labels.of(Rez.Strings.StateAvailable),
                     :disabled => Labels.of(Rez.Strings.StateDisabled) },
                    m, st, null));
            }
        }
        WatchUi.pushView(menu, new ModeToggleDelegate(_lamp), WatchUi.SLIDE_LEFT);
    }

    //! Les délais partent vers la lampe : c'est son firmware qui les applique,
    //! et ils continuent de valoir même sans compteur.
    function _pushDelay(title as Lang.String, key as Lang.String,
                        config as Lang.Number, parent as WatchUi.MenuItem) as Void {
        var menu = new WatchUi.Menu2({ :title => title });
        var current = SettingsMenu._num(key, 120);
        var choices = SettingsMenu.DELAY_CHOICES;
        for (var i = 0; i < choices.size(); i++) {
            var v = choices[i] as Lang.Number;
            var label = (v < 60) ? v.format("%d") + " " + Labels.of(Rez.Strings.UnitSec)
                                 : (v / 60).format("%d") + " " + Labels.of(Rez.Strings.UnitMin);
            menu.addItem(new WatchUi.MenuItem(label,
                (v == current) ? Labels.of(Rez.Strings.Current) : null, v, null));
        }
        WatchUi.pushView(menu,
            new DelayChoiceDelegate(_lamp, key, config, parent), WatchUi.SLIDE_LEFT);
    }

    function _pushChoices(title as Lang.String, key as Lang.String,
                                  values as Lang.Array, unit as Lang.String,
                                  parent as WatchUi.MenuItem) as Void {
        var menu = new WatchUi.Menu2({ :title => title });
        var current = SettingsMenu._num(key, values[0] as Lang.Number);
        for (var i = 0; i < values.size(); i++) {
            var v = values[i] as Lang.Number;
            menu.addItem(new WatchUi.MenuItem(v.format("%d") + " " + unit,
                (v == current) ? Labels.of(Rez.Strings.Current) : null, v, null));
        }
        WatchUi.pushView(menu, new ValueChoiceDelegate(key, unit, parent, _auto),
                         WatchUi.SLIDE_LEFT);
    }
}


//! Applique une valeur choisie dans une liste, met à jour l'étiquette de
//! l'entrée parente, puis referme.
class ValueChoiceDelegate extends WatchUi.Menu2InputDelegate {

    private var _key as Lang.String;
    private var _unit as Lang.String;
    private var _parent as WatchUi.MenuItem;
    private var _auto as AutoController;

    function initialize(key as Lang.String, unit as Lang.String,
                        parent as WatchUi.MenuItem, auto as AutoController) {
        Menu2InputDelegate.initialize();
        _key = key;
        _unit = unit;
        _parent = parent;
        _auto = auto;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var v = item.getId();
        if (v instanceof Lang.Number) {
            SettingsMenu.save(_key, v);
            _parent.setSubLabel(v.format("%d") + " " + _unit);
            // Relecture immédiate : les seuils sont convertis en m/s une seule
            // fois, au chargement.
            _auto.loadSettings();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}


//! Applique un délai à la lampe et le retient localement pour l'affichage.
class DelayChoiceDelegate extends WatchUi.Menu2InputDelegate {

    private var _lamp as LampManager;
    private var _key as Lang.String;
    private var _config as Lang.Number;
    private var _parent as WatchUi.MenuItem;

    function initialize(lamp as LampManager, key as Lang.String,
                        config as Lang.Number, parent as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _lamp = lamp;
        _key = key;
        _config = config;
        _parent = parent;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var v = item.getId();
        if (v instanceof Lang.Number) {
            // On conserve l'etat marche/arret courant : changer le delai ne doit
            // pas activer un automatisme que l'utilisateur avait desactive.
            var configs = _lamp.status.configs;
            var state = (configs == null) ? LC.BSCS_CFG_ON : configs.get(_config);
            if (state == null) { state = LC.BSCS_CFG_ON; }
            _lamp.send(LightProtocol.setSmartConfigTimed(_config, state, v));
            SettingsMenu.save(_key, v);
            _parent.setSubLabel((v < 60) ? v.format("%d") + " " + Labels.of(Rez.Strings.UnitSec)
                                         : (v / 60).format("%d") + " " + Labels.of(Rez.Strings.UnitMin));
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}


//! Active ou désactive un mode dans la lampe.
class ModeToggleDelegate extends WatchUi.Menu2InputDelegate {

    private var _lamp as LampManager;

    function initialize(lamp as LampManager) {
        Menu2InputDelegate.initialize();
        _lamp = lamp;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var mode = item.getId();
        if (!(mode instanceof Lang.Number)) { return; }
        if (!(item instanceof WatchUi.ToggleMenuItem)) { return; }
        _lamp.setModeEnabled(mode, item.isEnabled());
    }
}
