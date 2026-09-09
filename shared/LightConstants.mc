using Toybox.Lang;

//! Constantes du protocole des lampes iGPSPORT.
//!
//! Valeurs extraites de l'app Android com.qiwu.worldwide.ride v8.06.42 par
//! analyse statique — voir docs/protocole-vs1800s.md.
//!
//! Ce jeu est celui du dialogue **app <-> lampe** (`PeripheralLightApp`), pas
//! celui du dialogue compteur <-> lampe : l'Edge se substitue au téléphone comme
//! central BLE, il tient donc le rôle de l'app.
module LightConstants {

    // ---- Transport (relevé par capture HCI le 08/09/2026) -------------------
    // Nordic UART standard. La lampe ne l'annonce PAS dans son advertising :
    // il n'apparaît qu'après connexion. On ne peut donc pas filtrer le scan
    // dessus — voir ADVERT_MARKER_UUID.
    const SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
    const TX_UUID      = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";  // central -> lampe
    const RX_UUID      = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";  // lampe -> central

    //! Seul UUID annoncé par la VS1800S. Absent de l'app iGPSPORT : c'est un
    //! marqueur de repérage, pas un service exploitable. Il sert uniquement à
    //! reconnaître la lampe pendant le scan.
    const ADVERT_MARKER_UUID = "A238C112-8136-52A9-364B-D61AC015024E";

    const BATTERY_SERVICE_UUID = "0000180F-0000-1000-8000-00805F9B34FB";
    const BATTERY_LEVEL_UUID   = "00002A19-0000-1000-8000-00805F9B34FB";

    // ---- En-tête de transport ----------------------------------------------
    // 20 octets, dont deux CRC-8/MAXIM. Voir docs/protocole-vs1800s.md §2.
    //! Taille maximale d'une ecriture BLE sous Connect IQ.
    //!
    //! La documentation du SDK est explicite : « Support for long writes is not
    //! implemented ». Une trame plus longue est refusee par requestWrite(). Il
    //! faut donc la fragmenter — ce que la lampe fait deja elle-meme pour ses
    //! notifications, avec exactement la meme taille.
    const MAX_WRITE = 20;

    const HDR_LEN = 20;
    const HDR_TYPE_DATA  = 0x01;    // en-tête suivi d'une charge utile protobuf
    const HDR_TYPE_ACK   = 0x02;    // accusé d'une écriture, sans contenu
    const HDR_TYPE_STATE = 0x03;    // état spontané, valeur inscrite dans l'en-tête

    // Emplacements de valeur dans les trames d'état (type 03). Le protobuf n'y
    // est pas utilisé : la valeur tient dans les octets laissés à 0xFF.
    const HDR_VALUE8  = 7;          // sous-service 2 : le mode courant
    const HDR_VALUE32 = 11;         // sous-service 5 : l'autonomie, 32 bits LE

    //! Identifiant de service du protocole d'éclairage, dans l'en-tête et dans
    //! le champ 1 de la charge utile.
    const SERVICE_LIGHT = 106;

    //! Opération au niveau de l'enveloppe. Ne pas confondre avec
    //! BLE_LIGHT_OPERATE : ici 1 écrit, 2 lit ou notifie.
    const OP_WRITE = 1;
    const OP_READ  = 2;

    // ---- Numéros de champ de blt_message_format ----------------------------
    const F_SERVICE_TYPE     = 1;   // vaut SERVICE_LIGHT
    const F_OPERATE_TYPE     = 2;   // OP_WRITE ou OP_READ
    const F_BLT_SERVICE_TYPE = 3;   // sous-service : un BLS_*
    const F_BLT_OPERATE_TYPE = 4;
    const F_LIGHT_SELF       = 5;
    const F_MODE_SUP         = 6;
    const F_CUS_MODE_GET     = 7;
    const F_MODE_ARG         = 8;
    const F_CFG_SUP          = 9;
    const F_CFG_SET          = 10;
    const F_MODE_SET         = 11;
    const F_CUSTOM_CFG       = 12;
    const F_CUR_MODE         = 13;
    const F_LEFT_TIME        = 14;
    const F_BAT_PCT          = 15;
    const F_RIDE_CFG_ALL     = 16;
    const F_RIDE_CFG_SET     = 17;

