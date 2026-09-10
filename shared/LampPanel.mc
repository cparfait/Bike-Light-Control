using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using LightConstants as LC;

//! Panneau de pilotage : bandeau d'état, mode courant, catégories, niveaux.
//!
//! Composant de dessin, volontairement pas une View : il sert à la fois à
//! l'application compagnon et au champ de données quand celui-ci occupe assez
//! de place. Une seule mise en page à maintenir plutôt que deux qui divergent.
//!
//! Le classement par catégorie évite d'avoir à traverser les six crans de
//! faisceau pour atteindre le flash : une tape sur « Flash » y va directement,
//! à son niveau le plus faible.
//!
//! **Mise en page élastique.** La même page doit tenir dans les 246x322 d'un
//! Edge 530 comme dans les 480x800 d'un 1050. Rien n'est exprimé en pixels :
//! les tuiles se dimensionnent sur la largeur disponible, plafonnées par la
//! hauteur, et l'espace qui reste va au bandeau du mode courant. C'est ce
//! plafond qui manquait à la version précédente, où deux rangées se
//! partageaient toute la hauteur et donnaient des pavés de 300 pixels.
class LampPanel {

    //! Valeurs sentinelles pour les zones tactiles qui n'appliquent pas un mode.
    //! Hors de la plage des modes réels, qui va de 0 à 75.
    static const ACTION_SETTINGS = -1;
    static const ACTION_AUTO     = -2;
    static const ACTION_CATEGORY = -100;   // -100 - index de catégorie

    //! Forme des libellés d'une rangée de catégories, la même pour toutes.
    static const LABEL_NONE  = 0;
    static const LABEL_SHORT = 1;
    static const LABEL_FULL  = 2;

    private var _lamp as LampManager;
    private var _auto as AutoController;

    //! Zones tactiles calculées au dessin : `[x, y, largeur, hauteur, action]`.
    var hitBoxes as Lang.Array = [];

    //! Curseur pour la navigation aux boutons, sur les modèles sans tactile.
    var cursor as Lang.Number = 0;

    //! Catégorie dont les modes sont listés sous la rangée. Elle **suit le mode
    //! courant** tant que l'utilisateur n'en a pas choisi une lui-même : voir
    //! `chooseCategory()` et `_categoryChosen`.
    private var selectedCategory as Lang.Number or Null = null;

    //! Vrai des que l'utilisateur a designe une categorie, directement ou en
    //! touchant un mode. La selection cesse alors de suivre la lampe.
    //!
    //! Sans ce drapeau, la selection etait figee au **premier** dessin et n'en
    //! bougeait plus. Or ce premier dessin tombe juste apres le clignotement
    //! d'identification, qui met la lampe sur un cran intermediaire de
    //! l'echelle — `BLM_HBEAM_LSTEADY`, donc « Route ». La categorie Route
    //! restait donc entouree de vert pour le reste de la session, alors que
    //! personne ne l'avait choisie et que la lampe etait revenue a l'extinction.
    private var _categoryChosen as Lang.Boolean = false;

    //! Affiche le badge AUTO / MANU. Vrai par défaut. L'application compagnon
    //! le masque : Connect IQ isole l'état de chaque binaire, et l'ajustement
    //! selon la vitesse ne tourne que dans le champ de données — un badge qui
    //! bascule un drapeau sans effet est un mensonge.
    var showAuto as Lang.Boolean = true;

    //! Affiche la roue dentée des réglages. Faux par défaut : seul un binaire
    //! capable d'empiler une vue — l'application compagnon — peut la proposer.
    var showSettings as Lang.Boolean = false;

    //! Vrai sur les Edge à boutons. Le curseur n'y est pas un détail : sans
    //! trace à l'écran, `onNextPage()` déplaçait une sélection invisible et la
    //! page paraissait ne pas répondre.
    private var _showCursor as Lang.Boolean = false;

    //! Vrai sur les modeles a boutons : la selection s'y fait au curseur. Sur un
    //! tactile, c'est la tape qui designe, et le curseur n'a pas de sens.
    function usesCursor() as Lang.Boolean { return _showCursor; }

    //! Designe la categorie a lister, sur un geste de l'utilisateur.
    //!
    //! Passer par cette methode plutot que d'ecrire le champ : c'est elle qui
    //! marque le choix comme volontaire et arrete le suivi automatique du mode
    //! de la lampe.
    function chooseCategory(cat as Lang.Number or Null) as Void {
        selectedCategory = cat;
        _categoryChosen = true;
    }

    //! Oublie les zones tactiles : plus rien de ce panneau n'est a l'ecran.
    //!
    //! A appeler par toute vue qui, sur un rafraichissement, dessine **autre
    //! chose** que ce panneau. `hitBoxes` n'est vide que par `draw()`, si bien
    //! qu'un champ de donnees passe du plein ecran a une petite case gardait les
    //! zones de l'affichage precedent : la tape tombait dans le panneau, ne
    //! trouvait aucune tuile sous le doigt, et etait avalee. La petite case
    //! cessait purement et simplement de repondre au toucher.
    function clearHitBoxes() as Void {
        hitBoxes = [];
        _settingsBox = null;
    }

    //! Supprime le curseur, quel que soit l'appareil.
    //!
    //! Le champ de donnees l'appelle : aucune touche n'est transmise a un data
    //! field, meme plein ecran. Sur un Edge 530, 540 ou MTB, le cadre blanc
    //! restait donc fige sur la premiere tuile — une selection qu'aucun bouton
    //! ne pouvait deplacer, et qui laissait croire a une page bloquee.
    function hideCursor() as Void { _showCursor = false; }

    private var _settingsBox as Lang.Array or Null = null;

    //! Precision affichee au repos a la place de « toucher pour lancer la
    //! recherche ». Le champ de donnees la pose sur les modeles a boutons, ou
    //! aucune tape n'atteint jamais la case : la recherche y part avec le
    //! chrono, et c'est ce qu'il faut ecrire.
    var idleHint as Lang.String or Null = null;

    //! Caches de mesure de texte. La page se redessine chaque seconde, et
    //! chaque image mesurait une vingtaine de chaines dans jusqu'a cinq polices
    //! pour retomber sur le meme resultat : sur un Edge 530, c'est du
    //! processeur — donc de la batterie — pour rien. La cle change quand la
    //! place ou le nombre de modes change, et seulement la.
    private var _heroKey as Lang.Number = -1;
    private var _heroFont as Graphics.FontDefinition = Graphics.FONT_SMALL;
    private var _labelKey as Lang.Number = -1;
    private var _labelForm as Lang.Number = LABEL_FULL;

    function initialize(lamp as LampManager, auto as AutoController) {
        _lamp = lamp;
        _auto = auto;
        var settings = System.getDeviceSettings();
        _showCursor = !((settings has :isTouchScreen) && settings.isTouchScreen);
    }

