using Toybox.Test;
using Toybox.Lang;
using Toybox.Application;
using LightConstants as LC;

//! Tests du codec protobuf, du transport et des automatismes.
//!
//!   bash app/build.sh test
//!
//! Les octets attendus dans les tests de trames ne sont pas construits de tête :
//! ce sont ceux réellement émis par l'app iGPSPORT, relevés dans la capture HCI
//! du 08/09/2026 (`captures/20260908-160831-lampe`). Si le code cesse de les
//! reproduire, c'est le code qui a tort.
module ProtocolTest {

    function hex(bytes as Lang.ByteArray) as Lang.String {
        var s = "";
        for (var i = 0; i < bytes.size(); i++) {
            var b = bytes[i];
            s += (b < 16 ? "0" : "") + b.format("%X");
            if (i < bytes.size() - 1) { s += " "; }
        }
        return s;
    }

    function expect(logger as Test.Logger, label as Lang.String,
                    actual as Lang.ByteArray, expected as Lang.String) as Lang.Boolean {
        var got = hex(actual);
        if (!got.equals(expected)) {
            logger.error(label + " : attendu [" + expected + "], obtenu [" + got + "]");
            return false;
        }
        return true;
    }

    // ---- Varints -----------------------------------------------------------

    (:test)
    function varintSingleByte(logger as Test.Logger) as Lang.Boolean {
        return expect(logger, "0", Protobuf.encodeVarint(0), "00")
            && expect(logger, "12", Protobuf.encodeVarint(12), "0C")
            && expect(logger, "127", Protobuf.encodeVarint(127), "7F");
    }

    (:test)
    function varintMultiByte(logger as Test.Logger) as Lang.Boolean {
        // 300 -> AC 02, l'exemple canonique de la documentation protobuf.
        // 315 -> BB 02 : l'autonomie reelle lue sur la lampe.
        return expect(logger, "128", Protobuf.encodeVarint(128), "80 01")
            && expect(logger, "300", Protobuf.encodeVarint(300), "AC 02")
            && expect(logger, "315", Protobuf.encodeVarint(315), "BB 02")
            && expect(logger, "16384", Protobuf.encodeVarint(16384), "80 80 01");
    }

    (:test)
    function varintRoundTrip(logger as Test.Logger) as Lang.Boolean {
        var values = [0, 1, 12, 127, 128, 255, 300, 315, 4095, 16384, 1000000];
        for (var i = 0; i < values.size(); i++) {
            var v = values[i];
            var r = Protobuf.decodeVarint(Protobuf.encodeVarint(v), 0);
            if (r == null || r[0] != v) {
                logger.error("aller-retour rate pour " + v);
                return false;
            }
        }
        return true;
    }

    (:test)
    function varintRejectsNegative(logger as Test.Logger) as Lang.Boolean {
        try {
            Protobuf.encodeVarint(-1);
        } catch (e instanceof Lang.InvalidValueException) {
            return true;
        }
        logger.error("une valeur negative aurait du lever une exception");
        return false;
    }

    (:test)
    function decodeRejectsTruncated(logger as Test.Logger) as Lang.Boolean {
        if (Protobuf.decodeVarint([0x80]b, 0) != null) {
            logger.error("un varint tronque aurait du etre refuse");
            return false;
        }
        return true;
    }

    // ---- CRC de transport --------------------------------------------------

    (:test)
    function crcMaxim(logger as Test.Logger) as Lang.Boolean {
        if (Crc8.maxim([0x00]b) != 0x00) {
            logger.error("CRC de 00 incorrect");
            return false;
        }
        // Charge utile reelle « lire le mode courant » : donne l'octet 9 de
        // l'en-tete, soit 0x5C dans la capture.
        if (Crc8.maxim([0x08, 0x6A, 0x10, 0x02, 0x18, 0x02]b) != 0x5C) {
            logger.error("CRC de la charge utile incorrect");
            return false;
        }
        return true;
    }

    // ---- Trames émises, comparées à la capture -----------------------------

    (:test)
    function frameReadCurrentMode(logger as Test.Logger) as Lang.Boolean {
        return expect(logger, "lecture mode courant", LightProtocol.readCurrentMode(),
            "01 6A 02 FF 02 FF FF 00 06 5C 01 FF FF FF FF FF FF FF FF 72"
            + " 08 6A 10 02 18 02");
    }

    (:test)
    function frameReadSupportedModes(logger as Test.Logger) as Lang.Boolean {
        return expect(logger, "lecture modes supportes", LightProtocol.readSupportedModes(),
            "01 6A 01 FF 02 FF FF 00 06 BE 01 FF FF FF FF FF FF FF FF 65"
            + " 08 6A 10 02 18 01");
    }

    (:test)
    function frameReadRemainingTime(logger as Test.Logger) as Lang.Boolean {
        return expect(logger, "lecture autonomie", LightProtocol.readRemainingTime(),
            "01 6A 05 FF 02 FF FF 00 06 DF 01 FF FF FF FF FF FF FF FF A6"
            + " 08 6A 10 02 18 05");
    }

    (:test)
    function frameSetLowBeamMedium(logger as Test.Logger) as Lang.Boolean {
        return expect(logger, "croisement moyen", LightProtocol.setMode(LC.BLM_LBEAM_MSTEADY),
            "01 6A 02 FF 01 FF FF 00 0A 1F 01 FF FF FF FF FF FF FF FF 08"
            + " 08 6A 10 01 18 02 6A 02 08 0B");
    }

    (:test)
    function frameSetLowBeamLow(logger as Test.Logger) as Lang.Boolean {
        return expect(logger, "croisement faible", LightProtocol.setMode(LC.BLM_LBEAM_LSTEADY),
            "01 6A 02 FF 01 FF FF 00 0A 9C 01 FF FF FF FF FF FF FF FF 11"
            + " 08 6A 10 01 18 02 6A 02 08 0C");
    }

