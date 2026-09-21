#!/usr/bin/env python3
"""Etablit la liste des appareils cibles a partir des profils du SDK installes.

    python tools/gen-targets.py                # le tableau, rien d'autre
    python tools/gen-targets.py --manifest     # le bloc <iq:product> a coller
    python tools/gen-targets.py --jungle       # les groupes d'icones du jungle
    python tools/gen-targets.py --markdown     # le tableau de docs/compatibilite.md
    python tools/gen-targets.py --list         # les identifiants, sur une ligne

Pourquoi un generateur maintenant, alors que la liste des treize Edge etait
ecrite a la main : a treize, une table relue par `check-ble-devices.sh` suffisait
et se verifiait d'un coup d'oeil. Avec toute la gamme des montres, c'est une
centaine de lignes qui changent a chaque mise a jour du SDK — recopiees a la
main, elles seraient fausses des la suivante. Le critere, lui, n'a pas bouge :
ce qui est lu dans le profil, jamais ce qui est annonce par la documentation.

**Quatre conditions, toutes necessaires, toutes relues dans le profil :**

  1. le role central BLE existe reellement — les methodes `setScanState` et
     `registerProfile` dans la definition d'API, et pas la simple mention de la
     permission, que TOUS les appareils contiennent (c'est le piege qui a motive
     `check-ble-devices.sh`) ;
  2. l'appareil sait executer les deux types dont le projet a besoin,
     `datafield` et `watchApp` ;
  3. son champ de donnees dispose d'au moins 128 Ko — le binaire en fait ~90, et
     les vieux boitiers a 32 Ko ne le chargeraient pas ;
  4. sa version Connect IQ atteint le `minApiLevel` du manifeste, 3.1.0.

Ce que ce script ne prouve pas : que le binaire compile. Le compilateur reste le
juge, et `bash app/build.sh` la verification qui compte — c'est lui qui a le
dernier mot sur la liste.
"""

import argparse
import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEVICES = os.path.expanduser("~/AppData/Roaming/Garmin/ConnectIQ/Devices")

# Les noms commerciaux portent des marques deposees — « Edge® », « tactix® 7 —
# AMOLED » — que la console Windows en cp1252 ne sait pas ecrire. On force la
# sortie en UTF-8 plutot que de mutiler les noms.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

MIN_API = (3, 1, 0)
MIN_DATAFIELD = 128 * 1024

# L'Edge MTB est le seul appareil dont la tuile de vignette est posee sur un fond
# clair ; tous les autres, montres AMOLED comprises, sont sur fond sombre. Voir
# l'en-tete de widget/monkey.jungle, ou ce choix est explique en detail.
GLANCE_LIGHT = {"edgemtb"}


def _version(text):
    parts = re.findall(r"\d+", text or "")
    return tuple(int(p) for p in (parts + ["0", "0", "0"])[:3])


def profile(device):
    """Tout ce qu'on lit d'un appareil, ou None s'il ne remplit pas les criteres."""
    folder = os.path.join(DEVICES, device)
    compiler = os.path.join(folder, "compiler.json")
    if not os.path.exists(compiler):
        return None
    conf = json.load(io.open(compiler, encoding="utf-8"))

    types = {a["type"]: a.get("memoryLimit", 0) for a in conf.get("appTypes", [])}
    if "datafield" not in types or "watchApp" not in types:
        return None
    if types["datafield"] < MIN_DATAFIELD:
        return None

    versions = [_version(p.get("connectIQVersion"))
                for p in conf.get("partNumbers", [])]
    if not versions or min(versions) < MIN_API:
        return None

    # Le discriminant du role central : les methodes, pas le nom de la
    # permission. Voir tools/check-ble-devices.sh, meme critere.
    api = sorted(glob.glob(os.path.join(folder, "*.api.debug.xml")))
    if not api:
        return None
    text = io.open(api[0], encoding="utf-8", errors="ignore").read()
    if "setScanState" not in text or "registerProfile" not in text:
        return None

    icon = conf.get("launcherIcon") or {}
    if icon.get("width") != icon.get("height") or not icon.get("width"):
        return None

    display = {}
    sim = os.path.join(folder, "simulator.json")
    if os.path.exists(sim):
        display = json.load(io.open(sim, encoding="utf-8")).get("display", {})
    location = display.get("location") or {}

    return {
        "id": device,
        "name": conf.get("displayName", device),
        "icon": icon["width"],
        "ciq": ".".join(str(n) for n in min(versions)),
        "datafield": types["datafield"] // 1024,
        "shape": display.get("shape", "?"),
        "touch": bool(display.get("isTouch")),
        "w": location.get("width"),
        "h": location.get("height"),
        "glance": "light" if device in GLANCE_LIGHT else "dark",
        "family": conf.get("deviceFamily", "?"),
    }


def targets():
    if not os.path.isdir(DEVICES):
        sys.exit("profils d'appareil introuvables : %s" % DEVICES)
    found = []
    for device in sorted(os.listdir(DEVICES)):
        info = profile(device)
        if info:
            found.append(info)
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", action="store_true")
    ap.add_argument("--jungle", action="store_true")
    ap.add_argument("--glance", action="store_true")
    ap.add_argument("--markdown", action="store_true")
    ap.add_argument("--list", action="store_true")
    args = ap.parse_args()

    found = targets()

    if args.list:
        print(" ".join(t["id"] for t in found))
        return 0

    if args.manifest:
        for t in found:
            print('            <iq:product id="%s"/>' % t["id"])
        return 0

    if args.jungle:
        sizes = {}
        for t in found:
            sizes.setdefault(t["icon"], []).append(t["id"])
        for size in sorted(sizes):
            print("# %d x %d px" % (size, size))
            for device in sizes[size]:
                print("%s.resourcePath = $(%s.resourcePath);resources-icon-%d"
                      % (device, device, size))
            print("")
        return 0

    if args.glance:
        for t in found:
            print("%s.sourcePath = $(%s.sourcePath);source-glance-%s"
                  % (t["id"], t["id"], t["glance"]))
        return 0

    if args.markdown:
        print("| Modèle | Profil SDK | Écran | CIQ | Champ | Icône |")
        print("|---|---|---|---|---|---|")
        for t in found:
            screen = ("%sx%s %s" % (t["w"], t["h"], t["shape"])
                      if t["w"] else t["shape"])
            print("| %s | `%s` | %s | %s | %s Ko | %s px |"
                  % (t["name"], t["id"], screen, t["ciq"], t["datafield"], t["icon"]))
        print("")
        print("**%d cibles.**" % len(found))
        return 0

    shapes = {}
    icons = {}
    for t in found:
        shapes[t["shape"]] = shapes.get(t["shape"], 0) + 1
        icons[t["icon"]] = icons.get(t["icon"], 0) + 1
    print("%-22s %-6s %-5s %-14s %s" % ("PROFIL", "ICONE", "CIQ", "ECRAN", "NOM"))
    for t in found:
        print("%-22s %-6s %-5s %-14s %s"
              % (t["id"], t["icon"], t["ciq"],
                 "%sx%s %s" % (t["w"], t["h"], t["shape"][:4]), t["name"]))
    print("\n%d cibles." % len(found))
    print("Formes  : %s" % ", ".join("%s=%d" % kv for kv in sorted(shapes.items())))
    print("Icones  : %s" % ", ".join("%s=%d" % kv for kv in sorted(icons.items())))
    return 0


if __name__ == "__main__":
    sys.exit(main())
