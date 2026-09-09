#!/usr/bin/env python3
"""
Décode les trames échangées avec la lampe sur le Nordic UART, et cherche la
règle des deux octets de contrôle de l'en-tête.

    python tools/decode-lamp-frames.py <btsnoop_hci.log>

Structure observée : un en-tête de 20 octets, suivi d'une charge utile protobuf
dont la longueur est annoncée dans l'en-tête. Sur les écritures, les deux
parties tiennent dans un seul PDU ; sur les notifications, elles arrivent en
fragments de 20 octets.
"""

import io
import os
import struct
import sys
from datetime import datetime, timedelta


EPOCH_DELTA_US = 0x00DCDDB30F2F8000
HDR_LEN = 20

# Handles relevés dans la table GATT de la VS1800S (docs/protocole-vs1800s.md).
TX_HANDLE = 33      # 6E400002 — central -> lampe
RX_HANDLE = 30      # 6E400003 — lampe -> central


def hexs(b):
    return " ".join(f"{x:02X}" for x in b)


def records(path):
    with open(path, "rb") as f:
        head = f.read(16)
        _ver, datalink = struct.unpack(">II", head[8:16])
        while True:
            hdr = f.read(24)
            if len(hdr) < 24:
                return
            _o, ilen, flags, _d, ts = struct.unpack(">IIIIq", hdr)
            data = f.read(ilen)
            if len(data) < ilen:
                return
            yield flags, ts, data, datalink


def att_frames(path):
    """-> (instant, sens, handle ATT, valeur)"""
    asm = {}
    for flags, ts, data, datalink in records(path):
        if not data or data[0] != 0x02:
            continue
        body = data[1:]
        if len(body) < 4:
            continue
        hf, dlen = struct.unpack("<HH", body[0:4])
        h, pb = hf & 0x0FFF, (hf >> 12) & 0x03
        payload = body[4:4 + dlen]
        asm[h] = (asm.get(h, b"") + payload) if pb == 0x01 else payload
        buf = asm[h]
        if len(buf) < 4:
            continue
        l2len, cid = struct.unpack("<HH", buf[0:4])
        if len(buf) < 4 + l2len:
            continue
        frame = buf[4:4 + l2len]
        asm.pop(h, None)
        if cid != 0x0004 or len(frame) < 3:
            continue
        op = frame[0]
        if op not in (0x12, 0x52, 0x1B, 0x1D):
            continue
        att_h = struct.unpack("<H", frame[1:3])[0]
        when = datetime(1970, 1, 1) + timedelta(microseconds=ts - EPOCH_DELTA_US)
        yield when, ("->" if not (flags & 1) else "<-"), att_h, frame[3:]


def varint(b, i):
    r, s = 0, 0
    while i < len(b):
        c = b[i]; i += 1
        r |= (c & 0x7F) << s
        if not c & 0x80:
            return r, i
        s += 7
    return None, i


def pb_decode(b, depth=0):
    """Rend une représentation lisible d'un message protobuf."""
    out, i = [], 0
    pad = "  " * depth
    while i < len(b):
        key, i = varint(b, i)
        if key is None:
            break
        field, wire = key >> 3, key & 7
        if wire == 0:
            v, i = varint(b, i)
            if v is None:
                break
            out.append(f"{pad}{field} = {v}")
        elif wire == 2:
            ln, i = varint(b, i)
            if ln is None or i + ln > len(b):
                break
            sub = b[i:i + ln]; i += ln
            inner = pb_decode(sub, depth + 1)
            out.append(f"{pad}{field} {{\n{inner}\n{pad}}}" if inner else f"{pad}{field} {{}}")
        else:
            out.append(f"{pad}{field} = <wire {wire}, non gere>")
            break
    return "\n".join(out)


