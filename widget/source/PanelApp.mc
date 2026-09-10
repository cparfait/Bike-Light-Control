using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using LightConstants as LC;

//! Application compagnon : page de pilotage de la lampe.
//!
//! Elle existe pour deux raisons :
//!
//! - sur les Edge à boutons (530, 540), `onTap()` du data field ne se déclenche
//!   jamais, et sur l'Edge 1050 la barre de contrôle du système intercepte la
//!   tape avant lui — sans cette page, aucun pilotage manuel n'est possible ;
//! - hors activité, aucun data field ne tourne, alors qu'on veut pouvoir allumer
//!   la lampe avant de partir.
//!
//! Type **watch-app** et non widget : les Edge récents (540, 550, 840, 850,
//! 1040, 1050, Explore 2, MTB) ne supportent pas le type widget. `watch-app` est
//! le seul type commun aux 13 modèles cibles — vérifiable avec
//! `bash tools/check-app-types.sh`.
class PanelApp extends Application.AppBase {

    private var _lamp as LampManager or Null = null;
    private var _auto as AutoController or Null = null;

    function initialize() {
        AppBase.initialize();
    }

    //! Volontairement vide.
    //!
    //! `onStart()` est appelé **aussi quand le système ne veut que la tuile de
    //! résumé**. Y monter la pile BLE chargeait `LampManager`, `LightProtocol`,
    //! `Protobuf` et leurs dépendances dans le contexte du résumé, dont le
    //! budget mémoire n'est que de 64 Ko sur un Edge 1050 — la moitié de celui
    //! d'un champ de données. Connect IQ ne signale pas un dépassement : la
    //! tuile reste simplement noire et vide, ce qu'on a constaté à l'écran.
    //!
    //! Tout est donc monté à l'ouverture de la page, pas au démarrage.
    function onStart(state as Lang.Dictionary or Null) as Void {
    }

    function onStop(state as Lang.Dictionary or Null) as Void {
        // Contrairement au data field, on **n'éteint pas** la lampe en quittant :
        // l'utilisateur vient précisément de l'allumer avant de partir rouler.
        // On libère seulement la connexion, pour que le data field ou le
        // téléphone puisse la reprendre.
        if (_lamp != null) { _lamp.stop(); }
    }

    //! C'est ici que la lampe est cherchée, et nulle part ailleurs : on n'y
    //! passe que si l'utilisateur ouvre vraiment la page.
    //! Lampe factice du mode demonstration. Deux formes annotees plutot qu'un
    //! `if` : le binaire de diffusion ne contient pas la seconde ligne, et pas
    //! davantage `LampDemo`. Meme procede que la surcouche de diagnostic.
    (:demo)
    private function _demo(lamp as LampManager) as Void { LampDemo.apply(lamp); }

    (:nodemo)
    private function _demo(lamp as LampManager) as Void { }

    function getInitialView() {
        if (_lamp == null) {
            _lamp = new LampManager();
            _auto = new AutoController();
            _demo(_lamp as LampManager);
            // Ici, « au demarrage » ne peut pas vouloir dire « au depart de
            // l'activite » : il n'y en a pas. On ouvre cette page pour allumer
            // sa lampe avant de partir, et le moment equivalent est celui ou on
            // la trouve. Le champ de donnees, lui, garde son declenchement au
            // chrono — voir `AutoController.onRideState()`.
            _lamp.lightOnConnect = AutoController.lightOnStart();
            if (AutoController.searchOnStart(false)) { _lamp.start(); }
        }
        var view = new LampControlView(_lamp, _auto);
        return [ view, new LampControlDelegate(_lamp, _auto, view) ];
    }

    //! Tuile de résumé, dans le carrousel de l'écran d'accueil.
    //!
    //! C'est l'endroit naturel pour piloter une lampe avant de partir : une
    //! application d'appareil, elle, oblige à quitter son profil d'activité.
    //! Les Edge anciens (530, 830, 1030, Explore) n'ont pas de résumés — le
    //! système ignore simplement cette vue, et l'application reste accessible
    //! par la liste des applications.
    (:glance)
    function getGlanceView() {
        return [ new LampGlanceView() ];
    }

}

//! Résumé compact : le dernier état connu de la lampe.
//!
//! **Il ne se connecte pas.** Un résumé dispose de 64 Ko sur un Edge 1050, et
//! Connect IQ n'échoue pas proprement quand on les dépasse : la tuile reste
//! noire, sans message. Charger la pile BLE ici — ce que faisait la version
//! précédente par le biais de `onStart()` — coûtait `LampManager`,
//! `LightProtocol`, `Protobuf` et le panneau de dessin, pour un résultat qui de
//! toute façon n'aurait rien affiché : un scan BLE demande plusieurs secondes,
//! là où une tuile se dessine instantanément.
//!
//! Elle montre donc ce que la page de pilotage a vu en dernier, et sert avant
//! tout de raccourci pour l'ouvrir — sur Edge, l'autre chemin oblige à quitter
//! son profil d'activité.
(:glance)
class LampGlanceView extends WatchUi.GlanceView {