    // Champs internes des charges utiles.
    const F_CUR_MODE_VALUE = 1;   // blt_light_mode_cur.curMode
    const F_LEFT_TIME_VALUE = 1;  // blt_left_time.time
    const F_BAT_PCT_VALUE = 13;   // blt_bat_pct.batPct — oui, 13 et non 1
    const F_SMT_CFG_CONFIG = 1;   // blt_smt_cfg.config
    const F_SMT_CFG_STATUS = 2;   // blt_smt_cfg.status
    const F_SMT_CFG_USERDATA = 3; // blt_smt_cfg.userData (delai en secondes)
    const F_LIGHT_SELF_TYPE = 1;  // blt_light_self.lightType
    const F_LIGHT_SELF_CNT = 2;   // blt_light_self.lightCnt
    const F_MODE_SUP_MODE = 1;    // blt_mode_sup.mode
    const F_MODE_SUP_ENABLE = 3;  // blt_mode_sup.enable
    const F_MODE_ENABLE_MODE = 1; // blt_mode_enable.mode
    const F_MODE_ENABLE_FLAG = 2; // blt_mode_enable.enable

    // ---- BLE_LIGHT_SERVICE -------------------------------------------------
    const BLS_LIGHT_CFG          = 0;
    const BLS_MODE_SUP           = 1;
    const BLS_MODE_CUR           = 2;
    const BLS_CUSTOME_MODE       = 3;
    const BLS_SMT_CONFIG         = 4;
    const BLS_LEFT_TIME          = 5;
    const BLS_BAT_PCT            = 6;
    const BLS_MODE_ENABLE        = 7;
    const BLS_CONFIG_RESPECTIVE  = 8;
    const BLS_RIDE_CFG           = 9;

    // ---- BLE_LIGHT_OPERATE -------------------------------------------------
    const BLO_GET     = 1;
    const BLO_NTC     = 2;   // notification montante
    const BLO_ENABLE  = 3;
    const BLO_DISABLE = 4;

    // ---- BLE_LIGHT_MODE ----------------------------------------------------
    const BLM_LIGHT_OFF       = 0;
    const BLM_HIGH_ALWAYS     = 1;
    const BLM_MID_ALWAYS      = 2;
    const BLM_LOW_ALWAYS      = 3;
    const BLM_HIGH_BLINK      = 4;
    const BLM_LOW_BLINK       = 5;
    const BLM_GRADIENT        = 6;
    const BLM_HBEAM_HSTEADY   = 7;    // feu de route, intensite haute
    const BLM_HBEAM_MSTEADY   = 8;
    const BLM_HBEAM_LSTEADY   = 9;
    const BLM_LBEAM_HSTEADY   = 10;   // feu de croisement, intensite haute
    const BLM_LBEAM_MSTEADY   = 11;
    const BLM_LBEAM_LSTEADY   = 12;
    const BLM_ROTATION        = 13;
    const BLM_LEFT_TURN       = 14;
    const BLM_RIGHT_TURN      = 15;
    const BLM_SUPERHIGH       = 16;
    const BLM_SOS_WARNING     = 17;
    const BLM_COMET_FLASH     = 18;
    const BLM_WATERFALL_FLASH = 19;
    const BLM_PINWHEEL        = 20;

    // Modes personnalisables (editables dans l'app iGPSPORT) et modes speciaux
    // du constructeur. La VS1800S declare 64, 65 et 66.
    const BLM_SPECIAL_1     = 32;
    const BLM_SPECIAL_10    = 41;
    const BLM_CUSTOMIZE_1   = 64;
    const BLM_CUSTOMIZE_12  = 75;

    //! Échelles d'intensité, du plus faible au plus fort.
    //!
    //! Deux familles coexistent dans la gamme iGPSPORT : les lampes à haut et bas
    //! faisceau (VS1200S, VS1800S…) et les lampes à intensité simple (VS500,
    //! VS800…). On ne devine pas laquelle on a en face : la lampe déclare ses
    //! modes via `BLS_MODE_SUP`, et `ladderFor()` retient la famille qui
    //! correspond.
    const BEAM_LADDER = [
        BLM_LBEAM_LSTEADY,
        BLM_LBEAM_MSTEADY,
        BLM_LBEAM_HSTEADY,
        BLM_HBEAM_LSTEADY,
        BLM_HBEAM_MSTEADY,
        BLM_HBEAM_HSTEADY
    ];

