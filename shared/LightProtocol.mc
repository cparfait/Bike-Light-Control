using Toybox.Lang;
using LightConstants as LC;

//! Construction et lecture des messages échangés avec la lampe.
//!
//! Une trame complète comporte deux niveaux :
//!
//! 1. un **en-tête de transport de 20 octets**, propre à iGPSPORT, avec deux
//!    CRC-8/MAXIM — il n'apparaît nulle part dans l'APK, il a été relevé par
//!    capture HCI ;
//! 2. une **charge utile protobuf** (`blt_message_format`), dont le schéma vient
//!    de l'analyse statique de l'app.
//!
//! Les trames produites ici ont été confrontées à la capture du 08/09/2026 :
//! les 19 commandes distinctes émises par l'app iGPSPORT sont reconstruites à
//! l'octet près. Voir docs/protocole-vs1800s.md §2 et §4.
module LightProtocol {

    //! Emballe une charge utile dans l'en-tête de transport.
    function frame(subService as Lang.Number, operate as Lang.Number,
                   payload as Lang.ByteArray) as Lang.ByteArray {
        var h = [
            LC.HDR_TYPE_DATA,
            LC.SERVICE_LIGHT,
            subService,
            0xFF,
            operate,
            0xFF, 0xFF,
            0x00,
            payload.size(),
            Crc8.maxim(payload),
            0x01,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
        ]b;
        // Le CRC de l'en-tête porte sur les 19 octets qui le précèdent.
        h.add(Crc8.maxim(h));
        return h.addAll(payload);
    }

    //! Charge utile : service, opération, sous-service, puis le contenu éventuel.
    function envelope(subService as Lang.Number, operate as Lang.Number,
                      body as Lang.ByteArray) as Lang.ByteArray {
        return Protobuf.varintField(LC.F_SERVICE_TYPE, LC.SERVICE_LIGHT)
            .addAll(Protobuf.varintField(LC.F_OPERATE_TYPE, operate))
            .addAll(Protobuf.varintField(LC.F_BLT_SERVICE_TYPE, subService))
            .addAll(body);
    }

    //! Message complet, prêt à écrire sur la caractéristique TX.
    function message(subService as Lang.Number, operate as Lang.Number,
                     body as Lang.ByteArray) as Lang.ByteArray {
        return frame(subService, operate, envelope(subService, operate, body));
    }

    // ---- Requêtes de lecture ----------------------------------------------

    //! Demande à la lampe ce qu'elle est : type d'éclairage, nombre de canaux.
    //!
    //! Le sous-service `BLS_LIGHT_CFG` est déduit du schéma, pas observé : la
    //! capture du 08/09 ne contient aucune requête de ce genre. Si la lampe ne
    //! répond pas, le type reste inconnu — sans conséquence, l'affichage et
    //! l'échelle d'intensité s'en passent.
    function readSelf() as Lang.ByteArray {
        return message(LC.BLS_LIGHT_CFG, LC.OP_READ, []b);
    }

    function readSupportedModes() as Lang.ByteArray {
        return message(LC.BLS_MODE_SUP, LC.OP_READ, []b);
    }

    function readCurrentMode() as Lang.ByteArray {
        return message(LC.BLS_MODE_CUR, LC.OP_READ, []b);
    }

    function readSmartConfig() as Lang.ByteArray {
        return message(LC.BLS_SMT_CONFIG, LC.OP_READ, []b);
    }

    function readRemainingTime() as Lang.ByteArray {
        return message(LC.BLS_LEFT_TIME, LC.OP_READ, []b);
    }

    function readBattery() as Lang.ByteArray {
        return message(LC.BLS_BAT_PCT, LC.OP_READ, []b);
    }

    // ---- Commandes ---------------------------------------------------------

    //! `BLM_LIGHT_OFF` vaut 0, c'est-à-dire la valeur par défaut de l'enum : un
    //! encodeur protobuf conforme ne l'émet pas et le sous-message part vide.
    //!
    //! Aucune extinction n'a été capturée à ce jour, mais l'app omet bien les
    //! valeurs par défaut ailleurs — la trame `52 02 08 05` observée pour un
    //! automatisme désactivé n'émet pas son champ `status` à 0. On reproduit ce
    //! comportement. Si un essai montre le contraire, basculer ce drapeau.
    const FORCE_EXPLICIT_OFF = false;

