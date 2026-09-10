using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;

//! Réglages du champ de données, **sur le compteur**.
//!
//! Le SDK prévoit pour cela `AppBase.getSettingsView()`, et sa documentation
//! est explicite : « only applicable to watch faces and data fields ». C'est
//! donc le seul point d'entrée légitime, et il n'était pas implémenté.
//!
//! **Ne pas l'implémenter n'est pas neutre : ça fait tomber l'application.**
//! Quand le système demande la vue de réglages — depuis la configuration du
//! champ sur l'appareil, ou depuis « Settings » dans le simulateur — il appelle
//! la méthode de `AppBase`, qui n'a rien à rendre. L'écran de Connect IQ
//! apparaît, l'application meurt, et rien n'indique pourquoi : de l'extérieur,
//! on a simplement cliqué sur « réglages ».
//!
//! Le menu reprend **les mêmes réglages, les mêmes libellés et les mêmes
//! valeurs par défaut** que la fiche de Garmin Connect : ce sont les titres
//! déclarés dans `resources/settings/settings.xml`, déjà traduits en treize
//! langues. Deux chemins vers un seul jeu de propriétés, pas deux réglages
//! parallèles qui divergeraient.
//!
//! Les nombres se choisissent **en tournant** dans une courte liste plutôt qu'en
//! ouvrant un sélecteur : c'est une vue de moins à embarquer, et les 128 Ko d'un
//! champ de données se comptent. Les valeurs proposées sont celles qui ont un
//! sens sur un vélo, pas la plage entière autorisée par `settings.xml`.
module FieldSettings {

    const ID_AUTO      = 1;
    const ID_SYNC_OFF  = 2;
    const ID_ON_START  = 3;
    const ID_SEARCH    = 4;
    const ID_SPEED1    = 5;
    const ID_SPEED2    = 6;
    const ID_SPEED3    = 7;
    const ID_BATTERY   = 8;

    const SPEED1_CHOICES = [5, 8, 10, 12, 15];
    const SPEED2_CHOICES = [15, 18, 20, 22, 25];
    const SPEED3_CHOICES = [25, 30, 35, 40, 45];
    const BATTERY_CHOICES = [10, 15, 20, 25, 30, 40];

    //! Unités écrites en clair. Elles ne passent pas par la table de
    //! ressources : « km/h » et « % » s'écrivent de la même façon dans les
    //! treize langues déclarées, et une chaîne de plus par langue coûterait
    //! plus que ce qu'elle rapporte.
    const UNIT_SPEED = " km/h";
    const UNIT_PCT   = " %";

    function build() as WatchUi.Menu2 {
        var menu = new WatchUi.Menu2({ :title => Labels.of(Rez.Strings.AppName) });

        // Pas de libellés d'état sur les interrupteurs : `ToggleMenuItem` en
        // dessine un, et le dessin dit déjà tout ce qu'un « Oui / Non » aurait
        // dit — sans rien ajouter à la table de ressources.
        menu.addItem(new WatchUi.ToggleMenuItem(Labels.of(Rez.Strings.SetAuto),
            null, ID_AUTO, _bool("autoEnabled", true), null));
        menu.addItem(new WatchUi.ToggleMenuItem(Labels.of(Rez.Strings.SetSyncOff),
            null, ID_SYNC_OFF, _bool("syncOff", true), null));
        menu.addItem(new WatchUi.ToggleMenuItem(Labels.of(Rez.Strings.SetLightOnStart),
            null, ID_ON_START, _bool("lightOnStart", true), null));
        menu.addItem(new WatchUi.ToggleMenuItem(Labels.of(Rez.Strings.SetSearchOnStart),
            null, ID_SEARCH, _bool("searchOnStart", false), null));

        menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.SetSpeed1),
            _num("speed1", 8) + UNIT_SPEED, ID_SPEED1, null));
        menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.SetSpeed2),
            _num("speed2", 18) + UNIT_SPEED, ID_SPEED2, null));
        menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.SetSpeed3),
            _num("speed3", 30) + UNIT_SPEED, ID_SPEED3, null));
        menu.addItem(new WatchUi.MenuItem(Labels.of(Rez.Strings.SetLowBattery),
            _num("lowBatteryPct", 20) + UNIT_PCT, ID_BATTERY, null));

        return menu;
    }

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

    function save(key as Lang.String, value) as Void {
        try {
            Application.Properties.setValue(key, value);
        } catch (e) {
        }
    }

    //! Valeur suivante dans la liste, en bouclant. Une valeur absente de la
    //! liste — saisie depuis Garmin Connect, qui accepte toute la plage — rend
    //! la première : on ne la perd pas silencieusement au milieu du tour.
    function next(choices as Lang.Array, current as Lang.Number) as Lang.Number {
        for (var i = 0; i < choices.size(); i++) {
            if ((choices[i] as Lang.Number) == current) {
                return choices[(i + 1) % choices.size()] as Lang.Number;
            }
        }
        return choices[0] as Lang.Number;
    }
}


