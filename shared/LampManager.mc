using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Lang;
using Toybox.System;
using Toybox.Activity;
using LightConstants as LC;

//! Connexion BLE à la lampe et machine à états associée.
//!
//! Trois contraintes dictent la conception, les deux premières venant de la
//! plateforme, la troisième de la lampe elle-même :
//!
//! - **Une seule opération GATT en vol à la fois** : toute écriture attend son
//!   `onCharacteristicWrite`, d'où la file d'attente.
//! - **L'appairage ne persiste pas d'une instance d'application à l'autre.**
//!   Sans conséquence ici : la capture montre que la lampe se connecte sans
//!   bonding SMP.
//! - **La lampe n'annonce pas son service.** Son advertising ne contient qu'un
//!   marqueur (`ADVERT_MARKER_UUID`) absent de l'app iGPSPORT. On la repère donc
//!   par ce marqueur ou par son nom, puis on découvre après connexion.
class LampManager extends Ble.BleDelegate {

    enum {
        STATE_IDLE,
        STATE_SCANNING,
        STATE_CONNECTING,
        STATE_SUBSCRIBING,
        STATE_READY,
        STATE_UNSUPPORTED
    }

    //! Cycle du scan BLE, en secondes. Scanner en continu quand la lampe est
    //! absente — eteinte, ou en veille — est de loin ce qui coute le plus cher
    //! en batterie du compteur. On alterne donc fenetres d'ecoute et pauses.
    const SCAN_WINDOW_S = 15;
    const SCAN_PAUSE_S = 45;

    //! Interrogation de l'autonomie restante. Rare a dessein : la lampe la
    //! notifie spontanement a chaque changement de mode (trame de type 03), ce
    //! qui rend ce rappel presque superflu.
    const POLL_TICKS = 300;

    //! Duree d'ecoute avant de choisir, une fois la premiere lampe reperee.
    //!
    //! On ne se connecte plus a la premiere lampe vue. Dans un garage, a un
    //! depart de groupe, deux lampes repondent au meme moment et la premiere
    //! arrivee n'est pas la sienne. Trois secondes suffisent a en voir
    //! plusieurs ; on garde ensuite la plus proche, celle dont le signal est le
    //! plus fort — sur un velo, la lampe posee a un metre du compteur.
    const PICK_WINDOW_S = 3;

    //! Nombre de clignotements a la connexion, et duree d'un demi-cycle en
    //! secondes. Le battement etant a 1 Hz — `Toybox.Timer` est proscrit dans un
    //! champ de donnees — un clignotement dure deux secondes.
    //! `static` : la sequence est verifiee par un test qui n'instancie pas de
    //! gestionnaire, faute de pile BLE dans le simulateur.
    static const IDENTIFY_BLINKS = 2;

    var state as Lang.Number = STATE_IDLE;
    var status as LightProtocol.LightStatus;
    var lastError as Lang.String or Null = null;

    private var _device as Ble.Device or Null = null;
    private var _tx as Ble.Characteristic or Null = null;
    private var _rx as Ble.Characteristic or Null = null;
    private var _battery as Ble.Characteristic or Null = null;
    private var _queue as Lang.Array = [];
    private var _busy as Lang.Boolean = false;
    private var _rxBuffer as Lang.ByteArray = []b;
    private var _ticks as Lang.Number = 0;
    private var _scanSeconds as Lang.Number = 0;
    private var _scanning as Lang.Boolean = false;
    private var _needBatterySubscribe as Lang.Boolean = false;

    //! Les profils GATT ne s'enregistrent qu'une fois. La documentation
    //! presente `registerProfile` comme un appel de demarrage — « define all of
    //! the Profiles that will be used in the application » — plafonne a trois et
    //! sans operation inverse. Or `start()` est rappele a chaque deconnexion :
    //! sans ce drapeau, une lampe qui passe en veille puis se reveille en cours
    //! de sortie, le cas le plus courant, ferait un quatrieme enregistrement.
    private var _profilesRegistered as Lang.Boolean = false;

    //! Noms d'appareils vus au scan, connectes, et qui n'exposaient pas le
    //! service de la lampe. Sans cette memoire, un voisin BLE au nom proche
    //! etait appaire, rejete, retrouve au scan suivant, et ainsi de suite : la
    //! recherche tournait en boucle sans jamais atteindre la vraie lampe.
    private var _rejected as Lang.Array = [];

    //! Lampes reperees pendant la fenetre de choix en cours, la meilleure
    //! d'abord. Bornee : au-dela de quatre lampes autour de soi, la cinquieme
    //! n'apprend rien et la memoire d'un champ de donnees est comptee.
    private var _candidates as Lang.Array = [];

    //! Annonce de la lampe a laquelle on s'est connecte. Conservee parce que
    //! c'est le seul objet qui identifie un appareil : `isSameDevice()` compare
    //! des annonces, et deux exemplaires du meme modele portent le meme nom.
    private var _paired as Ble.ScanResult or Null = null;
    private var _pickSeconds as Lang.Number = 0;

    //! Identification : la lampe clignote a la connexion pour se designer
    //! elle-meme. C'est la seule reponse honnete a « laquelle de ces lampes
    //! ai-je attrapee ? » — le nom annonce est le meme d'un exemplaire a
    //! l'autre, et rien a l'ecran ne peut le dire a sa place.
    //!
    //! `-1` : pas d'identification en cours. Sinon, le numero de la demi-phase,
    //! une par battement : allumee, eteinte, allumee, eteinte, puis remise dans
    //! l'etat d'avant.
    private var _identifyStep as Lang.Number = -1;