    //! Lampes sans haut/bas faisceau.
    const ALWAYS_LADDER = [
        BLM_LOW_ALWAYS,
        BLM_MID_ALWAYS,
        BLM_HIGH_ALWAYS,
        BLM_SUPERHIGH
    ];

    //! Construit l'échelle utilisable à partir des modes que la lampe déclare
    //! supporter. `supported` à `null` signifie « pas encore répondu » : on garde
    //! alors l'échelle haut/bas faisceau, celle de la VS1800S.
    //!
    //! On privilégie la famille faisceau quand elle est disponible : elle offre
    //! six crans au lieu de quatre, donc un ajustement plus fin selon la vitesse.
    //! `lightType` vient de `blt_light_self` : un feu arrière n'a pas de
    //! faisceau, inutile de chercher l'échelle haut/bas chez lui.
    function ladderFor(supported as Lang.Array or Null,
                       lightType as Lang.Number or Null) as Lang.Array {
        if (supported == null || supported.size() == 0) {
            return isFrontLight(lightType) ? BEAM_LADDER : ALWAYS_LADDER;
        }

        var always = _retain(ALWAYS_LADDER, supported);
        if (!isFrontLight(lightType)) {
            if (always.size() >= 2) { return always; }
        }

        var beam = _retain(BEAM_LADDER, supported);
        if (beam.size() >= 2) { return beam; }

        if (always.size() >= 2) { return always; }

        // Lampe atypique : au moins de quoi allumer et éteindre.
        if (beam.size() == 1) { return beam; }
        if (always.size() == 1) { return always; }
        return isFrontLight(lightType) ? BEAM_LADDER : ALWAYS_LADDER;
    }

    //! Vrai pour une lampe avant, y compris quand le type est encore inconnu :
    //! c'est le cas d'usage visé, et l'échelle faisceau est la plus fine.
    function isFrontLight(lightType as Lang.Number or Null) as Lang.Boolean {
        return lightType == null
            || lightType == BLT_FRONT_LIGHT
            || lightType == BLT_HEAD_LIGHT;
    }

    //! Libellé du type de lampe, pour l'affichage et le diagnostic.
    //! Libelle du type de lampe, pour l'affichage et le diagnostic.
    function typeLabel(lightType as Lang.Number or Null) as Lang.String {
        // Le type reste nul tant que la lampe n'a pas repondu : « ? » se lit
        // comme une attente, pas comme une anomalie.
        if (lightType == null) { return "?"; }
        switch (lightType) {
            case BLT_TAIL_LIGHT:  return Labels.of(Rez.Strings.TypeTail);
            case BLT_FRONT_LIGHT: return Labels.of(Rez.Strings.TypeFront);
            case BLT_HEAD_LIGHT:  return Labels.of(Rez.Strings.TypeHead);
            case BLT_LEFT_LIGHT:  return Labels.of(Rez.Strings.TypeLeft);
            case BLT_RIGHT_LIGHT: return Labels.of(Rez.Strings.TypeRight);
        }
        return "?";
    }

    function _retain(ladder as Lang.Array, supported as Lang.Array) as Lang.Array {
        var kept = [];
        for (var i = 0; i < ladder.size(); i++) {
            for (var j = 0; j < supported.size(); j++) {
                if (supported[j] == ladder[i]) { kept.add(ladder[i]); break; }
            }
        }
        return kept;
    }

    // ---- BLE_LIGHT_TYPE ----------------------------------------------------
    const BLT_TAIL_LIGHT  = 0;
    const BLT_FRONT_LIGHT = 1;   // la VS1800S
    const BLT_HEAD_LIGHT  = 2;
    const BLT_LEFT_LIGHT  = 3;
    const BLT_RIGHT_LIGHT = 4;

