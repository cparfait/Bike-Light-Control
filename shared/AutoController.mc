using Toybox.Lang;
using Toybox.Application;
using LightConstants as LC;

//! Automatismes calculés sur le compteur : ajustement selon la vitesse (F5),
//! extinction synchronisée (F6), repli sur batterie faible (F7).
//!
//! Ces règles sont volontairement appliquées **côté Edge** plutôt que déléguées
//! à la lampe. L'Edge connaît sa propre vitesse — capteur de roue ou GPS de
//! compteur, plus fiable qu'un téléphone en poche — et les seuils restent
//! modifiables sans dépendre du firmware de la lampe.
class AutoController {

    //! Seuils de passage par défaut, en km/h, du plus lent au plus rapide.
    //! À l'arrêt et en côte on éclaire peu, en descente on éclaire loin.
    //! Modifiables depuis Garmin Connect (voir resources/settings/settings.xml).
    const DEFAULT_SPEEDS = [8, 18, 30];

    //! Marge de recouvrement, en m/s (~2 km/h). Sans elle, rouler pile sur un
    //! seuil ferait clignoter la lampe entre deux modes à chaque rafale de vent.
    const HYSTERESIS = 0.6;

    //! Au-delà de ce cran, on ne monte plus quand la batterie est basse : mieux
    //! vaut une lumière faible qui dure qu'une lumière forte qui s'éteint.
    const LOW_BATTERY_MAX_INDEX = 1;

    //! Etats de sortie. La distinction entre pause et arret est le coeur de
    //! F6 : voir `onRideState()`.
    static const RIDE_STOPPED = 0;
    static const RIDE_PAUSED  = 1;
    static const RIDE_RUNNING = 2;

    //! Valeurs de `Activity.Info.timerState`, recopiees du SDK pour que ce
    //! module reste utilisable — et testable — sans contexte d'activite.
    static const TIMER_STATE_OFF     = 0;
    static const TIMER_STATE_STOPPED = 1;
    static const TIMER_STATE_PAUSED  = 2;
    static const TIMER_STATE_ON      = 3;

    //! Ajustement selon la vitesse en service. En lecture seule de l'extérieur :
    //! passer par `setEnabledManually()` ou `setEnabledFromSettings()`, dont la
    //! distinction est expliquée sur `_manualHold`.
    var enabled as Lang.Boolean = true;

    //! Vrai dès que l'utilisateur a suspendu — ou rendu — l'automatisme d'un
    //! geste sur le compteur. `loadSettings()` cesse alors d'écraser `enabled`.
    //!
    //! Sans ce verrou, la relecture des réglages déclenchée depuis Garmin
    //! Connect — n'importe lequel d'entre eux, un seuil de vitesse par exemple —
    //! réactiverait l'ajustement qu'une tape venait de suspendre, et la lampe
    //! repartirait toute seule au cran suivant. Le geste sur le guidon est plus
    //! récent que le réglage : c'est lui qui gagne.
    private var _manualHold as Lang.Boolean = false;

    //! Seuils en m/s, dérivés des réglages utilisateur.
    private var _thresholds as Lang.Array = [2.2, 5.0, 8.3];
    private var _lowBatteryPct as Lang.Number = 20;
    private var _syncOff as Lang.Boolean = true;
    private var _lightOnStart as Lang.Boolean = true;

    private var _index as Lang.Number = 0;   // position dans l'echelle courante
    private var _band as Lang.Number = 0;    // palier de vitesse courant
    private var _riding as Lang.Boolean = false;
    private var _rideState as Lang.Number = RIDE_STOPPED;
    //! Échelle d'intensité en vigueur. Par défaut celle des lampes à faisceau ;
    //! remplacée dès que la lampe a déclaré ses modes.
    private var _ladder as Lang.Array = LC.BEAM_LADDER;

    function initialize() {
        loadSettings();
    }