    //! Identification decidee, mais pas encore commencee.
    //!
    //! Elle ne peut pas partir des l'etablissement de la liaison : il faut
    //! d'abord que le bilan initial revienne, pour savoir dans quel mode
    //! remettre la lampe apres le clignotement. Ce drapeau couvre cet
    //! intervalle, et `isIdentifying()` le compte comme une identification en
    //! cours.
    //!
    //! Sans lui, la page passait « prete » des la connexion, dessinait ses
    //! tuiles, puis l'identification demarrait deux ou trois secondes plus tard
    //! et **reprenait l'ecran** : tuiles, « Celle-ci ? », tuiles. Un aller-retour
    //! que rien ne justifiait, et qui donnait l'impression d'un ecran surgi pour
    //! rien — d'autant qu'on ne pouvait pas y repondre.
    private var _identifyPending as Lang.Boolean = false;

    //! Secondes ecoulees depuis le passage a READY, pour le delai de garde
    //! ci-dessous.
    private var _readySeconds as Lang.Number = 0;

    //! Au-dela de ce delai, on identifie sans attendre le bilan initial. Une
    //! lampe qui ne repond plus laissait sinon la page bloquee sur
    //! « Celle-ci ? » indefiniment, la file ne se vidant jamais.
    static const IDENTIFY_SETTLE_MAX_S = 5;
    private var _identifyMode as Lang.Number = LC.BLM_LIGHT_OFF;
    private var _restoreMode as Lang.Number or Null = null;
    private var _identifiedOnce as Lang.Boolean = false;

    // UUID convertis une fois pour toutes : appeler stringToUuid a chaque
    // notification serait du gaspillage pur.
    private var _uuidService as Ble.Uuid;
    private var _uuidTx as Ble.Uuid;
    private var _uuidRx as Ble.Uuid;
    private var _uuidBatterySvc as Ble.Uuid;
    private var _uuidBatteryLvl as Ble.Uuid;
    private var _uuidMarker as Ble.Uuid;

    function initialize() {
        BleDelegate.initialize();
        status = new LightProtocol.LightStatus();
        _uuidService    = Ble.stringToUuid(LC.SERVICE_UUID);
        _uuidTx         = Ble.stringToUuid(LC.TX_UUID);
        _uuidRx         = Ble.stringToUuid(LC.RX_UUID);
        _uuidBatterySvc = Ble.stringToUuid(LC.BATTERY_SERVICE_UUID);
        _uuidBatteryLvl = Ble.stringToUuid(LC.BATTERY_LEVEL_UUID);
        _uuidMarker     = Ble.stringToUuid(LC.ADVERT_MARKER_UUID);
    }

    //! Cadence externe, appelee une fois par seconde par le data field ou a
    //! chaque rafraichissement du widget.
    //!
    //! On evite volontairement Toybox.Timer : son usage dans un data field est
    //! mal supporte, et compute() fournit deja un battement a la seconde.
    function tick() as Void {
        _ticks++;

        // Recherche par intermittence : 15 s d'ecoute, 45 s de silence. La
        // lampe emet son advertising en continu, on la trouvera au cycle
        // suivant — au prix d'une minute d'attente au pire, contre un scan
        // permanent qui viderait le compteur sur une sortie entiere.
        if (state == STATE_SCANNING) {
            _scanSeconds++;

            // Une lampe au moins a repondu : on laisse quelques secondes aux
            // autres pour se manifester avant de choisir la plus proche.
            if (_candidates.size() > 0) {
                _pickSeconds++;
                if (_pickSeconds >= PICK_WINDOW_S
                        || (_scanning && _scanSeconds >= SCAN_WINDOW_S)) {
                    _connectToBest();
                }
                return;
            }

            if (_scanning && _scanSeconds >= SCAN_WINDOW_S) {
                _setScanning(false);
            } else if (!_scanning && _scanSeconds >= SCAN_PAUSE_S) {
                _setScanning(true);
            }
            return;
        }

        if (state != STATE_READY) { return; }

        if (_identifyStep >= 0) { _identifyTick(); return; }

        _readySeconds++;

        // Premier battement apres l'etablissement de la liaison, une fois le
        // bilan initial ecoule : la lampe a repondu son mode courant, on sait
        // donc dans quel etat la remettre apres le clignotement.
        //
        // **`status.mode != null` est la condition qui manquait.** La file vide
        // et `_busy` a faux disent seulement que *nos ecritures* sont parties ;
        // les reponses de la lampe, elles, arrivent en notification, plus tard.
        // L'identification demarrait donc avant que le mode courant ne soit
        // connu : `_restoreMode` valait `null`, et la surcouche de diagnostic
        // l'a montre en clair sur l'appareil — `m=-`, puis `m=- id`, et le
        // `m=12` n'arrivait qu'une fois le clignotement commence.
        //
        // Le delai de garde evite qu'une lampe muette — qui ne repond jamais —
        // laisse la page bloquee sur l'ecran d'identification.
        if (!_identifiedOnce
                && ((status.mode != null && !_busy && _queue.size() == 0)
                    || _readySeconds >= IDENTIFY_SETTLE_MAX_S)) {
            _identifiedOnce = true;
            _startIdentify();
            return;
        }

        if (_ticks % POLL_TICKS == 0) { send(LightProtocol.readRemainingTime()); }
    }

