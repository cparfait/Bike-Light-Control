using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Timer;
using LightConstants as LC;

//! Enveloppe de vue autour du panneau partagé.
//!
//! Tout le dessin vit dans `LampPanel`, commun avec le champ de données : une
//! seule mise en page, et une correction profite aux deux surfaces.
class LampControlView extends WatchUi.View {

    var panel as LampPanel;

    private var _lamp as LampManager;

    //! Battement a la seconde. Le champ de donnees recoit `compute()` chaque
    //! seconde du systeme ; une application, elle, n'est rappelee que quand
    //! quelque chose la touche. Sans ce minuteur, `LampManager.tick()` ne
    //! tournait qu'au rythme des tapes, et l'ecran ne se redessinait jamais
    //! quand la liaison changeait d'etat : la page restait sur « Recherche »
    //! alors que la lampe etait peut-etre deja la — et les tapes, ignorees hors
    //! liaison, semblaient tomber dans le vide. C'est ce qu'a montre la ligne
    //! de diagnostic : `ko` au moment de la tape.
    //!
    //! `Toybox.Timer` est proscrit dans un data field (voir LampManager) mais
    //! parfaitement legitime dans une application.
    private var _timer as Timer.Timer = new Timer.Timer();

    //! Dernières valeurs écrites, pour ne pas réécrire la flash à chaque image.
    private var _savedBattery as Lang.Number or Null = null;
    private var _savedMode as Lang.Number or Null = null;

    function initialize(lamp as LampManager, auto as AutoController) {
        View.initialize();
        _lamp = lamp;
        panel = new LampPanel(lamp, auto);
        // Seule l'application compagnon peut empiler le menu des réglages ;
        // c'est donc la seule à afficher la roue dentée.
        panel.showSettings = true;
        // L'automatisme ne tourne que dans le champ de donnees, et chaque
        // binaire a son propre etat : le badge n'aurait ici aucun effet.
        panel.showAuto = false;
    }

    function onShow() as Void {
        _timer.start(method(:onTick), 1000, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    //! Cadence la liaison et force le rafraichissement : c'est ce qui fait
    //! passer le bandeau de « Recherche » a « Liaison » puis « OK » sous les
    //! yeux de l'utilisateur, au lieu d'attendre qu'il touche l'ecran.
    function onTick() as Void {
        _lamp.tick();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        panel.draw(dc);
        _remember();
    }

    //! Retient de quoi remplir la tuile de résumé.
    //!
    //! La tuile ne peut pas interroger la lampe elle-même — 64 Ko de budget, et
    //! un scan BLE prend plusieurs secondes là où une tuile se dessine
    //! instantanément. Elle affiche donc ce que cette page a relevé en dernier.
    //!
    //! On lui range des chaînes **toutes faites** : elle n'a accès ni aux
    //! libellés ni au catalogue des modes. Et on n'écrit que sur changement, le
    //! stockage d'un Connect IQ étant une mémoire flash, pas une variable.
    private function _remember() as Void {
        var battery = _lamp.status.batteryPct;
        var mode = _lamp.status.mode;
        if (battery == null) { return; }
        if (battery == _savedBattery && mode == _savedMode) { return; }

        var type = _lamp.status.lightType;
        var title = Labels.of(Rez.Strings.LightGeneric);
        if (type != null) { title += " " + LC.typeLabel(type); }

        var summary = battery.format("%d") + "%";
        if (mode != null) { summary += "  " + LC.modeShort(mode); }

        try {
            Application.Storage.setValue(LampGlanceView.KEY_TITLE, title);
            Application.Storage.setValue(LampGlanceView.KEY_SUMMARY, summary);
            _savedBattery = battery;
            _savedMode = mode;
        } catch (e) {
        }
    }
}
