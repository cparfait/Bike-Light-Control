using Toybox.Lang;

//! Le geste qui lance la recherche depuis le champ de données, sur un compteur
//! où **la tape n'atteint pas le champ**.
//!
//! Neuf des treize cibles : les quatre sans écran tactile (530, 540, 550, MTB),
//! et les cinq dont la barre de contrôle du système prend la tape avant
//! l'application (840, 850, 1040, 1050, Explore 2). Reste le bouton Lap, seul
//! appui que le système transmette à un champ de données.
//!
//! Voir `source-hint-tap/FieldGesture.mc` pour l'autre variante, et le jungle
//! pour la répartition — établie sur `controlBarSupport` et `display.isTouch`
//! des profils du SDK, pas sur une supposition.
module FieldGesture {
    function idleHint() as Lang.String {
        return Labels.of(Rez.Strings.MsgIdleHintLap);
    }
}