    private function _setScanning(on as Lang.Boolean) as Void {
        _scanning = on;
        _scanSeconds = 0;
        try {
            Ble.setScanState(on ? Ble.SCAN_STATE_SCANNING : Ble.SCAN_STATE_OFF);
        } catch (e) {
            lastError = Labels.of(Rez.Strings.ErrScanRefused);
        }
    }

    function start() as Void {
        if (!(Ble has :setScanState)) {
            state = STATE_UNSUPPORTED;
            lastError = Labels.of(Rez.Strings.ErrBleUnavailable);
            return;
        }
        Ble.setDelegate(self);
        // Les profils doivent être enregistrés avant toute connexion. On en
        // déclare deux sur les trois autorisés : le canal de commande, et le
        // service batterie standard. Une seule fois pour toute la vie de
        // l'application : voir `_profilesRegistered`.
        if (!_profilesRegistered) {
            _registerProfiles();
        }
        _candidates = [];
        _pickSeconds = 0;
        state = STATE_SCANNING;
        _setScanning(true);
    }

    private function _registerProfiles() as Void {
        try {
            Ble.registerProfile({
                :uuid => _uuidService,
                :characteristics => [
                    { :uuid => _uuidTx },
                    { :uuid => _uuidRx, :descriptors => [ Ble.cccdUuid() ] }
                ]
            });
            Ble.registerProfile({
                :uuid => _uuidBatterySvc,
                :characteristics => [
                    { :uuid => _uuidBatteryLvl, :descriptors => [ Ble.cccdUuid() ] }
                ]
            });
            _profilesRegistered = true;
        } catch (e) {
            lastError = Labels.of(Rez.Strings.ErrProfilesRefused);
        }
    }

    //! Extinction de fin d'application, puis arret.
    //!
    //! `turnOff()` suivi de `stop()` ne marchait pas : `requestWrite` est
    //! asynchrone, et `unpairDevice` coupe la liaison avant que la trame ne
    //! parte. La lampe restait allumee apres la sortie — le defaut est
    //! silencieux, on ne le voit qu'en rentrant.
    //!
    //! Ici la trame d'extinction est ecrite **directement**, en tete de file et
    //! sans attendre l'acquittement de l'ecriture en cours : il n'y aura pas de
    //! seconde suivante pour relancer la pompe. Et on ne desappaire pas : le
    //! systeme ferme la liaison en fin d'application, ce qui laisse a l'ecriture
    //! le temps de partir.
    function shutdown() as Void {
        if (isReady() && _tx != null) {
            var frame = LightProtocol.turnOff();
            _queue = [];
            if (frame.size() <= LC.MAX_WRITE) {
                try {
                    _tx.requestWrite(frame, { :writeType => Ble.WRITE_TYPE_WITH_RESPONSE });
                } catch (e) {
                    lastError = Labels.of(Rez.Strings.ErrWriteRefused);
                }
            } else {
                _busy = false;
                send(frame);
            }
        }
        if (_scanning) { _setScanning(false); }
        _queue = [];
        _busy = false;
        _rxBuffer = []b;
        state = STATE_IDLE;
    }

    function stop() as Void {
        _identifyStep = -1;
        _identifyPending = false;
        if (_scanning) { _setScanning(false); }
        if (_device != null) { Ble.unpairDevice(_device); _device = null; }
        _tx = null;
        _rx = null;
        _battery = null;
        _queue = [];
        _busy = false;
        _rxBuffer = []b;
        state = STATE_IDLE;
    }

    function isReady() as Lang.Boolean {
        return state == STATE_READY;
    }

    //! Vrai quand rien n'est en cours : ni recherche, ni liaison.
    //!
    //! C'est l'etat au repos, celui ou la page propose son bouton de mise en
    //! route. On n'y arrive que si la recherche automatique est coupee, ou si
    //! `stop()` a ete appele — jamais tout seul.
    function isIdle() as Lang.Boolean {
        return state == STATE_IDLE;
    }

    // ---- Envoi de commandes ------------------------------------------------

    //! Met une trame en file, découpée si nécessaire.
    //!
    //! Deux contraintes se cumulent : Connect IQ n'implémente pas les écritures
    //! longues (20 octets maximum), et une seule opération GATT peut être en vol
    //! à la fois. On découpe donc la trame en fragments de 20 octets, qu'on
    //! écrit l'un après l'autre — c'est aussi la taille que la lampe emploie
    //! pour ses propres notifications.
    function send(frame as Lang.ByteArray) as Void {
        if (state != STATE_READY || _tx == null) { return; }
        // Au-delà de quelques fragments en attente, c'est que la lampe ne répond
        // plus : mieux vaut jeter les plus anciens que gonfler la file.
        if (_queue.size() >= 16) { _queue = _queue.slice(4, null); }
        var offset = 0;
        while (offset < frame.size()) {
            var end = offset + LC.MAX_WRITE;
            if (end > frame.size()) { end = frame.size(); }
            _queue.add(frame.slice(offset, end));
            offset = end;
        }
        _pump();
    }

    function setMode(mode as Lang.Number) as Void {
        // Un mode que la lampe declare mais garde desactive — les deux flashs
        // de la VS1800S, sortis d'usine ainsi — ne repond pas a un simple
        // changement de mode. On l'active d'abord. L'utilisateur a touche la
        // tuile : c'est qu'il le veut, inutile de l'envoyer chercher un menu.
        if (!isModeEnabled(mode)) {
            send(LightProtocol.setModeEnabled(mode, true));
            // Anticipation optimiste, comme pour le mode lui-meme : la tuile
            // doit cesser d'etre grisee au geste, pas a la reponse.
            if (status.modeStates != null) { status.modeStates.put(mode, true); }
        }
        send(LightProtocol.setMode(mode));
    }

