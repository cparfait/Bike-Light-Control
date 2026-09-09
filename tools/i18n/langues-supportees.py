#!/usr/bin/env python3
"""Langues portees par les 13 Edge cibles, d'apres les profils du SDK.

    python tools/i18n/langues-supportees.py
    python tools/i18n/langues-supportees.py --declarees

Meme methode que tools/check-ble-devices.sh : on interroge les profils
d'appareil installes localement, pas la documentation en ligne.

Ce qu'il faut comprendre avant de declarer une langue au manifeste : le SDK
associe a chaque **reference materielle** un jeu de polices. Une reference
« ww » porte les langues europeennes ; une reference APAC porte le japonais, le
coreen, le chinois et le thai — et pas l'inverse. Les 13 modeles totalisent 18
references, si bien qu'aucune langue autre que l'anglais n'est portee par
toutes. Ce n'est pas un probleme : une langue absente d'une reference retombe
sur l'anglais, c'est le mecanisme prevu par Garmin.

En revanche la taille du binaire, elle, grandit avec **chaque** langue
declaree, qu'elle serve ou non sur la reference compilee. Un champ de donnees
dispose de 128 Ko : les 36 langues de l'union mesuraient 113 Ko, ce qui ne
laisse rien pour le tas. D'ou le tri : on ne declare que les langues portees
par un nombre significatif de references.
"""

import json
import io
import os
import re
import sys

TARGETS = ("edge530 edge540 edge550 edge830 edge840 edge850 edge1030 "
           "edge1030plus edge1040 edge1050 edgeexplore edgeexplore2 "
           "edgemtb").split()

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEVICES = os.path.expanduser("~/AppData/Roaming/Garmin/ConnectIQ/Devices")


def declared():
    path = os.path.join(ROOT, "app", "manifest.xml")
    text = io.open(path, encoding="utf-8").read()
    return re.findall(r"<iq:language>(\w+)</iq:language>", text)


def main():
    if not os.path.isdir(DEVICES):
        sys.exit("profils d'appareil introuvables : %s" % DEVICES)

    per_reference = {}
    for target in TARGETS:
        path = os.path.join(DEVICES, target, "compiler.json")
        if not os.path.exists(path):
            print("  %-14s profil absent" % target)
            continue
        profile = json.load(io.open(path, encoding="utf-8"))
        for part in profile.get("partNumbers", []):
            codes = {lang["code"] for lang in part.get("languages", [])}
            per_reference[(target, part["number"])] = codes

    total = len(per_reference)
    counts = {}
    for codes in per_reference.values():
        for code in codes:
            counts[code] = counts.get(code, 0) + 1

    mine = set(declared())
    only = "--declarees" in sys.argv

    print("%d references materielles pour %d modeles.\n" % (total, len(TARGETS)))
    print("%-6s %-9s %s" % ("LANGUE", "REFS", "DECLAREE"))
    for code in sorted(counts, key=lambda c: (-counts[c], c)):
        if only and code not in mine:
            continue
        print("%-6s %2d / %-4d %s"
              % (code, counts[code], total, "oui" if code in mine else ""))

    missing = [c for c in mine if c not in counts]
    if missing:
        print("\nDeclarees mais portees par AUCUNE reference : %s"
              % " ".join(sorted(missing)))
        return 1
    print("\nToutes les langues declarees sont portees par au moins une reference.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
