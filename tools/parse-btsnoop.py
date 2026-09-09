#!/usr/bin/env python3
"""
Dépouille un journal Bluetooth HCI snoop : advertising, connexions, table GATT
et trafic ATT.

    python tools/parse-btsnoop.py <btsnoop_hci.log> [--addr C7:C6] [--all]

Écrit pour éviter d'installer Wireshark : le format btsnoop est trivial, et on
n'a besoin que d'une poignée de couches (HCI, ACL, L2CAP, ATT). En prime, la
sortie est directement reportable dans docs/protocole-vs1800s.md.

`--addr` filtre sur une adresse ou un suffixe d'adresse (Android masque le début
des adresses dans ses journaux, mais pas dans le HCI snoop).
`--all` affiche tout le trafic ATT plutôt que le seul résumé.
"""

import io
import os
import struct
import sys
from datetime import datetime, timedelta

# Le temps btsnoop compte les microsecondes depuis le 1er janvier de l'an 0.
EPOCH_DELTA_US = 0x00DCDDB30F2F8000

# La console Windows est en cp1252 : sans ça, un accent suffit à faire planter
# l'affichage du rapport.
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

ATT_OPCODES = {
    0x01: "Error Response",
    0x02: "Exchange MTU Request",
    0x03: "Exchange MTU Response",
    0x04: "Find Information Request",
    0x05: "Find Information Response",
    0x08: "Read By Type Request",
    0x09: "Read By Type Response",
    0x0A: "Read Request",
    0x0B: "Read Response",
    0x10: "Read By Group Type Request",
    0x11: "Read By Group Type Response",
    0x12: "Write Request",
    0x13: "Write Response",
    0x1B: "Notification",
    0x1D: "Indication",
    0x1E: "Confirmation",
    0x52: "Write Command",
}

# Caractéristiques et services standard rencontrés, pour lire la table sans
# aller chercher la spécification.
KNOWN_UUID = {
    "1800": "Generic Access",
    "1801": "Generic Attribute",
    "180A": "Device Information",
    "180F": "Battery Service",
    "2800": "Primary Service",
    "2801": "Secondary Service",
    "2803": "Characteristic",
    "2901": "Characteristic User Description",
    "2902": "Client Characteristic Configuration",
    "2A00": "Device Name",
    "2A19": "Battery Level",
    "2A26": "Firmware Revision String",
    "2A27": "Hardware Revision String",
    "2A28": "Software Revision String",
    "2A29": "Manufacturer Name String",
    "6E400001-B5A3-F393-E0A9-E50E24DCCA9E": "Nordic UART Service",
    "6E400002-B5A3-F393-E0A9-E50E24DCCA9E": "NUS TX (ecriture)",
    "6E400003-B5A3-F393-E0A9-E50E24DCCA9E": "NUS RX (notification)",
}

CHAR_PROPS = [
    (0x01, "Broadcast"), (0x02, "Read"), (0x04, "WriteNoResp"), (0x08, "Write"),
    (0x10, "Notify"), (0x20, "Indicate"), (0x40, "SignedWrite"), (0x80, "Extended"),
]


def hexs(b):
    return " ".join(f"{x:02X}" for x in b)


def addr_str(b):
    return ":".join(f"{x:02X}" for x in reversed(b))


def uuid_str(b):
    """UUID en little-endian tel qu'il circule sur le fil."""
    if len(b) == 2:
        return f"{b[1]:02X}{b[0]:02X}"
    if len(b) == 4:
        return f"{b[3]:02X}{b[2]:02X}{b[1]:02X}{b[0]:02X}"
    if len(b) == 16:
        r = bytes(reversed(b))
        return (f"{r[0:4].hex().upper()}-{r[4:6].hex().upper()}-{r[6:8].hex().upper()}"
                f"-{r[8:10].hex().upper()}-{r[10:16].hex().upper()}")
    return b.hex().upper()


def name_of(u):
    return KNOWN_UUID.get(u, "")


def props_str(p):
    return "/".join(n for bit, n in CHAR_PROPS if p & bit) or "-"


def records(path):
    with open(path, "rb") as f:
        head = f.read(16)
        if head[:8] != b"btsnoop\x00":
            sys.exit("Ce n'est pas un fichier btsnoop.")
        _ver, datalink = struct.unpack(">II", head[8:16])
        while True:
            hdr = f.read(24)
            if len(hdr) < 24:
                return
            _olen, ilen, flags, _drops, ts = struct.unpack(">IIIIq", hdr)
            data = f.read(ilen)
            if len(data) < ilen:
                return
            yield flags, ts, data, datalink


