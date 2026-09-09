#!/usr/bin/env python3
"""Ecrit les fichiers de chaines traduits a partir des tables JSON de ce dossier.

    python tools/i18n/generate.py

Une langue = un fichier `<code>.json`, ou `<code>` est le code Garmin a trois
lettres (`deu`, `zhs`, ...). Le fichier reprend la structure des trois jeux de
ressources — `shared`, `app`, `widget` — et doit declarer **exactement** les
memes identifiants que l'anglais, qui fait reference : un identifiant present
d'un seul cote compile sans erreur et manque a l'execution, sur les seuls
appareils configures dans cette langue. D'ou la verification ci-dessous, qui
refuse d'ecrire quoi que ce soit tant que les jeux ne correspondent pas.

L'anglais (`resources/`) et le francais (`resources-fre/`) restent ecrits a la
main : ils portent les commentaires de maintenance, que ce script ne genere pas.
"""

import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.join(ROOT, "tools", "i18n")

# Repertoire de ressources anglais de chaque jeu, qui sert de reference.
SETS = {
    "shared": os.path.join(ROOT, "shared"),
    "app": os.path.join(ROOT, "app"),
    "widget": os.path.join(ROOT, "widget"),
}

HEADER = """<!--
  {label} — genere par tools/i18n/generate.py, ne pas editer a la main.

  La table de traduction est dans tools/i18n/{code}.json. Les identifiants
  doivent rester identiques a ceux de resources/strings/strings.xml : un
  identifiant manquant ne se voit qu'a l'execution, et seulement sur un
  appareil configure dans cette langue.
-->
"""

LABELS = {
    "deu": "Deutsch", "spa": "Espanol", "ita": "Italiano", "por": "Portugues",
    "dut": "Nederlands", "pol": "Polski", "rus": "Russkij", "jpn": "Nihongo",
    "kor": "Hangugeo", "zhs": "Jianti zhongwen", "zht": "Fanti zhongwen",
}


def english(setname):
    path = os.path.join(SETS[setname], "resources", "strings", "strings.xml")
    text = io.open(path, encoding="utf-8").read()
    return re.findall(r'<string id="([^"]+)">(.*?)</string>', text, re.S)


def escape(value):
    # Seules ces trois entites sont necessaires dans un contenu d'element.
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def main():
    reference = {name: [i for i, _ in english(name)] for name in SETS}
    codes = sorted(f[:-5] for f in os.listdir(HERE) if f.endswith(".json")
                   and f[:-5] in LABELS)
    if not codes:
        sys.exit("aucune table de langue dans %s" % HERE)

    problems = []
    for code in codes:
        table = json.load(io.open(os.path.join(HERE, code + ".json"),
                                  encoding="utf-8"))
        for name, want in reference.items():
            got = table.get(name, {})
            missing = [i for i in want if i not in got]
            extra = [i for i in got if i not in want]
            if missing:
                problems.append("%s/%s : manquants %s" % (code, name, missing))
            if extra:
                problems.append("%s/%s : en trop %s" % (code, name, extra))
    if problems:
        sys.exit("\n".join(problems))

    written = 0
    for code in codes:
        table = json.load(io.open(os.path.join(HERE, code + ".json"),
                                  encoding="utf-8"))
        for name, want in reference.items():
            folder = os.path.join(SETS[name], "resources-" + code, "strings")
            if not os.path.isdir(folder):
                os.makedirs(folder)
            lines = [HEADER.format(label=LABELS[code], code=code), "<strings>\n"]
            for key in want:
                lines.append('    <string id="%s">%s</string>\n'
                             % (key, escape(table[name][key])))
            lines.append("</strings>\n")
            io.open(os.path.join(folder, "strings.xml"), "w",
                    encoding="utf-8", newline="\n").write("".join(lines))
            written += 1
    print("%d fichiers ecrits, %d langues, %d chaines chacune"
          % (written, len(codes), sum(len(v) for v in reference.values())))


if __name__ == "__main__":
    main()
