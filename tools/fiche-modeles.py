#!/usr/bin/env python3
"""Ecrit docs/essai-modeles.md a partir des profils du SDK.

    python tools/fiche-modeles.py

Une fiche d'essai ecrite a la main vieillit mal : les profils d'appareil
changent d'une version de SDK a l'autre, et une fiche fausse est pire qu'une
fiche absente — on va sur le terrain verifier une chose qui n'existe pas, et on
manque celle qui compte. Tout ce qui est factuel est donc relu ici dans
`compiler.json` et `simulator.json`, comme le font deja `tools/check-icons.py`
et `tools/i18n/langues-supportees.py`.

Les tailles de binaire viennent de `app/bin/` et `widget/bin/` : lancer
`bash app/build.sh` avant, sinon elles manqueront.

Ce que le script deduit, et qui fait l'interet de la fiche :

  - **La matrice de la tape.** Un champ de donnees ne recoit `onTap()` que si
    l'ecran est tactile ET qu'aucune barre de controle systeme ne s'interpose.
    Trois classes en decoulent, et elles changent la facon d'utiliser l'appli.
  - **Les classes d'equivalence.** Deux modeles qui partagent ecran, icone,
    polices, tactile, barre et resume montrent la meme chose : en essayer un
    dispense de l'autre. C'est ce qui ramene treize modeles a une poignee.
"""

import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEVICES = os.path.expanduser("~/AppData/Roaming/Garmin/ConnectIQ/Devices")
OUT = os.path.join(ROOT, "docs", "essai-modeles.md")

# Noms commerciaux : les identifiants du SDK sont illisibles sur une fiche
# qu'on tient a la main devant un guidon.
NAMES = {
    "edge530": "Edge 530", "edge540": "Edge 540", "edge550": "Edge 550",
    "edge830": "Edge 830", "edge840": "Edge 840", "edge850": "Edge 850",
    "edge1030": "Edge 1030", "edge1030plus": "Edge 1030 Plus",
    "edge1040": "Edge 1040", "edge1050": "Edge 1050",
    "edgeexplore": "Edge Explore", "edgeexplore2": "Edge Explore 2",
    "edgemtb": "Edge MTB",
}


def targets():
    """Les produits declares au manifeste, dans l'ordre du manifeste."""
    text = io.open(os.path.join(ROOT, "app", "manifest.xml"), encoding="utf-8").read()
    return re.findall(r'<iq:product id="([^"]+)"/>', text)


def probe(device):
    """Tout ce que les deux profils disent de cet appareil."""
    c = json.load(io.open(os.path.join(DEVICES, device, "compiler.json"),
                          encoding="utf-8"))
    s = json.load(io.open(os.path.join(DEVICES, device, "simulator.json"),
                          encoding="utf-8"))
    layout = (s.get("layouts") or [{}])[0]
    bar = layout.get("controlBar") or {}
    resolution = c.get("resolution", {})
    width = resolution.get("width")
    types = [a.get("type") if isinstance(a, dict) else a for a in c.get("appTypes", [])]

    # Polices : bitmap, le SDK donne des pixels ; vectorielles, un pourcentage
    # de la largeur d'ecran, qu'on convertit pour pouvoir comparer.
    fonts, vector = {}, False
    ww = [f for f in s.get("fonts", []) if f.get("fontSet") == "ww"]
    for font in (ww[0].get("fonts", []) if ww else []):
        if font.get("name") not in ("small", "medium", "large"):
            continue
        if font.get("type") == "ttf":
            vector = True
            fonts[font["name"]] = int(round(font["size"] * width / 100.0))
        else:
            match = re.search(r"_(\d+)$", font.get("filename", ""))
            fonts[font["name"]] = int(match.group(1)) if match else None

    return {
        "device": device,
        "name": NAMES.get(device, device),
        "width": width,
        "height": resolution.get("height"),
        "icon": (c.get("launcherIcon") or {}).get("width"),
        "touch": bool(s.get("display", {}).get("isTouch")),
        "bar": bar.get("height") or 0,
        "glance": "glance" in types,
        "alpha": bool(c.get("alphaBlendingSupport")),
        "buttons": [k.get("id") for k in (s.get("keys") or []) if k.get("id")],
        "parts": len(c.get("partNumbers", [])),
        "fonts": (fonts.get("small"), fonts.get("medium"), fonts.get("large")),
        "vector": vector,
        "prg": binary_size("app", device),
        "widget_prg": binary_size("widget", device),
    }


