using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;

//! Point d'entrée du data field.
class LampApp extends Application.AppBase {

    private var _lamp as LampManager or Null = null;
    private var _auto as AutoController or Null = null;

    function initialize() {
        AppBase.initialize();
    }

    //! **Le champ de donnees ne cherche jamais la lampe de lui-meme.**
    //!
    //! Ce n'est pas un reglage decoche par defaut, c'est une absence : le scan
    //! BLE est de loin ce qui coute le plus cher en batterie du compteur, et un
    //! champ de donnees demarre a **chaque** activite, y compris les centaines
    //! ou la lampe est restee dans son tiroir. Un reglage aurait laisse le
    //! mauvais cas par defaut pour qui ne le trouve pas.
    //!
    //! La case affiche donc un bouton, et la recherche part au premier geste —
    //! voir `LampView.onTap()`. L'application compagnon, elle, garde son
    //! reglage : on ne l'ouvre pas par accident.
    function onStart(state as Lang.Dictionary or Null) as Void {
        _lamp = new LampManager();
        _auto = new AutoController();
        // Chercher la lampe est un geste deliberé : si on l'a fait, c'est qu'on
        // veut sa lampe allumee. Elle s'allume donc au cran le plus faible des
        // qu'elle repond, sans attendre le depart du chrono.
        _lamp.lightOnConnect = AutoController.lightOnStart();
    }

    //! Rappelee par le systeme quand les reglages changent depuis Garmin
    //! Connect, l'application tournant.
    //!
    //! **C'est ici et nulle part ailleurs.** Le SDK ne declare
    //! `onSettingsChanged` que sur `AppBase` : la meme methode ecrite sur la
    //! vue — c'est ou elle etait — n'est jamais appelee, et le compilateur ne
    //! dit rien puisque le nom est libre. Les seuils saisis depuis le telephone
    //! restaient donc sans effet jusqu'au redemarrage du champ, ce qui ne se
    //! voit pas : on croit avoir mal regle.
    function onSettingsChanged() as Void {
        if (_auto != null) {
            _auto.loadSettings();
        }
        if (_lamp != null) {
            _lamp.lightOnConnect = AutoController.lightOnStart();
        }
        WatchUi.requestUpdate();
    }

    function onStop(state as Lang.Dictionary or Null) as Void {
        if (_lamp != null) {
            // Ne pas laisser la lampe allumée après l'activité, et libérer la
            // connexion pour que le téléphone puisse la reprendre.
            //
            // `shutdown()` et non `turnOff()` puis `stop()` : la seconde forme
            // désappairait avant que l'écriture asynchrone n'ait quitté le
            // compteur, et la lampe restait allumée.
            _lamp.shutdown();
        }
    }

    function getInitialView() {
        // On rend aussi un delegue d'entree : sur Edge, les evenements tactiles
        // d'un data field passent par la, et pas seulement par la vue. Ca ne
        // suffit pas toujours — la barre de controle du 1050 intercepte la tape
        // avant nous — d'ou l'existence du widget compagnon.
        var view = new LampView(_lamp, _auto);
        return [ view, new LampInputDelegate(view) ];
    }
}

//! Relaie les tapes vers la vue. Seul `onTap` est transmis aux data fields.
class LampInputDelegate extends WatchUi.InputDelegate {

    private var _view as LampView;

    function initialize(view as LampView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onTap(evt as WatchUi.ClickEvent) as Lang.Boolean {
        // Rendre true est indispensable : sinon le systeme reprend la main et
        // affiche sa propre barre de controle.
        return _view.onTap(evt);
    }
}