    (:test)
    function frameSmartConfigOn(logger as Test.Logger) as Lang.Boolean {
        // Activation de « Luminosite en fonction de la vitesse ».
        return expect(logger, "vitesse variable ON",
            LightProtocol.setSmartConfig(LC.BLCS_LUMEN_VARY, LC.BSCS_CFG_ON),
            "01 6A 04 FF 01 FF FF 00 0C 57 01 FF FF FF FF FF FF FF FF 29"
            + " 08 6A 10 01 18 04 52 04 08 09 10 01");
    }

    (:test)
    function frameSmartConfigOff(logger as Test.Logger) as Lang.Boolean {
        // Statut a 0 : protobuf omet le champ, comme le fait l'app.
        var payload = LightProtocol.unframe(
            LightProtocol.setSmartConfig(LC.BLCS_SYNC_OFF, LC.BSCS_CFG_OFF));
        if (payload == null) { logger.error("trame invalide"); return false; }
        return expect(logger, "charge utile", payload, "08 6A 10 01 18 04 52 02 08 05");
    }

    (:test)
    function frameTurnOff(logger as Test.Logger) as Lang.Boolean {
        // BLM_LIGHT_OFF vaut 0 : le sous-message part vide. Non observe en
        // capture — a confirmer, voir LightProtocol.FORCE_EXPLICIT_OFF.
        var payload = LightProtocol.unframe(LightProtocol.turnOff());
        if (payload == null) { logger.error("trame invalide"); return false; }
        return expect(logger, "extinction", payload, "08 6A 10 01 18 02 6A 00");
    }

    // ---- Décapsulation -----------------------------------------------------

    //! Un en-tete n'est cru que si son CRC est juste : c'est ce qui autorise
    //! le reassemblage a lire l'octet de longueur, et a se resynchroniser
    //! sinon. Un octet de bruit devant une trame valide ne doit pas la cacher.
    (:test)
    function headerValidGuardsTheLengthByte(logger as Test.Logger) as Lang.Boolean {
        var good = LightProtocol.readCurrentMode();
        if (!LightProtocol.headerValid(good)) {
            logger.error("un en-tete valide a ete refuse");
            return false;
        }
        var corrupt = good.slice(0, null);
        corrupt[8] = 0xFF;   // longueur corrompue : 255 octets a attendre
        if (LightProtocol.headerValid(corrupt)) {
            logger.error("un en-tete a longueur corrompue a ete accepte");
            return false;
        }
        // Un octet de bruit devant : l'en-tete decale est refuse, et un pas
        // de resynchronisation retrouve le bon.
        var noisy = [0x42]b.addAll(good);
        if (LightProtocol.headerValid(noisy)) {
            logger.error("un en-tete decale d'un octet a ete accepte");
            return false;
        }
        if (!LightProtocol.headerValid(noisy.slice(1, null))) {
            logger.error("la resynchronisation d'un octet n'a pas retrouve l'en-tete");
            return false;
        }
        return true;
    }

    (:test)
    function unframeRejectsBadCrc(logger as Test.Logger) as Lang.Boolean {
        var good = LightProtocol.readCurrentMode();
        if (LightProtocol.unframe(good) == null) {
            logger.error("une trame valide a ete refusee");
            return false;
        }
        var bad = good.slice(0, null);
        bad[19] = (bad[19] + 1) & 0xFF;
        if (LightProtocol.unframe(bad) != null) {
            logger.error("un CRC d'en-tete faux aurait du etre refuse");
            return false;
        }
        var bad2 = good.slice(0, null);
        bad2[21] = (bad2[21] + 1) & 0xFF;
        if (LightProtocol.unframe(bad2) != null) {
            logger.error("un CRC de charge utile faux aurait du etre refuse");
            return false;
        }
        return true;
    }

    (:test)
    function unframeRejectsShort(logger as Test.Logger) as Lang.Boolean {
        // Premier fragment seul : la charge utile n'est pas encore arrivee.
        var partial = LightProtocol.readCurrentMode().slice(0, 20);
        if (LightProtocol.unframe(partial) != null) {
            logger.error("un fragment incomplet aurait du etre refuse");
            return false;
        }
        return true;
    }

    (:test)
    function frameRoundTrip(logger as Test.Logger) as Lang.Boolean {
        for (var i = 0; i < LC.BEAM_LADDER.size(); i++) {
            var mode = LC.BEAM_LADDER[i];
            var st = LightProtocol.parseFrame(LightProtocol.setMode(mode));
            if (st == null || st.mode != mode) {
                logger.error("aller-retour rate pour le mode " + mode);
                return false;
            }
        }
        return true;
    }

    // ---- Réponses réelles de la lampe --------------------------------------

    (:test)
    function parseRealModeNotification(logger as Test.Logger) as Lang.Boolean {
        var st = LightProtocol.parseStatus(
            [0x08, 0x6A, 0x10, 0x02, 0x18, 0x02, 0x6A, 0x02, 0x08, 0x0C]b);
        if (st == null) { logger.error("charge utile refusee"); return false; }
        if (st.mode != LC.BLM_LBEAM_LSTEADY) {
            logger.error("mode attendu 12, obtenu " + st.mode);
            return false;
        }
        return true;
    }

