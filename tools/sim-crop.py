#!/usr/bin/env python3
"""Decoupe l'ecran du compteur dans une capture de la fenetre du simulateur.

    python tools/sim-crop.py captures/sim/widget-edge1050.png edge1050

Une capture de fenetre contient la barre de titre, le menu, le gabarit de
l'appareil, du blanc autour et la barre d'etat du simulateur. Le Connect IQ
Store, lui, veut l'ecran et rien d'autre : c'est ce que produit ce script, aux
dimensions exactes de l'appareil.

**Rien n'est devine.** Le profil du SDK (`Devices/<appareil>/simulator.json`)
donne le fichier du gabarit et la position de l'ecran a l'interieur de celui-ci
(`display.location`). Reste a retrouver ou le gabarit a ete dessine dans la
fenetre, en deux temps :

1. **Isoler la zone de dessin.** La barre de titre, le trait sous le menu et la
   barre d'etat du bas occupent *toute* la largeur ; le gabarit, lui, laisse du
   blanc sur les cotes. On cherche donc les dernieres lignes pleines en haut et
   les premieres en bas : entre les deux, c'est la zone de dessin. Sans cette
   etape, la boite englobante du gabarit couvrait la fenetre entiere — barre de
   titre comprise — et l'ecran decoupe etait decale d'une trentaine de pixels.
2. **Mesurer le gabarit** dans cette zone, par sa boite englobante sur le blanc,
   puis appliquer l'echelle qu'il a subie a la position de l'ecran.
"""

import io
import json
import os
import sys

from PIL import Image

#: Un pixel plus clair que ceci, sur les trois canaux, compte pour du fond.
WHITE = 244

#: Pas d'echantillonnage horizontal. Le gabarit fait des centaines de pixels de
#: large : un pixel sur quatre suffit a le voir, et divise le travail par quatre.
STEP = 4


def profile(device):
    """Position de l'ecran, et boite du **corps** de l'appareil dans le gabarit.

    Pas la taille de l'image du gabarit : celle-ci porte de larges marges
    **blanches et opaques** autour de l'appareil. Les prendre pour reference
    donnait une echelle fausse d'un cinquieme, et un ecran decoupe trop petit.
    On mesure donc le corps de l'appareil dans l'image, exactement comme on le
    mesurera dans la capture.
    """
    root = os.path.join(os.environ["APPDATA"], "Garmin", "ConnectIQ",
                        "Devices", device)
    with io.open(os.path.join(root, "simulator.json"), encoding="utf-8") as f:
        j = json.load(f)
    im = Image.open(os.path.join(root, j["image"])).convert("RGB")
    w, h = im.size
    box = bezel_box(im.load(), w, 0, h)
    if box is None:
        raise SystemExit("%s : gabarit illisible" % device)
    return j["display"]["location"], box


def _row_full(px, w, y):
    """Vrai si la ligne n'a aucun pixel de fond : une barre du simulateur."""
    for x in range(0, w, STEP):
        r, g, b = px[x, y]
        if r > WHITE and g > WHITE and b > WHITE:
            return False
    return True


def canvas(px, w, h):
    """Bornes verticales de la zone de dessin, barres du simulateur exclues."""
    top = 0
    for y in range(0, int(h * 0.25)):
        if _row_full(px, w, y):
            top = y + 1
    bottom = h
    for y in range(h - 1, int(h * 0.70), -1):
        if _row_full(px, w, y):
            bottom = y
    return top, bottom


def _is_white(px, x, y):
    r, g, b = px[x, y]
    return r > WHITE and g > WHITE and b > WHITE


def _row_span(px, w, y):
    """Bords du gabarit sur une ligne, **cadre de fenetre exclu**.

    `PrintWindow` rend la fenetre avec son cadre : une bande noire de quelques
    pixels a gauche et a droite, sur toutes les lignes. Prise pour du contenu,
    elle donnait au gabarit la largeur entiere de la fenetre. On saute donc le
    cadre — tout ce qui precede le premier pixel de fond — avant de chercher le
    gabarit, et symetriquement a droite.
    """
    x = 0
    while x < w and not _is_white(px, x, y):
        x += 1                      # cadre de la fenetre
    while x < w and _is_white(px, x, y):
        x += 1                      # marge autour du gabarit
    first = x
    x = w - 1
    while x >= 0 and not _is_white(px, x, y):
        x -= 1
    while x >= 0 and _is_white(px, x, y):
        x -= 1
    return (first, x) if first < x else None


def _median(values):
    v = sorted(values)
    return v[len(v) // 2]


def bezel_box(px, w, top, bottom):
    """Boite du gabarit dans la zone de dessin, mesuree **par mediane**.

    Pas par les extremes : il suffit d'une ligne qui touche le bord — un liseré
    de fenetre, l'ombre d'une barre — pour que la boite englobante saute a la
    largeur entiere de la fenetre. Le decoupage se decalait alors d'une
    vingtaine de pixels, et l'ecran sortait avec le mot GARMIN du gabarit en
    bas. Le gabarit occupe la grande majorite des lignes de la zone de dessin :
    la mediane de leurs bords donne les siens, et les lignes aberrantes ne
    pesent rien.
    """
    spans = []
    for y in range(top, bottom):
        span = _row_span(px, w, y)
        if span is not None:
            spans.append((y, span[0], span[1]))
    if not spans:
        return None

    x0 = _median([s[1] for s in spans])
    x1 = _median([s[2] for s in spans])
    width = x1 - x0
    if width <= 0:
        return None

    # Bords haut et bas : les premieres et dernieres lignes qui appartiennent
    # vraiment au gabarit. Ses coins sont arrondis, donc on n'exige pas la
    # largeur pleine — un cinquieme suffit a distinguer le gabarit du vide.
    rows = [s[0] for s in spans if (s[2] - s[1]) > width / 5]
    if not rows:
        return None
    return (x0, min(rows), x1 + 1, max(rows) + 1)


def crop(path, device, out=None):
    im = Image.open(path).convert("RGB")
    w, h = im.size
    px = im.load()
    loc, bezel = profile(device)

    top, bottom = canvas(px, w, h)
    box = bezel_box(px, w, top, bottom)
    if box is None:
        raise SystemExit("%s : aucun gabarit trouve dans la capture" % path)

    # L'echelle rapporte le corps de l'appareil tel qu'il est dessine a celui
    # du gabarit d'origine ; la position de l'ecran, elle, est donnee dans les
    # coordonnees du gabarit entier — d'ou le retrait de son coin.
    scale = float(box[2] - box[0]) / (bezel[2] - bezel[0])
    x = box[0] + (loc["x"] - bezel[0]) * scale
    y = box[1] + (loc["y"] - bezel[1]) * scale
    shot = im.crop((int(round(x)), int(round(y)),
                    int(round(x + loc["width"] * scale)),
                    int(round(y + loc["height"] * scale))))

    # Ramene a la definition exacte de l'appareil : le store attend les pixels
    # du compteur, pas ceux de la fenetre.
    if shot.size != (loc["width"], loc["height"]):
        shot = shot.resize((loc["width"], loc["height"]), Image.LANCZOS)

    if out is None:
        base, ext = os.path.splitext(path)
        out = base + "-ecran" + ext
    shot.save(out)
    return out, shot.size, round(scale, 3)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    out, size, scale = crop(sys.argv[1], sys.argv[2],
                            sys.argv[3] if len(sys.argv) > 3 else None)
    print("%s  %dx%d  (echelle %s)" % (out, size[0], size[1], scale))