    //! Modes que la lampe **declare**, actives ou non. C'est cette liste que la
    //! page affiche : un mode desactive doit rester visible, grise, sinon
    //! l'utilisateur croit que sa lampe ne sait pas le faire. `supportedModes`
    //! ne garde que les actifs et sert aux automatismes.
    function declaredModes() as Lang.Array or Null {
        if (status.modeStates != null) { return status.modeStates.keys(); }
        return status.supportedModes;
    }

    //! Vrai sauf si la lampe a explicitement dit que ce mode est desactive.
    function isModeEnabled(mode as Lang.Number) as Lang.Boolean {
        if (status.modeStates == null) { return true; }
        var v = status.modeStates.get(mode);
        return !(v instanceof Lang.Boolean) || v;
    }

    function turnOff() as Void {
        send(LightProtocol.turnOff());
    }

    //! Active ou desactive un mode, puis relit la liste : la lampe est seule
    //! juge de ce qu'elle accepte, et on prefere sa reponse a notre supposition.
    function setModeEnabled(mode as Lang.Number, enabled as Lang.Boolean) as Void {
        send(LightProtocol.setModeEnabled(mode, enabled));
        send(LightProtocol.readSupportedModes());
    }

    private function _pump() as Void {
        if (_busy || _queue.size() == 0 || _tx == null) { return; }
        var frame = _queue[0];
        _queue = _queue.slice(1, null);
        try {
            _tx.requestWrite(frame, { :writeType => Ble.WRITE_TYPE_WITH_RESPONSE });
            _busy = true;
        } catch (e) {
            _busy = false;
            lastError = Labels.of(Rez.Strings.ErrWriteRefused);
        }
    }

    // ---- Découverte --------------------------------------------------------

    //! Collecte les lampes vues, sans se connecter tout de suite.
    //!
    //! La version precedente prenait la premiere venue. Avec deux lampes cote a
    //! cote — un depart de groupe, un garage a velos — c'etait un tirage au
    //! sort. On accumule maintenant les candidates pendant `PICK_WINDOW_S`, et
    //! `tick()` retient la plus proche.
    function onScanResults(scanResults as Ble.Iterator) as Void {
        if (state != STATE_SCANNING) { return; }
        for (var raw = scanResults.next(); raw != null; raw = scanResults.next()) {
            var r = raw as Ble.ScanResult;
            if (!_looksLikeLamp(r)) { continue; }
            _remember(r);
        }
    }

    //! Range une lampe parmi les candidates, la plus proche en tete.
    private function _remember(result as Ble.ScanResult) as Void {
        var rssi = result.getRssi();
        for (var i = 0; i < _candidates.size(); i++) {
            var known = _candidates[i] as Ble.ScanResult;
            // Le meme appareil revu : on garde la mesure la plus recente, la
            // puissance recue variant d'une annonce a l'autre.
            if (result.isSameDevice(known)) {
                _candidates[i] = result;
                _sortCandidates();
                return;
            }
        }
        if (_candidates.size() >= 4) { return; }
        _candidates.add(result);
        _sortCandidates();
        // Un signal beaucoup plus fort que les autres, c'est la lampe posee sur
        // le guidon : inutile de faire attendre l'utilisateur.
        if (rssi > -45 && _candidates.size() == 1) { _pickSeconds = PICK_WINDOW_S - 1; }
    }

    private function _sortCandidates() as Void {
        // Tri par insertion, du signal le plus fort au plus faible. Quatre
        // elements au plus : l'algorithme n'a aucune importance, la lisibilite
        // si.
        for (var i = 1; i < _candidates.size(); i++) {
            var j = i;
            while (j > 0
                   && (_candidates[j] as Ble.ScanResult).getRssi()
                      > (_candidates[j - 1] as Ble.ScanResult).getRssi()) {
                var tmp = _candidates[j];
                _candidates[j] = _candidates[j - 1];
                _candidates[j - 1] = tmp;
                j--;
            }
        }
    }

    //! Nombre de lampes vues pendant la recherche en cours. Affiche a
    //! l'identification : savoir qu'il y en avait trois change le regard qu'on
    //! porte sur celle qui clignote.
    function nearbyCount() as Lang.Number {
        return _candidates.size();
    }

    private function _connectToBest() as Void {
        if (_candidates.size() == 0) { return; }
        var best = _candidates[0] as Ble.ScanResult;
        _paired = best;
        _setScanning(false);
        state = STATE_CONNECTING;
        _pickSeconds = 0;
        _device = Ble.pairDevice(best);
    }

    //! Reconnaît la lampe à son marqueur d'advertising, à défaut à son nom.
    //! Le marqueur est le critère fiable ; le nom sert de filet pour les modèles
    //! qui n'en annonceraient pas.
    private function _looksLikeLamp(result as Ble.ScanResult) as Lang.Boolean {
        if (_isRejected(result)) { return false; }
        var name = result.getDeviceName();

        var advertised = result.getServiceUuids();
        for (var raw = advertised.next(); raw != null; raw = advertised.next()) {
            if ((raw as Ble.Uuid).equals(_uuidMarker)) { return true; }
        }
        return nameLooksLikeLamp(name);
    }

