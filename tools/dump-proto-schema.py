#!/usr/bin/env python3
"""
Reconstruit le schéma protobuf (numéros et types de champ) de la bibliothèque
BLE iGPSPORT, à partir des chaînes `newMessageInfo` de protobuf-lite.

    python tools/dump-proto-schema.py <fichier.apk> [motif_de_classe]

protobuf-lite n'embarque pas de descripteur, mais chaque classe de message
contient dans sa méthode `dynamicMethod` :
  - un tableau d'objets : les noms de champs, dans l'ordre de déclaration ;
  - une chaîne « info » compacte : en-tête puis, par champ, son numéro et son type.

Ce script décode cette chaîne. Chaque message décodé est **validé** (nombre de
champs cohérent, numéros dans les bornes annoncées par l'en-tête, noms
disponibles) ; ce qui ne passe pas la validation est signalé comme douteux
plutôt que publié comme un fait.
"""

import os
import sys
import zipfile
from datetime import datetime

from loguru import logger
logger.remove()  # androguard journalise chaque étape de parsing en DEBUG

from androguard.core.dex import DEX

DEFAULT_FILTER = "com/igpsport/blelib"

# Ordinaux de com.google.protobuf.FieldType
SCALARS = [
    "double", "float", "int64", "uint64", "int32", "fixed64", "fixed32", "bool",
    "string", "message", "bytes", "uint32", "enum", "sfixed32", "sfixed64",
    "sint32", "sint64", "group",
]
ONEOF_TYPE_OFFSET = 51


def type_name(t):
    if t < 18:
        return SCALARS[t]
    if t < 35:
        return f"repeated {SCALARS[(t - 18) % 17]}"
    if t < 50:
        return f"repeated {SCALARS[(t - 35) % 17]} [packed]"
    if t == 50:
        return "map"
    return f"oneof:{SCALARS[(t - ONEOF_TYPE_OFFSET) % 18]}"


class Info:
    """Lecteur de la chaîne info (entiers encodés sur 13 bits par caractère)."""

    def __init__(self, s):
        self.s = s
        self.i = 0

    def next(self):
        v = ord(self.s[self.i]); self.i += 1
        if v < 0xD800:
            return v
        result = v & 0x1FFF
        shift = 13
        while True:
            v = ord(self.s[self.i]); self.i += 1
            if v < 0xD800:
                return result | (v << shift)
            result |= (v & 0x1FFF) << shift
            shift += 13

    def done(self):
        return self.i >= len(self.s)


def decode(info_str, names):
    """-> (liste de champs, liste d'anomalies)."""
    r = Info(info_str)
    problems = []
    try:
        _flags = r.next()
        field_count = r.next()
        if field_count == 0:
            return [], ["message sans champ"]
        _oneof_count = r.next()
        has_bits_count = r.next()
        min_fn = r.next()
        max_fn = r.next()
        num_entries = r.next()
        _map_count = r.next()
        _repeated_count = r.next()
        _check_init = r.next()
    except IndexError:
        return [], ["en-tête tronqué"]

    fields = []
    ni = 0
    for _ in range(num_entries):
        try:
            number = r.next()
            type_bits = r.next()
        except IndexError:
            problems.append("chaîne tronquée en cours de champ")
            break
        ftype = type_bits & 0xFF

        if ftype >= ONEOF_TYPE_OFFSET:
            try:
                r.next()  # index du oneof
            except IndexError:
                problems.append("oneof tronqué")
                break
            ni += 1  # le oneof consomme aussi une entrée d'objets
        else:
            ni += 1
            # Les références de classe qui accompagnent les champs de type
            # message/map sont écartées de `names` à l'extraction : l'index
            # avance donc d'un seul cran par champ.
            if has_bits_count > 0 and ftype <= 17:
                try:
                    r.next()  # index + décalage du bit de présence
                except IndexError:
                    problems.append("bits de présence tronqués")
                    break

        name = names[ni - 1] if 0 < ni <= len(names) else None
        if name is None:
            problems.append(f"nom manquant pour le champ {number}")
        if not (min_fn <= number <= max_fn):
            problems.append(f"champ {number} hors bornes [{min_fn}, {max_fn}]")
        fields.append((number, type_name(ftype), name or "?"))

    if len(fields) != field_count and not problems:
        problems.append(f"{len(fields)} champs décodés pour {field_count} annoncés")
    if not r.done():
        problems.append("octets restants en fin de chaîne")
    return fields, problems


def extract(cls):
    """-> (chaîne info, noms d'objets) pour une classe de message."""
    for m in cls.get_methods():
        if m.get_name() != "dynamicMethod":
            continue
        try:
            ins = list(m.get_instructions())
        except Exception:
            return None, []
        info, names = None, []
        for i in ins:
            n = i.get_name()
            if not n.startswith("const-string") and n != "const-class":
                continue
            out = i.get_output()
            if '"' in out:
                lit = out[out.index('"') + 1: out.rindex('"')]
            else:
                lit = out.split(",")[-1].strip()
            decoded = lit.encode().decode("unicode_escape")
            if any(ord(c) < 0x20 for c in decoded):
                info = decoded
            elif decoded.startswith("L") and decoded.endswith(";"):
                pass  # référence de classe : ne fait pas partie des noms de champs
            else:
                names.append(decoded.rstrip("_"))
        return info, names
    return None, []


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: python tools/dump-proto-schema.py <fichier.apk> [motif]")
    apk_path = sys.argv[1]
    want = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_FILTER

    z = zipfile.ZipFile(apk_path)
    results = {}
    for entry in sorted(n for n in z.namelist() if n.endswith(".dex")):
        raw = z.read(entry)
        if want.encode() not in raw:
            continue
        print(f"  {entry}…", flush=True)
        d = DEX(raw)
        for cls in d.get_classes():
            name = cls.get_name()[1:-1]
            if want not in name or name.endswith("OrBuilder") or "$Builder" in name:
                continue
            info, names = extract(cls)
            if not info:
                continue
            fields, problems = decode(info, names)
            if fields:
                results[name] = (fields, problems)

    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    outdir = os.path.join(
        repo, "captures", "schema-" + datetime.now().strftime("%Y%m%d-%H%M%S")
    )
    os.makedirs(outdir, exist_ok=True)

    lines = [f"# Schéma protobuf — `{os.path.basename(apk_path)}`\n",
             f"> Extrait le {datetime.now():%d/%m/%Y à %H:%M} par `tools/dump-proto-schema.py`.",
             f"> Filtre : `{want}`. Messages décodés : {len(results)}.\n",
             "> Un message marqué ⚠️ n'a pas passé la validation : ne pas s'y fier sans vérification.\n"]
    ok = 0
    for name in sorted(results):
        fields, problems = results[name]
        short = name.split("/")[-1]
        flag = " ⚠️" if problems else ""
        lines.append(f"### `{short}`{flag}\n")
        if problems:
            for p in problems:
                lines.append(f"- ⚠️ {p}")
            lines.append("")
        else:
            ok += 1
        lines.append("| # | Type | Champ |")
        lines.append("|---|---|---|")
        for num, typ, nm in sorted(fields):
            lines.append(f"| **{num}** | `{typ}` | `{nm}` |")
        lines.append("")

    report = os.path.join(outdir, "schema.md")
    with open(report, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
    print(f"\nRapport : {report}")
    print(f"{len(results)} messages, dont {ok} validés sans anomalie.")


if __name__ == "__main__":
    main()
