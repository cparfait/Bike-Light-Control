using Toybox.Lang;

//! CRC-8/MAXIM, celui de Dallas / 1-Wire.
//!
//! Utilisé deux fois dans l'en-tête de transport de la lampe : sur la charge
//! utile (octet 9) et sur l'en-tête lui-même (octet 19).
//!
//! Paramètres : polynôme 0x31 réfléchi — soit 0x8C en décalage à droite —,
//! init 0x00, entrée et sortie réfléchies, pas de XOR final. Identifié par
//! recherche exhaustive sur les 256 polynômes, puis vérifié sur les 44 trames
//! de la capture du 08/09/2026 : 44 correspondances sur 44.
module Crc8 {

    //! Implémentation par décalage à droite : le polynôme réfléchi (0x8C)
    //! évite d'avoir à retourner chaque octet, ce qui compte sur un Edge.
    function maxim(data as Lang.ByteArray) as Lang.Number {
        var crc = 0;
        for (var i = 0; i < data.size(); i++) {
            crc = crc ^ data[i];
            for (var b = 0; b < 8; b++) {
                if ((crc & 0x01) != 0) {
                    crc = ((crc >> 1) ^ 0x8C) & 0xFF;
                } else {
                    crc = (crc >> 1) & 0xFF;
                }
            }
        }
        return crc;
    }
}