    //! Un nom peut-il être celui d'une lampe iGPSPORT ?
    //!
    //! Chercher « VS » ou « TL » n'importe où dans le nom était bien trop
    //! large : un capteur « Wahoo TICKR », un « TL » dans « BONTRAGER
    //! FLARE RT », n'importe quel voisin en salle, tout passait. Les lampes de
    //! la marque s'annoncent « VS1800S », « TL30 » : deux lettres en tête, puis
    //! un chiffre. On exige donc ce motif, en plus du nom de marque complet.
    static function nameLooksLikeLamp(name as Lang.String or Null) as Lang.Boolean {
        if (name == null) { return false; }
        var upper = name.toUpper();
        if (upper.find("IGPSPORT") != null) { return true; }
        var prefix = (upper.substring(0, 2) == null) ? "" : upper.substring(0, 2);
        if (!prefix.equals("VS") && !prefix.equals("TL")) { return false; }
        // Troisieme caractere : un chiffre, sinon ce n'est pas une reference.
        var third = upper.substring(2, 3);
        if (third == null) { return false; }
        return (third as Lang.String).toNumber() != null;
    }

    //! Vrai si cet appareil a déjà été essayé et écarté.
    //!
    //! La comparaison porte sur l'appareil, pas sur son nom : deux exemplaires
    //! du meme modele s'annoncent « VS1800S » tous les deux, et ecarter l'un
    //! par son nom ecarterait aussi l'autre — celui qu'on cherche, justement.
    private function _isRejected(result as Ble.ScanResult) as Lang.Boolean {
        for (var i = 0; i < _rejected.size(); i++) {
            if (result.isSameDevice(_rejected[i] as Ble.ScanResult)) { return true; }
        }
        return false;
    }

    private function _reject(result as Ble.ScanResult or Null) as Void {
        if (result == null || _isRejected(result)) { return; }
        // Plafonnee : une liste qui grossit sans fin sur une sortie de six
        // heures finirait par peser sur les 128 Ko du champ de donnees.
        if (_rejected.size() >= 6) { _rejected = _rejected.slice(1, null); }
        _rejected.add(result);
    }

    //! Ecarte la lampe connectee et repart en recherche.
    //!
    //! C'est la sortie de secours de l'identification : le clignotement montre
    //! une lampe qui n'est pas la sienne, on demande la suivante. Sans elle,
    //! savoir que la lampe est la mauvaise ne servirait a rien.
    function forgetCurrentLamp() as Void {
        _reject(_paired);
        _identifyStep = -1;
        _identifyPending = false;
        _identifiedOnce = false;
        if (_device != null) {
            try { Ble.unpairDevice(_device); } catch (e) { }
            _device = null;
        }
        _paired = null;
        _tx = null;
        _rx = null;
        _battery = null;
        _queue = [];
        _busy = false;
        _rxBuffer = []b;
        status = new LightProtocol.LightStatus();
        start();
    }

    function onProfileRegister(uuid as Ble.Uuid, regStatus as Ble.Status) as Void {
        if (regStatus != Ble.STATUS_SUCCESS) {
            lastError = Labels.of(Rez.Strings.ErrProfileRegister);
        }
    }

    function onConnectedStateChanged(device as Ble.Device,
                                     connectionState as Ble.ConnectionState) as Void {
        if (connectionState != Ble.CONNECTION_STATE_CONNECTED) {
            _tx = null;
            _rx = null;
            _battery = null;
            _busy = false;
            _queue = [];
            _rxBuffer = []b;
            _needBatterySubscribe = false;
            _identifyStep = -1;
            _identifyPending = false;
            // Desappairer avant de rechercher : l'ancienne liaison compte
            // encore pour la pile BLE du compteur, et la lampe qui se reveille
            // annonce une nouvelle session. Sans ca, le second appairage se
            // faisait par-dessus le premier.
            if (_device != null) {
                try { Ble.unpairDevice(_device); } catch (e) { }
                _device = null;
            }
            if (state != STATE_IDLE && state != STATE_UNSUPPORTED) { start(); }
            return;
        }

        _device = device;
        var service = device.getService(_uuidService);
        if (service == null) {
            // Ce n'était pas une lampe : on retient son nom pour ne pas la
            // reprendre au scan suivant, et on relance la recherche.
            lastError = Labels.of(Rez.Strings.ErrServiceMissing);
            _reject(_paired);
            Ble.unpairDevice(device);
            _device = null;
            start();
            return;
        }
        _tx = service.getCharacteristic(_uuidTx);
        _rx = service.getCharacteristic(_uuidRx);
        if (_tx == null || _rx == null) {
            lastError = Labels.of(Rez.Strings.ErrCharsMissing);
            return;
        }

        // La batterie est aussi exposée par le service standard 0x180F, notifié
        // spontanément : plus simple et plus fiable que le chemin propriétaire.
        var batteryService = device.getService(_uuidBatterySvc);
        if (batteryService != null) {
            _battery = batteryService.getCharacteristic(_uuidBatteryLvl);
        }

        // Sans écriture du CCCD, la lampe n'enverra aucune notification : c'est
        // l'oubli classique, et il est silencieux.
        var cccd = _rx.getDescriptor(Ble.cccdUuid());
        if (cccd == null) {
            lastError = Labels.of(Rez.Strings.ErrCccdMissing);
            return;
        }
        state = STATE_SUBSCRIBING;
        cccd.requestWrite([0x01, 0x00]b);
    }