    //! Catégories réellement disponibles sur cette lampe. « Éteint » est
    //! toujours proposé ; les autres n'apparaissent que si la lampe déclare au
    //! moins un mode dedans — une icône sans effet vaut moins que rien.
    function categories() as Lang.Array {
        // Les modes **declares**, pas seulement les actifs : la VS1800S sort
        // d'usine avec ses deux flashs desactives, et la categorie « Flash »
        // disparaissait purement et simplement. L'utilisateur en concluait que
        // l'application ne les connaissait pas.
        var out = [];
        for (var i = 0; i < LC.CATEGORY_ORDER.size(); i++) {
            var cat = LC.CATEGORY_ORDER[i] as Lang.Number;
            if (cat == LC.CAT_OFF || _lamp.modesFor(cat).size() > 0) {
                out.add(cat);
            }
        }
        return out;
    }

    //! Dessine le panneau et recalcule les zones tactiles.
    function draw(dc as Graphics.Dc) as Void {
        _auto.setSupportedModes(_lamp.status.supportedModes, _lamp.status.lightType);

        // **Lissage des contours.** Il n'était activé nulle part, et c'est la
        // première raison pour laquelle les icônes paraissaient sales : tout est
        // tracé en primitives, donc chaque diagonale, chaque cercle et chaque
        // coin arrondi sortait en escalier. Le dessin n'y était pour rien.
        //
        // Sous condition : les Edge anciens (530, 830, 1030, Explore, MTB) n'ont
        // pas de composition alpha et ne déclarent pas `setAntiAlias`.
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }

        dc.setColor(LC.UI_TEXT, LC.UI_BG);
        dc.clear();
        hitBoxes = [];
        _settingsBox = null;

        var w = dc.getWidth();
        var h = dc.getHeight();

        // Tant que la lampe n'est pas la — pendant qu'elle repond au bilan
        // initial, et pendant qu'elle se designe en clignotant — la page ne
        // montre qu'une chose : ou on en est. Afficher les tuiles d'une lampe
        // absente etait un mensonge poli : elles ne repondaient pas a la tape,
        // et l'etat se lisait en petit dans un coin, dans une police differente
        // de tout le reste.
        //
        // `isSettling()` couvre la seconde ou deux qui suivent l'abonnement :
        // liaison faite, mais mode encore inconnu, donc cinq tuiles grises et
        // aucune allumee. Voir LampManager.isSettling().
        if (!_lamp.isReady() || _lamp.isSettling() || _lamp.isIdentifying()) {
            _drawWaiting(dc, w, h);
            // La surcouche vaut surtout **ici** : c'est l'ecran ou l'on attend,
            // ou l'on identifie, et donc celui ou l'on a le plus besoin de voir
            // l'etat brut. Elle n'y etait pas dessinee, faute d'etre appelee
            // avant la sortie.
            _drawDebug(dc);
            return;
        }

        if (w < 200 || h < 160) {
            _drawCompact(dc, w, h);
            _drawDebug(dc);
            return;
        }

        // La catégorie suit le mode courant tant qu'on n'en a pas choisi une.
        // À chaque dessin, et non au premier seulement : c'est ce que dit cette
        // phrase depuis le début, ce n'est pas ce que faisait le code.
        if (!_categoryChosen) {
            selectedCategory = LC.categoryOf(_lamp.status.mode);
        }

        // Toute la geometrie est calculee par PanelLayout, qui ne connait que
        // des nombres : c'est ce qui permet de la verifier sur les tailles
        // reelles des 13 Edge cibles depuis un test unitaire, plutot que de la
        // constater sur un appareil a la fois.
        var cats = categories();
        var levels = _levelModes();
        var m = new PanelLayout(w, h, cats.size(), levels.size(), _hasLevelRow(),
                                dc.getFontHeight(Graphics.FONT_SMALL),
                                dc.getFontHeight(Graphics.FONT_MEDIUM),
                                dc.getFontHeight(Graphics.FONT_LARGE));

        _drawHeader(dc, m.x, m.headerY, m.cw);
        _drawBattery(dc, m.x, m.batteryY, m.cw);

        if (m.heroH > 0) {
            _drawHero(dc, m.x, m.heroY, m.cw, m.heroH);
        }

        _drawCategories(dc, m.x, m.rowsY, m.cw, cats, m.tw, m.catH, m.cols, m.gap);
        // La rangée peut être réservée mais vide — « Éteint » n'a pas de crans.
        // La place reste prise pour que rien ne se déplace ; c'est exactement là
        // que va le rappel d'extinction, dans un espace déjà réservé plutôt que
        // par-dessus quelque chose.
        if (m.levH > 0 && levels.size() > 0) {
            _drawLevels(dc, m.x, m.levY, m.cw, m.levH, levels, m.gap);
        } else if (m.levH > 0) {
            _drawOffNotice(dc, m.x, m.levY, m.cw, m.levH);
        }

        if (_settingsBox != null) {
            hitBoxes.add([_settingsBox[0], _settingsBox[1], _settingsBox[2],
                          _settingsBox[3], ACTION_SETTINGS]);
        }

