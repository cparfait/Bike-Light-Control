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
ce sont les regles de publication.

**Les icones de lanceur sont opaques et pleines, bord a bord.** C'est la
convention de Garmin lui-meme : les icones des exemples du SDK sont des carres
pleins, sans coin arrondi et sans canal alpha, coin et centre de la meme
couleur. La version precedente dessinait un rectangle arrondi quasi-noir sur
fond transparent, et le resultat etait mauvais sur l'appareil — les coins
retombaient en noir, le carre sombre se detachait du menu, et l'Edge MTB ne
gere de toute facon pas la transparence (`alphaBlendingSupport` a False dans
son profil).

Le fond est donc le meme bleu nuit que l'icone du store : les deux se
ressemblent, ce qui est le but, et un bleu se lit comme une couleur choisie la
ou un gris a 30/255 se lit comme une erreur d'affichage.
"""

import math
import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SS = 8                       # facteur de suréchantillonnage

BG = (27, 42, 58)            # bleu nuit, commun au lanceur et au store
BEAM = (255, 160, 0)         # orange du faisceau
PANEL_FRAME = (255, 160, 0)  # cadre orange, propre au panneau

# Tailles de lanceur par appareil.
SIZES = {
    35: ["edge530", "edge540", "edge830", "edge840"],
    36: ["edge1030", "edge1030plus", "edgeexplore", "edgeexplore2", "edgemtb"],
    40: ["edge1040"],
    56: ["edge550", "edge850"],
    68: ["edge1050"],
}


def draw_icon(size, frame):
    """Dessine l'icone a `size` pixels.

    Toujours opaque et pleine : pas de canal alpha, pas de coin arrondi. Voir
    l'en-tete du module. `frame` distingue le panneau du champ de donnees.
    """
    n = size * SS
    im = Image.new("RGB", (n, n), BG)
    d = ImageDraw.Draw(im)

    # Le panneau porte un cadre : c'est ce qui le distingue du champ de
    # donnees dans la liste des applications, ou les deux se suivent.
    #
    # Un cadre plein plutot que le lisere arrondi d'avant : a 35 px celui-ci
    # tombait sous le pixel et ne laissait qu'un halo sale. Ici l'epaisseur est
    # calculee pour faire au moins deux pixels a la plus petite taille.
    inset = 0
    if frame:
        w = max(2 * SS, int(n * 0.055))
        d.rectangle([0, 0, n - 1, n - 1], outline=frame, width=w)
        inset = w

    # Tete de lampe : un disque, decale a gauche pour laisser la place au
    # faisceau. Le dessin se cale sur la zone restee libre a l'interieur du
    # cadre, sinon le panneau serait dessine plus petit que le champ.
    x0, y0 = inset, inset
    span = n - 2 * inset
    cx, cy = x0 + span * 0.30, y0 + span * 0.50
    rad = span * 0.155
    d.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], fill=BEAM)

    # Faisceau : trois traits en eventail. Deux suffiraient a 35 px, trois
    # tiennent encore et se lisent mieux a 68.
    #
    # Les trois rayons partent du **bord du disque** a distance constante et
    # ont tous la meme longueur. La version precedente les faisait aller
    # jusqu'a un meme rayon depuis le centre : projete a l'horizontale, le
    # trait du milieu paraissait alors nettement plus court que les deux
    # obliques, et l'ensemble tombait de travers.
    gap = span * 0.06
    length = span * 0.24
    width = max(1, int(span * 0.072))
    for angle in (-35, 0, 35):
        a = math.radians(angle)
        ux, uy = math.cos(a), math.sin(a)
        ax, ay = cx + (rad + gap) * ux, cy + (rad + gap) * uy
        bx, by = ax + length * ux, ay + length * uy
        d.line([ax, ay, bx, by], fill=BEAM, width=width)
        # Bouts arrondis : PIL n'en pose pas, on les ajoute a la main.
        for x, y in ((ax, ay), (bx, by)):
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
    for binary, frame in (("app", None), ("widget", PANEL_FRAME)):
        print("%s :" % binary)
        for size in sorted(SIZES):
            folder = os.path.join(ROOT, binary, "resources-icon-%d" % size)
            write(os.path.join(folder, "drawables", "launcher.png"),
                  draw_icon(size, frame))
            with open(os.path.join(folder, "drawables", "drawables.xml"),
                      "w", encoding="utf-8", newline="\n") as f:
                f.write(DRAWABLES_XML)
        # Icone de la fiche du store : 500x500. Meme dessin, meme fond que le
        # lanceur — la fiche et le compteur doivent montrer la meme image.
        write(os.path.join(ROOT, "store", "%s-icon-500.png" % binary),
              draw_icon(500, frame))


if __name__ == "__main__":
    main()
