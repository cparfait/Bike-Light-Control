using Toybox.Lang;

//! Encre de la vignette de résumé, sur un compteur dont le fond de tuile est
//! **clair**. Un seul l'est : l'Edge MTB, dont les sept thèmes de vignette ont
//! tous une zone de contenu blanche — relevé dans les images du profil SDK,
//! puis vérifié à l'écran.
//!
//! L'ambre de l'application ne tiendrait pas sur du blanc : à 0xFFAA00 le
//! contraste tombe à 2 pour 1. On garde la teinte et on descend la luminosité.
(:glance)
module GlanceInk {
    const TEXT  = 0x1A1A1A;
    const VALUE = 0xB36B00;
}