    (:test)
    function parseRealRemainingTime(logger as Test.Logger) as Lang.Boolean {
        // 315 minutes, soit 5 h 15 — ce qu'affichait l'app au meme moment.
        var st = LightProtocol.parseStatus(
            [0x08, 0x6A, 0x10, 0x02, 0x18, 0x05, 0x72, 0x03, 0x08, 0xBB, 0x02]b);
        if (st == null) { logger.error("charge utile refusee"); return false; }
        if (st.remainingMinutes != 315) {
            logger.error("autonomie attendue 315, obtenue " + st.remainingMinutes);
            return false;
        }
        return true;
    }

    (:test)
    function parseRealSupportedModes(logger as Test.Logger) as Lang.Boolean {
        // Reponse reelle de la VS1800S : six modes actives, plus deux
        // clignotants presents mais sans « enable » — les icones grisees de
        // l'application.
        var st = LightProtocol.parseStatus([
            0x08, 0x6A, 0x10, 0x02, 0x18, 0x01,
            0x32, 0x04, 0x08, 0x0C, 0x18, 0x01,
            0x32, 0x04, 0x08, 0x0B, 0x18, 0x01,
            0x32, 0x04, 0x08, 0x0A, 0x18, 0x01,
            0x32, 0x02, 0x08, 0x04,
            0x32, 0x02, 0x08, 0x05,
            0x32, 0x04, 0x08, 0x09, 0x18, 0x01,
            0x32, 0x04, 0x08, 0x08, 0x18, 0x01,
            0x32, 0x04, 0x08, 0x07, 0x18, 0x01]b);
        if (st == null || st.supportedModes == null) {
            logger.error("modes supportes non decodes");
            return false;
        }
        if (st.supportedModes.size() != 6) {
            logger.error("6 modes actives attendus, obtenus " + st.supportedModes.size());
            return false;
        }
        if (st.supportedModes.indexOf(LC.BLM_HIGH_BLINK) >= 0) {
            logger.error("un mode desactive a ete retenu");
            return false;
        }
        var l = LC.ladderFor(st.supportedModes, LC.BLT_FRONT_LIGHT);
        if (l.size() != 6) {
            logger.error("echelle a 6 crans attendue, obtenue " + l.size());
            return false;
        }
        return true;
    }

    (:test)
    function parseRejectsGarbage(logger as Test.Logger) as Lang.Boolean {
        // Type de fil 5 : non gere, la trame doit etre rejetee en bloc.
        if (LightProtocol.parseStatus([0x0D, 0x01, 0x02]b) != null) {
            logger.error("une trame inconnue aurait du etre refusee");
            return false;
        }
        if (LightProtocol.parseStatus([0x6A, 0x7F, 0x01]b) != null) {
            logger.error("une longueur incoherente aurait du etre refusee");
            return false;
        }
        return true;
    }

    (:test)
    function missingFieldsStayNull(logger as Test.Logger) as Lang.Boolean {
        // Absence de charge utile n'est pas valeur nulle : c'est ce qui evite
        // d'afficher « 0 % » quand la lampe n'a rien dit.
        var st = LightProtocol.parseFrame(LightProtocol.readCurrentMode());
        if (st == null) { logger.error("trame refusee"); return false; }
        if (st.batteryPct != null || st.mode != null) {
            logger.error("les champs absents auraient du rester nuls");
            return false;
        }
        return true;
    }

    // ---- Trames d'état, déclenchées par le bouton physique -----------------
    //
    // La lampe signale ses changements de mode par des trames de type 03, sans
    // charge utile protobuf : la valeur est inscrite dans l'en-tête. Ce sont
    // celles-ci qui permettent d'afficher l'etat REEL de la lampe plutot que le
    // dernier ordre envoye. Octets releves lors des appuis sur le bouton.

    (:test)
    function parseStateFrameMode(logger as Test.Logger) as Lang.Boolean {
        // Appui bouton -> feu de route faible (mode 9).
        var st = LightProtocol.parseFrame(
            [0x03, 0x6A, 0x02, 0xFF, 0x01, 0xFF, 0xFF, 0x09, 0xFF, 0xFF, 0xFF,
             0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x09]b);
        if (st == null) { logger.error("trame d'etat refusee"); return false; }
        if (st.mode != LC.BLM_HBEAM_LSTEADY) {
            logger.error("mode attendu 9, obtenu " + st.mode);
            return false;
        }
        return true;
    }

    (:test)
    function parseStateFrameRemainingTime(logger as Test.Logger) as Lang.Boolean {
        // Autonomie sur 32 bits petit-boutiste : 0x0000012B = 299... ici 0x8C = 140.
        var st = LightProtocol.parseFrame(
            [0x03, 0x6A, 0x05, 0xFF, 0x01, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
             0x8C, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xB2]b);
        if (st == null) { logger.error("trame d'etat refusee"); return false; }
        if (st.remainingMinutes != 140) {
            logger.error("autonomie attendue 140, obtenue " + st.remainingMinutes);
            return false;
        }
        // Valeur sur deux octets : 0x0127 = 295 minutes.
        var st2 = LightProtocol.parseFrame(
            [0x03, 0x6A, 0x05, 0xFF, 0x01, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
             0x27, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x5A]b);
        if (st2 == null || st2.remainingMinutes != 295) {
            logger.error("autonomie sur deux octets mal decodee");
            return false;
        }
        return true;
    }

    (:test)
    function ackFrameYieldsNothing(logger as Test.Logger) as Lang.Boolean {
        // Accuse d'ecriture : aucune information d'etat a en tirer.
        var st = LightProtocol.parseFrame(
            [0x02, 0x6A, 0x02, 0xFF, 0x01, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF,
             0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xD3]b);
        if (st != null) {
            logger.error("un accuse ne devrait produire aucun etat");
            return false;
        }
        return true;
    }