    //! Clés de stockage, écrites par `LampControlView`.
    //!
    //! Ce sont des **chaînes déjà composées et déjà traduites**, pas des
    //! valeurs à mettre en forme. La tuile ne dépend ainsi de rien : ni de
    //! `LightConstants`, ni de `Labels`, ni même de la table de ressources.
    //!
    //! Ce n'est pas de la prudence excessive. Le journal de l'appareil a donné
    //! deux plantages successifs, tous deux « Illegal Access » dans le contexte
    //! du résumé : d'abord `LampManager`, puis `Labels` — alors que le module
    //! portait pourtant l'annotation `(:glance)`. Un résumé voit si peu du
    //! reste de l'application qu'il vaut mieux ne rien lui demander du tout.
    //!
    //! Contrepartie assumée : après un changement de langue du compteur, la
    //! tuile garde les anciens mots jusqu'à la prochaine ouverture de la page.
    //!
    //! Connect IQ isole le stockage par binaire : ce sont bien les relevés de
    //! cette application, pas ceux du champ de données.
    static const KEY_TITLE   = "glanceTitle";
    static const KEY_SUMMARY = "glanceSummary";

    //! Titre de repli, tant que la page n'a jamais été ouverte.
    //!
    //! **Écrit en dur, et c'est la seule façon.** La tuile n'a pas accès à la
    //! table de ressources — deux plantages « Illegal Access » l'ont établi —
    //! donc pas de traduction possible ici. Le nom du produit n'en demande pas.
    //!
    //! Sans lui, la tuile était **entièrement vide** avant la première
    //! ouverture : le système dessine sa tuile et l'icône du lanceur, et nous
    //! n'écrivions rien, au motif qu'on n'avait encore rien mesuré. Vu du
    //! carrousel, au milieu de tuiles qui affichent toutes quelque chose, ça ne
    //! se lit pas comme une application discrète mais comme une application
    //! cassée. Le simulateur l'a montré du premier coup.
    static const FALLBACK_TITLE = "Bike Light";

    //! **La vignette ne peint pas son fond.** Le système dessine la tuile, avec
    //! le thème que l'utilisateur a choisi ; la recouvrir revient à effacer ce
    //! choix. Une version l'a fait — une pastille sombre sous le texte, pour
    //! régler le cas de l'Edge MTB — et sur un Edge 1050 ça donnait une boîte
    //! grise posée au milieu d'une tuile bleu nuit.
    //!
    //! Reste le problème que la pastille réglait : **le fond de tuile n'a pas
    //! la même clarté d'un Edge à l'autre**, et aucune couleur de texte ne
    //! convient au blanc comme au noir. Il est réglé à la compilation, l'encre
    //! venant de `GlanceInk` — un fichier par variante, associé aux appareils
    //! par le jungle, exactement comme la taille de l'icône de lanceur. Mesuré
    //! sur les huit modèles qui ont une vignette : seul le MTB est clair.

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Ni `clear()` ni fond : le système a déjà peint sa tuile, et c'est la
        // sienne qu'on doit laisser voir.
        var pad = h / 6;
        if (pad < 4) { pad = 4; }