    // ---- BLE_LIGHT_CONFIG_SUP (automatismes) -------------------------------
    const BLCS_ROUTE          = 0;
    const BLCS_RIDE_SYNC      = 1;
    const BLCS_BRAKE_LIGHT    = 2;
    const BLCS_AUTO_LIGHT     = 3;
    const BLCS_AUTO_SLEEP     = 4;
    const BLCS_SYNC_OFF       = 5;    // extinction synchronisee (F6)
    const BLCS_TEAM_RIDE      = 6;
    const BLCS_RADAR          = 7;
    const BLCS_AUTO_START     = 8;
    const BLCS_LUMEN_VARY     = 9;    // luminosite variable (candidat F5)
    const BLCS_ANGEL_VARY     = 10;
    const BLCS_HL_BEAM        = 11;
    const BLCS_AUTO_TURN      = 12;
    const BLCS_AUTO_LOW       = 13;
    const BLCS_SLP_VARY       = 14;
    const BLCS_AUTO_LOWBAT    = 15;
    const BLCS_INTELL_SAVING  = 16;
    const BLCS_KNOCK_TRANS    = 17;
    const BLCS_AUTO_LOOP      = 18;
    const BLCS_STOP_FLASH     = 19;
    const BLCS_AD_WARN        = 20;
    const BLCS_RADAR_WARN     = 21;

    // ---- BLT_SMT_CFG_STATUS ------------------------------------------------
    const BSCS_CFG_OFF = 0;
    const BSCS_CFG_ON  = 1;
    const BSCS_CFG_FOL = 2;   // « follow » : la lampe suit le compteur

    // ---- Thème graphique ---------------------------------------------------
    //
    // Un seul jeu de couleurs pour les deux binaires. Les 13 Edge cibles
    // affichent 16 bits par pixel : on peut donner des valeurs RVB libres
    // plutot que de se limiter aux COLOR_* du SDK, dont le gris « fonce »
    // rendait presque blanc sur un ecran de compteur en plein jour.
    //
    // Le fond reste noir meme quand le champ de donnees est configure en theme
    // clair : c'est une page d'eclairage, elle se consulte surtout de nuit, et
    // un fond blanc a hauteur de guidon eblouit.

    const UI_BG        = 0x000000;   // fond
    const UI_TILE      = 0x262626;   // tuile au repos
    const UI_EDGE      = 0x585858;   // filets et contours
    const UI_TEXT      = 0xFFFFFF;
    const UI_DIM       = 0xA0A0A0;   // texte secondaire
    //! Ambre : meme famille que la rampe d'intensite, pour que l'accent de
    //! l'interface et la couleur des modes racontent la meme chose.
    const UI_ACCENT    = 0xFFAA00;
    const UI_OK        = 0x00C060;
    const UI_WARN      = 0xFF8800;
    const UI_ALERT     = 0xFF3B30;
    //! Lampe eteinte : gris franc plutot qu'ambre — l'accent chaud signifie
    //! « ca eclaire », l'employer pour l'extinction dirait le contraire.
    const UI_OFF       = 0x8A8A8A;

    //! Rampe d'intensite : jaune, orange, rouge.
    //!
    //! C'est la lecture universelle d'une echelle croissante — un thermometre,
    //! une jauge de charge, un indicateur de regime. Le rouge en haut dit aussi
    //! ce que la teinte chaude seule ne disait pas : ce cran-la vide la
    //! batterie.
    //!
    //! Le rouge d'alerte batterie (UI_ALERT) est volontairement plus vif et
    //! plus rose que UI_LEVEL_HIGH : les deux ne se cotoient jamais sur la meme
    //! tuile, mais ils ne doivent pas se confondre d'un coup d'oeil.
    const UI_LEVEL_LOW  = 0xFFDD00;   // jaune
    const UI_LEVEL_MID  = 0xFF8800;   // orange
    const UI_LEVEL_HIGH = 0xE01E00;   // rouge

    //! Couleur representant un cran d'intensite, du plus faible au plus fort.
    //!
    //! Interpole sur le nombre de crans reellement disponibles, donc valable
    //! aussi bien pour les six modes d'une VS1800S que pour les trois d'une
    //! VS500. Les 13 Edge cibles affichent 16 bits par pixel : aucune contrainte
    //! de palette, aucun cas particulier par modele.
    function intensityColor(index as Lang.Number, count as Lang.Number) as Lang.Number {
        if (count <= 1) { return UI_LEVEL_MID; }
        var t = index * 200 / (count - 1);       // 0 a 200, en deux segments
        if (t <= 100) {
            return _mix(UI_LEVEL_LOW, UI_LEVEL_MID, t);        // jaune -> orange
        }
        return _mix(UI_LEVEL_MID, UI_LEVEL_HIGH, t - 100);     // orange -> rouge
    }