    function setMode(mode as Lang.Number) as Lang.ByteArray {
        var inner = []b;
        if (mode != LC.BLM_LIGHT_OFF || FORCE_EXPLICIT_OFF) {
            inner = Protobuf.varintField(LC.F_CUR_MODE_VALUE, mode);
        }
        return message(LC.BLS_MODE_CUR, LC.OP_WRITE,
                       Protobuf.messageField(LC.F_CUR_MODE, inner));
    }

    function turnOff() as Lang.ByteArray {
        return setMode(LC.BLM_LIGHT_OFF);
    }

    //! Active ou désactive un mode dans la liste de la lampe.
    //!
    //! Les flashs et les modes personnalisés sont désactivés d'usine : tant
    //! qu'ils le sont, ni l'application ni le bouton physique ne peuvent y
    //! basculer. C'est le pendant du bouton « Éditer » de l'app iGPSPORT.
    function setModeEnabled(mode as Lang.Number, enabled as Lang.Boolean) as Lang.ByteArray {
        var inner = Protobuf.varintField(LC.F_MODE_ENABLE_MODE, mode);
        if (enabled) {
            inner = inner.addAll(Protobuf.varintField(LC.F_MODE_ENABLE_FLAG, 1));
        }
        return message(LC.BLS_MODE_ENABLE, LC.OP_WRITE,
                       Protobuf.messageField(LC.F_MODE_SET, inner));
    }

    //! Active ou désactive un automatisme de la lampe.
    //! Forme confirmée par la capture : `52 04 08 <config> 10 <status>`, et
    //! `52 02 08 <config>` quand le statut vaut 0.
    function setSmartConfig(config as Lang.Number, status as Lang.Number) as Lang.ByteArray {
        var inner = Protobuf.varintField(LC.F_SMT_CFG_CONFIG, config);
        if (status != LC.BSCS_CFG_OFF) {
            inner = inner.addAll(Protobuf.varintField(LC.F_SMT_CFG_STATUS, status));
        }
        return message(LC.BLS_SMT_CONFIG, LC.OP_WRITE,
                       Protobuf.messageField(LC.F_CFG_SET, inner));
    }

    //! Automatisme assorti d'un delai, en secondes — veille automatique,
    //! luminosite reduite a l'arret. Forme relevee dans la capture :
    //! `52 09 08 04 10 01 1A 03 08 B4 01`, soit config, statut, puis un
    //! sous-message portant la duree.
    function setSmartConfigTimed(config as Lang.Number, status as Lang.Number,
                                 seconds as Lang.Number) as Lang.ByteArray {
        var inner = Protobuf.varintField(LC.F_SMT_CFG_CONFIG, config);
        if (status != LC.BSCS_CFG_OFF) {
            inner = inner.addAll(Protobuf.varintField(LC.F_SMT_CFG_STATUS, status));
        }
        inner = inner.addAll(Protobuf.messageField(LC.F_SMT_CFG_USERDATA,
                                Protobuf.varintField(1, seconds)));
        return message(LC.BLS_SMT_CONFIG, LC.OP_WRITE,
                       Protobuf.messageField(LC.F_CFG_SET, inner));
    }

    // ---- Lecture des réponses et notifications -----------------------------

    //! État de la lampe reconstitué à partir d'un message reçu.
    //! Chaque champ vaut `null` tant que la lampe ne l'a pas communiqué —
    //! à distinguer soigneusement de zéro.
    class LightStatus {
        var mode as Lang.Number or Null;
        var batteryPct as Lang.Number or Null;
        var remainingMinutes as Lang.Number or Null;
        //! Modes activés, ceux qu'on peut réellement appliquer.
        var supportedModes as Lang.Array or Null;
        //! Tous les modes déclarés par la lampe, activés ou non : mode vers
        //! booléen. C'est ce qui permet de proposer d'activer un mode que le
        //! constructeur a désactivé d'usine — les flashs, par exemple.
        var modeStates as Lang.Dictionary or Null;
        var lightType as Lang.Number or Null;
        var subService as Lang.Number or Null;
        //! Automatismes declares par la lampe : identifiant BLCS_* vers etat
        //! BSCS_*. Renseigne par la reponse a `readSmartConfig()`.
        var configs as Lang.Dictionary or Null;

