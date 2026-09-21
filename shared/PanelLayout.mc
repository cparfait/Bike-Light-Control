using Toybox.Lang;
using Toybox.Math;

//! Géométrie de la page de pilotage, calculée **sans écran**.
//!
//! `LampPanel` ne fait que dessiner ce que cette classe décide. La séparation
//! n'est pas cosmétique : elle permet de vérifier la mise en page sur les
//! tailles réelles des 15 cibles depuis un test unitaire, au lieu de la
//! constater sur un appareil à la fois.
//!
//! Les 13 Edge couvrent six formats d'écran — 240x320, 240x400, 246x322,
//! 282x470, 420x600, 480x800 — et un champ de données peut n'en occuper qu'une
//! fraction. Rien n'est donc exprimé en pixels : tout se déduit de la largeur
//! disponible et de la hauteur des polices, que l'appelant mesure sur son `Dc`.
//!
//! **Les deux Venu 4 ajoutent un disque** — 390x390 et 454x454. Un disque n'est
//! pas un petit rectangle : la largeur utilisable dépend de la hauteur où l'on
//! se trouve, et les quatre coins d'un rectangle inscrit tombent dans le vide.
//! Chaque bande de la page réclame donc sa propre corde (voir `_half()`), ce
//! qui évite d'inscrire la page dans le carré central — 0,707 du diamètre, soit
//! la moitié du cadran perdue — et lui fait occuper le disque.
//!
//! Le chemin rectangulaire est inchangé, au pixel près : `round` à faux remet
//! `_half()` sur la demi-colonne unique et les marges sur `pad`.
class PanelLayout {

    //! Marge extérieure et espacement entre tuiles.
    var pad as Lang.Number = 0;
    var gap as Lang.Number = 0;

    //! Boîte de référence : la colonne de contenu d'un écran rectangulaire.
    //! Sur un disque, chaque bande a en plus la sienne, plus large ou plus
    //! étroite selon la hauteur où elle tombe.
    var x as Lang.Number = 0;
    var cw as Lang.Number = 0;

    //! Les deux bandeaux du haut : titre et pastille d'état, puis la charge.
    var headerX as Lang.Number = 0;
    var headerW as Lang.Number = 0;
    var headerY as Lang.Number = 0;
    var headerH as Lang.Number = 0;
    var batteryX as Lang.Number = 0;
    var batteryW as Lang.Number = 0;
    var batteryY as Lang.Number = 0;
    var batteryH as Lang.Number = 0;

    //! Bandeau du mode courant. `heroH` vaut zéro quand il n'y a pas la place.
    var heroX as Lang.Number = 0;
    var heroW as Lang.Number = 0;
    var heroY as Lang.Number = 0;
    var heroH as Lang.Number = 0;

    //! Grille des catégories.
    var gridX as Lang.Number = 0;
    var gridW as Lang.Number = 0;
    var rowsY as Lang.Number = 0;
    var rows as Lang.Number = 1;
    var cols as Lang.Number = 1;
    var tw as Lang.Number = 0;
    var catH as Lang.Number = 0;
    var gridH as Lang.Number = 0;

    //! Rangée des niveaux. `levH` vaut zéro quand il n'y a rien à y montrer ;
    //! `levRowW` est la largeur de la rangée, `levW` celle d'une seule tuile.
    var levX as Lang.Number = 0;
    var levRowW as Lang.Number = 0;
    var levY as Lang.Number = 0;
    var levH as Lang.Number = 0;
    var levW as Lang.Number = 0;

