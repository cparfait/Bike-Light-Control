using Toybox.Lang;
using Toybox.WatchUi;

//! Accès aux chaînes traduites, avec cache.
//!
//! Connect IQ ne propose pas de langue au choix dans Garmin Connect : une
//! application parle celle du compteur. Le système sélectionne le jeu de
//! ressources correspondant au démarrage — `shared/resources-fre` pour un Edge
//! en français, `shared/resources` pour tous les autres, l'anglais y servant de
//! repli. Il n'y a donc rien à décider ici, seulement à lire.
//!
//! **Pourquoi un cache.** `loadResource()` va chercher la chaîne dans la table
//! de ressources du binaire à chaque appel. La page de pilotage en demande une
//! quinzaine par rafraîchissement, et se redessine plusieurs fois par seconde :
//! sans cache, on relirait les mêmes chaînes des milliers de fois par minute
//! sur un appareil dont le processeur est déjà le facteur limitant.
//!
//! Le cache se remplit à la demande. Une page qui n'affiche jamais les modes
//! « flash » ne paie jamais leurs libellés — ce qui compte face aux 128 Ko d'un
//! champ de données.
//! Ce module n'est **pas** accessible à la tuile de résumé, et c'est voulu :
//! l'annotation `(:glance)` a été essayée et n'a pas suffi — l'appareil levait
//! toujours « Illegal Access » sur `Labels.of()`. La tuile n'affiche donc que
//! des chaînes déjà composées par la page, voir `LampGlanceView`.
module Labels {

    var _cache as Lang.Dictionary = {};

    //! Chaîne traduite pour un identifiant `Rez.Strings.*`.
    function of(id as Lang.ResourceId) as Lang.String {
        var hit = _cache[id];
        if (hit != null) { return hit as Lang.String; }

        // Une ressource absente leverait une exception en plein dessin, donc de
        // nuit sur un vélo. On retombe sur une chaîne vide : l'écran est
        // incomplet, mais il reste affiché et la lampe reste pilotable.
        var text = "";
        try {
            text = WatchUi.loadResource(id) as Lang.String;
        } catch (e) {
        }
        _cache[id] = text;
        return text;
    }
}
