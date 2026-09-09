#!/usr/bin/env python3
"""
Analyse statique « premier passage » de l'APK iGPSPORT.

    python tools/scan-apk.py chemin/vers/igpsport.apk

Ne nécessite ni Java ni jadx : les chaînes de caractères d'un fichier .dex sont
stockées en clair, y compris quand le code est obfusqué par ProGuard/R8 — un
obfuscateur renomme les classes et les méthodes, pas les littéraux. Or les UUID
BLE *sont* des littéraux. C'est donc le moyen le plus court d'obtenir la table
GATT sans avoir la lampe sous la main.

Produit un rapport Markdown dans captures/apk-<horodatage>/.
"""

import os
import re
import sys
import zipfile
from collections import defaultdict
from datetime import datetime

# --- UUID adoptés par le Bluetooth SIG, utiles à reconnaître au passage -------
BASE_SUFFIX = "-0000-1000-8000-00805f9b34fb"

STANDARD = {
    "1800": "Generic Access",
    "1801": "Generic Attribute",
    "180a": "Device Information",
    "180f": "Battery Service",
    "1802": "Immediate Alert",
    "1803": "Link Loss",
    "1804": "Tx Power",
    "1816": "Cycling Speed and Cadence",
    "1818": "Cycling Power",
    "181c": "User Data",
    "2a19": "Battery Level",
    "2a00": "Device Name",
    "2a24": "Model Number String",
    "2a25": "Serial Number String",
    "2a26": "Firmware Revision String",
    "2a27": "Hardware Revision String",
    "2a28": "Software Revision String",
    "2a29": "Manufacturer Name String",
    "2902": "Client Characteristic Configuration (CCCD)",
    "fff0": "Service propriétaire courant (modules chinois)",
    "ffe0": "Transport transparent TI CC254x",
    "ffe1": "Caractéristique TI CC254x",
}

# UUID 128 bits fréquents sur ce type de matériel
KNOWN_128 = {
    "6e400001-b5a3-f393-e0a9-e50e24dcca9e": "Nordic UART Service (NUS)",
    "6e400002-b5a3-f393-e0a9-e50e24dcca9e": "NUS TX — écriture (téléphone → périphérique)",
    "6e400003-b5a3-f393-e0a9-e50e24dcca9e": "NUS RX — notification (périphérique → téléphone)",
    "0000fee7-0000-1000-8000-00805f9b34fb": "Service Tencent/anta courant",
    "0000fe59-0000-1000-8000-00805f9b34fb": "Nordic DFU (mise à jour firmware)",
    "00001530-1212-efde-1523-785feabcd123": "Legacy Nordic DFU",
}

# Mots-clés dont la présence oriente le dépouillement. Un obfuscateur ne les
# touche pas quand ils sont dans des littéraux (logs, clés JSON, noms de modes).
KEYWORDS = {
    "Éclairage / modes": [
        "lamp", "light", "beam", "highbeam", "lowbeam", "high_beam", "low_beam",
        "brightness", "lumen", "flash", "strobe", "blink", "dayflash",
    ],
    "Modèles": ["vs1800", "vs800", "vs1200", "tl30", "igs630", "igs800"],
    "Vitesse / automatismes": [
        "speed", "velocity", "kmh", "km/h", "autolight", "auto_light",
        "automode", "auto_mode", "smartmode", "smart_mode", "threshold",
    ],
    "Batterie": ["battery", "batt", "soc", "power_level", "voltage"],
    "Protocole / trames": [
        "checksum", "crc", "crc8", "crc16", "opcode", "payload", "frame",
        "packet", "protocol", "cmd_", "command", "header", "preamble",
    ],
    "Chiffrement (⚠ à surveiller)": [
        "aes", "encrypt", "decrypt", "cipher", "secretkey", "seckey",
        "handshake", "challenge", "token", "signature", "hmac",
    ],
}

# La console Windows est en cp1252 : sans ça, un simple caractère accentué ou un
# symbole dans un nom de catégorie fait planter l'affichage du résumé.
try:
    sys.stdout.reconfigure(errors="replace")
except (AttributeError, ValueError):
    pass

PRINTABLE = re.compile(rb"[\x20-\x7e]{4,}")
UUID_RE = re.compile(
    r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
)
# Motifs de construction dynamique : "0000%04X-0000-1000-8000-00805f9b34fb"
UUID_FMT_RE = re.compile(
    r"[0-9a-fA-F%04xXsd]{4,8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
)


def strings_of(blob):
    """Toutes les chaînes ASCII imprimables d'un blob binaire."""
    for m in PRINTABLE.finditer(blob):
        yield m.group().decode("ascii", "replace")