def reassemble(path):
    """-> (instant, sens, en-tête, charge utile)"""
    pend = {"->": None, "<-": None}
    for when, d, h, val in att_frames(path):
        if h not in (TX_HANDLE, RX_HANDLE):
            continue
        cur = pend[d]
        if cur is None:
            if len(val) < HDR_LEN:
                continue
            hdr, rest = val[:HDR_LEN], val[HDR_LEN:]
            need = hdr[8]
            if len(rest) >= need:
                yield when, d, hdr, rest[:need]
            else:
                pend[d] = [when, hdr, rest, need]
        else:
            w, hdr, buf, need = cur
            buf += val
            if len(buf) >= need:
                pend[d] = None
                yield w, d, hdr, buf[:need]
            else:
                pend[d] = [w, hdr, buf, need]


def find_checksum(frames, index, label):
    """Cherche une règle simple expliquant l'octet `index` de l'en-tête."""
    ops = {
        "XOR": lambda acc, x: acc ^ x,
        "somme": lambda acc, x: (acc + x) & 0xFF,
    }
    results = []
    for name, op in ops.items():
        for start in range(0, 3):
            for end in (9, 10, 19, 20):
                if end <= start or start > index or (start <= index < end):
                    continue
                ok = True
                for _, _, hdr, _ in frames:
                    acc = 0
                    for x in hdr[start:end]:
                        acc = op(acc, x)
                    if acc != hdr[index]:
                        ok = False
                        break
                if ok:
                    results.append(f"{label} = {name} des octets [{start}:{end}]")
    # Variante incluant la charge utile.
    for name, op in ops.items():
        for start in range(0, 3):
            ok = True
            for _, _, hdr, pl in frames:
                acc = 0
                for x in list(hdr[start:index]) + list(hdr[index + 1:]) + list(pl):
                    acc = op(acc, x)
                if acc != hdr[index]:
                    ok = False
                    break
            if ok:
                results.append(f"{label} = {name} de l'en-tete[{start}:] hors lui-meme + charge utile")
    return results


def main():
    # Console Windows en cp1252 : on n'y touche que dans main(), pour que le
    # module reste importable par d'autres scripts sans effet de bord.
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    if len(sys.argv) < 2:
        sys.exit("usage: python tools/decode-lamp-frames.py <btsnoop_hci.log>")
    path = sys.argv[1]
    frames = list(reassemble(path))
    if not frames:
        sys.exit("Aucune trame lampe trouvée (handles 30/33).")

    print(f"# Trames lampe — {os.path.basename(path)}\n")
    print(f"{len(frames)} trames reconstituées.\n")

    print("## En-têtes\n")
    print("| Heure | Sens | 0 | svc | sub | 3 | op | 5 | 6 | 7 | len | 9 | 10 | 11..18 | 19 |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for w, d, h, pl in frames:
        mid = "FF" * 8 if all(x == 0xFF for x in h[11:19]) else hexs(h[11:19])
        print(f"| {w:%H:%M:%S} | {d} | {h[0]:02X} | **{h[1]:02X}** | **{h[2]:02X}** | {h[3]:02X} "
              f"| **{h[4]:02X}** | {h[5]:02X} | {h[6]:02X} | {h[7]:02X} | {h[8]:02X} "
              f"| {h[9]:02X} | {h[10]:02X} | {mid} | {h[19]:02X} |")
    print()

    print("## Recherche des octets de contrôle\n")
    for idx, label in ((9, "octet 9"), (19, "octet 19")):
        found = find_checksum(frames, idx, label)
        if found:
            for f in found:
                print(f"- ✅ {f}")
        else:
            print(f"- ❌ {label} : aucune règle simple trouvée (XOR/somme sur les plages testées)")
    print()

    print("## Charges utiles décodées\n")
    for w, d, h, pl in frames:
        if not pl:
            continue
        print(f"### {w:%H:%M:%S.%f} {d}  service={h[1]} sous-service={h[2]} op={h[4]}\n")
        print("```")
        print(f"brut : {hexs(pl)}")
        print(pb_decode(pl))
        print("```\n")


if __name__ == "__main__":
    main()