//! Applique les choix du menu de réglages du champ.
//!
//! `AutoController` est relu à chaque changement : les seuils sont convertis en
//! m/s une seule fois, au chargement, et un réglage qui n'aurait d'effet qu'au
//! redémarrage du champ serait un réglage qu'on croit avoir mal mis.
class FieldSettingsDelegate extends WatchUi.Menu2InputDelegate {

    private var _auto as AutoController;
    private var _lamp as LampManager;

    function initialize(lamp as LampManager, auto as AutoController) {
        Menu2InputDelegate.initialize();
        _lamp = lamp;
        _auto = auto;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (!(id instanceof Lang.Number)) { return; }

        if (item instanceof WatchUi.ToggleMenuItem) {
            var on = item.isEnabled();
            if (id == FieldSettings.ID_AUTO) {
                FieldSettings.save("autoEnabled", on);
                // Le réglage l'emporte sur une tape précédente : c'est un geste
                // plus explicite encore. Voir AutoController._manualHold.
                _auto.setEnabledFromSettings(on);
                return;
            }
            if (id == FieldSettings.ID_SYNC_OFF)  { FieldSettings.save("syncOff", on); }
            if (id == FieldSettings.ID_ON_START)  {
                FieldSettings.save("lightOnStart", on);
                // Vaut pour la prochaine liaison, sans rouvrir quoi que ce soit.
                _lamp.lightOnConnect = on;
            }
            if (id == FieldSettings.ID_SEARCH)    { FieldSettings.save("searchOnStart", on); }
            _auto.loadSettings();
            return;
        }

        // Nombres : on tourne dans la liste, et l'étiquette suit aussitôt.
        var key = null;
        var choices = null;
        var unit = FieldSettings.UNIT_SPEED;
        var fallback = 0;
        if (id == FieldSettings.ID_SPEED1) {
            key = "speed1"; choices = FieldSettings.SPEED1_CHOICES; fallback = 8;
        } else if (id == FieldSettings.ID_SPEED2) {
            key = "speed2"; choices = FieldSettings.SPEED2_CHOICES; fallback = 18;
        } else if (id == FieldSettings.ID_SPEED3) {
            key = "speed3"; choices = FieldSettings.SPEED3_CHOICES; fallback = 30;
        } else if (id == FieldSettings.ID_BATTERY) {
            key = "lowBatteryPct"; choices = FieldSettings.BATTERY_CHOICES;
            fallback = 20; unit = FieldSettings.UNIT_PCT;
        }
        if (key == null) { return; }

        var value = FieldSettings.next(choices as Lang.Array,
                                       FieldSettings._num(key as Lang.String, fallback));
        FieldSettings.save(key as Lang.String, value);
        item.setSubLabel(value + unit);
        _auto.loadSettings();
        WatchUi.requestUpdate();
    }
}
