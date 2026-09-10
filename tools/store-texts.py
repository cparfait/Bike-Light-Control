#!/usr/bin/env python3
"""Extrait de `store/fiches-store.md` les textes a coller dans le formulaire.

    python tools/store-texts.py

Ecrit `store/listing/` : un fichier par champ et par langue, en texte brut, sans
la citation Markdown ni les retours a la ligne du fichier source. Le formulaire
du Connect IQ Store attend du texte suivi ; y coller des lignes coupees a
quatre-vingts colonnes donne une description hachee.

**La verite reste `fiches-store.md`.** Ces fichiers en sont derives : les
modifier ne sert a rien, ils sont reecrits au prochain passage. C'est le meme
principe que les tables de traduction de `tools/i18n/`.

Les limites du formulaire sont verifiees au passage — 50 caracteres pour un
titre, 4000 pour une description — parce qu'on ne s'en apercoit sinon qu'une
fois le texte colle et tronque.
"""

import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, "store", "fiches-store.md")
OUT = os.path.join(ROOT, "store", "listing")

TITLE_MAX = 50
DESC_MAX = 4000

#: Les deux fiches, et le nom des fichiers produits.
CARDS = [("Champ de données — description", "control"),
         ("Application — description", "panel")]

#: Langues du formulaire, et **le libelle exact de l'onglet** tel que le
#: formulaire de Garmin l'affiche.
#:
#: Le libelle plutot que le code : un onglet asiatique ne se reconnait pas a
#: l'oeil quand on ne lit pas la langue, et se tromper d'onglet met le titre
#: coreen sur la fiche japonaise sans que rien ne le signale. En recopiant le
#: libelle tel qu'il s'affiche, la ligne se retrouve par simple comparaison.
LANGS = [("en", "English"), ("fr", "Francais"), ("de", "Deutsch"),
         ("es", "Espanol"), ("it", "Italiano"), ("pt", "Portugues (Portugal)"),
         ("nl", "Nederlands"), ("pl", "Polski"), ("ru", "Russkij"),
         ("ja", "JAPONAIS"), ("ko", "COREEN"),
         ("zh-CN", "CHINOIS SIMPLIFIE"), ("zh-TW", "CHINOIS TRADITIONNEL")]


#: Le libelle des onglets asiatiques, ecrit avec ses propres caracteres. Il est
#: pose ici et non dans LANGS pour que le fichier reste lisible dans un editeur
#: qui ne rendrait pas ces ecritures.
LABELS = {"ja": "\u65e5\u672c\u8a9e  (japonais)",
          "ko": "\ud55c\uad6d\uc5b4  (coreen)",
          "zh-CN": "\u7b80\u4f53\u4e2d\u6587  (chinois simplifie)",
          "zh-TW": "\u7e41\u9ad4\u4e2d\u6587  (chinois traditionnel)",
          "ru": "\u0420\u0443\u0441\u0441\u043a\u0438\u0439",
          "fr": "Fran\u00e7ais", "es": "Espa\u00f1ol",
          "pt": "Portugu\u00eas (Portugal)"}


def paragraphs(block):
    """Rend le texte suivi : la citation retiree, les lignes recollees."""
    lines = [re.sub(r"^>\s?", "", l) for l in block.strip().split("\n")]
    text = "\n".join(lines).replace("**", "")
    out, para = [], []
    for line in text.split("\n"):
        if line.strip() == "":
            if para:
                out.append(" ".join(para))
                para = []
            out.append("")
        else:
            para.append(line.strip())
    if para:
        out.append(" ".join(para))
    # Les lignes vides en trop se reduisent a une seule : un formulaire ne
    # rend pas deux sauts de ligne differemment d'un seul.
    joined = "\n".join(out)
    return re.sub(r"\n{3,}", "\n\n", joined).strip()


def descriptions(source):
    for heading, name in CARDS:
        block = source.split("## " + heading)[1]
        block = re.split(r"\n## |\n---", block)[0]
        en = block.split("**Anglais**")[1].split("**Français**")[0]
        fr = block.split("**Français**")[1]
        yield name, "en", paragraphs(en)
        yield name, "fr", paragraphs(fr)


def titles(source):
    """Table des titres : une ligne « | Titre (xx) | champ | appli |»."""
    rows = {}
    for line in source.split("\n"):
        m = re.match(r"\|\s*Titre \(([\w-]+)\)\s*\|([^|]+)\|([^|]+)\|", line)
        if m:
            rows[m.group(1)] = (m.group(2).strip(), m.group(3).strip())
    return rows


def main():
    source = io.open(SOURCE, encoding="utf-8").read()
    if not os.path.isdir(OUT):
        os.makedirs(OUT)

    problems = []
    for name, lang, text in descriptions(source):
        path = os.path.join(OUT, "%s-description-%s.txt" % (name, lang))
        io.open(path, "w", encoding="utf-8", newline="\n").write(text + "\n")
        flag = "" if len(text) <= DESC_MAX else "  DEPASSE %d" % DESC_MAX
        if flag:
            problems.append(path)
        print("  %-44s %5d caracteres%s"
              % (os.path.relpath(path, ROOT), len(text), flag))

    rows = titles(source)
    path = os.path.join(OUT, "titres.txt")
    with io.open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("# Onglet du formulaire  ->  titre a coller\n#\n")
        for lang, label in LANGS:
            if lang not in rows:
                continue
            champ, appli = rows[lang]
            f.write("%s\n" % LABELS.get(lang, label))
            f.write("   champ de donnees : %s\n" % champ)
            f.write("   application      : %s\n\n" % appli)
            for title in (champ, appli):
                if len(title) > TITLE_MAX:
                    problems.append("%s : %s (%d)" % (lang, title, len(title)))
    print("  %-44s %5d langues" % (os.path.relpath(path, ROOT), len(rows)))

    if problems:
        raise SystemExit("Textes hors limites :\n  " + "\n  ".join(problems))
    print("\nTextes prets dans store/listing/. La verite reste fiches-store.md.")


if __name__ == "__main__":
    main()
