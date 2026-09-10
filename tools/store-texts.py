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

#: Langues du formulaire, dans l'ordre de la table des titres du fichier
#: source. Le nom est celui qu'affiche le formulaire de Garmin.
LANGS = ["en", "fr", "de", "es", "it", "pt", "nl", "pl", "ru", "ja", "ko",
         "zh-CN", "zh-TW"]


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
        f.write("# langue\tchamp de donnees\tapplication\n")
        for lang in LANGS:
            if lang not in rows:
                continue
            champ, appli = rows[lang]
            f.write("%s\t%s\t%s\n" % (lang, champ, appli))
            for title in (champ, appli):
                if len(title) > TITLE_MAX:
                    problems.append("%s : %s (%d)" % (lang, title, len(title)))
    print("  %-44s %5d langues" % (os.path.relpath(path, ROOT), len(rows)))

    if problems:
        raise SystemExit("Textes hors limites :\n  " + "\n  ".join(problems))
    print("\nTextes prets dans store/listing/. La verite reste fiches-store.md.")


if __name__ == "__main__":
    main()