    (:test)
    function frameLengthHandlesStateFrames(logger as Test.Logger) as Lang.Boolean {
        // Le piege : l'octet 8 d'une trame d'etat vaut 0xFF. Le lire comme une
        // longueur ferait attendre 255 octets qui ne viendraient jamais.
        var state = [0x03, 0x6A, 0x05, 0xFF, 0x01, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                     0xFF, 0x8C, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xB2]b;
        if (LightProtocol.frameLength(state) != 20) {
            logger.error("une trame d'etat doit faire exactement 20 octets");
            return false;
        }
        // Une trame de donnees, elle, annonce bien sa charge utile.
        if (LightProtocol.frameLength(LightProtocol.readCurrentMode()) != 26) {
            logger.error("longueur de trame de donnees incorrecte");
            return false;
        }
        return true;
    }

    // ---- Généralisation à la gamme iGPSPORT --------------------------------

    (:test)
    function ladderDefaultsToBeam(logger as Test.Logger) as Lang.Boolean {
        var l = LC.ladderFor(null, LC.BLT_FRONT_LIGHT);
        if (l.size() != 6) {
            logger.error("echelle par defaut attendue a 6 crans, obtenue " + l.size());
            return false;
        }
        return true;
    }

    (:test)
    function ladderAdaptsToSimpleLight(logger as Test.Logger) as Lang.Boolean {
        // Une VS500 sans haut/bas faisceau : trois intensites simples.
        var supported = [LC.BLM_LOW_ALWAYS, LC.BLM_MID_ALWAYS,
                         LC.BLM_HIGH_ALWAYS, LC.BLM_LOW_BLINK];
        var l = LC.ladderFor(supported, LC.BLT_FRONT_LIGHT);
        if (l.size() != 3) {
            logger.error("echelle attendue a 3 crans, obtenue " + l.size());
            return false;
        }
        if (l[0] != LC.BLM_LOW_ALWAYS || l[2] != LC.BLM_HIGH_ALWAYS) {
            logger.error("echelle mal ordonnee");
            return false;
        }
        return true;
    }

    (:test)
    function ladderKeepsOnlyDeclaredModes(logger as Test.Logger) as Lang.Boolean {
        var supported = [LC.BLM_LBEAM_LSTEADY, LC.BLM_LBEAM_HSTEADY, LC.BLM_HBEAM_HSTEADY];
        var l = LC.ladderFor(supported, LC.BLT_FRONT_LIGHT);
        if (l.size() != 3) {
            logger.error("attendu 3 crans, obtenu " + l.size());
            return false;
        }
        for (var i = 0; i < l.size(); i++) {
            if (supported.indexOf(l[i]) < 0) {
                logger.error("mode non declare retenu : " + l[i]);
                return false;
            }
        }
        return true;
    }

    (:test)
    function ladderForTailLightAvoidsBeam(logger as Test.Logger) as Lang.Boolean {
        var supported = [LC.BLM_LOW_ALWAYS, LC.BLM_HIGH_ALWAYS,
                         LC.BLM_LBEAM_LSTEADY, LC.BLM_LBEAM_HSTEADY];
        var l = LC.ladderFor(supported, LC.BLT_TAIL_LIGHT);
        if (l[0] != LC.BLM_LOW_ALWAYS) {
            logger.error("echelle faisceau retenue a tort pour un feu arriere");
            return false;
        }
        return true;
    }

    // ---- Automatisme selon la vitesse --------------------------------------

    (:test)
    function autoRisesWithSpeed(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        if (a.indexForSpeed(0.0, null) != 0) {
            logger.error("a l'arret, cran 0 attendu");
            return false;
        }
        var top = a.indexForSpeed(20.0, null);
        if (top != a.ladder().size() - 1) {
            logger.error("a 72 km/h, dernier cran attendu, obtenu " + top);
            return false;
        }
        return true;
    }

    (:test)
    function autoHysteresisPreventsFlapping(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        var up = a.indexForSpeed(5.2, null);
        var down = a.indexForSpeed(4.9, null);
        if (down != up) {
            logger.error("le cran a change pour 0.3 m/s : hysteresis inoperante");
            return false;
        }
        if (a.indexForSpeed(3.0, null) >= up) {
            logger.error("pas de redescente a vitesse nettement plus basse");
            return false;
        }
        return true;
    }

    (:test)
    function autoCapsOnLowBattery(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        if (a.indexForSpeed(20.0, 5) >= a.indexForSpeed(20.0, 80)) {
            logger.error("l'intensite n'est pas plafonnee sur batterie faible");
            return false;
        }
        if (!a.isBatteryLow(5) || a.isBatteryLow(80)) {
            logger.error("seuil de batterie faible mal evalue");
            return false;
        }
        return true;
    }

    (:test)
    function autoRespectsShorterLadder(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes([LC.BLM_LOW_ALWAYS, LC.BLM_MID_ALWAYS, LC.BLM_HIGH_ALWAYS],
                            LC.BLT_FRONT_LIGHT);
        if (a.ladder().size() != 3) {
            logger.error("echelle a 3 crans attendue");
            return false;
        }
        if (a.indexForSpeed(20.0, null) != 2) {
            logger.error("dernier cran attendu");
            return false;
        }
        if (a.modeForSpeed(20.0, null, null) != LC.BLM_HIGH_ALWAYS) {
            logger.error("mode attendu HIGH_ALWAYS");
            return false;
        }
        return true;
    }

    (:test)
    function autoSkipsRedundantCommand(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        var mode = a.modeForSpeed(0.0, null, null);
        if (mode == null) { logger.error("premier ordre attendu"); return false; }
        if (a.modeForSpeed(0.0, null, mode) != null) {
            logger.error("ordre redondant emis");
            return false;
        }
        return true;
    }

    // ---- Pause, arret et extinction synchronisee ---------------------------

