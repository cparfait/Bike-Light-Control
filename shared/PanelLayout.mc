using Toybox.Lang;

//! Géométrie de la page de pilotage, calculée **sans écran**.
//!
//! `LampPanel` ne fait que dessiner ce que cette classe décide. La séparation
//! n'est pas cosmétique : elle permet de vérifier la mise en page sur les
//! tailles réelles des 13 Edge cibles depuis un test unitaire, au lieu de la
//! constater sur un appareil à la fois.
//!
//! Les 13 cibles couvrent six formats d'écran — 240x320, 240x400, 246x322,
//! 282x470, 420x600, 480x800 — et un champ de données peut n'en occuper qu'une
//! fraction. Rien n'est donc exprimé en pixels : tout se déduit de la largeur
//! disponible et de la hauteur des polices, que l'appelant mesure sur son `Dc`.
class PanelLayout {

    //! Marge extérieure et espacement entre tuiles.
    var pad as Lang.Number = 0;
    var gap as Lang.Number = 0;

    //! Colonne de contenu.
    var x as Lang.Number = 0;
    var cw as Lang.Number = 0;

    //! Ordonnées des deux bandeaux du haut.
    var headerY as Lang.Number = 0;
    var headerH as Lang.Number = 0;
    var batteryY as Lang.Number = 0;
    var batteryH as Lang.Number = 0;

    //! Bandeau du mode courant. `heroH` vaut zéro quand il n'y a pas la place.
    var heroY as Lang.Number = 0;
    var heroH as Lang.Number = 0;

    //! Grille des catégories.
    var rowsY as Lang.Number = 0;
    var rows as Lang.Number = 1;
    var cols as Lang.Number = 1;
    var tw as Lang.Number = 0;
    var catH as Lang.Number = 0;
    var gridH as Lang.Number = 0;

    //! Rangée des niveaux. `levH` vaut zéro quand il n'y a rien à y montrer.
    var levY as Lang.Number = 0;
    var levH as Lang.Number = 0;
    var levW as Lang.Number = 0;