    //! Interpolation lineaire entre deux couleurs, canal par canal.
    //! `ratio` va de 0 (couleur a) a 100 (couleur b).
    function _mix(a as Lang.Number, b as Lang.Number, ratio as Lang.Number) as Lang.Number {
        var r = ((a >> 16) & 0xFF) + ((((b >> 16) & 0xFF) - ((a >> 16) & 0xFF)) * ratio) / 100;
        var g = ((a >> 8) & 0xFF) + ((((b >> 8) & 0xFF) - ((a >> 8) & 0xFF)) * ratio) / 100;
        var bl = (a & 0xFF) + (((b & 0xFF) - (a & 0xFF)) * ratio) / 100;
        return (r << 16) | (g << 8) | bl;
    }

    //! Noir ou blanc selon la clarte du fond, pour que le texte reste lisible.
    //! Ponderation classique de la luminance percue : le vert compte plus que
    //! le rouge, et le bleu presque pas.
    function contrastOn(background as Lang.Number) as Lang.Number {
        var lum = (((background >> 16) & 0xFF) * 30
                 + ((background >> 8) & 0xFF) * 59
                 + (background & 0xFF) * 11) / 100;
        return (lum > 140) ? 0x000000 : 0xFFFFFF;
    }

    // ---- Catégories de modes -----------------------------------------------
    //
    // Regrouper par famille plutôt que d'aligner tous les modes : sur un guidon,
    // atteindre le flash ne doit pas demander de traverser six crans.

    const CAT_LOW_BEAM  = 0;   // feu de croisement
    const CAT_HIGH_BEAM = 1;   // feu de route
    const CAT_STEADY    = 2;   // intensité fixe, lampes sans faisceau
    const CAT_FLASH     = 3;   // clignotants et effets
    const CAT_CUSTOM    = 4;   // modes personnalisés
    const CAT_OFF       = 5;   // éteint

    //! Ordre de présentation, du plus courant au plus rare.
    const CATEGORY_ORDER = [CAT_LOW_BEAM, CAT_HIGH_BEAM, CAT_STEADY,
                            CAT_FLASH, CAT_CUSTOM, CAT_OFF];

    function categoryLabel(cat as Lang.Number) as Lang.String {
        switch (cat) {
            case CAT_LOW_BEAM:  return Labels.of(Rez.Strings.CatLowBeam);
            case CAT_HIGH_BEAM: return Labels.of(Rez.Strings.CatHighBeam);
            case CAT_STEADY:    return Labels.of(Rez.Strings.CatSteady);
            case CAT_FLASH:     return Labels.of(Rez.Strings.CatFlash);
            case CAT_CUSTOM:    return Labels.of(Rez.Strings.CatCustom);
            case CAT_OFF:       return Labels.of(Rez.Strings.CatOff);
        }
        return "?";
    }

    //! Libellé de repli quand la tuile est trop étroite pour le libellé complet.
    //! Seul « Croisement » pose vraiment problème ; les autres sont donnés pour
    //! que l'abréviation reste homogène d'une tuile à l'autre — une rangée où un
    //! seul mot est abrégé se lit comme une erreur.
    //! Libelle de repli quand la tuile est trop etroite pour le libelle complet.
    //! La rangee choisit une forme unique pour toutes ses tuiles : une rangee ou
    //! un seul mot est abrege se lit comme un defaut d'affichage.
    function categoryLabelShort(cat as Lang.Number) as Lang.String {
        switch (cat) {
            case CAT_LOW_BEAM:  return Labels.of(Rez.Strings.CatLowBeamShort);
            case CAT_HIGH_BEAM: return Labels.of(Rez.Strings.CatHighBeamShort);
            case CAT_STEADY:    return Labels.of(Rez.Strings.CatSteadyShort);
            case CAT_FLASH:     return Labels.of(Rez.Strings.CatFlashShort);
            case CAT_CUSTOM:    return Labels.of(Rez.Strings.CatCustomShort);
            case CAT_OFF:       return Labels.of(Rez.Strings.CatOffShort);
        }
        return "?";
    }