    //! Relit les réglages utilisateur. Appelée au démarrage et à chaque
    //! modification depuis Garmin Connect.
    //!
    //! Les seuils sont saisis en km/h — l'unité que l'utilisateur a sous les
    //! yeux — et convertis ici en m/s, l'unité de `Activity.Info.currentSpeed`.
    //! Faire la conversion à un seul endroit évite de la refaire à chaque appel
    //! de `compute()`, une fois par seconde.
    function loadSettings() as Void {
        // Un choix fait à la main sur le compteur prime sur le réglage : voir
        // `_manualHold`.
        if (!_manualHold) {
            enabled = _boolSetting("autoEnabled", true);
        }
        _syncOff = _boolSetting("syncOff", true);
        _lightOnStart = _boolSetting("lightOnStart", true);
        _lowBatteryPct = _numSetting("lowBatteryPct", 20, 0, 100);

        var kmh = [
            _numSetting("speed1", DEFAULT_SPEEDS[0], 1, 80),
            _numSetting("speed2", DEFAULT_SPEEDS[1], 1, 80),
            _numSetting("speed3", DEFAULT_SPEEDS[2], 1, 80)
        ];
        // Des seuils saisis dans le désordre donneraient un comportement
        // incompréhensible : on les remet en ordre croissant plutôt que de
        // refuser la configuration.
        kmh = _sortedAscending(kmh);

        _thresholds = [];
        for (var i = 0; i < kmh.size(); i++) {
            _thresholds.add((kmh[i] as Lang.Number) / 3.6);
        }
    }

    //! Vrai si la recherche de la lampe doit demarrer d'elle-meme.
    //!
    //! Statique et lue a la volee : elle ne concerne pas l'ajustement selon la
    //! vitesse, mais les deux binaires ont besoin de la meme reponse et c'est
    //! ici que vit deja l'acces aux reglages.
    static function searchOnStart() as Lang.Boolean {
        try {
            var v = Application.Properties.getValue("searchOnStart");
            if (v instanceof Lang.Boolean) { return v; }
        } catch (e) {
        }
        // Meme valeur que `properties.xml` : un repli qui dirait le contraire
        // ferait chercher la lampe le jour ou la propriete devient illisible.
        return false;
    }

    //! Vrai si la lampe doit s'allumer d'elle-meme, sans qu'on le demande.
    //!
    //! Le moment n'est pas le meme dans les deux binaires, et c'est voulu : le
    //! champ de donnees allume **au depart de l'activite** (`onRideState()`),
    //! l'application compagnon **des qu'elle trouve la lampe** — elle n'a pas
    //! d'activite, et le moment equivalent est celui ou la liaison s'etablit.
    //!
    //! Statique, pour la meme raison que `searchOnStart()` : `LampManager` en a
    //! besoin sans avoir d'instance sous la main.
    static function lightOnStart() as Lang.Boolean {
        try {
            var v = Application.Properties.getValue("lightOnStart");
            if (v instanceof Lang.Boolean) { return v; }
        } catch (e) {
        }
        return true;
    }

    //! Suspend ou rend l'ajustement d'un geste sur le compteur — une tape sur le
    //! champ, le badge du panneau. Le choix tient jusqu'à la fin de l'activité,
    //! même si les réglages changent entre-temps depuis le téléphone.
    function setEnabledManually(on as Lang.Boolean) as Void {
        enabled = on;
        _manualHold = true;
    }

    //! Applique la valeur venue des réglages, et lève le verrou : l'utilisateur
    //! est allé changer le réglage lui-même, c'est donc lui qui reprend la main
    //! sur son geste précédent.
    function setEnabledFromSettings(on as Lang.Boolean) as Void {
        enabled = on;
        _manualHold = false;
    }