    //! Le defaut le plus grave releve a l'audit : la pause automatique
    //! eteignait la lampe. Elle se declenche a chaque feu rouge, c'est-a-dire
    //! au moment ou un cycliste immobile a le plus besoin d'etre vu.
    (:test)
    function pauseDoesNotSwitchTheLightOff(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        a.onRideState(AutoController.RIDE_RUNNING, null);

        var m = a.onRideState(AutoController.RIDE_PAUSED, LC.BLM_HIGH_ALWAYS);
        if (m != null) {
            logger.error("la pause a commande un changement de mode : " + m);
            return false;
        }
        return true;
    }

    //! Reprise apres pause : la lampe est restee dans son mode, et un allumage
    //! doux annulerait le choix manuel de l'utilisateur.
    (:test)
    function resumingFromPauseChangesNothing(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        a.onRideState(AutoController.RIDE_RUNNING, null);
        a.onRideState(AutoController.RIDE_PAUSED, LC.BLM_HIGH_ALWAYS);

        var m = a.onRideState(AutoController.RIDE_RUNNING, LC.BLM_HIGH_ALWAYS);
        if (m != null) {
            logger.error("la reprise a impose le mode " + m);
            return false;
        }
        return true;
    }

    //! L'arret, lui, eteint bien : c'est ce que promet le libelle du reglage.
    (:test)
    function stoppingSwitchesTheLightOff(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        a.onRideState(AutoController.RIDE_RUNNING, null);

        var m = a.onRideState(AutoController.RIDE_STOPPED, LC.BLM_HIGH_ALWAYS);
        if (m == null || m != LC.BLM_LIGHT_OFF) {
            logger.error("extinction attendue a l'arret, obtenu " + m);
            return false;
        }
        return true;
    }

    //! Depart : allumage doux au premier cran de l'echelle.
    (:test)
    function startingLightsTheFirstStep(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        var m = a.onRideState(AutoController.RIDE_RUNNING, LC.BLM_LIGHT_OFF);
        if (m == null || m != a.ladder()[0]) {
            logger.error("premier cran attendu au depart, obtenu " + m);
            return false;
        }
        return true;
    }

    //! L'arret eteint **meme apres un geste manuel**. Le test sur `enabled`
    //! sortait avant : une tape sur un mode pendant la sortie, puis l'arret du
    //! chrono, et la lampe restait allumee.
    (:test)
    function stoppingSwitchesOffEvenInManualMode(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        a.onRideState(AutoController.RIDE_RUNNING, null);
        a.setEnabledManually(false);

        var m = a.onRideState(AutoController.RIDE_STOPPED, LC.BLM_HBEAM_HSTEADY);
        if (m == null || m != LC.BLM_LIGHT_OFF) {
            logger.error("extinction attendue a l'arret en mode manuel, obtenu " + m);
            return false;
        }
        // Et l'arret leve le verrou : la sortie suivante repart en automatique.
        if (a.isManuallyHeld()) {
            logger.error("le verrou manuel a survecu a l'arret");
            return false;
        }
        return true;
    }

    //! Le mode manuel ne suspend que l'ajustement selon la vitesse : le depart
    //! suivant, verrou leve, allume a nouveau le premier cran.
    (:test)
    function manualHoldEndsWithTheRide(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        a.onRideState(AutoController.RIDE_RUNNING, null);
        a.setEnabledManually(false);
        a.onRideState(AutoController.RIDE_STOPPED, LC.BLM_LIGHT_OFF);

        var m = a.onRideState(AutoController.RIDE_RUNNING, LC.BLM_LIGHT_OFF);
        if (m == null || m != a.ladder()[0]) {
            logger.error("premier cran attendu au depart suivant, obtenu " + m);
            return false;
        }
        return true;
    }

    //! Le depart n'allume pas quand le reglage le dit. Le compteur ne sait pas
    //! s'il fait nuit : une sortie de jour videre la lampe pour rien.
    (:test)
    function startingDoesNothingWhenLightOnStartIsOff(logger as Test.Logger) as Lang.Boolean {
        Application.Properties.setValue("lightOnStart", false);
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        var m = a.onRideState(AutoController.RIDE_RUNNING, LC.BLM_LIGHT_OFF);
        Application.Properties.setValue("lightOnStart", true);
        if (m != null) {
            logger.error("allumage au depart malgre le reglage coupe : " + m);
            return false;
        }
        return true;
    }

    //! Le defaut symetrique du precedent : le reglage a true doit allumer.
    (:test)
    function startingStillLightsWhenSettingIsOn(logger as Test.Logger) as Lang.Boolean {
        Application.Properties.setValue("lightOnStart", true);
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        var m = a.onRideState(AutoController.RIDE_RUNNING, LC.BLM_LIGHT_OFF);
        if (m == null || m != a.ladder()[0]) {
            logger.error("premier cran attendu au depart, obtenu " + m);
            return false;
        }
        return true;
    }

    // ---- Reglages relus en cours de route ----------------------------------

    //! Une tape sur le champ suspend l'ajustement. Si l'utilisateur change
    //! ensuite n'importe quel reglage depuis Garmin Connect, la relecture ne
    //! doit pas reactiver l'automatisme dans son dos : la lampe repartirait
    //! toute seule au cran suivant.
    (:test)
    function reloadingSettingsKeepsAManualSuspension(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setEnabledManually(false);
        a.loadSettings();
        if (a.enabled) {
            logger.error("la relecture des reglages a annule la suspension manuelle");
            return false;
        }
        return true;
    }

    //! L'inverse : changer le reglage lui-meme est un geste plus fort qu'une
    //! tape, et leve le verrou.
    (:test)
    function changingTheSettingItselfClearsTheHold(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setEnabledManually(false);
        a.setEnabledFromSettings(false);
        a.loadSettings();                       // la propriete vaut true par defaut
        if (!a.enabled) {
            logger.error("le verrou manuel a survecu a un changement de reglage");
            return false;
        }
        return true;
    }

