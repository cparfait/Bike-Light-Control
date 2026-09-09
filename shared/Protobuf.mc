using Toybox.Lang;

//! Encodage et décodage protobuf minimal, suffisant pour le protocole des
//! lampes iGPSPORT.
//!
//! Il n'existe pas de bibliothèque protobuf pour Connect IQ. Les messages de la
//! lampe n'utilisent que des varints et des sous-messages : on n'implémente donc
//! que ces deux types de fil, et rien d'autre.
//!
//! Voir docs/protocole-vs1800s.md §4 pour le schéma.
module Protobuf {

    //! Types de fil protobuf effectivement rencontrés.
    const WIRE_VARINT = 0;
    const WIRE_LENGTH = 2;

    //! Encode un entier non signé en varint (base 128, petit-boutiste,
    //! bit 7 à 1 tant qu'il reste des octets).
    //!
    //! Les valeurs négatives sont refusées : protobuf les encoderait sur dix
    //! octets en complément à deux, ce dont le protocole de la lampe n'a pas
    //! l'usage. Mieux vaut une erreur franche qu'une trame silencieusement fausse.
    function encodeVarint(value as Lang.Number) as Lang.ByteArray {
        if (value < 0) {
            throw new Lang.InvalidValueException("varint negatif: " + value);
        }
        var out = []b;
        var v = value;
        while (true) {
            var b = v & 0x7F;
            v = v >> 7;
            if (v == 0) {
                out.add(b);
                return out;
            }
            out.add(b | 0x80);
        }
        return out;   // inatteignable, mais le compilateur exige une sortie
    }

    //! Décode un varint à partir de `offset`.
    //! Retourne `[valeur, offset suivant]`, ou `null` si la trame est tronquée.
    function decodeVarint(bytes as Lang.ByteArray, offset as Lang.Number) as Lang.Array or Null {
        var result = 0;
        var shift = 0;
        var i = offset;
        while (i < bytes.size()) {
            var b = bytes[i];
            i++;
            result = result | ((b & 0x7F) << shift);
            if ((b & 0x80) == 0) {
                return [result, i];
            }
            shift += 7;
            if (shift > 28) {
                // Au-delà de 32 bits on sortirait du domaine des Number.
                return null;
            }
        }
        return null;
    }

    //! Octet de tag : numéro de champ et type de fil.
    function tag(field as Lang.Number, wireType as Lang.Number) as Lang.ByteArray {
        return encodeVarint((field << 3) | wireType);
    }

    //! Champ scalaire (enum, int32, bool) encodé en varint.
    function varintField(field as Lang.Number, value as Lang.Number) as Lang.ByteArray {
        return tag(field, WIRE_VARINT).addAll(encodeVarint(value));
    }

    //! Champ sous-message : tag, longueur, puis contenu.
    function messageField(field as Lang.Number, payload as Lang.ByteArray) as Lang.ByteArray {
        return tag(field, WIRE_LENGTH)
            .addAll(encodeVarint(payload.size()))
            .addAll(payload);
    }

    //! Décompose un message en dictionnaire `numéro de champ => valeur`.
    //!
    //! Les varints donnent un `Number`, les champs à longueur préfixée un
    //! `ByteArray` (à re-parser pour un sous-message). Les champs répétés ne
    //! conservent que la dernière occurrence : le protocole de la lampe n'en
    //! utilise que pour les listes de modes supportés, traitées à part.
    //!
    //! Retourne `null` si la trame est malformée — jamais un résultat partiel,
    //! qu'on interpréterait à tort comme un état valide de la lampe.
    function parse(bytes as Lang.ByteArray) as Lang.Dictionary or Null {
        var fields = {};
        var i = 0;
        var size = bytes.size();
        while (i < size) {
            var t = decodeVarint(bytes, i);
            if (t == null) { return null; }
            var key = t[0];
            i = t[1];

            var field = key >> 3;
            var wire = key & 0x07;

            if (wire == WIRE_VARINT) {
                var v = decodeVarint(bytes, i);
                if (v == null) { return null; }
                fields.put(field, v[0]);
                i = v[1];
            } else if (wire == WIRE_LENGTH) {
                var l = decodeVarint(bytes, i);
                if (l == null) { return null; }
                var len = l[0];
                i = l[1];
                if (i + len > size) { return null; }
                fields.put(field, bytes.slice(i, i + len));
                i += len;
            } else {
                // Type de fil inattendu : on ne sait pas de combien avancer,
                // donc on ne peut pas continuer sans risquer de tout décaler.
                return null;
            }
        }
        return fields;
    }

    //! Collecte **toutes** les occurrences d'un champ à longueur préfixée.
    //!
    //! `parse()` ne garde que la dernière occurrence d'un champ répété, ce qui
    //! convient aux messages simples mais perdrait la liste des modes supportés
    //! par la lampe — précisément ce qui permet à l'app de s'adapter à un modèle
    //! qu'on n'a pas en main.
    //!
    //! Retourne `null` si la trame est malformée, un tableau vide si le champ
    //! est absent.
    function parseRepeated(bytes as Lang.ByteArray,
                           field as Lang.Number) as Lang.Array or Null {
        var found = [];
        var i = 0;
        var size = bytes.size();
        while (i < size) {
            var t = decodeVarint(bytes, i);
            if (t == null) { return null; }
            var key = t[0];
            i = t[1];
            var wire = key & 0x07;

            if (wire == WIRE_VARINT) {
                var v = decodeVarint(bytes, i);
                if (v == null) { return null; }
                i = v[1];
            } else if (wire == WIRE_LENGTH) {
                var l = decodeVarint(bytes, i);
                if (l == null) { return null; }
                var len = l[0];
                i = l[1];
                if (i + len > size) { return null; }
                if ((key >> 3) == field) {
                    found.add(bytes.slice(i, i + len));
                }
                i += len;
            } else {
                return null;
            }
        }
        return found;
    }

    //! Lit un champ varint d'un message déjà décomposé, avec valeur par défaut.
    //!
    //! Indispensable : protobuf n'émet pas les champs valant leur valeur par
    //! défaut. Un champ absent vaut 0, il ne signifie pas « inconnu ».
    function getVarint(fields as Lang.Dictionary, field as Lang.Number,
                       fallback as Lang.Number) as Lang.Number {
        var v = fields.get(field);
        if (v instanceof Lang.Number) { return v; }
        return fallback;
    }

    //! Lit un champ sous-message et le décompose à son tour.
    function getMessage(fields as Lang.Dictionary, field as Lang.Number) as Lang.Dictionary or Null {
        var v = fields.get(field);
        if (v instanceof Lang.ByteArray) { return parse(v); }
        return null;
    }
}