    function onDescriptorWrite(descriptor as Ble.Descriptor,
                               writeStatus as Ble.Status) as Void {
        if (writeStatus != Ble.STATUS_SUCCESS) {
            lastError = Labels.of(Rez.Strings.ErrSubscribeRefused);
        }
        if (state != STATE_SUBSCRIBING) { return; }

        // On passe a READY des que le canal de commande est abonne. L'abonnement
        // a la batterie est facultatif : le chainer ici bloquait tout l'etat
        // « Connexion » s'il echouait ou restait sans reponse.
        state = STATE_READY;
        _busy = false;
        _needBatterySubscribe = (_battery != null);
        _readySeconds = 0;
        // L'identification est decidee **ici**, pas quand elle demarre : la page
        // enchaine ainsi « Connexion » et « Celle-ci ? » sans montrer ses tuiles
        // entre les deux, pour les reprendre aussitot. Voir `_identifyPending`.
        _identifyPending = !_identifiedOnce;

        // Premier bilan : ce que la lampe sait faire, ou elle en est.
        send(LightProtocol.readSelf());
        send(LightProtocol.readSupportedModes());
        send(LightProtocol.readCurrentMode());
        send(LightProtocol.readSmartConfig());
        send(LightProtocol.readRemainingTime());
    }

    //! Applique un automatisme et met a jour l'etat local sans attendre la
    //! confirmation : le menu doit repondre au geste immediatement.
    //!
    //! Le parametre s'appelle `value` et non `status` : ce dernier nom est deja
    //! celui de l'etat de la lampe, et le masquer casserait tout.
    function setSmartConfig(config as Lang.Number, value as Lang.Number) as Void {
        send(LightProtocol.setSmartConfig(config, value));
        if (status.configs == null) { status.configs = {}; }
        status.configs.put(config, value);
    }

    // ---- Identification ----------------------------------------------------

    //! Vrai pendant que la lampe clignote pour se designer.
    function isIdentifying() as Lang.Boolean {
        return _identifyStep >= 0 || _identifyPending;
    }

    //! Vrai pendant l'attente qui precede le clignotement, pas pendant celui-ci.
    //!
    //! Sert a annoncer ce qui va se passer avant que ca se passe : « votre lampe
    //! va clignoter », puis « votre lampe clignote ». Sans cette distinction, le
    //! compteur affirmait un clignotement une a deux secondes avant qu'il ne
    //! commence, et l'utilisateur regardait une lampe eteinte en se demandant ce
    //! qu'il devait voir.
    function isIdentifyAnnounced() as Lang.Boolean {
        return _identifyPending && _identifyStep < 0;
    }

    //! Abandonne l'identification et remet la lampe comme on l'a trouvee.
    //!
    //! Appelee sur une tape. L'ecran « Celle-ci ? » posait une question sans
    //! offrir de reponse : la tape y etait avalee sans effet, et il n'y avait
    //! qu'a attendre. Une tape veut dire « c'est bon, j'ai vu » — on abrege.
    function cancelIdentify() as Void {
        _identifyPending = false;
        if (_identifyStep < 0) { return; }
        _identifyStep = -1;
        var back = (_restoreMode == null) ? LC.BLM_LIGHT_OFF : _restoreMode;
        send(LightProtocol.setMode(back));
        send(LightProtocol.readCurrentMode());
    }

    //! Vrai quand la phase en cours allume la lampe. L'ecran affiche un
    //! pictogramme au meme rythme : c'est ce qui fait le lien entre ce qu'on
    //! voit sur le guidon et ce qu'on lit sur le compteur.
    function identifyLit() as Lang.Boolean {
        return _identifyStep >= 0 && _identifyStep % 2 == 0;
    }

    //! Lance le clignotement d'identification, si le moment s'y prete.
    //!
    //! Une seule fois par session, et **jamais chrono demarre** : faire
    //! clignoter le phare de quelqu'un qui roule de nuit, a chaque reconnexion
    //! apres une mise en veille, serait dangereux. L'identification a sa place
    //! avant le depart, quand on verifie son materiel.
    private function _startIdentify() as Void {
        // En premier, et sans condition : les sorties ci-dessous laissaient
        // sinon la page sur l'ecran d'identification pour toujours.
        _identifyPending = false;
        if (_tx == null || !_identifyPermitted()) { return; }

        // **Une seule lampe a portee : on n'y touche pas.**
        //
        // Le clignotement repond a « laquelle de ces lampes ai-je attrapee ? ».
        // Quand il n'y en a qu'une, la question ne se pose pas, et le prix est
        // eleve : allumer la lampe est le seul geste que l'application fasse
        // sans qu'on le lui demande.
        //
        // Or ce prix s'est revele plus lourd que prevu. Mesure sur l'appareil :
        // une VS1800S **eteinte au bouton** annonce `curMode = 12` — croisement
        // faible, son mode memorise — exactement comme une lampe allumee en
        // croisement faible. Aucun des dix sous-services ne dit si elle eclaire,
        // et `blt_light_self` ne porte que le type et le nombre de lampes.
        // L'application ne peut donc pas savoir qu'elle est eteinte : elle
        // relevait `_restoreMode = 12`, clignotait, puis « restaurait » le mode
        // 12 — et rallumait une lampe que l'utilisateur venait d'eteindre.
        //
        // Avec plusieurs lampes autour, l'utilisateur est en train de les
        // demeler et un bref allumage est ce qu'il attend. Avec une seule, non.
        if (nearbyCount() <= 1) { return; }

        // On retient l'etat d'avant pour le remettre : l'utilisateur avait
        // peut-etre deja allume sa lampe a la main.
        _restoreMode = status.mode;
        var ladder = LC.ladderFor(status.supportedModes, status.lightType);
        // Un cran intermediaire : assez visible en plein jour, sans envoyer le
        // plein phare dans les yeux de celui qui se penche sur sa lampe.
        _identifyMode = ladder[ladder.size() / 2] as Lang.Number;

        _identifyStep = 0;
        send(LightProtocol.setMode(_identifyMode));
    }