    //! Repartition des paliers sur l'echelle : entre le seuil bas et le seuil
    //! moyen, on veut le milieu de l'echelle, pas son bas. La division entiere
    //! donnait le cran 1 sur 5 la ou l'arrondi au plus proche donne le 2.
    (:test)
    function midSpeedLandsInTheMiddleOfTheLadder(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes(null, LC.BLT_FRONT_LIGHT);
        if (a.ladder().size() != 6) {
            logger.error("echelle faisceau a 6 crans attendue");
            return false;
        }
        // 3.0 m/s = 10.8 km/h : au-dessus du seuil bas (8), sous le moyen (18).
        var idx = a.indexForSpeed(3.0, null);
        if (idx != 2) {
            logger.error("cran 2 attendu en palier bas-moyen, obtenu " + idx);
            return false;
        }
        return true;
    }

    //! La traduction de `Activity.Info.timerState` est le point ou le defaut
    //! s'etait glisse : tout ce qui n'etait pas ON valait arret.
    (:test)
    function timerStateMapsPauseApartFromStop(logger as Test.Logger) as Lang.Boolean {
        if (AutoController.rideStateOf(AutoController.TIMER_STATE_ON)
                != AutoController.RIDE_RUNNING) {
            logger.error("ON mal traduit");
            return false;
        }
        if (AutoController.rideStateOf(AutoController.TIMER_STATE_PAUSED)
                != AutoController.RIDE_PAUSED) {
            logger.error("PAUSED mal traduit — c'est le defaut de l'audit");
            return false;
        }
        if (AutoController.rideStateOf(AutoController.TIMER_STATE_STOPPED)
                != AutoController.RIDE_STOPPED
            || AutoController.rideStateOf(AutoController.TIMER_STATE_OFF)
                != AutoController.RIDE_STOPPED
            || AutoController.rideStateOf(null) != AutoController.RIDE_STOPPED) {
            logger.error("arret mal traduit");
            return false;
        }
        return true;
    }

    //! Deux echelles de meme longueur mais de modes differents : comparer les
    //! tailles laissait l'ancienne en place, et les commandes partaient vers des
    //! modes que la lampe ne connaissait pas.
    (:test)
    function ladderChangesWhenModesDifferAtEqualLength(logger as Test.Logger) as Lang.Boolean {
        var a = new AutoController();
        a.setSupportedModes([LC.BLM_LOW_ALWAYS, LC.BLM_MID_ALWAYS, LC.BLM_HIGH_ALWAYS],
                            LC.BLT_FRONT_LIGHT);
        var first = a.ladder();
        if (first.size() != 3) {
            logger.error("echelle a 3 crans attendue");
            return false;
        }

        var other = [LC.BLM_LBEAM_LSTEADY, LC.BLM_LBEAM_MSTEADY, LC.BLM_LBEAM_HSTEADY];
        a.setSupportedModes(other, LC.BLT_FRONT_LIGHT);
        var second = a.ladder();
        if (second.size() != 3) {
            logger.error("echelle a 3 crans attendue apres changement");
            return false;
        }
        if (second[0] == first[0] && second[2] == first[2]) {
            logger.error("echelle inchangee alors que les modes different");
            return false;
        }
        return true;
    }

    // ---- Filtre de recherche BLE -------------------------------------------

    //! « VS » ou « TL » n'importe ou dans le nom acceptait la moitie des
    //! capteurs d'une salle. Le filtre exige desormais le motif d'une reference
    //! iGPSPORT : deux lettres, puis un chiffre.
    (:test)
    function scanFilterAcceptsRealLampNames(logger as Test.Logger) as Lang.Boolean {
        var names = ["VS1800S", "vs1800s", "TL30", "TL50", "iGPSPORT VS800"];
        for (var i = 0; i < names.size(); i++) {
            if (!LampManager.nameLooksLikeLamp(names[i] as Lang.String)) {
                logger.error("lampe rejetee a tort : " + names[i]);
                return false;
            }
        }
        return true;
    }

    (:test)
    function scanFilterRejectsNeighbours(logger as Test.Logger) as Lang.Boolean {
        var names = ["TICKR X", "BONTRAGER FLARE RT", "VOLT 800", "Wahoo KICKR",
                     "TLC Sensor", "VS", null];
        for (var i = 0; i < names.size(); i++) {
            if (LampManager.nameLooksLikeLamp(names[i] as Lang.String or Null)) {
                logger.error("appareil etranger accepte : " + names[i]);
                return false;
            }
        }
        return true;
    }

    // ---- Identification de la lampe ----------------------------------------

    //! La sequence : allumee, eteinte, allumee, eteinte, puis fini. C'est ce
    //! qui permet de reconnaitre sa lampe parmi plusieurs.
    (:test)
    function identifyBlinksThenStops(logger as Test.Logger) as Lang.Boolean {
        var lit = LC.BLM_MID_ALWAYS;
        var expected = [lit, LC.BLM_LIGHT_OFF, lit, LC.BLM_LIGHT_OFF];
        for (var step = 0; step < expected.size(); step++) {
            var got = LampManager.identifyModeAt(step, lit);
            if (got == null || got != expected[step]) {
                logger.error("phase " + step + " : attendu " + expected[step]
                             + ", obtenu " + got);
                return false;
            }
        }
        if (LampManager.identifyModeAt(expected.size(), lit) != null) {
            logger.error("la sequence ne s'arrete pas");
            return false;
        }
        return true;
    }

    // ---- Messages de liaison -----------------------------------------------

