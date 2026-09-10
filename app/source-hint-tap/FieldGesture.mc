using Toybox.Lang;

//! Le geste qui lance la recherche depuis le champ de données, sur un compteur
//! où **la tape atteint le champ**.
//!
//! Quatre cibles : Edge 830, 1030, 1030 Plus et Explore. Écran tactile, et
//! aucune barre de contrôle système pour s'interposer — c'est ce qui les
//! distingue des 840, 850, 1040, 1050 et Explore 2, tactiles eux aussi mais
//! dont la barre prend la tape avant l'application.
//!
//! Le bouton Lap y fonctionne également ; on nomme la tape parce que c'est le
//! geste naturel devant un écran tactile.
module FieldGesture {
    function idleHint() as Lang.String {
        return Labels.of(Rez.Strings.MsgIdleHint);
    }
}