    //! Modes d'une catégorie, du plus faible au plus fort, filtrés sur ce que
    //! la lampe déclare supporter. `supported` à null signifie « pas encore
    //! répondu » : on retourne alors le catalogue de la catégorie.
    function modesInCategory(cat as Lang.Number,
                             supported as Lang.Array or Null) as Lang.Array {
        // Initialise a vide : le compilateur exige qu'une variable soit
        // affectee sur toutes les branches, y compris celles qu'on n'ecrit pas.
        var all = [];
        switch (cat) {
            case CAT_LOW_BEAM:
                all = [BLM_LBEAM_LSTEADY, BLM_LBEAM_MSTEADY, BLM_LBEAM_HSTEADY];
                break;
            case CAT_HIGH_BEAM:
                all = [BLM_HBEAM_LSTEADY, BLM_HBEAM_MSTEADY, BLM_HBEAM_HSTEADY];
                break;
            case CAT_STEADY:
                all = [BLM_LOW_ALWAYS, BLM_MID_ALWAYS, BLM_HIGH_ALWAYS, BLM_SUPERHIGH];
                break;
            case CAT_FLASH:
                // Deduit de `categoryOf()` plutot qu'ecrit a la main. « Flash »
                // est la categorie fourre-tout : tout mode que `categoryOf()`
                // ne reconnait pas y atterrit, y compris des valeurs qu'aucun
                // firmware connu n'emploie. Une liste ecrite a la main finit
                // toujours par diverger, et un mode absent du catalogue est
                // **injoignable depuis la page** — sa categorie s'allume, et
                // aucune tuile n'y mene. En le derivant, les deux ne peuvent
                // plus se contredire.
                //
                // La borne haute est le premier mode personnalisable : au-dela,
                // `categoryOf()` bascule sur CAT_CUSTOM.
                all = [];
                for (var m = 1; m < BLM_CUSTOMIZE_1; m++) {
                    if (categoryOf(m) == CAT_FLASH) { all.add(m); }
                }
                break;
            case CAT_CUSTOM:
                // Les douze emplacements, pas six : la VS1800S en declare
                // trois, mais rien ne dit qu'un autre modele s'arrete la.
                all = [];
                for (var m = BLM_CUSTOMIZE_1; m <= BLM_CUSTOMIZE_12; m++) {
                    all.add(m);
                }
                break;
            case CAT_OFF:
                return [BLM_LIGHT_OFF];
        }
        if (supported == null) { return all; }
        return _retain(all, supported);
    }

    //! Catégorie d'un mode donné, pour surligner la bonne icône.
    function categoryOf(mode as Lang.Number or Null) as Lang.Number {
        if (mode == null) { return CAT_OFF; }
        if (mode == BLM_LIGHT_OFF) { return CAT_OFF; }
        if (mode >= BLM_CUSTOMIZE_1) { return CAT_CUSTOM; }
        if (mode == BLM_LBEAM_LSTEADY || mode == BLM_LBEAM_MSTEADY
                || mode == BLM_LBEAM_HSTEADY) { return CAT_LOW_BEAM; }
        if (mode == BLM_HBEAM_LSTEADY || mode == BLM_HBEAM_MSTEADY
                || mode == BLM_HBEAM_HSTEADY) { return CAT_HIGH_BEAM; }
        if (mode == BLM_LOW_ALWAYS || mode == BLM_MID_ALWAYS
                || mode == BLM_HIGH_ALWAYS || mode == BLM_SUPERHIGH) {
            return CAT_STEADY;
        }
        return CAT_FLASH;
    }