    //! L'abonnement aux notifications n'est plus une etape a part : c'est un
    //! detail de protocole, et il portait un mot que personne ne comprenait.
    (:test)
    function connectingAndSubscribingReadTheSame(logger as Test.Logger) as Lang.Boolean {
        var m = new LampManager();
        m.state = LampManager.STATE_CONNECTING;
        var connecting = m.stateMessage();
        m.state = LampManager.STATE_SUBSCRIBING;
        if (!m.stateMessage().equals(connecting)) {
            logger.error("deux messages differents pour une seule etape");
            return false;
        }
        m.state = LampManager.STATE_SCANNING;
        if (m.stateMessage().equals(connecting)) {
            logger.error("la recherche et la connexion se lisent pareil");
            return false;
        }
        return true;
    }

    //! La police de l'ecran d'attente se mesure sur ce message : s'il n'etait
    //! pas le plus long, un autre deborderait ou changerait de corps.
    (:test)
    function longestMessageCoversEveryStep(logger as Test.Logger) as Lang.Boolean {
        var reference = LampManager.longestStateMessage();
        var m = new LampManager();
        var states = [LampManager.STATE_SCANNING, LampManager.STATE_CONNECTING,
                      LampManager.STATE_SUBSCRIBING, LampManager.STATE_UNSUPPORTED,
                      LampManager.STATE_IDLE];
        for (var i = 0; i < states.size(); i++) {
            m.state = states[i] as Lang.Number;
            if (m.stateMessage().length() > reference.length()) {
                logger.error("message plus long que la reference : " + m.stateMessage());
                return false;
            }
        }
        return true;
    }

    // ---- Panneau de pilotage -----------------------------------------------

    //! Les deux délégués dispatchent sur le **signe et la plage** de l'action :
    //! négatif proche de zéro pour les commandes, au-delà de ACTION_CATEGORY
    //! pour les catégories, positif pour un mode. Une sentinelle qui glisserait
    //! dans la plage des modes ferait allumer la lampe en touchant un badge.
    (:test)
    function panelActionsStayOutOfModeRange(logger as Test.Logger) as Lang.Boolean {
        if (LampPanel.ACTION_SETTINGS >= 0 || LampPanel.ACTION_AUTO >= 0) {
            logger.error("une commande empiete sur la plage des modes");
            return false;
        }
        if (LampPanel.ACTION_SETTINGS <= LampPanel.ACTION_CATEGORY
                || LampPanel.ACTION_AUTO <= LampPanel.ACTION_CATEGORY) {
            logger.error("une commande est prise pour une categorie");
            return false;
        }
        if (LampPanel.ACTION_SETTINGS == LampPanel.ACTION_AUTO) {
            logger.error("deux commandes partagent la meme valeur");
            return false;
        }
        for (var i = 0; i < LC.CATEGORY_ORDER.size(); i++) {
            var cat = LC.CATEGORY_ORDER[i] as Lang.Number;
            if (LampPanel.ACTION_CATEGORY - cat > LampPanel.ACTION_CATEGORY) {
                logger.error("categorie " + cat + " hors de sa plage");
                return false;
            }
        }
        return true;
    }

    //! Tailles d'écran et de champ à couvrir, relevées dans les définitions du
    //! SDK (`Devices/<appareil>/simulator.json`) et non supposées.
    //!
    //! Les 13 cibles se repartissent sur six formats : 240x320 (MTB),
    //! 240x400 (Explore, Explore 2), 246x322 (530, 540, 830, 840),
    //! 282x470 (1030, 1030+, 1040), 420x600 (550, 850), 480x800 (1050). S'y
    //! ajoutent les découpes de champ assez grandes pour que le panneau
    //! s'affiche — un champ plein écran, une demi-page, un tiers de page.
    //!
    (:test)
    const PANEL_SIZES = [
        [240, 320],   // MTB, plein ecran
        [240, 400],   // Explore, Explore 2
        [246, 322],   // 530, 540, 830, 840
        [282, 470],   // 1030, 1030+, 1040
        [420, 600],   // 550, 850
        [420, 299],   // 550, 850 : champ demi-page
        [480, 800],   // 1050
        [480, 399],   // 1050 : champ demi-page
        [480, 319],   // 1050 : champ tiers de page
        [480, 266],   // 1050 : le plus petit champ ou la page tient encore
        [200, 260]    // borne exacte de PanelLayout.fits()
    ];

    //! Hauteurs de police (small, medium, large) couvrant les mêmes appareils.
    //!
    //! Les trois premiers jeux sont relevés dans le SDK, qui les donne en
    //! pixels pour les appareils à polices bitmap : 14/16/26 sur un Edge
    //! Explore, 22/26/41 sur un 530, 26/29/48 sur un 1030. Les deux derniers
    //! encadrent les appareils à polices vectorielles (550, 850, 1040, 1050),
    //! dont le SDK ne donne qu'une taille relative — on borne large plutôt que
    //! de supposer juste.
    (:test)
    const PANEL_FONTS = [
        [14, 16, 26], [22, 26, 41], [26, 29, 48], [33, 37, 60], [41, 46, 75]
    ];

