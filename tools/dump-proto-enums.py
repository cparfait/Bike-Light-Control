#!/usr/bin/env python3
"""
Extrait les énumérations protobuf de la bibliothèque BLE iGPSPORT.

    python tools/dump-proto-enums.py <fichier.apk> [motif_de_classe]

protobuf-lite ne conserve pas de descripteur exploitable à l'exécution, mais il
génère pour chaque valeur d'énumération une constante `public static final int
XXX_VALUE = N`. Ces constantes sont stockées dans la table `static_values` du
dex : on les lit directement, sans décompilateur ni JDK.
"""

import os
import re
import sys
from collections import defaultdict
from datetime import datetime

from androguard.core.apk import APK
from loguru import logger
logger.remove()  # androguard journalise chaque étape de parsing en DEBUG

from androguard.core.dex import DEX

DEFAULT_FILTER = "com/igpsport/blelib"


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: python tools/dump-proto-enums.py <fichier.apk> [motif]")
    apk_path = sys.argv[1]
    want = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_FILTER

    print(f"Lecture de {os.path.basename(apk_path)}…")
    apk = APK(apk_path)

    # classe -> {constante: valeur}
    enums = defaultdict(dict)
    # classe -> [noms de champs protobuf]
    fields = defaultdict(list)

    for i, raw in enumerate(apk.get_all_dex()):
        print(f"  dex #{i + 1}…", flush=True)
        dex = DEX(raw)
        for cls in dex.get_classes():
            name = cls.get_name()[1:-1]  # LFoo/Bar;  ->  Foo/Bar
            if want not in name:
                continue
            for f in cls.get_fields():
                fname = f.get_name()
                init = f.get_init_value()
                if fname.endswith("_VALUE") and init is not None:
                    val = init.get_value()
                    if isinstance(val, int):
                        enums[name][fname[: -len("_VALUE")]] = val
                elif fname.endswith("_") and not fname.startswith("_"):
                    fields[name].append(fname[:-1])

    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    outdir = os.path.join(
        repo, "captures", "proto-" + datetime.now().strftime("%Y%m%d-%H%M%S")
    )
    os.makedirs(outdir, exist_ok=True)

    lines = []
    A = lines.append
    A(f"# Énumérations et champs protobuf — `{os.path.basename(apk_path)}`\n")
    A(f"> Extrait le {datetime.now():%d/%m/%Y à %H:%M} par `tools/dump-proto-enums.py`.")
    A(f"> Filtre : `{want}`\n")

    A("## Énumérations\n")
    for cls in sorted(enums):
        vals = enums[cls]
        if not vals:
            continue
        short = cls.split("/")[-1]
        A(f"### `{short}`\n")
        A("| Constante | Valeur |")
        A("|---|---|")
        for k, v in sorted(vals.items(), key=lambda kv: kv[1]):
            A(f"| `{k}` | **{v}** |")
        A("")

    A("## Champs des messages\n")
    for cls in sorted(fields):
        fs = sorted(set(fields[cls]))
        if not fs:
            continue
        short = cls.split("/")[-1]
        A(f"- **`{short}`** — " + ", ".join(f"`{f}`" for f in fs))
    A("")

    report = os.path.join(outdir, "enums.md")
    with open(report, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))

    total = sum(len(v) for v in enums.values())
    print(f"\nRapport : {report}")
    print(f"{len(enums)} enums, {total} constantes, {len(fields)} messages avec champs.")


if __name__ == "__main__":
    main()
