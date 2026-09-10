#!/usr/bin/env python3
"""Genere l'image de banniere des fiches du store, 1440x720.

    python tools/make-hero.py

Le formulaire du Connect IQ Store l'appelle « Hero Image » et la dit
facultative : c'est l'image large qui presente l'application sur mobile. Sans
elle, la fiche montre l'icone seule sur une bande vide.

Elle reprend, sans rien inventer, ce que la fiche a deja : le bleu nuit et le
pictogramme de phare de l'icone, et une **vraie capture** de la page prise dans
le simulateur. Une banniere qui montrerait autre chose que l'application
serait une promesse a tenir.

Contraintes du formulaire : 1440x720 exactement, JPG, GIF ou PNG, 2048 Ko au
plus. La notre pese quelques dizaines de kilo-octets.
"""

import io
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = 1440, 720
BG = (27, 42, 58)            # bleu nuit, celui de l'icone
BEAM = (255, 170, 0)         # ambre, celui de l'accent de l'application
TEXT = (255, 255, 255)
DIM = (150, 165, 180)

#: Une police du systeme, essayee dans l'ordre. Aucune n'est embarquee : la
#: banniere se regenere sur la machine qui a le SDK, pas sur n'importe laquelle.
FONTS = ["segoeuib.ttf", "arialbd.ttf", "calibrib.ttf", "DejaVuSans-Bold.ttf"]
FONTS_LIGHT = ["segoeui.ttf", "arial.ttf", "calibri.ttf", "DejaVuSans.ttf"]


def font(names, size):
    for name in names:
        for folder in (r"C:\Windows\Fonts", "/usr/share/fonts/truetype/dejavu"):
            path = os.path.join(folder, name)
            if os.path.exists(path):
                return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def headlight(d, cx, cy, r, color):
    """Le pictogramme de phare, comme sur l'icone et sur les tuiles."""
    pen = max(2, int(r * 0.17))
    dr = (r - pen / 2.0) * 0.86
    dx = cx - r + pen / 2.0 + dr
    d.arc([dx - dr, cy - dr, dx + dr, cy + dr], 90, 270, fill=color, width=pen)
    d.line([dx, cy - dr, dx, cy + dr], fill=color, width=pen)
    bx0, bx1 = dx + dr * 0.45, cx + r - pen / 2.0
    for k in (-3, -1, 1, 3):
        y = cy + k * dr / 4.0
        d.line([bx0, y, bx1, y], fill=color, width=pen)
        for x in (bx0, bx1):
            h = pen / 2.0
            d.ellipse([x - h, y - h, x + h, y + h], fill=color)


def main():
    shot_path = os.path.join(ROOT, "store", "screenshots", "control-1-edge1050.png")
    if not os.path.exists(shot_path):
        raise SystemExit("Capture absente : %s\n"
                         "La produire avec `bash tools/sim-captures.sh app edge1050`."
                         % os.path.relpath(shot_path, ROOT))

    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)

    # La capture, a droite, a la hauteur de la banniere moins une marge. Elle
    # garde ses proportions : un ecran de compteur etire se reconnait tout de
    # suite, et sur une fiche ca fait amateur.
    shot = Image.open(shot_path).convert("RGB")
    target_h = H - 120
    target_w = int(shot.width * target_h / shot.height)
    shot = shot.resize((target_w, target_h), Image.LANCZOS)
    shot_x = W - target_w - 120
    im.paste(shot, (shot_x, (H - target_h) // 2))

    # Un filet ambre autour de la capture : sans lui, le noir de l'ecran se
    # fond dans le bleu nuit et l'appareil n'a plus de contour.
    d.rectangle([shot_x - 2, (H - target_h) // 2 - 2,
                 shot_x + target_w + 1, (H + target_h) // 2 + 1],
                outline=BEAM, width=3)

    # Le titre et la ligne d'explication, a gauche.
    left = 96
    headlight(d, left + 62, 250, 62, BEAM)
    d.text((left, 340), "Bike Light Control", font=font(FONTS, 72), fill=TEXT)
    d.text((left, 432), "Pilotez votre lampe iGPSPORT", font=font(FONTS_LIGHT, 38), fill=BEAM)
    d.text((left, 486), "depuis votre compteur, en roulant.", font=font(FONTS_LIGHT, 38), fill=DIM)

    out = os.path.join(ROOT, "store", "hero-1440x720.png")
    im.save(out)
    size = os.path.getsize(out)
    print("  %-34s %dx%d  %.0f Ko" % (os.path.relpath(out, ROOT), W, H, size / 1024))
    if size > 2048 * 1024:
        raise SystemExit("Trop lourde : le formulaire plafonne a 2048 Ko.")


if __name__ == "__main__":
    main()