    //! Libellé abrégé, pour les champs de données étroits.
    //! « Cr. » et « Rt. » plutôt que « C » et « R » : une abréviation qui
    //! demande une explication est une abréviation ratée.
    //! Libelle abrege, pour les champs de donnees etroits.
    //! « Cr. » et « Rt. » plutot que « C » et « R » : une abreviation qui
    //! demande une explication est une abreviation ratee.
    function modeShort(mode as Lang.Number or Null) as Lang.String {
        // Monkey C ne sait pas faire un switch sur null : il faut sortir
        // avant. Le mode reste nul tant que la lampe n'a pas repondu, et un
        // plantage de nuit sur un velo ne vaut pas trois lignes d'economie.
        if (mode == null) { return "--"; }
        switch (mode) {
            case BLM_LIGHT_OFF:     return Labels.of(Rez.Strings.ModeOff);
            case BLM_LBEAM_LSTEADY: return Labels.of(Rez.Strings.ShortDipLow);
            case BLM_LBEAM_MSTEADY: return Labels.of(Rez.Strings.ShortDipMid);
            case BLM_LBEAM_HSTEADY: return Labels.of(Rez.Strings.ShortDipHigh);
            case BLM_HBEAM_LSTEADY: return Labels.of(Rez.Strings.ShortMainLow);
            case BLM_HBEAM_MSTEADY: return Labels.of(Rez.Strings.ShortMainMid);
            case BLM_HBEAM_HSTEADY: return Labels.of(Rez.Strings.ShortMainHigh);
            case BLM_LOW_ALWAYS:    return Labels.of(Rez.Strings.LvlLow);
            case BLM_MID_ALWAYS:    return Labels.of(Rez.Strings.LvlMid);
            case BLM_HIGH_ALWAYS:   return Labels.of(Rez.Strings.LvlHigh);
            case BLM_SUPERHIGH:     return Labels.of(Rez.Strings.LvlMax);
            case BLM_HIGH_BLINK:    return Labels.of(Rez.Strings.ShortFlashDay);
            case BLM_LOW_BLINK:     return Labels.of(Rez.Strings.ShortFlashNight);
            case BLM_SOS_WARNING:   return Labels.of(Rez.Strings.ModeSos);
            case BLM_GRADIENT:      return Labels.of(Rez.Strings.ModeGradient);
            case BLM_COMET_FLASH:   return Labels.of(Rez.Strings.ModeComet);
            case BLM_WATERFALL_FLASH: return Labels.of(Rez.Strings.ModeWaterfall);
            case BLM_PINWHEEL:      return Labels.of(Rez.Strings.ModePinwheel);
            case BLM_ROTATION:      return Labels.of(Rez.Strings.ModeRotation);
            case BLM_LEFT_TURN:     return Labels.of(Rez.Strings.ModeLeftTurn);
            case BLM_RIGHT_TURN:    return Labels.of(Rez.Strings.ModeRightTurn);
        }
        if (mode >= BLM_CUSTOMIZE_1 && mode <= BLM_CUSTOMIZE_12) {
            return Labels.of(Rez.Strings.PrefixCustom) + (mode - BLM_CUSTOMIZE_1 + 1);
        }
        if (mode >= BLM_SPECIAL_1 && mode <= BLM_SPECIAL_10) {
            return Labels.of(Rez.Strings.PrefixSpecial) + (mode - BLM_SPECIAL_1 + 1);
        }
        return Labels.of(Rez.Strings.PrefixMode) + mode;
    }

    //! Libellé pour une tuile de la page de pilotage : seulement le niveau.
    //! L'icône y indique déjà si le faisceau est bas ou haut — le répéter sur
    //! les six tuiles n'apprendrait rien et volerait de la place.
    //! Libelle pour une tuile de la page de pilotage : seulement le niveau.
    //! L'icone y indique deja si le faisceau est bas ou haut — le repeter sur
    //! les six tuiles n'apprendrait rien et volerait de la place.
    function modeLevel(mode as Lang.Number or Null) as Lang.String {
        // Monkey C ne sait pas faire un switch sur null : il faut sortir
        // avant. Le mode reste nul tant que la lampe n'a pas repondu, et un
        // plantage de nuit sur un velo ne vaut pas trois lignes d'economie.
        if (mode == null) { return "--"; }
        switch (mode) {
            case BLM_LIGHT_OFF:     return Labels.of(Rez.Strings.ModeOff);
            case BLM_LBEAM_LSTEADY: return Labels.of(Rez.Strings.LvlLow);
            case BLM_LBEAM_MSTEADY: return Labels.of(Rez.Strings.LvlMid);
            case BLM_LBEAM_HSTEADY: return Labels.of(Rez.Strings.LvlHigh);
            case BLM_HBEAM_LSTEADY: return Labels.of(Rez.Strings.LvlLow);
            case BLM_HBEAM_MSTEADY: return Labels.of(Rez.Strings.LvlMid);
            case BLM_HBEAM_HSTEADY: return Labels.of(Rez.Strings.LvlHigh);
            case BLM_LOW_ALWAYS:    return Labels.of(Rez.Strings.LvlLow);
            case BLM_MID_ALWAYS:    return Labels.of(Rez.Strings.LvlMid);
            case BLM_HIGH_ALWAYS:   return Labels.of(Rez.Strings.LvlHigh);
            case BLM_SUPERHIGH:     return Labels.of(Rez.Strings.LvlMax);
        }
        return modeShort(mode);
    }