    //! Un battement du clignotement. Appele par `tick()`, donc une fois par
    //! seconde : deux clignotements durent quatre secondes.
    private function _identifyTick() as Void {
        _identifyStep++;
        var last = 2 * IDENTIFY_BLINKS;
        if (_identifyStep >= last) {
            _identifyStep = -1;
            // Remise dans l'etat d'avant. Un mode inconnu — la lampe n'avait pas
            // encore repondu — vaut « eteinte » : c'est l'etat ou on l'a
            // trouvee, puisqu'elle n'eclairait pas.
            var back = (_restoreMode == null) ? LC.BLM_LIGHT_OFF : _restoreMode;
            send(LightProtocol.setMode(back));
            send(LightProtocol.readCurrentMode());
            return;
        }
        var next = identifyModeAt(_identifyStep, _identifyMode);
        if (next != null) { send(LightProtocol.setMode(next as Lang.Number)); }
    }

    //! Mode de la phase `step` du clignotement, ou `null` quand la sequence est
    //! terminee. Sortie a part pour etre verifiable sans lampe ni liaison.
    static function identifyModeAt(step as Lang.Number,
                                   lit as Lang.Number) as Lang.Number or Null {
        if (step < 0 || step >= 2 * IDENTIFY_BLINKS) { return null; }
        return (step % 2 == 0) ? lit : LC.BLM_LIGHT_OFF;
    }

    //! Vrai tant que l'activite n'a pas demarre.
    //!
    //! `Activity.getActivityInfo()` est lisible depuis les deux binaires, ce qui
    //! evite de confier la regle a chaque appelant — le widget ne saurait pas
    //! qu'une activite tourne.
    private function _identifyPermitted() as Lang.Boolean {
        try {
            var info = Activity.getActivityInfo();
            if (info == null) { return true; }
            var ts = info.timerState;
            return ts == null || ts == Activity.TIMER_STATE_OFF;
        } catch (e) {
            return true;
        }
    }

    // ---- Réception ---------------------------------------------------------

    function onCharacteristicWrite(characteristic as Ble.Characteristic,
                                   writeStatus as Ble.Status) as Void {
        _busy = false;
        if (writeStatus != Ble.STATUS_SUCCESS) { lastError = Labels.of(Rez.Strings.ErrWriteFailed); }
        _pump();

        // Une fois la file videe, on s'abonne a la batterie standard — en
        // supplement du chemin proprietaire, jamais en prealable.
        if (!_busy && _needBatterySubscribe && _battery != null) {
            _needBatterySubscribe = false;
            try {
                var cccd = _battery.getDescriptor(Ble.cccdUuid());
                if (cccd != null) { cccd.requestWrite([0x01, 0x00]b); }
            } catch (e) {
                lastError = Labels.of(Rez.Strings.ErrBatterySubscribe);
            }
        }
    }

    function onCharacteristicChanged(characteristic as Ble.Characteristic,
                                     value as Lang.ByteArray) as Void {
        var uuid = characteristic.getUuid();

        // Service batterie standard : un seul octet, le pourcentage.
        if (uuid.equals(_uuidBatteryLvl)) {
            if (value.size() >= 1) { status.batteryPct = value[0]; }
            return;
        }
        if (!uuid.equals(_uuidRx)) { return; }

        // La lampe fragmente ses réponses par 20 octets, quel que soit le MTU
        // négocié : il faut réassembler avant de décoder.
        _rxBuffer = _rxBuffer.addAll(value);

        // Plusieurs trames peuvent s'enchaîner dans le tampon : on les traite
        // toutes, sinon un état spontané resterait coincé derrière une réponse.
        while (_rxBuffer.size() >= LC.HDR_LEN) {
            var expected = LightProtocol.frameLength(_rxBuffer);
            if (_rxBuffer.size() < expected) { return; }
            var frame = _rxBuffer.slice(0, expected);
            _rxBuffer = _rxBuffer.slice(expected, null);
            _apply(LightProtocol.parseFrame(frame));
        }
    }

    //! Fusionne un état reçu dans l'état courant. Une notification ne porte
    //! qu'un champ : elle ne doit pas effacer ce que les précédentes ont appris.
    private function _apply(incoming as LightProtocol.LightStatus or Null) as Void {
        if (incoming == null) { return; }       // trame illisible : on l'ignore
        if (incoming.mode != null) { status.mode = incoming.mode; }
        if (incoming.batteryPct != null) { status.batteryPct = incoming.batteryPct; }
        if (incoming.remainingMinutes != null) {
            status.remainingMinutes = incoming.remainingMinutes;
        }
        if (incoming.lightType != null) { status.lightType = incoming.lightType; }
        if (incoming.configs != null) {
            if (status.configs == null) {
                status.configs = incoming.configs;
            } else {
                var keys = incoming.configs.keys();
                for (var i = 0; i < keys.size(); i++) {
                    status.configs.put(keys[i], incoming.configs.get(keys[i]));
                }
            }
        }
        if (incoming.modeStates != null) { status.modeStates = incoming.modeStates; }
        if (incoming.supportedModes != null) {
            if (status.supportedModes == null) {
                status.supportedModes = incoming.supportedModes;
            } else {
                var merged = status.supportedModes;
                for (var i = 0; i < incoming.supportedModes.size(); i++) {
                    var m = incoming.supportedModes[i];
                    if (merged.indexOf(m) < 0) { merged.add(m); }
                }
                status.supportedModes = merged;
            }
        }
    }