    //! La page complète doit tenir dans **toutes** les combinaisons, sans
    //! déborder ni produire une tuile de taille nulle.
    //!
    //! C'est la vérification qui manquait : la mise en page était réglée sur un
    //! Edge 1050 et constatée sur photo. Les 1 925 combinaisons ci-dessous
    //! couvrent les six formats d'écran, les découpes de champ, les cinq jeux de
    //! polices, et de deux à six catégories selon ce que déclare la lampe.
    (:test)
    function panelLayoutFitsEveryTarget(logger as Test.Logger) as Lang.Boolean {
        for (var s = 0; s < PANEL_SIZES.size(); s++) {
            var size = PANEL_SIZES[s] as Lang.Array;
            var w = size[0] as Lang.Number;
            var h = size[1] as Lang.Number;

            for (var f = 0; f < PANEL_FONTS.size(); f++) {
                var fonts = PANEL_FONTS[f] as Lang.Array;

                for (var nc = 2; nc <= 6; nc++) {
                    for (var nl = 0; nl <= 6; nl++) {
                        if (!_checkLayout(logger, w, h, nc, nl,
                                          fonts[0] as Lang.Number,
                                          fonts[1] as Lang.Number,
                                          fonts[2] as Lang.Number)) {
                            return false;
                        }
                    }
                }
            }
        }
        return true;
    }

    //! Sans annotation (:test) : c'est un utilitaire, pas un test — le
    //! lanceur execute toute fonction annotee, et celle-ci attend des
    //! arguments qu'il ne sait pas lui fournir.
    function _checkLayout(logger as Test.Logger, w as Lang.Number, h as Lang.Number,
                          nc as Lang.Number, nl as Lang.Number,
                          hs as Lang.Number, hm as Lang.Number,
                          hl as Lang.Number) as Lang.Boolean {
        // On verifie les deux etats de la rangee de niveaux : affichee, et
        // reservee mais vide — c'est le second qui garantit que toucher
        // « Eteint » ne deplace rien.
        var m = new PanelLayout(w, h, nc, nl, nl > 0, hs, hm, hl);
        var reserved = new PanelLayout(w, h, nc, 0, true, hs, hm, hl);
        if (nl > 0 && (reserved.rowsY != m.rowsY || reserved.catH != m.catH
                       || reserved.heroH != m.heroH || reserved.levY != m.levY)) {
            logger.error("la page bouge quand la rangee de niveaux se vide en "
                         + w + "x" + h + " cat=" + nc + " niv=" + nl);
            return false;
        }
        var where = w + "x" + h + " cat=" + nc + " niv=" + nl
                  + " polices=" + hs + "/" + hm + "/" + hl;

        if (m.tw < 1 || m.catH < 1) {
            logger.error("tuile degeneree en " + where);
            return false;
        }
        if (m.rows < 1 || m.cols < 1 || m.rows * m.cols < nc) {
            logger.error("grille trop petite pour " + nc + " categories en " + where);
            return false;
        }
        if (m.cols * m.tw + (m.cols - 1) * m.gap > m.cw) {
            logger.error("grille plus large que la colonne en " + where);
            return false;
        }
        if (m.heroY < m.batteryY + m.batteryH) {
            logger.error("le mode courant chevauche la batterie en " + where);
            return false;
        }
        if (m.rowsY < m.heroY + m.heroH) {
            logger.error("les tuiles chevauchent le mode courant en " + where);
            return false;
        }

        // Le bas de la derniere rangee ne doit pas sortir de l'ecran : c'est la
        // seule erreur qu'un utilisateur voit tout de suite, et la seule qui
        // rend une commande intouchable.
        var bottom = (m.levH > 0) ? m.levY + m.levH : m.rowsY + m.gridH;
        if (bottom > h) {
            logger.error("depassement de " + (bottom - h) + " px en " + where);
            return false;
        }
        if (m.levH > 0) {
            if (m.levY < m.rowsY + m.gridH) {
                logger.error("les niveaux chevauchent les categories en " + where);
                return false;
            }
            if (nl * m.levW + (nl - 1) * m.gap > m.cw) {
                logger.error("rangee de niveaux trop large en " + where);
                return false;
            }
        }
        return true;
    }

    //! Tout mode doit être listé par la catégorie où `categoryOf()` le range.
    //!
    //! C'est l'invariant qui manquait. `categoryOf()` renvoie « flash » pour
    //! tout ce qu'il ne reconnaît pas — clignotants, moulinet, modes spéciaux —
    //! alors que `modesInCategory(CAT_FLASH)` n'en listait que six. Un mode
    //! déclaré par la lampe mais absent du catalogue est **injoignable depuis
    //! la page** : sa catégorie s'allume, et aucune tuile ne permet d'y aller.
    (:test)
    function everyModeIsReachableFromItsCategory(logger as Test.Logger) as Lang.Boolean {
        for (var mode = 0; mode <= LC.BLM_CUSTOMIZE_12; mode++) {
            var cat = LC.categoryOf(mode);
            if (cat == LC.CAT_OFF) { continue; }   // l'extinction n'a pas de rangée

            var listed = LC.modesInCategory(cat, null);
            var found = false;
            for (var i = 0; i < listed.size(); i++) {
                if (listed[i] == mode) { found = true; }
            }
            if (!found) {
                logger.error("mode " + mode + " range en categorie " + cat
                             + " mais absent de son catalogue");
                return false;
            }
        }
        return true;
    }

    //! Chaque catégorie doit avoir un libellé de repli plus court que le
    //! complet : c'est ce qui permet à la tuile de dégrader proprement sur un
    //! Edge 530 au lieu de rogner le mot.
    (:test)
    function everyCategoryHasAShortLabel(logger as Test.Logger) as Lang.Boolean {
        for (var i = 0; i < LC.CATEGORY_ORDER.size(); i++) {
            var cat = LC.CATEGORY_ORDER[i] as Lang.Number;
            var full = LC.categoryLabel(cat);
            var brief = LC.categoryLabelShort(cat);
            if (brief.equals("?")) {
                logger.error("libelle court manquant pour la categorie " + cat);
                return false;
            }
            if (brief.length() > full.length()) {
                logger.error("libelle court plus long que le complet : " + brief);
                return false;
            }
        }
        return true;
    }
}