    private function _sortedAscending(values as Lang.Array) as Lang.Array {
        // Les elements d'un Array sont typés Object : le comparateur a besoin
        // d'un transtypage explicite.
        var out = values.slice(0, null);
        for (var i = 1; i < out.size(); i++) {
            var j = i;
            while (j > 0 && (out[j] as Lang.Number) < (out[j - 1] as Lang.Number)) {
                var tmp = out[j]; out[j] = out[j - 1]; out[j - 1] = tmp;
                j--;
            }
        }
        return out;
    }

    private function _numSetting(key as Lang.String, fallback as Lang.Number,
                                 min as Lang.Number, max as Lang.Number) as Lang.Number {
        try {
            var v = Application.Properties.getValue(key);
            if (v instanceof Lang.Number && v >= min && v <= max) { return v; }
        } catch (e) {
            // Reglage absent ou illisible : la valeur par defaut fait l'affaire.
        }
        return fallback;
    }

    private function _boolSetting(key as Lang.String, fallback as Lang.Boolean) as Lang.Boolean {
        try {
            var v = Application.Properties.getValue(key);
            if (v instanceof Lang.Boolean) { return v; }
        } catch (e) {
        }
        return fallback;
    }

    //! Adapte l'échelle aux modes déclarés par la lampe.
    //! C'est ce qui permet de piloter une VS500 ou une VS800 sans les avoir
    //! jamais eues en main : on ne suppose plus, on lit.
    function setSupportedModes(supported as Lang.Array or Null,
                              lightType as Lang.Number or Null) as Void {
        var next = LC.ladderFor(supported, lightType);
        // Comparaison element par element, et non par taille : deux echelles de
        // meme longueur mais de modes differents — un feu arriere et un feu
        // avant a trois crans, par exemple — laissaient l'ancienne en place.
        if (_sameLadder(next, _ladder)) { return; }
        _ladder = next;
        if (_index >= _ladder.size()) { _index = _ladder.size() - 1; }
        if (_band > _thresholds.size()) { _band = _thresholds.size(); }
    }

    private function _sameLadder(a as Lang.Array, b as Lang.Array) as Lang.Boolean {
        if (a.size() != b.size()) { return false; }
        for (var i = 0; i < a.size(); i++) {
            if ((a[i] as Lang.Number) != (b[i] as Lang.Number)) { return false; }
        }
        return true;
    }

    function ladder() as Lang.Array {
        return _ladder;
    }

    //! Indice de mode visé pour une vitesse donnée, hystérésis comprise.
    //! Retourne -1 si l'automatisme est désactivé.
    function indexForSpeed(speedMps as Lang.Float or Null,
                           batteryPct as Lang.Number or Null) as Lang.Number {
        if (!enabled) { return -1; }

        var v = (speedMps == null) ? 0.0 : speedMps;

        // Trois seuils délimitent quatre paliers de vitesse.
        var steps = _thresholds.size();
        var band = 0;
        for (var i = 0; i < steps; i++) {
            // On ne monte d'un palier qu'au-delà du seuil, on ne redescend qu'en
            // repassant sous le seuil diminué de l'hystérésis.
            var threshold = _thresholds[i] as Lang.Float;
            if (i < _band) { threshold -= HYSTERESIS; }
            if (v > threshold) { band = i + 1; }
        }
        _band = band;

        // Les paliers de vitesse sont répartis sur toute l'échelle de la lampe.
        // Sans cette mise à l'échelle, une lampe à six crans pilotée par trois
        // seuils n'atteindrait jamais ses deux modes les plus puissants.
        //
        // L'arrondi se fait **au plus proche**, et non par troncature. Quatre
        // paliers ne peuvent de toute façon pas couvrir six crans — deux
        // resteront hors de portée de l'automatisme, et accessibles à la main
        // seulement — mais la division entière les choisissait tous par défaut :
        // entre 8 et 18 km/h, une VS1800S restait sur son avant-dernier cran le
        // plus faible alors que le milieu de l'échelle est ce qu'on veut là.
        var maxIndex = _ladder.size() - 1;
        var target = (steps == 0)
            ? maxIndex
            : (2 * band * maxIndex + steps) / (2 * steps);

        if (batteryPct != null && batteryPct <= _lowBatteryPct
                && target > LOW_BATTERY_MAX_INDEX) {
            target = LOW_BATTERY_MAX_INDEX;
        }

        if (target > maxIndex) { target = maxIndex; }
        if (target < 0) { target = 0; }
        _index = target;
        return target;
    }