    //! Etat de la liaison en un mot, pour le bandeau.
    //!
    //! L'abonnement aux notifications ne merite pas une etape a lui : c'est un
    //! detail de protocole, et l'utilisateur n'a aucun geste a faire pendant ce
    //! temps. Il est fondu dans « Connexion ». Deux etapes, pas quatre.
    function stateLabel() as Lang.String {
        switch (state) {
            case STATE_IDLE:        return "--";
            case STATE_SCANNING:    return Labels.of(Rez.Strings.StScanning);
            case STATE_CONNECTING:  return Labels.of(Rez.Strings.StConnecting);
            case STATE_SUBSCRIBING: return Labels.of(Rez.Strings.StConnecting);
            case STATE_READY:       return Labels.of(Rez.Strings.StReady);
            case STATE_UNSUPPORTED: return Labels.of(Rez.Strings.StUnsupported);
        }
        return "?";
    }

    //! Phase de l'animation d'attente, de 0 a 2, avancant a chaque battement.
    //! Le seul mouvement de l'ecran de recherche : sans lui, une minute
    //! d'attente ressemble a un plantage.
    function pulse() as Lang.Number {
        return _ticks % 3;
    }

    //! L'etape en un mot, pour l'ecran d'attente.
    //!
    //! Un mot, pas une phrase : c'est lui qui s'affiche en gros, et une phrase
    //! entiere y aurait impose une police minuscule sur un Edge 1050 — beaucoup
    //! de noir autour d'un texte illisible. Le sens du mot est porte par
    //! `stateHint()`, en dessous et en plus petit.
    function stateMessage() as Lang.String {
        if (isIdle()) { return Labels.of(Rez.Strings.MsgIdle); }
        if (isIdentifying()) { return Labels.of(Rez.Strings.MsgIdentify); }
        switch (state) {
            case STATE_CONNECTING:
            case STATE_SUBSCRIBING: return Labels.of(Rez.Strings.MsgConnecting);
            case STATE_UNSUPPORTED: return Labels.of(Rez.Strings.MsgNoBle);
        }
        return Labels.of(Rez.Strings.MsgSearching);
    }

    //! La ligne de precision, sous le mot d'etape.
    //!
    //! Une panne passe avant tout : c'est la seule information qui appelle un
    //! geste. Vient ensuite le nombre de lampes vues — savoir qu'il y en avait
    //! trois autour change le regard qu'on porte sur celle qui clignote.
    function stateHint() as Lang.String {
        if (isIdle()) { return Labels.of(Rez.Strings.MsgIdleHint); }
        if (lastError != null && !isReady()) { return lastError as Lang.String; }
        if (isIdentifying()) {
            // L'annonce prime sur le decompte : dire « va clignoter » avant que
            // la lampe ne bouge est ce qui rend la seconde qui suit lisible.
            if (isIdentifyAnnounced()) {
                return Labels.of(Rez.Strings.MsgIdentifySoon);
            }
            var n = nearbyCount();
            if (n > 1) { return n.format("%d") + Labels.of(Rez.Strings.MsgNearby); }
            return Labels.of(Rez.Strings.MsgIdentifyHint);
        }
        switch (state) {
            case STATE_CONNECTING:
            case STATE_SUBSCRIBING: return Labels.of(Rez.Strings.MsgConnectingHint);
            case STATE_UNSUPPORTED: return Labels.of(Rez.Strings.MsgNoBleHint);
        }
        return Labels.of(Rez.Strings.MsgSearchingHint);
    }

    //! Le plus long des mots d'etape, et la plus longue des precisions.
    //!
    //! Ce sont eux qui servent a choisir la police, jamais le texte affiche :
    //! sinon « Connexion » s'ecrivait plus gros que « Recherche », et le texte
    //! changeait de corps a chaque etape. C'etait le defaut le plus visible de
    //! l'ecran d'attente.
    static function longestStateMessage() as Lang.String {
        return _longest([ Rez.Strings.MsgSearching, Rez.Strings.MsgConnecting,
                          Rez.Strings.MsgIdentify, Rez.Strings.MsgNoBle,
                          Rez.Strings.MsgIdle ]);
    }

    static function longestStateHint() as Lang.String {
        return _longest([ Rez.Strings.MsgSearchingHint, Rez.Strings.MsgConnectingHint,
                          Rez.Strings.MsgIdentifyHint, Rez.Strings.MsgNoBleHint,
                          Rez.Strings.MsgIdleHint ]);
    }

    private static function _longest(ids as Lang.Array) as Lang.String {
        var longest = "";
        for (var i = 0; i < ids.size(); i++) {
            var text = Labels.of(ids[i] as Lang.ResourceId);
            if (text.length() > longest.length()) { longest = text; }
        }
        return longest;
    }
}
