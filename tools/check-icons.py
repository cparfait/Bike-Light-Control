#!/usr/bin/env python3
"""Verifie la chaine complete des icones de lanceur, sur les 13 cibles.

    python tools/check-icons.py

Quatre maillons, et il suffit qu'un seul casse pour que l'icone soit floue ou
absente sur un modele — sans le moindre avertissement du compilateur, qui
redimensionne en silence :

  1. le manifeste declare le produit ;
  2. le profil SDK de ce produit annonce une taille d'icone attendue ;
  3. le jungle associe le produit a un dossier `resources-icon-<taille>` ;
  4. le PNG de ce dossier fait bien cette taille, et est opaque.

Le point 2 est celui qui a motive ce script : la table de `make-icons.py`
venait d'un fil de forum. Ici on la relit dans `compiler.json`, comme
`tools/check-ble-devices.sh` le fait pour la permission BLE.

Le point 4 verifie aussi l'opacite : les icones de lanceur de Garmin sont des
carres pleins, sans canal alpha. L'Edge MTB ne sait de toute facon pas composer
une transparence (`alphaBlendingSupport` a False).
"""

import glob
import io
import json
import os
import re
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEVICES = os.path.expanduser("~/AppData/Roaming/Garmin/ConnectIQ/Devices")


def products(binary):
    text = io.open(os.path.join(ROOT, binary, "manifest.xml"), encoding="utf-8").read()
    return re.findall(r'<iq:product id="([^"]+)"/>', text)


def icon_folders(binary):
    """Produit -> dossier de ressources d'icone, d'apres le jungle."""
    text = io.open(os.path.join(ROOT, binary, "monkey.jungle"), encoding="utf-8").read()
    found = {}
    for device, path in re.findall(r"^(\w+)\.resourcePath\s*=\s*.*?;(resources-icon-\d+)\s*$",
                                   text, re.M):
        found[device] = path
    return found


def expected_size(product):
    path = os.path.join(DEVICES, product, "compiler.json")
    if not os.path.exists(path):
        return None
    profile = json.load(io.open(path, encoding="utf-8"))
    icon = profile.get("launcherIcon") or {}
    if icon.get("width") != icon.get("height"):
        return ("non carre", icon)
    return icon.get("width")


def main():
    if not os.path.isdir(DEVICES):
        sys.exit("profils d'appareil introuvables : %s" % DEVICES)

    problems = []
    for binary in ("app", "widget"):
        print("%s :" % binary)
        folders = icon_folders(binary)
        for product in products(binary):
            want = expected_size(product)
            folder = folders.get(product)
            note = ""

            if want is None:
                problems.append("%s/%s : profil SDK absent" % (binary, product))
                note = "PROFIL ABSENT"
            elif folder is None:
                problems.append("%s/%s : aucun resources-icon-* dans le jungle"
                                % (binary, product))
                note = "PAS DE DOSSIER"
            else:
                declared = int(folder.rsplit("-", 1)[1])
                png = os.path.join(ROOT, binary, folder, "drawables", "launcher.png")
                if declared != want:
                    problems.append("%s/%s : le jungle pointe %d px, le SDK en attend %d"
                                    % (binary, product, declared, want))
                    note = "TAILLE FAUSSE"
                elif not os.path.exists(png):
                    problems.append("%s/%s : %s absent" % (binary, product, png))
                    note = "PNG ABSENT"
                else:
                    im = Image.open(png)
                    w, h = im.size
                    corners = {im.convert("RGB").getpixel(c)
                               for c in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1))}
                    if (w, h) != (want, want):
                        problems.append("%s/%s : PNG %dx%d, attendu %dx%d"
                                        % (binary, product, w, h, want, want))
                        note = "PNG MAL DIMENSIONNE"
                    elif im.mode != "RGB":
                        problems.append("%s/%s : PNG en mode %s, attendu RGB opaque"
                                        % (binary, product, im.mode))
                        note = "CANAL ALPHA"
                    elif len(corners) != 1:
                        problems.append("%s/%s : les quatre coins different %s"
                                        % (binary, product, corners))
                        note = "COINS INEGAUX"

            print("  %-14s SDK %-4s jungle %-20s %s"
                  % (product, want, folder or "-", note))

    orphans = sorted(set(glob.glob(os.path.join(ROOT, "*", "resources-icon-*")))
                     - {os.path.join(ROOT, b, f)
                        for b in ("app", "widget") for f in icon_folders(b).values()})
    if orphans:
        print("\nDossiers d'icone que le jungle n'utilise pas :")
        for path in orphans:
            print("  %s" % os.path.relpath(path, ROOT))

    if problems:
        print("\n%d probleme(s) :" % len(problems))
        for line in problems:
            print("  %s" % line)
        return 1
    print("\nLes 13 cibles ont une icone a la taille exacte annoncee par leur profil,"
          "\nopaque et aux quatre coins identiques.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