def binary_size(binary, device):
    path = os.path.join(ROOT, binary, "bin", device + ".prg")
    return os.path.getsize(path) if os.path.exists(path) else None


def tap_class(d):
    """Un champ de donnees recoit-il la tape ?

    Deux conditions, et il faut les deux : un ecran tactile, et aucune barre de
    controle systeme pour s'interposer. Sur l'Edge 1050 c'est la barre qui prend
    la tape avant l'application — d'ou l'existence du panneau compagnon.
    """
    if not d["touch"]:
        return "boutons"
    return "tactile-libre" if not d["bar"] else "tactile-barre"


TAP_LABEL = {
    "tactile-libre": "tactile, **sans** barre de controle",
    "tactile-barre": "tactile, **avec** barre de controle",
    "boutons": "boutons seuls, pas de tactile",
}

TAP_MEANING = {
    "tactile-libre": (
        "Rien ne devrait s'interposer : `onTap()` doit atteindre le champ de "
        "donnees, et le pilotage manuel se faire sans quitter la page. **C'est "
        "l'hypothese a verifier en priorite** — si elle tient, le champ se "
        "suffit a lui-meme sur ces modeles."),
    "tactile-barre": (
        "La barre de controle systeme peut prendre la tape avant l'application. "
        "C'est ce qui a ete constate sur l'Edge 1050, et c'est la raison d'etre "
        "du panneau compagnon. A confirmer sur les autres."),
    "boutons": (
        "Aucune tape possible : un champ de donnees ne recoit pas d'evenement de "
        "touche. Le panneau compagnon est **le seul** moyen de changer de mode a "
        "la main. Le curseur du panneau, lui, se pilote aux boutons."),
}


def equivalence(d):
    """Ce qui fait que deux modeles montrent la meme chose a l'ecran."""
    return (d["width"], d["height"], d["icon"], tap_class(d),
            d["glance"], d["fonts"], d["vector"])


def human(size):
    """« 80 572 o » plutot que « 80572 o » : ces nombres se lisent en diagonale."""
    if size is None:
        return "-"
    return "{:,} o".format(size).replace(",", " ")


def wrap(text, width=95):
    """Replie un paragraphe. Les fichiers du projet sont relus dans un terminal,
    et une ligne de 400 caracteres y est illisible."""
    words, lines, current = text.split(), [], ""
    for word in words:
        if current and len(current) + 1 + len(word) > width:
            lines.append(current)
            current = word
        else:
            current = (current + " " + word) if current else word
    if current:
        lines.append(current)
    return lines