        var title = _stored(KEY_TITLE);
        if (title == null) { title = FALLBACK_TITLE; }
        dc.setColor(GlanceInk.TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(pad, h / 2, Graphics.FONT_TINY, title,
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // La valeur en ambre, la couleur d'accent de la page : la vignette et
        // la page de pilotage parlent ainsi le même langage de couleurs.
        var summary = _stored(KEY_SUMMARY);
        if (summary != null) {
            dc.setColor(GlanceInk.VALUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w - pad, h / 2, Graphics.FONT_TINY, summary,
                        Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    //! Chaîne rangée par la page, ou `null` si elle n'a jamais été ouverte.
    //! Le titre retombe alors sur `FALLBACK_TITLE` ; le résumé, lui, reste
    //! vide : « -- » ferait croire à une panne alors qu'on n'a jamais demandé
    //! quoi que ce soit à la lampe.
    private function _stored(key as Lang.String) as Lang.String or Null {
        var v = null;
        try {
            v = Application.Storage.getValue(key);
        } catch (e) {
        }
        if (v instanceof Lang.String) { return v; }
        return _demoText(key);
    }

    //! Valeurs de demonstration, pour voir la vignette garnie dans le
    //! simulateur — sinon elle s'y montre toujours dans son etat d'avant la
    //! premiere ouverture. Ecrites ici, et non tirees de `LampDemo` : le
    //! contexte de resume ne voit ni `LightConstants` ni les libelles.
    (:demo)
    private function _demoText(key as Lang.String) as Lang.String or Null {
        return key.equals(KEY_TITLE) ? "Light Front" : "62%  Dipped 2";
    }

    (:nodemo)
    private function _demoText(key as Lang.String) as Lang.String or Null {
        return null;
    }
}


//! Tactile sur les tuiles, boutons haut/bas/sélection sur les autres modèles.
class LampControlDelegate extends WatchUi.BehaviorDelegate {

    private var _lamp as LampManager;
    private var _auto as AutoController;
    private var _view as LampControlView;

    function initialize(lamp as LampManager, auto as AutoController,
                        view as LampControlView) {
        BehaviorDelegate.initialize();
        _lamp = lamp;
        _auto = auto;
        _view = view;
    }

    //! Une tape sur une tuile applique directement son mode — c'est tout
    //! l'intérêt d'une page de contrôle par rapport à un cycle aveugle.
    function onTap(evt as WatchUi.ClickEvent) as Lang.Boolean {
        var p = evt.getCoordinates();
        var action = _view.panel.actionAt(p[0], p[1]);
        // Au repos, la page n'est qu'un bouton : la tape lance la recherche.
        if (_lamp.isIdle()) { _lamp.start(); WatchUi.requestUpdate(); return true; }
        // Hors liaison, on ne pilote rien — mais on redessine, pour que la
        // surcouche de diagnostic montre le point touche.
        if (!_lamp.isReady() || _lamp.isSettling()) { WatchUi.requestUpdate(); return true; }
        // Pendant l'identification, une tape veut dire « c'est bon, j'ai vu » :
        // on abrege et on remet la lampe comme on l'a trouvee. Voir
        // LampManager.cancelIdentify().
        if (_lamp.isIdentifying()) { _lamp.cancelIdentify(); WatchUi.requestUpdate(); return true; }
        if (action != null) { _activate(action); }
        return true;   // toujours consommer, sinon le systeme ouvre sa barre
    }

    //! Bouton « menu » sur les modeles qui en ont un.
    function onMenu() as Lang.Boolean {
        _openSettings();
        return true;
    }

    function _openSettings() as Void {
        WatchUi.pushView(SettingsMenu.build(_lamp, _auto),
                         new SettingsMenuDelegate(_lamp, _auto),
                         WatchUi.SLIDE_LEFT);
    }

    function onNextPage() as Lang.Boolean {
        return _move(1);
    }

    function onPreviousPage() as Lang.Boolean {
        return _move(-1);
    }

    //! Sur les modèles à boutons, le curseur se déplace puis la sélection
    //! applique — deux gestes, mais aucun mode n'est appliqué par erreur.
    //!
    //! Sur un modele tactile, on n'y repond pas : le systeme peut traduire une
    //! tape en « selection », et le curseur y designe alors la zone de la tape
    //! **precedente** — chaque geste appliquait la tuile d'avant. C'est le
    //! « les boutons ne correspondent pas » observe sur l'Edge 1050.
    function onSelect() as Lang.Boolean {
        // Au repos, la selection lance la recherche — y compris sur un Edge a
        // boutons, ou aucune tape n'est possible et ou le bouton serait sinon
        // inatteignable.
        if (_lamp.isIdle()) { _lamp.start(); WatchUi.requestUpdate(); return true; }
        if (!_view.panel.usesCursor()) { return false; }
        if (!_lamp.isReady() || _lamp.isSettling()) { return false; }
        var boxes = _view.panel.hitBoxes;
        if (_view.panel.cursor >= 0 && _view.panel.cursor < boxes.size()) {
            _activate(boxes[_view.panel.cursor][4]);
        }
        return true;
    }

    private function _move(direction as Lang.Number) as Lang.Boolean {
        var count = _view.panel.hitBoxes.size();
        if (count == 0) { return false; }
        var c = _view.panel.cursor + direction;
        if (c < 0) { c = count - 1; }
        if (c >= count) { c = 0; }
        _view.panel.cursor = c;
        WatchUi.requestUpdate();
        return true;
    }

    //! Applique l'action d'une zone : reglages, automatisme, categorie, ou
    //! mode precis.
    private function _activate(action as Lang.Number) as Void {
        if (action == LampPanel.ACTION_SETTINGS) {
            _openSettings();
            return;
        }
        if (action == LampPanel.ACTION_AUTO) {
            // Le badge rend l'ajustement selon la vitesse reversible depuis la
            // page. Sans lui, une seule tape sur un mode condamnait au manuel
            // jusqu'a la fin de l'activite.
            _auto.setEnabledManually(!_auto.enabled);
            WatchUi.requestUpdate();
            return;
        }
        if (action <= LampPanel.ACTION_CATEGORY) {
            var cat = LampPanel.ACTION_CATEGORY - action;
            _view.panel.chooseCategory(cat);
            var modes = _lamp.modesFor(cat);
            if (modes.size() > 0) {
                // Toujours le cran le plus faible : personne n'a envie
                // d'eblouir quelqu'un en touchant une icone.
                _apply(modes[0] as Lang.Number);
            } else {
                WatchUi.requestUpdate();
            }
            return;
        }
        _apply(action);
    }

    private function _apply(mode as Lang.Number) as Void {
        _lamp.setMode(mode);
        // Anticipation optimiste : l'écran doit répondre au geste sans attendre
        // la notification de la lampe.
        _lamp.status.mode = mode;
        _view.panel.chooseCategory(LC.categoryOf(mode));
        WatchUi.requestUpdate();
    }
}