    //! `hSmall`, `hMedium` et `hLarge` sont les hauteurs de police mesurées sur
    //! le `Dc`. Elles varient du simple au triple entre un Edge Explore et un
    //! 1050 : les prendre en entrée plutôt que de les supposer est ce qui rend
    //! la mise en page transposable.
    //! `nLevels` est le nombre de tuiles réellement affichées dans la rangée du
    //! bas ; `reserveLevels` dit s'il faut lui garder sa place même quand elle
    //! est vide.
    //!
    //! Les deux sont distincts pour une raison précise : « Éteint » n'a qu'un
    //! seul mode, donc pas de rangée de niveaux. Sans réservation, la toucher
    //! faisait disparaître la rangée — et **tout le reste de la page remontait**.
    //! On perdait le repère de l'endroit où l'on venait de taper, sur un écran
    //! qu'on regarde une demi-seconde en roulant. La place reste donc prise,
    //! vide, tant que la lampe a au moins une catégorie à plusieurs crans.
    function initialize(w as Lang.Number, h as Lang.Number,
                        nCats as Lang.Number, nLevels as Lang.Number,
                        reserveLevels as Lang.Boolean,
                        hSmall as Lang.Number, hMedium as Lang.Number,
                        hLarge as Lang.Number) {
        pad = w / 24;
        if (pad < 5)  { pad = 5; }
        if (pad > 16) { pad = 16; }
        gap = pad * 55 / 100;
        if (gap < 3) { gap = 3; }

        x = pad;
        cw = w - 2 * pad;

        headerY = pad;
        headerH = hSmall;
        batteryY = headerY + headerH + gap;
        batteryH = hMedium;

        var top = batteryY + batteryH + pad;

        // ---- Grille des catégories ------------------------------------------
        //
        // Deux rangées plutôt qu'une quand l'écran est nettement plus haut que
        // large pour le nombre de catégories. Six tuiles alignées sur les 480
        // pixels d'un 1050 font des colonnes de 80 de large qu'il faut ensuite
        // étirer sur 300 de haut pour remplir la page ; à trois par rangée elles
        // en font 144, l'icône respire, et rien ne reste noir.

        var rest = h - pad - top;
        if (rest < 0) { rest = 0; }
        var span = rest - gap;
        if (span < 0) { span = 0; }

        cols = (nCats > 0) ? nCats : 1;
        rows = 1;
        tw = (cw - gap * (cols - 1)) / cols;

        if (nCats >= 4) {
            var cols2 = (nCats + 1) / 2;
            var tw2 = (cw - gap * (cols2 - 1)) / cols2;
            if (2 * (tw2 * 115 / 100) + gap <= span * 78 / 100) {
                rows = 2;
                cols = cols2;
                tw = tw2;
            }
        }
        if (tw < 1) { tw = 1; }

        // La grille vise des tuiles 1,15 fois plus hautes que larges et s'étire
        // jusqu'à 1,85 pour occuper la place. Au-delà, ce ne sont plus des
        // tuiles mais des colonnes : c'est ce plafond qui manquait à la version
        // précédente, où les deux rangées se partageaient toute la hauteur.
        var inter = (rows - 1) * gap;
        gridH = rows * (tw * 115 / 100) + inter;
        var room = span * ((rows == 2) ? 70 : 46) / 100;
        if (room > gridH) {
            var gridMax = rows * (tw * 185 / 100) + inter;
            gridH = (room > gridMax) ? gridMax : room;
        }
        var ceiling = span * ((rows == 2) ? 84 : 68) / 100;
        if (gridH > ceiling) { gridH = ceiling; }
        if (gridH < inter + rows) { gridH = inter + rows; }
        catH = (gridH - inter) / rows;

        // ---- Rangée des niveaux ---------------------------------------------

        levH = 0;
        levW = 0;
        if (nLevels > 0 || reserveLevels) {
            levH = catH * 58 / 100;
            var levMax = span - gridH;
            if (levH > levMax) { levH = levMax; }
            if (levH < 0) { levH = 0; }
        }
        if (nLevels > 0) {
            levW = (cw - gap * (nLevels - 1)) / nLevels;
            if (levW < 1) { levH = 0; }
        }

        var used = gridH + ((levH > 0) ? gap + levH : 0);
        var slack = rest - used;
        if (slack < 0) { slack = 0; }

        // ---- Bandeau du mode courant ----------------------------------------
        //
        // Il n'apparaît que s'il reste vraiment de la place. Le sacrifier est le
        // bon arbitrage : l'information est déjà portée par la tuile allumée,
        // alors que rogner les tuiles casse la cible tactile.
        //
        // **Il en prenait trop.** Plafonné à 1,8 fois la grande police, il
        // faisait 135 pixels sur un Edge 1050 : « Perso 1 » s'y étalait en
        // caractères de titre pendant que les tuiles, elles, restaient à ce que
        // la grille avait bien voulu leur laisser. Or le libellé n'est qu'un
        // rappel — la tuile allumée dit déjà lequel — alors que les tuiles sont
        // ce qu'on vise du doigt en roulant. Le plafond est donc calé sur la
        // police moyenne, et la part de l'espace libre ramenée de 55 à 42 % ;
        // le reste va à la grille, dont les bornes montent d'autant.
        heroY = top;
        heroH = 0;
        if (slack >= hSmall * 130 / 100) {
            heroH = slack * 42 / 100;
            var heroMax = hMedium * 150 / 100;
            if (heroH > heroMax) { heroH = heroMax; }
        }

        // Deux groupes : l'état en haut, les commandes en bas, et l'espace libre
        // entre les deux comme séparation. Sur un guidon, le bas de l'écran
        // s'atteint bien plus facilement que son milieu.
        rowsY = h - pad - used;
        if (rowsY < heroY + heroH) { rowsY = heroY + heroH; }
        levY = rowsY + gridH + gap;
    }

    //! Vrai si la page complète a assez de place pour être lisible. En dessous,
    //! le champ de données se rabat sur son affichage à deux lignes.
    static function fits(width as Lang.Number, height as Lang.Number) as Lang.Boolean {
        return width >= 200 && height >= 260;
    }
}
