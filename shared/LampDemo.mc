using Toybox.Lang;
using LightConstants as LC;

//! Lampe factice, pour voir la page de pilotage dans le simulateur.
//!
//! Le simulateur n'a **pas de pile Bluetooth** : `Ble.setScanState()` n'y
//! trouve jamais rien, la machine a etats reste sur « Recherche », et le seul
//! ecran qu'on puisse regarder est celui de l'attente. Toute la page — bandeau,
//! jauge, mode courant, categories, crans — etait donc invisible ailleurs que
//! sur un appareil avec une vraie lampe au bout.
//!
//! Ce module remplit `LampManager.status` avec ce qu'une VS1800S declare
//! reellement — releve sur le materiel, pas invente — et pose l'etat a
//! « prete ». Le dessin est alors exactement celui d'une lampe connectee : le
//! panneau ne sait pas d'ou vient l'etat qu'il affiche.
//!
//! **Il n'est dans aucun binaire de diffusion.** Les deux jungles excluent
//! l'annotation `demo` ; seul `bash app/build.sh sim` la garde. Voir
//! `docs/application.md`, « Voir la page dans le simulateur ».
(:demo)
module LampDemo {

    //! Modes d'une VS1800S : les six crans de faisceau actifs, les deux flashs
    //! desactives — ils le sont a la sortie de l'usine — et les **trois**
    //! emplacements personnalisables que ce modele declare, remplis.
    //!
    //! Trois, et non deux : c'est ce que la lampe reelle expose. Une capture
    //! qui en montrerait deux ferait juger la mise en page sur un cas qui
    //! n'existe pas.
    //!
    //! Les flashs desactives, eux, sont gardes a dessein : c'est ce qui montre
    //! la tuile grisee, qu'une lampe dont tout serait actif ne montrerait
    //! jamais.
    function apply(lamp as LampManager) as Void {
        var states = {};
        states.put(LC.BLM_LBEAM_LSTEADY, true);
        states.put(LC.BLM_LBEAM_MSTEADY, true);
        states.put(LC.BLM_LBEAM_HSTEADY, true);
        states.put(LC.BLM_HBEAM_LSTEADY, true);
        states.put(LC.BLM_HBEAM_MSTEADY, true);
        states.put(LC.BLM_HBEAM_HSTEADY, true);
        states.put(LC.BLM_HIGH_BLINK, false);
        states.put(LC.BLM_LOW_BLINK, false);
        states.put(LC.BLM_CUSTOMIZE_1, true);
        states.put(LC.BLM_CUSTOMIZE_1 + 1, true);
        states.put(LC.BLM_CUSTOMIZE_1 + 2, true);

        var supported = [];
        var keys = states.keys();
        for (var i = 0; i < keys.size(); i++) {
            var m = keys[i] as Lang.Number;
            var on = states.get(m);
            if (on instanceof Lang.Boolean && on) { supported.add(m); }
        }

        var configs = {};
        configs.put(LC.BLCS_LUMEN_VARY, LC.BSCS_CFG_ON);
        configs.put(LC.BLCS_AUTO_LIGHT, LC.BSCS_CFG_OFF);
        configs.put(LC.BLCS_SYNC_OFF, LC.BSCS_CFG_ON);
        configs.put(LC.BLCS_AUTO_START, LC.BSCS_CFG_OFF);
        configs.put(LC.BLCS_AUTO_SLEEP, LC.BSCS_CFG_ON);
        configs.put(LC.BLCS_AUTO_LOW, LC.BSCS_CFG_OFF);

        var st = lamp.status;
        st.lightType = LC.BLT_FRONT_LIGHT;
        st.modeStates = states;
        st.supportedModes = supported;
        st.configs = configs;
        // Un cran de croisement, une charge qui n'est ni pleine ni basse, une
        // autonomie superieure a l'heure : c'est ce qui exerce le plus de
        // chemins de dessin d'un coup — jauge a mi-course, autonomie en
        // « 5 h 12 », tuile allumee au milieu de la rangee.
        st.mode = LC.BLM_LBEAM_MSTEADY;
        st.batteryPct = 62;
        st.remainingMinutes = 312;

        lamp.forceReady();
    }
}