        _drawCursor(dc);
        _drawDebug(dc);
    }

    //! Modes de la rangée du bas. Vide pour « Éteint » : la catégorie n'a qu'un
    //! seul mode, et une rangée d'une seule tuile n'apprendrait rien.
    private function _levelModes() as Lang.Array {
        if (selectedCategory == null || selectedCategory == LC.CAT_OFF) { return []; }
        var modes = _lamp.modesFor(selectedCategory as Lang.Number);
        return (modes.size() > 1) ? modes : [];
    }

    //! Vrai si la rangée des niveaux doit garder sa place, y compris quand la
    //! catégorie affichée n'en a pas.
    //!
    //! Ne dépend que de ce que la lampe déclare, jamais de la sélection : c'est
    //! précisément ce qui empêche la page de bouger quand on passe d'une
    //! catégorie à « Éteint » et retour.
    private function _hasLevelRow() as Lang.Boolean {
        for (var i = 0; i < LC.CATEGORY_ORDER.size(); i++) {
            var cat = LC.CATEGORY_ORDER[i] as Lang.Number;
            if (cat != LC.CAT_OFF && _lamp.modesFor(cat).size() > 1) {
                return true;
            }
        }
        return false;
    }

    // ---- Bandeau supérieur -------------------------------------------------

    private function _drawHeader(dc as Graphics.Dc, x as Lang.Number,
                                 y as Lang.Number, w as Lang.Number) as Lang.Number {
        var font = Graphics.FONT_SMALL;
        var hh = dc.getFontHeight(font);
        var cy = y + hh / 2;

        // Roue dentée collée au bord droit. C'est le seul accès aux réglages
        // sur un modèle sans bouton menu ; la coincer au milieu du bandeau,
        // comme avant, la faisait passer pour une décoration.
        //
        // Elle n'est dessinée que par l'application compagnon : un champ de
        // données n'a pas le droit d'empiler une vue, la roue y était donc un
        // bouton qui ne menait nulle part.
        var right = x + w;
        if (showSettings) {
            var gr = hh * 45 / 100;
            var gx = x + w - gr;
            _drawGear(dc, gx, cy, gr);
            _settingsBox = [gx - gr - 2, y, 2 * gr + 4, hh];
            right = gx - gr - _gap(hh);
        }

        // État de la liaison : une pastille verte, et rien d'autre. Le mot
        // « OK » qui l'accompagnait n'apprenait rien de plus qu'elle, dans une
        // police encore differente ; la page en comptait une de trop.
        //
        // Le bandeau ne s'affiche que lampe connectée — sinon c'est l'écran
        // d'attente qui prend toute la place — donc la pastille est verte, sauf
        // panne survenue en cours de liaison.
        var ready = _lamp.isReady();

        var dotR = hh / 7;
        if (dotR < 3) { dotR = 3; }

        dc.setColor(ready ? LC.UI_OK : LC.UI_WARN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(right - dotR, cy, dotR);

        // « Lampe avant » quand elle l'a dit, « Lampe » sinon : afficher
        // « Lampe ? » ferait croire a une anomalie alors qu'on attend juste
        // une reponse. Une panne signalee prend sa place : c'est ce qui rend le
        // diagnostic possible sans PC.
        var type = _lamp.status.lightType;
        var generic = Labels.of(Rez.Strings.LightGeneric);
        var title = (type == null) ? generic : generic + " " + LC.typeLabel(type);
        if (_lamp.lastError != null) { title = _lamp.lastError; }
        var titleMax = right - 3 * dotR - _gap(hh) - x;
        var titleFont = _fitFont(dc, title, titleMax,
            [Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY]);
        dc.setColor(LC.UI_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, cy, titleFont, title,
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        return y + hh;
    }

    //! Espacement proportionnel à la taille du texte voisin, pour que la
    //! respiration du bandeau suive la résolution de l'écran.
    private function _gap(fontHeight as Lang.Number) as Lang.Number {
        var g = fontHeight / 4;
        return (g < 3) ? 3 : g;
    }

    //! Roue dentée : un anneau épais, et huit dents courtes et larges.
    //!
    //! Elle était dessinée avec des rayons **fins et longs**, partant de 55 %
    //! du rayon jusqu'au bord : à l'écran, ça ne se lit pas comme un
    //! engrenage mais comme un **soleil**, c'est-à-dire comme une commande de
    //! luminosité — sur une page qui pilote une lampe, la confusion est
    //! particulièrement mal choisie. Une dent d'engrenage est courte et aussi
    //! large que le vide qui la sépare de la suivante ; c'est ce rapport-là,
    //! pas le nombre de dents, qui fait reconnaître le symbole.
    private function _drawGear(dc as Graphics.Dc, cx as Lang.Number,
                               cy as Lang.Number, r as Lang.Number) as Void {
        if (r < 5) { return; }
        dc.setColor(LC.UI_DIM, Graphics.COLOR_TRANSPARENT);

        // L'anneau, épais : c'est lui qui porte le dessin. Le trait vaut le
        // quart du rayon, tracé à mi-chemin du centre et du bord.
        var ring = r * 52 / 100;
        var pen = r * 26 / 100;
        if (pen < 2) { pen = 2; }
        dc.setPenWidth(pen);
        dc.drawCircle(cx, cy, ring);

        // Huit dents, aux quatre axes et aux quatre diagonales, de l'anneau au
        // bord. Les diagonales sont posées à 70 % de leur composante — la
        // valeur de cos(45°) — pour que toutes tombent sur le même cercle.
        var dxs = [10, 7, 0, -7, -10, -7,  0,  7];
        var dys = [ 0, 7, 10, 7,   0, -7, -10, -7];
        var from = ring + pen / 4;
        dc.setPenWidth(pen * 105 / 100);
        for (var i = 0; i < 8; i++) {
            var dx = dxs[i] as Lang.Number;
            var dy = dys[i] as Lang.Number;
            dc.drawLine(cx + dx * from / 10, cy + dy * from / 10,
                        cx + dx * r / 10, cy + dy * r / 10);
        }
        dc.setPenWidth(1);
    }

    //! Charge de la lampe : le pourcentage en clair, une jauge, l'autonomie.
    //!
    //! **Le pourcentage est sorti de la jauge.** Il y était écrit à l'intérieur,
    //! dans la plus petite police du jeu : sur un Edge 1050, un « 62 % » de
    //! quatorze pixels au milieu d'une barre de quatre cents. C'est pourtant le
    //! nombre qui décide si on part ou si on recharge, et le seul de la page
    //! qu'on lit avant de sortir — il n'avait aucune raison d'être le plus
    //! petit. Il est maintenant à gauche, dans la même police que l'autonomie,
    //! et **de la couleur de la charge** : vert, orange, rouge. La jauge, elle,
    //! garde son rôle — donner l'ordre de grandeur d'un coup d'œil — et prend
    //! simplement ce que les deux textes lui laissent.
    private function _drawBattery(dc as Graphics.Dc, x as Lang.Number,
                                  y as Lang.Number, w as Lang.Number) as Lang.Number {
        var pct = _lamp.status.batteryPct;
        var rowH = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var barH = rowH * 62 / 100;
        var barY = y + (rowH - barH) / 2;
        var cy = y + rowH / 2;
        var gap = _gap(rowH);

        // Lampe éteinte : l'autonomie serait celle d'avant l'extinction.
        var mode = _lamp.status.mode;
        var lit = (mode != null && mode != LC.BLM_LIGHT_OFF);
        var left = _lamp.status.remainingMinutes;
        var showLeft = (lit && left != null && left > 0);

        var fonts = [Graphics.FONT_MEDIUM, Graphics.FONT_SMALL,
                     Graphics.FONT_TINY, Graphics.FONT_XTINY];

        // Le pourcentage, à gauche.
        var used = 0;
        var barX = x;
        if (pct != null) {
            var text = pct.format("%d") + " %";
            var font = _fitFontIn(dc, text, w * 40 / 100, fonts, rowH);
            dc.setColor(_batteryColor(pct), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, cy, font, text,
                        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            used = dc.getTextWidthInPixels(text, font) + gap * 2;
            barX = x + used;
        }

        // L'autonomie, à droite. La jauge prend ce qui reste entre les deux :
        // sur un écran étroit, « 12 h 05 » ne chevauche donc jamais la barre.
        var barW = w - used;
        if (showLeft) {
            var lText = _duration(left);
            var lFont = _fitFontIn(dc, lText, w * 40 / 100, fonts, rowH);
            dc.setColor(LC.UI_TEXT, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + w, cy, lFont, lText,
                        Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            barW -= dc.getTextWidthInPixels(lText, lFont) + gap * 2;
        }

        // Sous cette largeur, la jauge ne dit plus rien de lisible : les deux
        // nombres suffisent, et valent mieux qu'un moignon de barre.
        if (barW < 30) { return y + rowH; }

        var radius = barH / 3;
        var nub = barH / 4;
        dc.setColor(LC.UI_TILE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barW - nub, barH, radius);
        dc.setColor(LC.UI_EDGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX + barW - nub, barY + barH / 3, nub, barH / 3, 1);

        if (pct != null) {
            var inner = barW - nub - 4;
            var fill = inner * pct / 100;
            if (fill < 3 && pct > 0) { fill = 3; }
            if (fill > 0) {
                // Un rayon plus grand que la moitié de la largeur ne définit
                // plus un rectangle : à 2 %, la jauge est plus étroite que son
                // propre arrondi.
                var fr = radius;
                if (fr > fill / 2) { fr = fill / 2; }
                dc.setColor(_batteryColor(pct), Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(barX + 2, barY + 2, fill, barH - 4, fr);
            }
        }
        return y + rowH;
    }

    private function _batteryColor(pct as Lang.Number) as Lang.Number {
        if (_auto.isBatteryLow(pct)) { return LC.UI_ALERT; }
        if (pct <= 40) { return LC.UI_WARN; }
        return LC.UI_OK;
    }

    // ---- Bandeau du mode courant -------------------------------------------

    //! Le mode en toutes lettres, et l'état de l'automatisme à droite.
    //!
    //! Le badge n'est pas décoratif : toute action manuelle coupe l'ajustement
    //! selon la vitesse, et jusqu'ici rien ne le disait ni ne permettait de le
    //! rétablir depuis la page — il fallait éteindre la lampe puis retaper.
    private function _drawHero(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number,
                               w as Lang.Number, h as Lang.Number) as Void {
        var badge = Labels.of(_auto.enabled ? Rez.Strings.BadgeAuto : Rez.Strings.BadgeManual);
        // Une vraie cible tactile, pas une etiquette : police de taille normale
        // et hauteur genereuse. Le badge est la seule commande de la page qui
        // n'est pas une tuile, il ne doit pas etre le plus petit element.
        var badgeFont = Graphics.FONT_SMALL;
        var bh = dc.getFontHeight(badgeFont) * 140 / 100;
        if (bh > h) { bh = h; }
        // Largeur fixee sur le plus long des deux mots : basculer AUTO/MANU ne
        // doit pas deplacer le badge, cale a droite, ni le libelle a sa gauche.
        var wAuto = dc.getTextWidthInPixels(Labels.of(Rez.Strings.BadgeAuto), badgeFont);
        var wManu = dc.getTextWidthInPixels(Labels.of(Rez.Strings.BadgeManual), badgeFont);
        var bw = ((wAuto > wManu) ? wAuto : wManu) + bh * 120 / 100;
        var bx = x + w - bw;
        var by = y + (h - bh) / 2;

        if (showAuto) {
            // Meme grammaire que les tuiles : plein vert = actif, sombre cercle
            // = inactif. On lit l'etat a la couleur avant de lire le mot.
            if (_auto.enabled) {
                dc.setColor(LC.UI_OK, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(bx, by, bw, bh, bh / 2);
                dc.setColor(LC.contrastOn(LC.UI_OK), Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(LC.UI_TILE, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(bx, by, bw, bh, bh / 2);
                dc.setColor(LC.UI_EDGE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(_pen(bh, 12));
                dc.drawRoundedRectangle(bx, by, bw, bh, bh / 2);
                dc.setPenWidth(1);
                dc.setColor(LC.UI_DIM, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(bx + bw / 2, by + bh / 2, badgeFont, badge,
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            hitBoxes.add([bx, by, bw, bh, ACTION_AUTO]);
        } else {
            bw = 0;
        }

        var mode = _lamp.status.mode;
        var label = (mode == null) ? "--" : LC.modeLabel(mode);
        var avail = w - bw - _gap(bh) * 2;
        // La police est choisie pour le **plus long libelle que la lampe peut
        // afficher**, pas pour celui du moment : sinon passer de « Route
        // eleve » a « Croisement moyen » faisait sauter la taille du texte a
        // chaque tape, et la page semblait bouger. Mise en cache sur la place
        // disponible et le nombre de modes declares, voir `_heroKey`.
        var declared = _lamp.declaredModes();
        var key = (avail * 64 + h) * 128 + ((declared == null) ? 0 : declared.size());
        if (key != _heroKey) {
            // **La hauteur compte autant que la largeur.** La police etait
            // choisie sur la seule largeur, puis rabattue sur la plus petite du
            // jeu des qu'elle ne tenait pas en hauteur — sans essayer celles du
            // milieu. Sur un Edge 1030, le bandeau fait 42 pixels et la grande
            // police 48 : « Croisement 2 » s'ecrivait donc en corps minuscule
            // au milieu d'un bandeau presque vide, alors que la police moyenne
            // — 29 pixels — y tenait largement. Le defaut se voyait sur les
            // 1030, 1030 Plus et Explore, jamais sur le 1050.
            _heroFont = _fitFontIn(dc, _longestModeLabel(label), avail, [
                Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL,
                Graphics.FONT_TINY, Graphics.FONT_XTINY
            ], h);
            _heroKey = key;
        }
        var font = _heroFont;
        dc.setColor(_modeColor(mode), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + h / 2, font, label,
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //! Le plus long des libelles de mode que la lampe declare — `fallback`
    //! compris, au cas ou le mode courant ne serait pas dans la liste. Sert a
    //! choisir une police qui ne changera pas d'un mode a l'autre.
    private function _longestModeLabel(fallback as Lang.String) as Lang.String {
        var longest = fallback;
        var modes = _lamp.declaredModes();
        if (modes == null) { return longest; }
        for (var i = 0; i < modes.size(); i++) {
            var l = LC.modeLabel(modes[i] as Lang.Number);
            if (l.length() > longest.length()) { longest = l; }
        }
        return longest;
    }

    //! Couleur d'un mode : sa place dans la rampe d'intensité de sa catégorie.
    //! Le libellé du mode courant a donc exactement la teinte de sa tuile.
    private function _modeColor(mode as Lang.Number or Null) as Lang.Number {
        if (mode == null || mode == LC.BLM_LIGHT_OFF) { return LC.UI_OFF; }
        var modes = _lamp.modesFor(LC.categoryOf(mode));
        for (var i = 0; i < modes.size(); i++) {
            if (modes[i] == mode) { return LC.intensityColor(i, modes.size()); }
        }
        return LC.UI_ACCENT;
    }

    // ---- Catégories --------------------------------------------------------

    private function _drawCategories(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number,
                                     w as Lang.Number, cats as Lang.Array,
                                     tw as Lang.Number, th as Lang.Number,
                                     cols as Lang.Number, gap as Lang.Number) as Void {
        var n = cats.size();
        if (n == 0 || th < 12 || cols < 1) { return; }
        var active = LC.categoryOf(_lamp.status.mode);
        var labelling = _labelling(dc, cats, tw, th);

        for (var i = 0; i < n; i++) {
            var cat = cats[i] as Lang.Number;
            var row = i / cols;
            var col = i % cols;

            // Une rangée incomplète est centrée : cinq catégories sur trois
            // colonnes donnent 3 + 2, et les deux du bas se placent au milieu
            // plutôt que de laisser un trou à droite.
            var inRow = n - row * cols;
            if (inRow > cols) { inRow = cols; }
            var rowW = inRow * tw + (inRow - 1) * gap;

            var tx = x + (w - rowW) / 2 + col * (tw + gap);
            var ty = y + row * (th + gap);
            _drawCategoryTile(dc, tx, ty, tw, th, cat,
                              cat == active, cat == selectedCategory, labelling);
            hitBoxes.add([tx, ty, tw, th, ACTION_CATEGORY - cat]);
        }
    }

    //! Forme des libellés, décidée **pour toute la rangée** : complète, abrégée,
    //! ou aucune. Trancher tuile par tuile donnerait sur un Edge 530 une rangée
    //! où « Route » est écrit et « Croisement » non — ce qui se lit comme un
    //! défaut d'affichage, pas comme une adaptation.
    private function _labelling(dc as Graphics.Dc, cats as Lang.Array,
                                tw as Lang.Number, h as Lang.Number) as Lang.Number {
        var key = (tw * 1024 + h) * 8 + cats.size();
        if (key == _labelKey) { return _labelForm; }
        _labelForm = _measureLabelling(dc, cats, tw, h);
        _labelKey = key;
        return _labelForm;
    }

    private function _measureLabelling(dc as Graphics.Dc, cats as Lang.Array,
                                       tw as Lang.Number, h as Lang.Number) as Lang.Number {
        var lh = dc.getFontHeight(Graphics.FONT_XTINY);
        if (h < lh * 5 / 2) { return LABEL_NONE; }

        var avail = tw * 88 / 100;
        var form = LABEL_FULL;
        for (var i = 0; i < cats.size(); i++) {
            var cat = cats[i] as Lang.Number;
            if (dc.getTextWidthInPixels(LC.categoryLabel(cat),
                                        Graphics.FONT_XTINY) > avail) {
                form = LABEL_SHORT;
            }
        }
        if (form == LABEL_FULL) { return LABEL_FULL; }

        for (var i = 0; i < cats.size(); i++) {
            var cat = cats[i] as Lang.Number;
            if (dc.getTextWidthInPixels(LC.categoryLabelShort(cat),
                                        Graphics.FONT_XTINY) > avail) {
                return LABEL_NONE;
            }
        }
        return LABEL_SHORT;
    }

    //! Trois états à distinguer, et une seule couleur d'accent pour le faire :
    //! la catégorie **allumée** est pleine, celle qu'on **consulte** est
    //! seulement cerclée, les autres restent sombres. Remplir la sélection
    //! comme l'état actif, ce que faisait la version précédente avec un bleu et
    //! un liseré blanc, obligeait à comparer deux tuiles pour savoir laquelle
    //! éclairait vraiment.
    private function _drawCategoryTile(dc as Graphics.Dc, x as Lang.Number,
                                       y as Lang.Number, w as Lang.Number,
                                       h as Lang.Number, cat as Lang.Number,
                                       active as Lang.Boolean,
                                       selected as Lang.Boolean,
                                       labelling as Lang.Number) as Void {
        var radius = h / 8;
        if (radius > w / 5) { radius = w / 5; }
        // Vert pour « c'est ce mode qui est allumé ». Sauf l'extinction : un
        // vert dirait « ça marche » là où il n'y a précisément plus de lumière.
        var accent = (cat == LC.CAT_OFF) ? LC.UI_OFF : LC.UI_OK;

        dc.setColor(active ? accent : LC.UI_TILE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, radius);
        if (selected && !active) {
            dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(_pen(h, 24));
            dc.drawRoundedRectangle(x, y, w, h, radius);
            dc.setPenWidth(1);
        }

        var ink = active ? LC.contrastOn(accent)
                         : (selected ? accent : LC.UI_DIM);

        // Icône et libellé forment un groupe centré, plutôt qu'une icône posée
        // dans ce qui reste au-dessus d'un libellé collé en bas : la tuile peut
        // être deux fois plus haute que large, et le contenu doit rester
        // groupé au milieu au lieu de flotter aux deux extrémités.
        var font = Graphics.FONT_XTINY;
        var lh = dc.getFontHeight(font);
        var label = null;
        if (labelling == LABEL_FULL)  { label = LC.categoryLabel(cat); }
        if (labelling == LABEL_SHORT) { label = LC.categoryLabelShort(cat); }
        var labelH = (label == null) ? 0 : lh;

        var r = w * 36 / 100;
        var rMax = (h - labelH) * 38 / 100;
        if (r > rMax) { r = rMax; }

        var lead = (labelH > 0) ? r / 3 : 0;
        var top = y + (h - (2 * r + lead + labelH)) / 2;

        _drawCategoryIcon(dc, x + w / 2, top + r, r, cat, ink);
        if (label != null) {
            dc.setColor(ink, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + w / 2, top + 2 * r + lead + labelH / 2, font, label,
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }


    //! Icônes dessinées en primitives : rien à embarquer, et elles s'adaptent à
    //! toutes les tailles d'écran, de 240x320 à 480x800.
    //!
    //! Toutes tiennent dans le carré `[cx - r, cx + r] x [cy - r, cy + r]`.
    //! C'est une contrainte, pas une remarque : le réflecteur du faisceau était
    //! posé en `cx - r` avec des rayons jusqu'à `cx + 2r`, soit une icône trois
    //! fois plus large que son rayon, qui empiétait sur la tuile voisine.
    //!
    //! **Ne pas découper cette fonction en sous-fonctions.** Elle est au fond de
    //! la pile la plus profonde de l'application :
    //!
    //!     LampView.onUpdate → draw → _drawCategories → _drawCategoryTile
    //!                       → _drawCategoryIcon
    //!
    //! Cinq niveaux, et un champ de données n'en supporte guère plus. Une
    //! version l'avait scindée en `_drawBeam()` puis `_stroke()` — deux niveaux
    //! de plus — et le champ plantait en « Stack Overflow Error » dès que la
    //! page complète s'affichait, c'est-à-dire juste après la recherche. Le
    //! compilateur ne dit rien, le simulateur non plus : ça ne s'est vu que dans
    //! `CIQ_LOG.YML` de l'appareil, où les sept adresses de pile s'empilaient
    //! proprement jusqu'ici. Voir `tools/pull-ciq-log.sh`.
    //!
    //! D'où le calcul d'épaisseur écrit en ligne plus bas, et l'écran d'attente
    //! qui appelle cette fonction directement au lieu de passer par un
    //! intermédiaire à lui.
    private function _drawCategoryIcon(dc as Graphics.Dc, cx as Lang.Number,
                                       cy as Lang.Number, r as Lang.Number,
                                       cat as Lang.Number,
                                       color as Lang.Number) as Void {
        if (r < 6) { return; }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        // Épaisseur de trait, proportionnelle à la taille de l'icône. Calculée
        // ici et pas dans une fonction : voir l'avertissement sur la pile, en
        // tête de cette section. `_pen()` ne conviendrait pas non plus, il
        // plafonne à cinq pixels et donnerait un filet sur le grand
        // pictogramme de l'écran d'attente.
        var pen = r * 17 / 100;
        if (pen < 2) { pen = 2; }

        if (cat == LC.CAT_LOW_BEAM || cat == LC.CAT_HIGH_BEAM
                || cat == LC.CAT_STEADY) {
            // Le pictogramme automobile, celui du tableau de bord : un « D »
            // couché — le réflecteur, vu de dessus — et les barres du faisceau.
            // Croisement et route s'y distinguent comme sur une voiture : barres
            // inclinées vers le bas d'un côté, horizontales de l'autre. Une
            // lampe sans faisceau prend le symbole du feu de route, le plus
            // neutre des deux.
            dc.setPenWidth(pen);

            // Le « D » : demi-cercle à gauche, côté plat à droite. Tracé comme
            // un arc, jamais comme un disque qu'on masquerait — le masque
            // resterait visible dès que la tuile change de fond, ce qui était
            // déjà le défaut de l'ancienne icône d'extinction.
            var dr = (r - pen / 2) * 82 / 100;
            var dx = cx - r + pen / 2 + dr;
            if (dc has :drawArc) {
                dc.drawArc(dx, cy, dr, Graphics.ARC_COUNTER_CLOCKWISE, 90, 270);
            } else {
                dc.drawCircle(dx, cy, dr);
            }
            dc.drawLine(dx, cy - dr, dx, cy + dr);

            // Quatre barres, réparties sur la hauteur du « D » et calées à
            // droite.
            var x0 = dx + dr * 45 / 100;
            var x1 = cx + r - pen / 2;
            if (x1 > x0) {
                var slant = (cat == LC.CAT_LOW_BEAM) ? dr * 22 / 100 : 0;
                var ys = [-3, -1, 1, 3];
                for (var i = 0; i < 4; i++) {
                    var y = cy + (ys[i] as Lang.Number) * dr / 4 - slant / 2;
                    dc.drawLine(x0, y, x1, y + slant);
                }
            }
        } else if (cat == LC.CAT_FLASH) {
            // Éclair. Les six sommets sont rangés dans l'ordre du tracé, la
            // pointe basse revenant sous la pointe haute : le zigzag précédent
            // se croisait légèrement au milieu, et le remplissage y laissait une
            // encoche visible dès que la tuile dépassait quarante pixels.
            dc.fillPolygon([
                [cx + r * 52 / 100, cy - r],
                [cx - r * 46 / 100, cy + r * 14 / 100],
                [cx + r *  4 / 100, cy + r * 14 / 100],
                [cx - r * 52 / 100, cy + r],
                [cx + r * 46 / 100, cy - r * 14 / 100],
                [cx - r *  4 / 100, cy - r * 14 / 100]
            ]);
        } else if (cat == LC.CAT_CUSTOM) {
            // Silhouette : tête et épaules. Les modes « perso » sont ceux que
            // l'utilisateur a réglés lui-même dans l'app iGPSPORT ; un bonhomme
            // le dit directement, là où l'étoile précédente évoquait plutôt un
            // favori ou une mise en avant.
            var hr = r * 30 / 100;
            dc.fillCircle(cx, cy - r + hr, hr);
            var bw = r * 128 / 100;
            var by = cy - r + 2 * hr + r / 12;
            dc.fillRoundedRectangle(cx - bw / 2, by, bw, cy + r - by, bw * 42 / 100);
        } else {
            // Éteint : le symbole d'alimentation ⏻. Il ne dit pas « lampe », et
            // c'est justement pour ça qu'il marche : les autres tuiles disent
            // toutes « lampe », celle-ci dit seulement « couper ».
            dc.setPenWidth(pen);
            var ar = r * 74 / 100;
            if (dc has :drawArc) {
                dc.drawArc(cx, cy, ar, Graphics.ARC_COUNTER_CLOCKWISE, 115, 65);
            } else {
                dc.drawCircle(cx, cy, ar);
            }
            dc.drawLine(cx, cy - r, cx, cy - r / 5);
        }
        dc.setPenWidth(1);
    }

    // ---- Niveaux de la catégorie sélectionnée ------------------------------

    //! Une jauge plutôt que six pavés colorés : chaque tuile porte un trait
    //! d'autant plus long que le cran est fort. La rangée se lit comme une
    //! échelle croissante, y compris du coin de l'œil, et seul le mode en cours
    //! est peint en plein.
    private function _drawLevels(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number,
                                 w as Lang.Number, h as Lang.Number,
                                 modes as Lang.Array, gap as Lang.Number) as Void {
        var n = modes.size();
        if (n == 0 || h < 12) { return; }

        var tw = (w - gap * (n - 1)) / n;
        var current = _lamp.status.mode;
        var radius = h / 6;
        if (radius > tw / 5) { radius = tw / 5; }

        for (var i = 0; i < n; i++) {
            var mode = modes[i] as Lang.Number;
            var tx = x + i * (tw + gap);
            var active = (current != null && current == mode);
            var tint = LC.intensityColor(i, n);
            // Declare mais desactive dans la lampe : grise, mais present et
            // touchable — le toucher l'active. Voir LampManager.setMode().
            var enabled = _lamp.isModeEnabled(mode);
            if (!enabled && !active) { tint = LC.UI_EDGE; }

            // Deux informations, deux canaux : le **vert** dit lequel est
            // allumé, la rampe jaune-orange-rouge dit la puissance. Peindre la
            // tuile active de sa propre teinte, comme avant, mélangeait les
            // deux — un cran fort et un cran allumé se ressemblaient.
            dc.setColor(active ? LC.UI_OK : LC.UI_TILE, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(tx, y, tw, h, radius);
            var ink = active ? LC.contrastOn(LC.UI_OK) : tint;

            var barH = h / 10;
            if (barH < 2) { barH = 2; }
            var label = LC.modeLevel(mode);
            var font = _fitFont(dc, label, tw - gap, [
                Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY
            ]);
            // Le texte se centre sur ce qui reste au-dessus de la jauge, pas
            // sur la tuile entière : sinon il mord dessus sur les tuiles basses.
            var textY = y + (h - 2 * barH) / 2;

            dc.setColor(ink, Graphics.COLOR_TRANSPARENT);
            dc.drawText(tx + tw / 2, textY, font, label,
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // Jauge : de 30 % de la tuile au premier cran, à 80 % au dernier.
            var barW = tw * (30 + ((n > 1) ? 50 * i / (n - 1) : 50)) / 100;
            dc.setColor(ink, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(tx + (tw - barW) / 2, y + h - barH * 2, barW, barH);

            hitBoxes.add([tx, y, tw, h, mode]);
        }
    }

    // ---- Curseur des modèles à boutons -------------------------------------

    private function _drawCursor(dc as Graphics.Dc) as Void {
        if (!_showCursor) { return; }
        if (cursor < 0 || cursor >= hitBoxes.size()) { return; }
        var b = hitBoxes[cursor];
        var m = 2;
        dc.setColor(LC.UI_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRoundedRectangle(b[0] - m, b[1] - m, b[2] + 2 * m, b[3] + 2 * m, 6);
        dc.setPenWidth(1);
    }

    // ---- Écran d'attente ---------------------------------------------------

    //! Une seule chose à l'écran : où en est la liaison.
    //!
    //! Trois textes de tailles différentes se disputaient la page pendant la
    //! connexion — un bandeau, un état dans un coin, un mode « -- » au centre —
    //! et le vocabulaire tenait du protocole : « Liaison », « Abonnement ».
    //! Ici, un pictogramme, un message en toutes lettres, une précision
    //! facultative. La taille du message est calculée sur le **plus long** des
    //! messages possibles, jamais sur celui du moment : c'est ce qui l'empêche
    //! de changer de corps d'une étape à l'autre.
    private function _drawWaiting(dc as Graphics.Dc, w as Lang.Number,
                                  h as Lang.Number) as Void {
        var mid = w / 2;
        var identifying = _lamp.isIdentifying();

        // Pictogramme de lampe. Pendant l'identification il s'allume et
        // s'éteint au rythme de la vraie lampe : c'est ce qui fait le lien
        // entre le guidon et l'écran, sans une ligne d'explication.
        //
        // **La lampe trouvée s'annonce par le pictogramme, pas par le texte.**
        // Tant qu'on cherche, c'est un phare éteint : croisement, gris. Dès
        // qu'elle répond, il passe au feu de route et au jaune — le dessin
        // s'ouvre et s'allume, ce qui se voit d'un coup d'œil là où « lampe
        // trouvée » écrit en petit sous le mot « Connexion » demandait d'être lu.
        var found = _lamp.isConnecting();
        var r = ((w < h) ? w : h) * 15 / 100;
        var glyphY = h * 30 / 100;
        var lit = identifying && _lamp.identifyLit();
        var ink = LC.UI_EDGE;
        if (identifying) { ink = lit ? LC.UI_ACCENT : LC.UI_TILE; }
        else if (found)  { ink = LC.UI_LEVEL_LOW; }
        _drawCategoryIcon(dc, mid, glyphY, r,
                          found ? LC.CAT_HIGH_BEAM : LC.CAT_LOW_BEAM, ink);

        // Au repos, le message est le libelle d'un bouton : on lui dessine un
        // cadre, sinon rien ne dit qu'il est touchable. C'est le seul etat ou la
        // page attend un geste plutot qu'un evenement.
        var idle = _lamp.isIdle();
        if (idle) {
            var bw = w * 62 / 100;
            var bh = h * 20 / 100;
            var bx = mid - bw / 2;
            var by = h * 62 / 100 - bh / 2;
            dc.setColor(LC.UI_TILE, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(bx, by, bw, bh, bh / 4);
            dc.setColor(LC.UI_ACCENT, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(_pen(bh, 14));
            dc.drawRoundedRectangle(bx, by, bw, bh, bh / 4);
            dc.setPenWidth(1);
        }

        var margin = w / 10;
        var font = _fitFont(dc, LampManager.longestStateMessage(), w - 2 * margin, [
            Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL,
            Graphics.FONT_TINY, Graphics.FONT_XTINY
        ]);
        dc.setColor(LC.UI_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, h * 62 / 100, font, _lamp.stateMessage(),
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Même règle pour la ligne du dessous : mesurée sur la plus longue des
        // précisions, elle garde son corps quand le message change.
        var hintFont = _fitFont(dc, LampManager.longestStateHint(), w - margin,
            [Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY]);
        var hint = (idle && idleHint != null) ? idleHint : _lamp.stateHint();
        dc.setColor(LC.UI_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, h * 78 / 100, hintFont, hint,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Trois points qui défilent : la seule chose qui dise « ça travaille »
        // pendant une recherche qui peut durer une minute. Inutile pendant
        // l'identification, où c'est la lampe elle-même qui bat la mesure.
        // Ni pendant l'identification, ou la lampe bat elle-meme la mesure, ni
        // au repos, ou rien ne travaille — trois points qui defilent devant un
        // bouton a presser seraient un mensonge.
        if (!identifying && !idle) {
            _drawProgress(dc, mid, h * 90 / 100, r / 5);
        }
    }

    //! Trois points, celui de la phase courante allumé.
    private function _drawProgress(dc as Graphics.Dc, cx as Lang.Number,
                                   cy as Lang.Number, r as Lang.Number) as Void {
        if (r < 2) { r = 2; }
        var step = _lamp.pulse();
        for (var i = 0; i < 3; i++) {
            dc.setColor((i == step) ? LC.UI_ACCENT : LC.UI_TILE,
                        Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx + (i - 1) * 4 * r, cy, r);
        }
    }

    // ---- Repli pour petits écrans ------------------------------------------

    private function _drawCompact(dc as Graphics.Dc, w as Lang.Number,
                                 h as Lang.Number) as Void {
        // On n'arrive ici que lampe connectée : `draw()` route l'attente vers
        // `_drawWaiting()`. Le titre ne dit donc plus l'état de la liaison.
        var mid = w / 2;
        var type = _lamp.status.lightType;
        var title = (type == null)
            ? Labels.of(Rez.Strings.LightGeneric)
            : Labels.of(Rez.Strings.LightGeneric) + " " + LC.typeLabel(type);
        if (_lamp.lastError != null) { title = _lamp.lastError; }

        dc.setColor(LC.UI_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, h / 8, Graphics.FONT_SMALL, title, Graphics.TEXT_JUSTIFY_CENTER);

        var mode = _lamp.status.mode;
        dc.setColor(_modeColor(mode), Graphics.COLOR_TRANSPARENT);
        dc.drawText(mid, h / 2, Graphics.FONT_LARGE,
                    (mode == null) ? "--" : LC.modeShort(mode),
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var line = "";
        var battery = _lamp.status.batteryPct;
        if (battery != null) { line = battery.format("%d") + " %"; }
        var left = _lamp.status.remainingMinutes;
        var lit = (mode != null && mode != LC.BLM_LIGHT_OFF);
        if (lit && left != null && left > 0) {
            if (!line.equals("")) { line += "  -  "; }
            line += _duration(left);
        }
        if (!line.equals("")) {
            dc.setColor(_batteryColor(battery == null ? 100 : battery),
                        Graphics.COLOR_TRANSPARENT);
            dc.drawText(mid, h * 3 / 4, Graphics.FONT_MEDIUM, line,
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // ---- Utilitaires -------------------------------------------------------

    //! Épaisseur de trait proportionnelle à la taille du motif, jamais nulle :
    //! un filet d'un pixel disparaît sur les 480x800 d'un Edge 1050, et un
    //! filet de trois pixels mange l'icône d'un 530.
    private function _pen(size as Lang.Number, divisor as Lang.Number) as Lang.Number {
        var p = size / divisor;
        if (p < 2) { p = 2; }
        if (p > 5) { p = 5; }
        return p;
    }

    //! Première police de la liste dont le texte tienne dans la largeur donnée.
    //! Le texte tronqué est le défaut le plus visible d'une page de compteur.
    private function _fitFont(dc as Graphics.Dc, text as Lang.String,
                              maxWidth as Lang.Number,
                              fonts as Lang.Array) as Graphics.FontDefinition {
        return _fitFontIn(dc, text, maxWidth, fonts, 0);
    }

    //! Même chose, avec une hauteur maximale. `maxHeight` à zéro ne contraint
    //! que la largeur — c'est le cas des textes posés sur une ligne, qui ont
    //! toute la hauteur qu'ils demandent.
    private function _fitFontIn(dc as Graphics.Dc, text as Lang.String,
                                maxWidth as Lang.Number, fonts as Lang.Array,
                                maxHeight as Lang.Number) as Graphics.FontDefinition {
        for (var i = 0; i < fonts.size(); i++) {
            var f = fonts[i] as Graphics.FontDefinition;
            if (dc.getTextWidthInPixels(text, f) > maxWidth) { continue; }
            if (maxHeight > 0 && dc.getFontHeight(f) > maxHeight) { continue; }
            return f;
        }
        return fonts[fonts.size() - 1] as Graphics.FontDefinition;
    }

    private function _duration(minutes as Lang.Number) as Lang.String {
        if (minutes < 60) { return minutes.format("%d") + " " + Labels.of(Rez.Strings.UnitMin); }
        return (minutes / 60).format("%d") + " h " + (minutes % 60).format("%02d");
    }

    //! Action associée au point touché, ou `null` si l'on a tapé à côté.
    function actionAt(x as Lang.Number, y as Lang.Number) as Lang.Number or Null {
        var hit = null;
        for (var i = 0; i < hitBoxes.size(); i++) {
            var b = hitBoxes[i];
            if (x >= b[0] && x <= b[0] + b[2] && y >= b[1] && y <= b[1] + b[3]) {
                cursor = i;
                hit = b[4];
                break;
            }
        }
        _noteTap(x, y, hit);
        return hit;
    }

    // ---- Rappel d'extinction -----------------------------------------------

    //! « Pensez à l'éteindre au bouton », tant que la lampe est éteinte.
    //!
    //! **Permanent, pas passager.** C'était un bandeau de cinq secondes déclenché
    //! par la tape ; cinq secondes suffisent à le rater, et le rappel ne porte
    //! pas sur le geste qu'on vient de faire mais sur l'état où l'on est —
    //! éteindre depuis le compteur coupe le faisceau, pas la lampe, qui reste
    //! connectée et continue de se décharger. Tant que c'est vrai, il faut que
    //! ça soit écrit.
    //!
    //! Il occupe la rangée des crans, réservée et vide quand la catégorie est
    //! « Éteint » : le rappel ne recouvre donc jamais une tuile, et rien ne se
    //! déplace quand il apparaît.
    //!
    //! **Un pavé qui clignote, pas une ligne de texte.** Il était écrit en gris
    //! sur le fond noir de la page, au motif que ce n'est pas une alerte : sauf
    //! qu'à cet endroit-là, du gris sur du noir, ça ne se voit pas — et un
    //! rappel qu'on ne voit pas ne rappelle rien. Il bat donc entre l'orange et
    //! le rouge, une seconde chacun, tant que la lampe est éteinte.
    private function _drawOffNotice(dc as Graphics.Dc, x as Lang.Number,
                                    y as Lang.Number, w as Lang.Number,
                                    h as Lang.Number) as Void {
        var mode = _lamp.status.mode;
        if (mode == null || mode != LC.BLM_LIGHT_OFF) { return; }

        var text = Labels.of(Rez.Strings.NoticeOff);
        var pad = w / 24;
        var font = _fitFont(dc, text, w - 2 * pad, [
            Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY
        ]);

        var back = _lamp.blink() ? LC.UI_WARN : LC.UI_ALERT;
        var radius = h / 5;
        if (radius > w / 12) { radius = w / 12; }
        dc.setColor(back, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, radius);

        // Le texte prend la couleur qui se lit sur le fond du moment : l'orange
        // et le rouge n'appellent pas la meme encre.
        dc.setColor(LC.contrastOn(back), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + w / 2, y + h / 2, font, text,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ---- Diagnostic ------------------------------------------------------

    //! Surcouche de diagnostic, inactive par defaut : taille du Dc, nombre de
    //! zones, dernier point touche et action trouvee, etat de la liaison.
    //!
    //! Gardee volontairement. Elle a tranche en une lecture ce que ni le
    //! simulateur ni le journal de plantage ne montraient : sur l'Edge 1050,
    //! `480x707 ko t=248,304>-101` a prouve que les coordonnees etaient justes
    //! et que le vrai probleme etait une liaison jamais etablie.
    //!
    //! **Absente des binaires de diffusion.** Les deux jungles excluent
    //! l'annotation `debug` ; il reste alors les coquilles vides annotees
    //! `nodebug`, et rien de tout ceci ne pese dans les 128 Ko du champ. Pour
    //! la reactiver : dans le jungle, remplacer `excludeAnnotations = debug`
    //! par `nodebug`, puis mettre `panel.debug = true` dans la vue concernee.
    var debug as Lang.Boolean = false;

    (:debug)
    private var _lastTap as Lang.Array or Null = null;

    (:debug)
    private function _noteTap(x as Lang.Number, y as Lang.Number,
                              hit as Lang.Number or Null) as Void {
        _lastTap = [x, y, hit];
    }

    (:nodebug)
    private function _noteTap(x as Lang.Number, y as Lang.Number,
                              hit as Lang.Number or Null) as Void {
    }

    (:nodebug)
    private function _drawDebug(dc as Graphics.Dc) as Void {
    }

    (:debug)
    private function _drawDebug(dc as Graphics.Dc) as Void {
        if (!debug) { return; }
        // `m=` est le mode **brut** annonce par la lampe, pas son libelle : c'est
        // la seule facon de savoir ce qu'une lampe eteinte au bouton raconte
        // d'elle-meme. `m=0` vaut BLM_LIGHT_OFF ; toute autre valeur signifie
        // qu'elle annonce un mode memorise alors qu'elle n'eclaire pas, et que
        // l'application ne peut pas distinguer les deux situations.
        var m = _lamp.status.mode;
        // `r=` est l'autonomie restante annoncee, en minutes. C'est le dernier
        // indicateur candidat pour distinguer une lampe qui eclaire d'une lampe
        // eteinte qui se souvient de son mode : `curMode` ne le dit pas — une
        // VS1800S eteinte au bouton annonce 12 — et si `r=0` accompagne
        // l'extinction, on tient enfin de quoi le savoir. Voir
        // docs/protocole-vs1800s.md, « Ce qu'il reste a etablir ».
        var r = _lamp.status.remainingMinutes;
        var text = dc.getWidth() + "x" + dc.getHeight()
                 + " z=" + hitBoxes.size()
                 + " " + (_lamp.isReady() ? "OK" : "ko")
                 + " m=" + ((m == null) ? "-" : m.toString())
                 + " r=" + ((r == null) ? "-" : r.toString())
                 + (_lamp.isIdentifying() ? " id" : "");
        if (_lastTap != null) {
            var a = _lastTap[2];
            text += " t=" + _lastTap[0] + "," + _lastTap[1]
                  + ">" + ((a == null) ? "-" : a.toString());
        }
        dc.setColor(LC.UI_BG, LC.UI_BG);
        var fh = dc.getFontHeight(Graphics.FONT_XTINY);
        dc.fillRectangle(0, dc.getHeight() - fh, dc.getWidth(), fh);
        dc.setColor(LC.UI_ALERT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - fh / 2, Graphics.FONT_XTINY,
                    text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //! Vrai si la place disponible permet d'afficher le panneau complet.
    //! En dessous, le champ de données se rabat sur son affichage à deux lignes.
    static function fits(width as Lang.Number, height as Lang.Number) as Lang.Boolean {
        return PanelLayout.fits(width, height);
    }
}
