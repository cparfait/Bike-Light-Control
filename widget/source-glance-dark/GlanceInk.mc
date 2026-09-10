using Toybox.Lang;

//! Encre de la vignette de résumé, sur un compteur dont le fond de tuile est
//! **sombre**. C'est le cas de douze des treize cibles.
//!
//! Voir `source-glance-light/GlanceInk.mc` pour l'autre variante, et le jungle
//! pour la répartition : c'est lui qui choisit le fichier, appareil par
//! appareil, comme il choisit déjà la taille de l'icône de lanceur.
(:glance)
module GlanceInk {
    const TEXT  = 0xFFFFFF;
    const VALUE = 0xFFAA00;
}