    //! Centre et rayon du cadran. `_r` reste nul sur un écran rectangulaire,
    //! et c'est ce qui neutralise tout le traitement du disque.
    hidden var _cy as Lang.Number = 0;
    hidden var _r as Lang.Number = 0;

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
    //!
    //! `round` dit que le `Dc` couvre un cadran rond entier — jamais qu'un
    //! champ de données découpé dedans, qui reste un rectangle. C'est
    //! `LampPanel.isRound()` qui tranche, à l'exécution.
    function initialize(w as Lang.Number, h as Lang.Number,
                        nCats as Lang.Number, nLevels as Lang.Number,
                        reserveLevels as Lang.Boolean,
                        hSmall as Lang.Number, hMedium as Lang.Number,
                        hLarge as Lang.Number, round as Lang.Boolean) {
        pad = w / 24;
        if (pad < 5)  { pad = 5; }
        if (pad > 16) { pad = 16; }
        gap = pad * 55 / 100;
        if (gap < 3) { gap = 3; }

        x = pad;
        cw = w - 2 * pad;

        // ---- Marges haute et basse ------------------------------------------
        //
        // Sur un rectangle, la marge est la même partout. Sur un disque, les
        // deux calottes ne portent qu'une corde trop courte pour une ligne de
        // texte : à 13 % du diamètre, le bandeau de titre dispose déjà de 54 %
        // de la largeur, ce qui suffit à « Lampe avant » et sa pastille. Plus
        // haut, le titre se réduirait à deux mots coupés ; plus bas, on
        // gaspillerait la hauteur dont la grille a besoin.
        _cy = h / 2;
        _r = 0;
        var padTop = pad;
        var padBottom = pad;
        if (round) {
            _r = ((w < h) ? w : h) / 2;
            padTop = h * 13 / 100;
            padBottom = padTop;
        }

        headerY = padTop;
        headerH = hSmall;
        batteryY = headerY + headerH + gap;
        batteryH = hMedium;

        var top = batteryY + batteryH + pad;

        // Largeur de travail : la corde de **toute** la zone que se partagent la
        // grille et les niveaux, donc la plus étroite qu'une de leurs bandes
        // puisse rencontrer. On dimensionne dessus, puis on élargit chaque bande
        // à sa propre corde une fois les ordonnées figées — élargir ne déplace
        // rien verticalement, la mise en page reste donc un calcul en une passe
        // et non un point fixe à itérer.
        var work = 2 * _half(top, h - padBottom);
        if (work < 1) { work = 1; }

        // ---- Grille des catégories ------------------------------------------
        //
        // Deux rangées plutôt qu'une quand l'écran est nettement plus haut que
        // large pour le nombre de catégories. Six tuiles alignées sur les 480
        // pixels d'un 1050 font des colonnes de 80 de large qu'il faut ensuite
        // étirer sur 300 de haut pour remplir la page ; à trois par rangée elles
        // en font 144, l'icône respire, et rien ne reste noir.

        var rest = h - padBottom - top;
        if (rest < 0) { rest = 0; }
        var span = rest - gap;
        if (span < 0) { span = 0; }

        cols = (nCats > 0) ? nCats : 1;
        rows = 1;
        tw = (work - gap * (cols - 1)) / cols;

        if (nCats >= 4) {
            var cols2 = (nCats + 1) / 2;
            var tw2 = (work - gap * (cols2 - 1)) / cols2;
            // **Le seuil n'est pas le même sur un disque.** Il est calé sur des
            // écrans bien plus hauts que larges, où une seule rangée reste
            // lisible ; un cadran est carré, et cinq tuiles y feraient 35 px de
            // large — intouchables avec un gant. La hauteur perdue par la
            // seconde rangée est justement ce qu'un disque a de trop.
            var room = round ? span : span * 78 / 100;
            if (2 * (tw2 * 115 / 100) + gap <= room) {
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
        var room2 = span * ((rows == 2) ? 70 : 46) / 100;
        if (room2 > gridH) {
            var gridMax = rows * (tw * 185 / 100) + inter;
            gridH = (room2 > gridMax) ? gridMax : room2;
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
            levW = (work - gap * (nLevels - 1)) / nLevels;
            if (levW < 1) { levH = 0; }
        }

        var used = gridH + ((levH > 0) ? gap + levH : 0);
        var slack = rest - used;
        if (slack < 0) { slack = 0; }

        // ---- Bandeau du mode courant ----------------------------------------
        //
        // Il n'apparaît que s'il reste vraiment de la place. Le sacrifier est le
        // bon arbitrage : l'information est déjà portée par la tuile allumée,
        // alors que rogner les tuiles casse la cible tactile. Sur un cadran, la
        // place ne s'y trouve jamais — la grille à deux rangées la prend toute,
        // et c'est le bon choix là comme ailleurs.
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
        rowsY = h - padBottom - used;
        if (rowsY < heroY + heroH) { rowsY = heroY + heroH; }
        levY = rowsY + gridH + gap;

        // ---- Largeur propre à chaque bande -----------------------------------
        //
        // Les ordonnées sont figées : chaque bande peut maintenant réclamer la
        // corde de sa seule hauteur, plus large que celle qui a servi au
        // dimensionnement. Sur un Venu 4 la grille y gagne un cinquième de sa
        // largeur, et c'est la différence entre une page inscrite dans le carré
        // central et une page qui occupe le cadran.
        //
        // Sur un rectangle, `_half()` rend toujours `cw / 2` : chaque bande
        // retombe exactement sur `x` et `cw`, et `tw` sur sa valeur d'avant.
        headerW = 2 * _half(headerY, headerY + headerH);
        headerX = (w - headerW) / 2;
        batteryW = 2 * _half(batteryY, batteryY + batteryH);
        batteryX = (w - batteryW) / 2;
        heroW = 2 * _half(heroY, heroY + heroH);
        heroX = (w - heroW) / 2;

        gridW = 2 * _half(rowsY, rowsY + gridH);
        gridX = (w - gridW) / 2;
        tw = (gridW - gap * (cols - 1)) / cols;
        if (tw < 1) { tw = 1; }

        levRowW = 2 * _half(levY, levY + levH);
        levX = (w - levRowW) / 2;
        if (nLevels > 0) {
            levW = (levRowW - gap * (nLevels - 1)) / nLevels;
            if (levW < 1) { levH = 0; }
        }
    }

    //! Demi-largeur utilisable par une bande horizontale allant de `y0` à `y1`.
    //!
    //! Sur un rectangle, c'est la moitié de la colonne de contenu, la même pour
    //! toutes les bandes — d'où l'égalité stricte avec l'ancienne mise en page.
    //!
    //! Sur un disque, c'est la demi-corde prise **au bord le plus éloigné du
    //! centre** : c'est lui qui contraint, et c'est là que tombent les deux
    //! coins qui sortiraient du cadran. La marge est retranchée au rayon et non
    //! à la corde, pour que le jeu soit le même tout autour de la page plutôt
    //! que seulement sur ses côtés.
    hidden function _half(y0 as Lang.Number, y1 as Lang.Number) as Lang.Number {
        if (_r <= 0) { return cw / 2; }
        return chordWidth(2 * _r, y0, y1, pad) / 2;
    }

    //! Largeur utilisable par une bande horizontale sur un cadran de `size`
    //! pixels de diamètre, marge `margin` comprise. Zéro si la bande sort du
    //! disque.
    //!
    //! Exposée et statique parce que la page de pilotage n'est pas seule à en
    //! avoir besoin : l'écran d'attente, lui, ne passe pas par `PanelLayout` —
    //! il n'a ni grille ni bandeaux — mais ses trois lignes de texte sont
    //! posées aux deux tiers et aux trois quarts de la hauteur, là où la corde
    //! est déjà nettement plus courte que le diamètre. Une seule formule, et un
    //! seul endroit où la corriger.
    static function chordWidth(size as Lang.Number, y0 as Lang.Number,
                               y1 as Lang.Number,
                               margin as Lang.Number) as Lang.Number {
        var c = size / 2;
        var d0 = (y0 - c).abs();
        var d1 = (y1 - c).abs();
        var dy = (d0 > d1) ? d0 : d1;
        var rr = c - margin;
        if (rr <= 0 || dy >= rr) { return 0; }
        return 2 * Math.sqrt((rr * rr - dy * dy).toFloat()).toNumber();
    }

    //! Vrai si la page complète a assez de place pour être lisible. En dessous,
    //! le champ de données se rabat sur son affichage à deux lignes.
    //!
    //! Sur un cadran, ce n'est pas le diamètre qu'il faut comparer aux bornes
    //! mais la bande réellement occupée : 74 % du diamètre en hauteur une fois
    //! les deux calottes retirées, et 67 % en largeur, la corde au plus étroit
    //! de cette bande. Les deux Venu 4 passent — 261x288 pour le 390 mm,
    //! 304x335 pour le 454.
    static function fits(width as Lang.Number, height as Lang.Number,
                         round as Lang.Boolean) as Lang.Boolean {
        var w = width;
        var h = height;
        if (round) {
            w = width * 67 / 100;
            h = height * 74 / 100;
        }
        return w >= 200 && h >= 260;
    }
}
