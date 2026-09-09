#!/usr/bin/env python3
"""Retablit les accents dans les chaines francaises.

    python tools/i18n/accents-fre.py

Les trois fichiers `resources-fre/strings/strings.xml` avaient ete ecrits en
ASCII pur : « Eteindre », « reglages », « caracteristiques ». Rien ne l'imposait
— les references materielles qui portent le francais portent aussi les
diacritiques latines, et l'application affiche desormais du japonais et du
coreen sur les references APAC — et un francais sans accents se voit
immediatement a l'ecran.

Le remplacement se fait **par identifiant** et sur la valeur entiere, jamais par
mot : « Route » est a la fois une categorie et un prefixe de mode, et une
substitution textuelle aurait touche les deux sans distinction.

Ce script est idempotent : une valeur deja accentuee n'est pas retouchee. Il ne
sert qu'une fois, mais il documente ce qui a ete change et permet de le rejouer
si le fichier est regenere.
"""

import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# identifiant -> valeur accentuee. Seuls les accents changent : la formulation,
# la ponctuation et les espaces significatifs — « PrefixSpecial » est suivi
# d'un numero — restent tels quels.
FIXES = {
    "shared/resources-fre/strings/strings.xml": {
        "TypeTail": "Arrière",
        "CatOff": "Éteint",
        "LvlHigh": "Élevé",
        "ModeOff": "Éteint",
        "ShortDipHigh": "Cr. élevé",
        "ShortMainHigh": "Rt. élevé",
        "ModeDipHigh": "Croisement élevé",
        "ModeMainHigh": "Route élevé",
        "ModeSteadyHigh": "Fixe élevé",
        "ModeGradient": "Dégradé",
        "ModeComet": "Comète",
        "PrefixCustomLong": "Personnalisé ",
        "PrefixSpecial": "Spécial ",
        "MsgConnectingHint": "lampe trouvée",
        "MsgNearby": " lampes à proximité",
        "MsgOtherLightHint": "Chercher à nouveau",
        "ErrScanRefused": "scan refusé",
        "ErrProfilesRefused": "profils refusés",
        "ErrWriteRefused": "écriture refusée",
        "ErrProfileRegister": "enregistrement du profil en échec",
        "ErrCharsMissing": "caractéristiques absentes",
        "ErrSubscribeRefused": "abonnement refusé",
        "ErrWriteFailed": "écriture en échec",
        "ErrBatterySubscribe": "abonnement batterie refusé",
    },
    "app/resources-fre/strings/strings.xml": {
        "AppName": "Commande éclairage vélo",
        "SetSyncOff": "Éteindre la lampe à l'arrêt de l'activité",
        "SetLightOnStart": "Allumer la lampe au départ de l'activité",
    },
    "widget/resources-fre/strings/strings.xml": {
        "AppName": "Panneau éclairage vélo",
        "MenuTitle": "Réglages",
        "HintNotConnected": "Lampe non connectée",
        "LampLumenVary": "Luminosité selon vitesse",
        "HintByLamp": "Géré par la lampe",
        "LampAutoLight": "Capteur de luminosité",
        "LampSyncOff": "Extinction synchronisée",
        "HintFollowsTimer": "Suit l'arrêt du compteur",
        "LampAutoStart": "Allumage au départ",
        "HintOnStart": "À la mise en route",
        "HintAfterIdle": "Après immobilité",
        "SleepDelay": "Délai de veille",
        "LampAutoLow": "Luminosité réduite à l'arrêt",
        "LowDelay": "Délai avant réduction",
        "AppSettings": "Réglages de l'application",
        "HintSeparate": "Distincts du champ de données",
        "OffAtEnd": "Éteindre en fin d'activité",
        "OnAtStart": "Allumer au départ",
        "StateDisabled": "Désactivé",
    },
}


def main():
    changed = 0
    for relative, table in FIXES.items():
        path = os.path.join(ROOT, *relative.split("/"))
        text = io.open(path, encoding="utf-8").read()
        for key, value in table.items():
            pattern = r'(<string id="%s">)(.*?)(</string>)' % re.escape(key)
            match = re.search(pattern, text, re.S)
            if match is None:
                sys.exit("identifiant absent de %s : %s" % (relative, key))
            if match.group(2) == value:
                continue
            text = text[:match.start(2)] + value + text[match.end(2):]
            changed += 1
        io.open(path, "w", encoding="utf-8", newline="").write(text)
    print("%d chaines francaises accentuees" % changed)


if __name__ == "__main__":
    main()