        function initialize() {
            mode = null;
            batteryPct = null;
            remainingMinutes = null;
            supportedModes = null;
            modeStates = null;
            lightType = null;
            subService = null;
            configs = null;
        }
    }

    //! Retire l'en-tête de transport d'une trame reçue et rend la charge utile,
    //! ou `null` si l'en-tête est absent, incomplet ou incohérent.
    //!
    //! On vérifie les deux CRC : une trame corrompue vaut mieux ignorée
    //! qu'interprétée comme un état de la lampe.
    function unframe(bytes as Lang.ByteArray) as Lang.ByteArray or Null {
        if (bytes.size() < LC.HDR_LEN) { return null; }
        if (bytes[0] != LC.HDR_TYPE_DATA) { return null; }   // accusé ou résultat

        var header = bytes.slice(0, LC.HDR_LEN - 1);
        if (Crc8.maxim(header) != bytes[LC.HDR_LEN - 1]) { return null; }

        var length = bytes[8];
        var payload = bytes.slice(LC.HDR_LEN, null);
        if (payload.size() < length) { return null; }        // fragment incomplet
        payload = payload.slice(0, length);
        if (Crc8.maxim(payload) != bytes[9]) { return null; }
        return payload;
    }

    //! Décode une charge utile déjà débarrassée de son en-tête.
    function parseStatus(payload as Lang.ByteArray) as LightStatus or Null {
        var fields = Protobuf.parse(payload);
        if (fields == null) { return null; }

        var st = new LightStatus();
        st.subService = fields.get(LC.F_BLT_SERVICE_TYPE);

        var cur = Protobuf.getMessage(fields, LC.F_CUR_MODE);
        if (cur != null) {
            // Sous-message présent mais vide => mode par défaut, donc éteint.
            st.mode = Protobuf.getVarint(cur, LC.F_CUR_MODE_VALUE, LC.BLM_LIGHT_OFF);
        }

        var bat = Protobuf.getMessage(fields, LC.F_BAT_PCT);
        if (bat != null) {
            st.batteryPct = Protobuf.getVarint(bat, LC.F_BAT_PCT_VALUE, 0);
        }

        var identity = Protobuf.getMessage(fields, LC.F_LIGHT_SELF);
        if (identity != null) {
            st.lightType = Protobuf.getVarint(identity, LC.F_LIGHT_SELF_TYPE, LC.BLT_TAIL_LIGHT);
        }

        var left = Protobuf.getMessage(fields, LC.F_LEFT_TIME);
        if (left != null) {
            st.remainingMinutes = Protobuf.getVarint(left, LC.F_LEFT_TIME_VALUE, 0);
        }

        // `modeSup` est répété : c'est par lui que la lampe annonce ce qu'elle
        // sait faire, et donc ce qui permet de piloter un modèle qu'on n'a pas
        // en main.
        var supEntries = Protobuf.parseRepeated(payload, LC.F_MODE_SUP);
        if (supEntries != null && supEntries.size() > 0) {
            var modes = [];
            var states = {};
            for (var i = 0; i < supEntries.size(); i++) {
                var entry = Protobuf.parse(supEntries[i] as Lang.ByteArray);
                if (entry == null) { continue; }
                var m = Protobuf.getVarint(entry, LC.F_MODE_SUP_MODE, -1);
                if (m < 0) { continue; }
                // La lampe liste aussi des modes qu'elle n'active pas — les
                // flashs sur la VS1800S. On garde les deux informations :
                // la liste des utilisables, et l'etat de chacun.
                var on = (Protobuf.getVarint(entry, LC.F_MODE_SUP_ENABLE, 0) != 0);
                states.put(m, on);
                if (on) { modes.add(m); }
            }
            if (states.size() > 0) { st.modeStates = states; }
            if (modes.size() > 0) { st.supportedModes = modes; }
        }

        // `cfgSup` est repete : la lampe y enumere ses automatismes et leur
        // etat. C'est ce qui permet au menu de refleter la realite plutot que
        // ce que l'application croit avoir envoye.
        var cfgEntries = Protobuf.parseRepeated(payload, LC.F_CFG_SUP);
        if (cfgEntries != null && cfgEntries.size() > 0) {
            var configs = {};
            for (var i = 0; i < cfgEntries.size(); i++) {
                var entry = Protobuf.parse(cfgEntries[i] as Lang.ByteArray);
                if (entry == null) { continue; }
                var id = Protobuf.getVarint(entry, LC.F_SMT_CFG_CONFIG, -1);
                if (id < 0) { continue; }
                configs.put(id, Protobuf.getVarint(entry, LC.F_SMT_CFG_STATUS,
                                                   LC.BSCS_CFG_OFF));
            }
            if (configs.size() > 0) { st.configs = configs; }
        }

        return st;
    }