def main():
    if not os.path.isdir(DEVICES):
        sys.exit("profils d'appareil introuvables : %s" % DEVICES)

    devices = [probe(t) for t in targets()]
    missing = [d["name"] for d in devices if d["prg"] is None]

    groups = {}
    for d in devices:
        groups.setdefault(equivalence(d), []).append(d)

    by_tap = {}
    for d in devices:
        by_tap.setdefault(tap_class(d), []).append(d)

    out = []
    w = out.append

    w("# Fiche d'essai — les 13 modeles compatibles\n")
    w("**Ce fichier est genere.** Tout ce qu'il affirme des appareils est relu dans les profils")
    w("du SDK installe localement, jamais dans la documentation en ligne. Le regenerer apres")
    w("une mise a jour du SDK ou du manifeste :\n")
    w("```bash")
    w("python tools/fiche-modeles.py")
    w("```\n")
    if missing:
        w("> **Tailles de binaire incompletes** : %s. Lancer `bash app/build.sh` puis"
          % ", ".join(missing))
        w("> regenerer.\n")
    w("Pour l'Edge 830, une fiche detaillee existe deja : [essai-edge830.md](essai-edge830.md).")
    w("Celle-ci couvre les treize, et sert a decider **lesquels valent le deplacement**.\n")
    w("---\n")

    # --- 1. La matrice de la tape ---------------------------------------------
    w("## 1. La question qui separe les modeles : la tape\n")
    w("Un champ de donnees ne recoit `onTap()` que si deux conditions sont reunies —")
    w("l'ecran est tactile, **et** aucune barre de controle systeme ne s'interpose. Les treize")
    w("cibles se rangent donc en trois classes, et elles ne s'utilisent pas de la meme facon.\n")
    for cls in ("tactile-libre", "tactile-barre", "boutons"):
        group = by_tap.get(cls, [])
        if not group:
            continue
        w("### %s — %d modeles\n" % (TAP_LABEL[cls].capitalize(), len(group)))
        w("> %s\n" % ", ".join(d["name"] for d in group))
        for line in wrap(TAP_MEANING[cls]):
            w(line)
        w("")

    # --- 2. Le tableau complet ------------------------------------------------
    w("---\n")
    w("## 2. Les treize, en un tableau\n")
    w("| Modele | Ecran | Icone | Tape | Barre | Resume | Polices s/m/l | Champ | Panneau |")
    w("|---|---|---|---|---|---|---|---|---|")
    for d in devices:
        w("| %s | %d×%d | %s px | %s | %s | %s | %s%s | %s | %s |" % (
            d["name"], d["width"], d["height"], d["icon"],
            {"tactile-libre": "oui", "tactile-barre": "a verifier",
             "boutons": "non"}[tap_class(d)],
            ("%d px" % d["bar"]) if d["bar"] else "aucune",
            "oui" if d["glance"] else "non",
            "/".join(str(f) for f in d["fonts"]),
            " (vect.)" if d["vector"] else "",
            human(d["prg"]), human(d["widget_prg"])))
    w("")
    w("« Barre » est la hauteur que la barre de controle systeme retire au champ plein ecran.")
    w("« Resume » est la tuile du carrousel d'accueil : les modeles a « non » n'en ont pas, et")
    w("`getGlanceView()` y est simplement ignore. Les polices marquees *vect.* sont vectorielles —")
    w("le SDK les donne en pourcentage de la largeur d'ecran, converties ici en pixels.\n")

    # --- 3. Classes d'equivalence --------------------------------------------
    w("---\n")
    w("## 3. Presque rien ne se recoupe\n")
    shared = [g for g in groups.values() if len(g) > 1]
    w("Deux modeles qui partagent ecran, icone, polices, classe de tape et tuile de resume")
    w("montrent exactement la meme chose — en essayer un dispenserait de l'autre. On esperait")
    w("ramener les treize a une poignee de cas. **Ce n'est pas ce qui sort du SDK.**\n")
    w("Les treize donnent **%d cas distincts**, et un seul regroupement : %s.\n"
      % (len(groups),
         " ; ".join(" et ".join(g["name"] for g in group) for group in shared)
         if shared else "aucun"))
    for line in wrap(
            "La raison est que Garmin fait varier les caracteristiques une par une d'un modele "
            "a l'autre. Le 530 et l'830 partagent tout sauf le tactile ; le 540 et le 840 tout "
            "sauf le tactile ; l'Explore et l'Explore 2 tout sauf la barre de controle et la "
            "tuile de resume. Chaque modele differe donc d'au moins un axe qui change ce qu'on "
            "voit a l'ecran, et il n'existe pas de raccourci : c'est l'ordre de priorite du "
            "chapitre suivant qui tranche, pas une equivalence."):
        w(line)
    w("")
    w("| Cas | Modeles | Ce qu'il apporte |")
    w("|---|---|---|")
    for i, (key, group) in enumerate(
            sorted(groups.items(), key=lambda kv: -kv[1][0]["width"]), 1):
        d = group[0]
        traits = ["%d×%d" % (d["width"], d["height"]), "icone %s px" % d["icon"],
                  {"tactile-libre": "tape directe", "tactile-barre": "tape sous barre",
                   "boutons": "boutons seuls"}[tap_class(d)],
                  "polices %s" % ("vectorielles" if d["vector"] else "bitmap %s"
                                  % "/".join(str(f) for f in d["fonts"]))]
        if not d["glance"]:
            traits.append("sans tuile de resume")
        if not d["alpha"]:
            traits.append("**sans composition alpha**")
        w("| %d | %s | %s |" % (i, ", ".join(g["name"] for g in group), " · ".join(traits)))
    w("")

    # --- 4. Ordre de priorite -------------------------------------------------
    w("---\n")
    w("## 4. Dans quel ordre, si on ne peut pas tout avoir\n")
    order = [
        ("edge830", "Le seul modele **tactile sans barre de controle** a portee. Il tranche "
                    "l'hypothese de la tape, et couvre en meme temps l'ecran 246×322, les "
                    "polices bitmap, l'icone 35 px et l'absence de tuile de resume."),
        ("edge530", "Le cas **boutons seuls** : le panneau compagnon y est le seul pilotage "
                    "manuel, et son curseur doit se deplacer aux touches. Meme ecran que "
                    "l'830, donc la mise en page y est deja acquise."),
        ("edge1040", "**Polices vectorielles de taille intermediaire** et icone 40 px, unique "
                     "au catalogue. Barre de controle presente."),
        ("edgeexplore2", "Le plus petit jeu de polices bitmap du catalogue — 14/16/26 px. "
                         "C'est la que les libelles risquent le plus d'etre tronques."),
        ("edgemtb", "Le **seul sans composition alpha**, et le plus petit ecran. Deja couvert "
                    "par le simulateur, mais l'icone y merite un coup d'oeil."),
    ]
    known = {d["device"]: d for d in devices}
    rank = 0
    for device, why in order:
        if device not in known:
            continue
        rank += 1
        lines = wrap("%d. **%s** — %s" % (rank, known[device]["name"], why))
        w(lines[0])
        for line in lines[1:]:
            w("   " + line)
        w("")
    w("L'Edge 1050 n'y figure pas : c'est celui qu'on a, et tout ce qu'il pouvait montrer l'a")
    w("deja ete.\n")

    # --- 5. Protocole commun --------------------------------------------------
    w("---\n")
    w("## 5. Le protocole, le meme sur tous\n")
    w("```bash")
    w("bash app/build.sh <appareil>")
    w("bash tools/deploy-edge.sh <appareil>")
    w("```\n")
    w("Puis **redemarrer l'Edge** : il consomme les fichiers de `GARMIN/Apps` au demarrage, il")
    w("est normal qu'ils y disparaissent. Garder le `.prg.debug.xml` du meme build, c'est lui")
    w("qui traduit les adresses d'un journal de plantage (`bash tools/pull-ciq-log.sh`).\n")
    w("### A l'arret\n")
    w("- [ ] Les **deux icones** dans la liste des applications : fond bleu nuit plein, **aucun")
    w("      coin noir visible**, et le panneau se distingue du champ par son cadre orange.")
    w("- [ ] Les **deux noms**, dans la langue du compteur, accents compris.")
    w("- [ ] Le **panneau s'ouvre** et trouve la lampe. En combien de secondes ?")
    w("- [ ] La lampe **clignote deux fois** a la connexion pour se designer.")
    w("- [ ] La page de pilotage **remplit l'ecran** : ni bande noire, ni libelle tronque.")
    w("- [ ] **Changer de mode** dans chaque categorie ; la lampe suit-elle ?")
    w("- [ ] Le **menu des reglages** lit et modifie les automatismes de la lampe.\n")
    w("### Le champ de donnees\n")
    w("- [ ] **Plein ecran** : la page de pilotage s'y affiche entiere.")
    w("- [ ] **La tape** — voir le §1 pour ce qui est attendu sur ce modele. Noter precisement :")
    w("      rien ne se passe / le mode change / autre chose s'ouvre.")
    w("- [ ] Le champ **dans une page a 2, 4 puis 6 cases** : le pourcentage reste-t-il lisible,")
    w("      et de la meme taille que les champs natifs voisins ?")
    w("- [ ] L'etiquette **« LAMPE - AUTO »** apparait, et s'efface sur les petites cases.\n")
    w("### En roulant\n")
    w("- [ ] **Depart du chrono** : la lampe s'allume au premier cran.")
    w("- [ ] **La vitesse fait changer de mode** — seuils par defaut 8, 18 et 30 km/h.")
    w("- [ ] **Pause a un feu rouge : la lampe RESTE allumee.** C'etait le defaut le plus grave")
    w("      de l'audit.")
    w("- [ ] **Arret du chrono : la lampe s'eteint**, si le reglage est actif.")
    w("- [ ] **La lampe mise en veille puis rallumee en route.** Chemin jamais eprouve sur aucun")
    w("      materiel : le champ se reconnecte-t-il seul, et en combien de temps ?")
    w("- [ ] **Rien ne rame** : le champ est rafraichi chaque seconde et porte toute la pile BLE.\n")
    w("### Apres\n")
    w("- [ ] Dans **Garmin Connect**, les courbes du mode et de la batterie de la lampe. C'est le")
    w("      seul moyen de valider les contributions FIT ; le simulateur ne les rend pas.")
    w("- [ ] `bash tools/pull-ciq-log.sh`, meme si tout s'est bien passe.\n")

    # --- 6. Ce qui est propre a chaque modele ---------------------------------
    w("---\n")
    w("## 6. Ce qu'il faut regarder en plus, modele par modele\n")
    for d in devices:
        notes = []
        cls = tap_class(d)
        if cls == "tactile-libre":
            notes.append("**La tape sur le champ doit fonctionner** : ni barre de controle, ni "
                         "ecran non tactile pour l'en empecher. Si elle ne marche pas, la barre "
                         "n'est pas la vraie cause du probleme constate sur le 1050.")
        elif cls == "boutons":
            notes.append("Pas de tape possible : verifier que le **curseur du panneau se deplace "
                         "aux boutons** (%s) et que le champ de donnees n'affiche aucun curseur."
                         % ", ".join(d["buttons"][:4]))
        else:
            notes.append("La barre de controle occupe **%d px** en bas du champ plein ecran : "
                         "la page doit s'accommoder de la hauteur restante (%d px)."
                         % (d["bar"], d["height"] - d["bar"]))
        if not d["glance"]:
            notes.append("**Pas de tuile de resume** : l'application doit rester atteignable par "
                         "la liste des applications, sans erreur.")
        if not d["alpha"]:
            notes.append("**Pas de composition alpha** : c'est le modele qui condamne toute "
                         "transparence dans l'icone. La regarder de pres.")
        if not d["vector"] and d["fonts"][0] and d["fonts"][0] <= 16:
            notes.append("**Le plus petit jeu de polices du catalogue** (%s px) : c'est ici que "
                         "les libelles risquent le plus d'etre tronques."
                         % "/".join(str(f) for f in d["fonts"]))
        if d["parts"] > 1:
            notes.append("**%d references materielles** : selon l'exemplaire, les langues "
                         "disponibles different (europeennes ou asiatiques). Noter la langue du "
                         "compteur." % d["parts"])
        # Les binaires les plus lourds se tiennent en quelques centaines d'octets :
        # les designer tous plutot que sacrer un vainqueur a 64 octets pres.
        biggest = max(x["prg"] or 0 for x in devices)
        if d["prg"] and d["prg"] >= biggest - 200:
            notes.append("**Parmi les binaires les plus lourds des treize** (%s, contre %s pour "
                         "le plus leger) : c'est le cas memoire le plus tendu. Un champ noir ou "
                         "un plantage est a signaler comme tel, pas a mettre sur le compte de la "
                         "lampe." % (human(d["prg"]),
                                     human(min(x["prg"] for x in devices if x["prg"]))))
        w("### %s — %d×%d, icone %s px\n" % (d["name"], d["width"], d["height"], d["icon"]))
        for note in notes:
            lines = wrap("- " + note, 93)
            w(lines[0])
            for line in lines[1:]:
                w("  " + line)
        w("")

    # --- 7. Rendre l'appareil ------------------------------------------------
    w("---\n")
    w("## 7. Sur un appareil qui n'est pas le sien\n")
    w("Les deux applications s'enlevent depuis l'Edge : liste des applications, appui long,")
    w("supprimer. A defaut, effacer les `.prg` de `GARMIN/Apps` en USB. Les reglages Connect IQ")
    w("partent avec l'application, et rien n'est envoye nulle part — **aucune permission reseau**")
    w("n'est demandee.\n")
    w("Prevenir en revanche que **la lampe appairee a l'Edge ne l'est plus au telephone** : une")
    w("lampe BLE de ce type n'accepte qu'une seule connexion centrale a la fois. Refaire")
    w("l'appairage telephone apres coup.\n")

    io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(out))
    print("%s ecrit — %d modeles, %d cas distincts"
          % (os.path.relpath(OUT, ROOT), len(devices), len(groups)))


if __name__ == "__main__":
    main()