    //! Mode à appliquer, ou null s'il n'y a rien à changer.
    //! `currentMode` est le dernier état connu de la lampe : on ne réémet pas
    //! une commande déjà satisfaite, la liaison BLE n'est pas gratuite.
    function modeForSpeed(speedMps as Lang.Float or Null,
                          batteryPct as Lang.Number or Null,
                          currentMode as Lang.Number or Null) as Lang.Number or Null {
        var idx = indexForSpeed(speedMps, batteryPct);
        if (idx < 0) { return null; }
        var mode = _ladder[idx];
        if (currentMode != null && currentMode == mode) { return null; }
        return mode;
    }

    //! Suit le chronomètre de l'activité.
    //! Retourne le mode à appliquer au changement d'état, ou null.
    //!
    //! **La pause n'éteint pas.** `Activity.TIMER_STATE_PAUSED` est l'état de la
    //! pause automatique : il survient à chaque feu rouge, et c'est justement le
    //! moment où un cycliste immobile a le plus besoin d'être vu. Seul un arrêt
    //! explicite du chronomètre — ou sa remise à zéro — déclenche l'extinction,
    //! ce que promet le libellé du réglage : « à l'arrêt de l'activité ».
    //!
    //! Reprendre après une pause ne renvoie pas non plus d'allumage doux : la
    //! lampe est restée dans son mode, et le geste manuel de l'utilisateur ne
    //! doit pas être annulé par un redémarrage de chrono.
    function onRideState(rideState as Lang.Number,
                         currentMode as Lang.Number or Null) as Lang.Number or Null {
        if (rideState == _rideState) { return null; }
        var previous = _rideState;
        _rideState = rideState;
        _riding = (rideState == RIDE_RUNNING);
        if (!enabled) { return null; }

        if (rideState == RIDE_PAUSED) { return null; }

        if (rideState == RIDE_STOPPED) {
            _index = 0;
            _band = 0;
            if (!_syncOff) { return null; }
            if (currentMode != null && currentMode == LC.BLM_LIGHT_OFF) { return null; }
            return LC.BLM_LIGHT_OFF;            // F6 : extinction en fin de sortie
        }

        // Reprise après pause : rien à faire, la lampe n'a pas changé d'état.
        if (previous == RIDE_PAUSED) { return null; }

        // Départ de sortie. L'allumage n'est pas systématique : le compteur ne
        // sait pas s'il fait jour, et une sortie de trois heures en plein
        // après-midi vidait la lampe pour rien. Qui roule de jour coupe le
        // réglage une fois pour toutes ; qui veut être vu de jour le laisse.
        if (!_lightOnStart) { return null; }
        return _ladder[0];                      // allumage doux au départ
    }

    //! Traduit `Activity.Info.timerState` en état de sortie.
    //! Les valeurs numériques sont celles du SDK ; les nommer ici évite de
    //! dépendre de `Toybox.Activity` dans un module testable hors activité.
    static function rideStateOf(timerState as Lang.Number or Null) as Lang.Number {
        if (timerState == null) { return RIDE_STOPPED; }
        if (timerState == TIMER_STATE_ON) { return RIDE_RUNNING; }
        if (timerState == TIMER_STATE_PAUSED) { return RIDE_PAUSED; }
        return RIDE_STOPPED;                    // OFF et STOPPED
    }

    //! Vrai si la batterie mérite une alerte à l'écran (F7).
    function isBatteryLow(batteryPct as Lang.Number or Null) as Lang.Boolean {
        return batteryPct != null && batteryPct <= _lowBatteryPct;
    }
}