    //! Libellé complet, repris tel quel de l'application iGPSPORT pour que le
    //! vocabulaire soit le même sur le téléphone et sur le compteur.
    //! Libelle complet, repris tel quel de l'application iGPSPORT pour que le
    //! vocabulaire soit le meme sur le telephone et sur le compteur.
    function modeLabel(mode as Lang.Number or Null) as Lang.String {
        // Monkey C ne sait pas faire un switch sur null : il faut sortir
        // avant. Le mode reste nul tant que la lampe n'a pas repondu, et un
        // plantage de nuit sur un velo ne vaut pas trois lignes d'economie.
        if (mode == null) { return "--"; }
        switch (mode) {
            case BLM_LIGHT_OFF:       return Labels.of(Rez.Strings.ModeOff);
            case BLM_LBEAM_LSTEADY:   return Labels.of(Rez.Strings.ModeDipLow);
            case BLM_LBEAM_MSTEADY:   return Labels.of(Rez.Strings.ModeDipMid);
            case BLM_LBEAM_HSTEADY:   return Labels.of(Rez.Strings.ModeDipHigh);
            case BLM_HBEAM_LSTEADY:   return Labels.of(Rez.Strings.ModeMainLow);
            case BLM_HBEAM_MSTEADY:   return Labels.of(Rez.Strings.ModeMainMid);
            case BLM_HBEAM_HSTEADY:   return Labels.of(Rez.Strings.ModeMainHigh);
            case BLM_HIGH_ALWAYS:     return Labels.of(Rez.Strings.ModeSteadyHigh);
            case BLM_MID_ALWAYS:      return Labels.of(Rez.Strings.ModeSteadyMid);
            case BLM_LOW_ALWAYS:      return Labels.of(Rez.Strings.ModeSteadyLow);
            case BLM_HIGH_BLINK:      return Labels.of(Rez.Strings.ModeFlashDay);
            case BLM_LOW_BLINK:       return Labels.of(Rez.Strings.ModeFlashNight);
            case BLM_GRADIENT:        return Labels.of(Rez.Strings.ModeGradient);
            case BLM_SUPERHIGH:       return Labels.of(Rez.Strings.ModeMaximum);
            case BLM_SOS_WARNING:     return Labels.of(Rez.Strings.ModeSos);
            case BLM_COMET_FLASH:     return Labels.of(Rez.Strings.ModeComet);
            case BLM_WATERFALL_FLASH: return Labels.of(Rez.Strings.ModeWaterfall);
            case BLM_PINWHEEL:        return Labels.of(Rez.Strings.ModePinwheel);
            case BLM_ROTATION:        return Labels.of(Rez.Strings.ModeRotation);
            case BLM_LEFT_TURN:       return Labels.of(Rez.Strings.ModeLeftTurn);
            case BLM_RIGHT_TURN:      return Labels.of(Rez.Strings.ModeRightTurn);
        }
        if (mode >= BLM_CUSTOMIZE_1 && mode <= BLM_CUSTOMIZE_12) {
            return Labels.of(Rez.Strings.PrefixCustomLong) + (mode - BLM_CUSTOMIZE_1 + 1);
        }
        if (mode >= BLM_SPECIAL_1 && mode <= BLM_SPECIAL_10) {
            return Labels.of(Rez.Strings.PrefixSpecial) + (mode - BLM_SPECIAL_1 + 1);
        }
        return Labels.of(Rez.Strings.PrefixMode) + mode;
    }
}