def parse_ad(data):
    """Champs AD d'un rapport d'advertising -> (nom, [uuids])."""
    name, uuids = None, []
    i = 0
    while i + 1 < len(data):
        ln = data[i]
        if ln == 0 or i + 1 + ln > len(data):
            break
        typ = data[i + 1]
        val = data[i + 2: i + 1 + ln]
        if typ in (0x08, 0x09):                      # nom court / complet
            name = val.decode("utf-8", "replace")
        elif typ in (0x02, 0x03):                    # UUID 16 bits
            for k in range(0, len(val) - 1, 2):
                uuids.append(uuid_str(val[k:k + 2]))
        elif typ in (0x06, 0x07):                    # UUID 128 bits
            for k in range(0, len(val) - 15, 16):
                uuids.append(uuid_str(val[k:k + 16]))
        i += 1 + ln
    return name, uuids


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    opts = [a for a in sys.argv[1:] if a.startswith("--")]
    if not args:
        sys.exit("usage: python tools/parse-btsnoop.py <btsnoop_hci.log> [--addr XX:XX] [--all]")
    path = args[0]
    want_addr = None
    for o in opts:
        if o.startswith("--addr"):
            want_addr = (o.split("=", 1)[1] if "=" in o else args[1]).upper()
    show_all = "--all" in opts

    adverts = {}          # addr -> (nom, {uuids})
    handles = {}          # handle de connexion -> addr
    assembling = {}       # handle -> tampon de réassemblage ACL
    gatt = {}             # addr -> {"services": [], "chars": [], "descs": []}
    traffic = []          # (ts, addr, sens, opcode, handle att, valeur)
    mtu = {}

    for flags, ts, data, datalink in records(path):
        if not data:
            continue
        received = bool(flags & 0x01)
        # Datalink 1002 = H4 : le premier octet donne le type de paquet HCI.
        ptype, body = (data[0], data[1:]) if datalink == 1002 else (None, data)
        when = datetime(1, 1, 1) + timedelta(microseconds=ts - EPOCH_DELTA_US + 62135596800000000)

        if ptype == 0x04:                             # HCI Event
            if len(body) < 2:
                continue
            code, plen = body[0], body[1]
            p = body[2:2 + plen]
            if code == 0x3E and p:                    # LE Meta
                sub = p[0]
                if sub == 0x02 and len(p) >= 2:       # Advertising Report
                    n = p[1]
                    off = 2
                    for _ in range(n):
                        if off + 9 > len(p):
                            break
                        addr = addr_str(p[off + 2:off + 8])
                        dlen = p[off + 8]
                        ad = p[off + 9:off + 9 + dlen]
                        nm, us = parse_ad(ad)
                        prev = adverts.setdefault(addr, [None, set()])
                        if nm:
                            prev[0] = nm
                        prev[1].update(us)
                        off += 9 + dlen + 1
                elif sub == 0x0D and len(p) >= 2:     # Extended Advertising Report
                    # Bluetooth 5 : en-tete de 24 octets par rapport, la ou
                    # l'advertising historique en utilise 9.
                    n = p[1]
                    off = 2
                    for _ in range(n):
                        if off + 24 > len(p):
                            break
                        addr = addr_str(p[off + 3:off + 9])
                        dlen = p[off + 23]
                        ad = p[off + 24:off + 24 + dlen]
                        nm, us = parse_ad(ad)
                        prev = adverts.setdefault(addr, [None, set()])
                        if nm:
                            prev[0] = nm
                        prev[1].update(us)
                        off += 24 + dlen
                elif sub in (0x01, 0x0A) and len(p) >= 12:   # Connection Complete
                    if p[1] == 0x00:
                        h = struct.unpack("<H", p[2:4])[0]
                        addr = addr_str(p[6:12] if sub == 0x01 else p[6:12])
                        handles[h] = addr
            elif code == 0x05 and len(p) >= 3:        # Disconnection Complete
                h = struct.unpack("<H", p[1:3])[0]
                handles.pop(h, None)
                assembling.pop(h, None)

        elif ptype == 0x02:                            # ACL
            if len(body) < 4:
                continue
            hf, dlen = struct.unpack("<HH", body[0:4])
            h = hf & 0x0FFF
            pb = (hf >> 12) & 0x03
            payload = body[4:4 + dlen]
            if pb == 0x01:                             # fragment de continuation
                assembling[h] = assembling.get(h, b"") + payload
            else:
                assembling[h] = payload
            buf = assembling[h]
            if len(buf) < 4:
                continue
            l2len, cid = struct.unpack("<HH", buf[0:4])
            if len(buf) < 4 + l2len:
                continue                               # PDU encore incomplet
            frame = buf[4:4 + l2len]
            assembling.pop(h, None)
            if cid != 0x0004 or not frame:             # 0x0004 = ATT
                continue

            addr = handles.get(h, f"handle:{h}")
            op = frame[0]
            body_att = frame[1:]
            direction = "<-" if received else "->"
            traffic.append((when, addr, direction, op, body_att))

            g = gatt.setdefault(addr, {"services": [], "chars": [], "descs": []})
            if op == 0x03 and len(body_att) >= 2:
                mtu[addr] = struct.unpack("<H", body_att[0:2])[0]
            elif op == 0x11 and body_att:              # Read By Group Type Resp
                sz = body_att[0]
                for k in range(1, len(body_att) - sz + 1, sz):
                    e = body_att[k:k + sz]
                    if len(e) < 4:
                        break
                    s, en = struct.unpack("<HH", e[0:4])
                    row = (s, en, uuid_str(e[4:]))
                    if row not in g["services"]:
                        g["services"].append(row)
            elif op == 0x09 and body_att:              # Read By Type Resp
                sz = body_att[0]
                for k in range(1, len(body_att) - sz + 1, sz):
                    e = body_att[k:k + sz]
                    if len(e) < 5:
                        break
                    decl = struct.unpack("<H", e[0:2])[0]
                    props = e[2]
                    vh = struct.unpack("<H", e[3:5])[0]
                    row = (decl, vh, props, uuid_str(e[5:]))
                    if row not in g["chars"]:
                        g["chars"].append(row)
            elif op == 0x05 and body_att:              # Find Information Resp
                fmt = body_att[0]
                sz = 4 if fmt == 1 else 18
                for k in range(1, len(body_att) - sz + 1, sz):
                    e = body_att[k:k + sz]
                    hh = struct.unpack("<H", e[0:2])[0]
                    row = (hh, uuid_str(e[2:]))
                    if row not in g["descs"]:
                        g["descs"].append(row)

    # ---------------- rapport ----------------
    print(f"# Dépouillement de {os.path.basename(path)}\n")

    print("## Appareils vus en advertising\n")
    if not adverts:
        print("aucun\n")
    for addr, (nm, us) in sorted(adverts.items()):
        keep = want_addr is None or addr.endswith(want_addr) or want_addr in addr
        if not keep:
            continue
        print(f"- **{addr}**  {nm or '(sans nom)'}")
        for u in sorted(us):
            print(f"    service annoncé : {u}  {name_of(u)}")
    print()

    print("## Connexions\n")
    if not handles and not traffic:
        print("aucune\n")
    seen = sorted({a for _, a, _, _, _ in traffic})
    for a in seen:
        nm = adverts.get(a, [None, set()])[0]
        print(f"- {a}  {nm or ''}   MTU {mtu.get(a, '?')}")
    print()

    for addr, g in gatt.items():
        if want_addr and not (addr.endswith(want_addr) or want_addr in addr):
            continue
        print(f"## Table GATT — {addr}\n")
        if g["services"]:
            print("### Services\n")
            print("| Handles | UUID | Nom |")
            print("|---|---|---|")
            for s, e, u in g["services"]:
                print(f"| {s}–{e} | `{u}` | {name_of(u)} |")
            print()
        if g["chars"]:
            print("### Caractéristiques\n")
            print("| Déclaration | Valeur | Propriétés | UUID | Nom |")
            print("|---|---|---|---|---|")
            for d, vh, p, u in g["chars"]:
                print(f"| {d} | **{vh}** | {props_str(p)} | `{u}` | {name_of(u)} |")
            print()
        if g["descs"]:
            print("### Descripteurs\n")
            for hh, u in g["descs"]:
                print(f"- {hh} : `{u}`  {name_of(u)}")
            print()

    print("## Trafic ATT\n")
    interesting = {0x12, 0x52, 0x1B, 0x1D, 0x0B}
    rows = [t for t in traffic if show_all or t[3] in interesting]
    if want_addr:
        rows = [t for t in rows if t[1].endswith(want_addr) or want_addr in t[1]]
    if not rows:
        print("aucune trame de commande ni notification.\n")
    else:
        print(f"{len(rows)} trames.\n")
        print("| Heure | Sens | Opération | Handle | Valeur |")
        print("|---|---|---|---|---|")
        for when, addr, d, op, b in rows:
            att_h = struct.unpack("<H", b[0:2])[0] if len(b) >= 2 else None
            val = b[2:] if len(b) >= 2 else b
            name = ATT_OPCODES.get(op, f"0x{op:02X}")
            print(f"| {when:%H:%M:%S.%f}"[:-3] + f" | {d} | {name} | {att_h} | `{hexs(val)}` |")


if __name__ == "__main__":
    main()