    //! Longueur totale attendue d'une trame dont on a reçu au moins l'en-tête.
    //!
    //! Les trames d'accusé et d'état ne portent pas de charge utile : leur
    //! octet 8 vaut 0x00 ou 0xFF et ne doit surtout pas être lu comme une
    //! longueur, sous peine d'attendre indéfiniment 255 octets qui ne viendront
    //! jamais.
    //! Vrai si les 20 premiers octets forment un en-tete dont le CRC est juste.
    //!
    //! C'est le seul critere qui autorise a lire l'octet de longueur : sans
    //! lui, un octet corrompu bloquait le reassemblage pour toute la liaison.
    function headerValid(bytes as Lang.ByteArray) as Lang.Boolean {
        if (bytes.size() < LC.HDR_LEN) { return false; }
        return Crc8.maxim(bytes.slice(0, LC.HDR_LEN - 1)) == bytes[LC.HDR_LEN - 1];
    }

    function frameLength(bytes as Lang.ByteArray) as Lang.Number {
        if (bytes.size() < LC.HDR_LEN) { return LC.HDR_LEN; }
        if (bytes[0] != LC.HDR_TYPE_DATA) { return LC.HDR_LEN; }
        return LC.HDR_LEN + bytes[8];
    }

    //! Décode une trame complète, quel qu'en soit le type.
    //!
    //! Les changements de mode déclenchés par le **bouton physique** de la lampe
    //! arrivent en type 03, avec la valeur inscrite directement dans l'en-tête
    //! et aucune charge utile protobuf. C'est ce qui permet à l'Edge d'afficher
    //! l'état réel de la lampe plutôt que le dernier ordre qu'il a envoyé.
    function parseFrame(bytes as Lang.ByteArray) as LightStatus or Null {
        if (bytes.size() < LC.HDR_LEN) { return null; }
        var header = bytes.slice(0, LC.HDR_LEN - 1);
        if (Crc8.maxim(header) != bytes[LC.HDR_LEN - 1]) { return null; }

        var type = bytes[0];
        if (type == LC.HDR_TYPE_ACK) { return null; }        // rien à en tirer

        if (type == LC.HDR_TYPE_STATE) {
            var st = new LightStatus();
            st.subService = bytes[2];
            if (st.subService == LC.BLS_MODE_CUR) {
                st.mode = bytes[LC.HDR_VALUE8];
            } else if (st.subService == LC.BLS_LEFT_TIME) {
                // 32 bits petit-boutiste. On se limite à 24 bits utiles :
                // l'autonomie ne dépassera jamais quelques milliers de minutes,
                // et le quatrième octet ferait déborder un Number signé.
                st.remainingMinutes = bytes[LC.HDR_VALUE32]
                    | (bytes[LC.HDR_VALUE32 + 1] << 8)
                    | (bytes[LC.HDR_VALUE32 + 2] << 16);
            } else {
                return null;
            }
            return st;
        }

        var payload = unframe(bytes);
        if (payload == null) { return null; }
        return parseStatus(payload);
    }
}