def describe(uuid):
    u = uuid.lower()
    if u in KNOWN_128:
        return KNOWN_128[u]
    if u.endswith(BASE_SUFFIX):
        short = u[4:8]
        if u[:4] == "0000" and short in STANDARD:
            return f"standard SIG 0x{short} — {STANDARD[short]}"
        return f"UUID court 0x{short} sur base SIG — non répertorié"
    return "propriétaire (128 bits)"


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: python tools/scan-apk.py <fichier.apk>")
    apk = sys.argv[1]
    if not os.path.isfile(apk):
        sys.exit(f"introuvable : {apk}")

    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    outdir = os.path.join(
        repo, "captures", "apk-" + datetime.now().strftime("%Y%m%d-%H%M%S")
    )
    os.makedirs(outdir, exist_ok=True)

    uuids = defaultdict(set)          # uuid -> {fichiers}
    uuid_fmts = set()
    hits = defaultdict(set)           # catégorie -> {chaînes}
    all_strings = []
    scanned = []

    with zipfile.ZipFile(apk) as z:
        names = z.namelist()
        targets = [
            n for n in names
            if n.endswith(".dex")
            or n.endswith(".so")
            or n.startswith("assets/")
            or n.endswith(".json")
        ]
        for n in targets:
            try:
                blob = z.read(n)
            except Exception:
                continue
            if len(blob) > 200 * 1024 * 1024:
                continue
            scanned.append((n, len(blob)))
            for s in strings_of(blob):
                all_strings.append(s)
                for m in UUID_RE.finditer(s):
                    uuids[m.group().lower()].add(n)
                for m in UUID_FMT_RE.finditer(s):
                    g = m.group()
                    if "%" in g:
                        uuid_fmts.add(g)
                low = s.lower()
                for cat, words in KEYWORDS.items():
                    for w in words:
                        if w in low:
                            hits[cat].add(s.strip())
                            break

    # --- rapport --------------------------------------------------------------
    lines = []
    A = lines.append
    A(f"# Analyse statique — `{os.path.basename(apk)}`\n")
    A(f"> Généré le {datetime.now():%d/%m/%Y à %H:%M} par `tools/scan-apk.py`.")
    A("> Premier passage automatique : à confronter au log HCI, pas à prendre pour argent comptant.\n")

    A("## Fichiers analysés\n")
    A("| Entrée | Taille |")
    A("|---|---|")
    for n, sz in sorted(scanned, key=lambda x: -x[1])[:25]:
        A(f"| `{n}` | {sz // 1024} Kio |")
    if len(scanned) > 25:
        A(f"| … | *{len(scanned) - 25} autres entrées* |")
    A(f"\nTotal : {len(scanned)} entrées, {len(all_strings)} chaînes extraites.\n")

    A("## UUID trouvés\n")
    if not uuids:
        A("Aucun UUID littéral. Deux explications possibles :\n")
        A("- les UUID sont construits dynamiquement (voir section suivante) ;")
        A("- la logique BLE est dans une bibliothèque native `.so` sous une forme non textuelle.\n")
    else:
        A(f"{len(uuids)} UUID distincts.\n")
        A("| UUID | Nature | Trouvé dans |")
        A("|---|---|---|")
        prop, std = [], []
        for u in sorted(uuids):
            (std if u.endswith(BASE_SUFFIX) else prop).append(u)
        for u in prop + std:
            src = ", ".join(sorted(uuids[u])[:2])
            A(f"| `{u}` | {describe(u)} | `{src}` |")
        A("")
        A("**Lecture** : les UUID *propriétaires* (128 bits hors base SIG) sont listés en")
        A("premier — c'est parmi eux que se trouve le service de commande de la lampe.")
        A("Un service standard `0x180F` dans la liste signifie que la lecture de batterie")
        A("(F2) est acquise sans rétro-ingénierie.\n")

    if uuid_fmts:
        A("### Construction dynamique d'UUID\n")
        A("Motifs à format détectés — les UUID sont assemblés à l'exécution :\n")
        for f in sorted(uuid_fmts):
            A(f"- `{f}`")
        A("")

    A("## Chaînes par thème\n")
    if not hits:
        A("Aucun mot-clé trouvé. APK probablement fortement obfusqué, ou logique BLE native.\n")
    for cat in KEYWORDS:
        found = sorted(hits.get(cat, ()))
        A(f"### {cat}\n")
        if not found:
            A("*rien*\n")
            continue
        A(f"{len(found)} occurrences" + (" (100 premières)" if len(found) > 100 else "") + " :\n")
        A("```")
        for s in found[:100]:
            A(s[:200])
        A("```\n")

    A("## À faire ensuite\n")
    A("1. Reporter les UUID propriétaires dans `docs/protocole-vs1800s.md` §2, en les")
    A("   marquant **supposés** tant que le log HCI ne les a pas confirmés.")
    A("2. Si la section « Chiffrement » ci-dessus est fournie, lire le code des classes")
    A("   concernées avant d'investir en Phase 2 — c'est le scénario bloquant du §7 du")
    A("   cahier des charges.")
    A("3. Pour aller au-delà des chaînes (table des commandes, seuils de vitesse), il faut")
    A("   décompiler : installer un JDK 11+ puis jadx, et cibler les classes repérées ici.\n")

    report = os.path.join(outdir, "rapport.md")
    with open(report, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    with open(os.path.join(outdir, "strings.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(all_strings))

    print(f"Rapport      : {report}")
    print(f"Chaînes      : {os.path.join(outdir, 'strings.txt')} ({len(all_strings)} lignes)")
    print(f"UUID trouvés : {len(uuids)}")
    for cat in KEYWORDS:
        print(f"  {cat:<32} {len(hits.get(cat, ())):>5}")


if __name__ == "__main__":
    main()
