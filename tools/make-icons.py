#!/usr/bin/env python3
"""Genere les icones de lanceur, une par taille d'ecran, et l'icone du store.

Pourquoi un script plutot qu'un fichier dessine une fois : chaque modele d'Edge
attend une taille d'icone precise, et il y en a cinq differentes sur les 13
cibles. Une icone unique laissee au compilateur est redimensionnee en silence,
avec la perte de nettete correspondante sur les petits ecrans — 68 px ramenes a
35, c'est un facteur deux sur une image deja minuscule.

Le dessin est donc vectoriel, rendu huit fois trop grand puis reduit en Lanczos :
les traits restent nets a 35 px comme a 500.

    python tools/make-icons.py

Tailles attendues (source : forum developpeurs Garmin, verifie contre les
profils du SDK) :

    35  edge530 edge540 edge830 edge840
    36  edge1030 edge1030plus edgeexplore edgeexplore2 edgemtb
    40  edge1040
    56  edge550 edge850
    68  edge1050

L'icone du store fait 500x500, en sRGB, sans transparence et sans fond noir —
ce sont les regles de publication. D'ou un fond bleu nuit plutot que le
quasi-noir des icones de lanceur, qui, lui, se fond dans l'interface du
compteur.
"""

import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SS = 8                       # facteur de suréchantillonnage

LAUNCHER_BG = (30, 30, 30)   # quasi-noir : la couleur de fond des menus Edge
STORE_BG = (27, 42, 58)      # bleu nuit : le store refuse un fond noir
BEAM = (255, 160, 0)         # orange du faisceau
PANEL_RING = (255, 160, 0)

# Tailles de lanceur par appareil.
SIZES = {
    35: ["edge530", "edge540", "edge830", "edge840"],
    36: ["edge1030", "edge1030plus", "edgeexplore", "edgeexplore2", "edgemtb"],
    40: ["edge1040"],
    56: ["edge550", "edge850"],
    68: ["edge1050"],
}


def draw_icon(size, bg, ring, alpha_bg=True):
    """Dessine l'icone a `size` pixels. `ring` distingue le panneau du champ."""
    n = size * SS
    mode = "RGBA" if alpha_bg else "RGB"
    im = Image.new(mode, (n, n), (0, 0, 0, 0) if alpha_bg else bg)
    d = ImageDraw.Draw(im)

    # Fond : carre a coins arrondis, comme les icones systeme.
    r = int(n * 0.22)
    d.rounded_rectangle([0, 0, n - 1, n - 1], radius=r,
                        fill=bg + ((255,) if alpha_bg else ()))

    # Le panneau porte un liseré : c'est ce qui le distingue du champ de
    # donnees dans la liste des applications, ou les deux se suivent.
    if ring:
        w = max(1, int(n * 0.045))
        m = int(n * 0.10)
        d.rounded_rectangle([m, m, n - 1 - m, n - 1 - m],
                            radius=int(n * 0.14), outline=ring, width=w)

    # Tete de lampe : un disque, decale a gauche pour laisser la place au
    # faisceau.
    cx, cy = n * 0.36, n * 0.50
    rad = n * (0.15 if ring else 0.17)
    d.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], fill=BEAM)

    # Faisceau : trois traits en eventail. Deux suffiraient a 35 px, trois
    # tiennent encore et se lisent mieux a 68.
    import math
    inner = rad * 1.45
    outer = n * (0.44 if ring else 0.47)
    width = max(1, int(n * 0.065))
    for angle in (-34, 0, 34):
        a = math.radians(angle)
        x0, y0 = cx + inner * math.cos(a), cy + inner * math.sin(a)
        x1, y1 = cx + outer * math.cos(a), cy + outer * math.sin(a)
        d.line([x0, y0, x1, y1], fill=BEAM, width=width)
        # Bouts arrondis : PIL n'en pose pas, on les ajoute a la main.
        for x, y in ((x0, y0), (x1, y1)):
            h = width / 2.0
            d.ellipse([x - h, y - h, x + h, y + h], fill=BEAM)

    return im.resize((size, size), Image.LANCZOS)


def write(path, im):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print("  %-58s %dx%d" % (os.path.relpath(path, ROOT), im.size[0], im.size[1]))


DRAWABLES_XML = """<!--
  Icone de lanceur a la taille exacte attendue par les appareils de ce groupe.
  Genere par tools/make-icons.py — ne pas retoucher a la main.
-->
<drawables>
    <bitmap id="LauncherIcon" filename="launcher.png"/>
</drawables>
"""


def main():
    for binary, ring in (("app", None), ("widget", PANEL_RING)):
        print("%s :" % binary)
        for size in sorted(SIZES):
            folder = os.path.join(ROOT, binary, "resources-icon-%d" % size)
            write(os.path.join(folder, "drawables", "launcher.png"),
                  draw_icon(size, LAUNCHER_BG, ring))
            with open(os.path.join(folder, "drawables", "drawables.xml"),
                      "w", encoding="utf-8", newline="\n") as f:
                f.write(DRAWABLES_XML)
        # Icone de la fiche du store : 500x500, opaque, fond non noir.
        write(os.path.join(ROOT, "store", "%s-icon-500.png" % binary),
              draw_icon(500, STORE_BG, ring, alpha_bg=False))


if __name__ == "__main__":
    main()
