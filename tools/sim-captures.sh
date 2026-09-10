#!/usr/bin/env bash
#
# Capture la page de pilotage dans le simulateur, un PNG par modele.
#
#   bash tools/sim-captures.sh                      # widget, les 6 formats
#   bash tools/sim-captures.sh app                  # champ de donnees
#   bash tools/sim-captures.sh widget edge530 edgemtb
#
# Les images vont dans captures/sim/, exclu du depot : ce sont des artefacts,
# on les regenere. Elles servent a deux choses — verifier la mise en page sur
# les six formats d'ecran sans posseder treize compteurs, et produire les
# captures que le Connect IQ Store exige par fiche.
#
# Le simulateur n'ayant pas de pile Bluetooth, le binaire est construit en mode
# demonstration (sim.jungle, shared/LampDemo.mc) : sans cela la page resterait
# sur « Recherche ». Ces binaires ne doivent jamais etre deposes.
#
# Par defaut, un modele par format d'ecran plutot que les treize : deux modeles
# de meme format donnent la meme image au pixel pres.

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WROOT="$(cygpath -w "$ROOT")"

DIR="${1:-widget}"
shift 2>/dev/null || true
DEVICES=("$@")
if [ ${#DEVICES[@]} -eq 0 ]; then
  # Un par format : 240x320, 240x400, 246x322, 282x470, 420x600, 480x800.
  DEVICES=(edgemtb edgeexplore edge530 edge1030 edge550 edge1050)
fi

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m!!!\033[0m %s\n' "$*" >&2; exit 1; }

if [ -z "${JAVA_HOME:-}" ] || [ ! -x "${JAVA_HOME}/bin/java" ]; then
  JAVA_HOME=$(ls -d "/c/Program Files/Eclipse Adoptium/jdk-"*"-hotspot" 2>/dev/null | sort -V | tail -1)
fi
export JAVA_HOME
SDK_ROOT="$(cygpath -u "${APPDATA}")/Garmin/ConnectIQ/Sdks"
SDK=$(ls -d "$SDK_ROOT"/connectiq-sdk-* 2>/dev/null | sort -V | tail -1)
[ -n "$SDK" ] || die "SDK Connect IQ introuvable."
export PATH="$JAVA_HOME/bin:$SDK/bin:$PATH"
KEY="$ROOT/developer_key.der"
[ -f "$KEY" ] || die "Cle developpeur absente : $KEY"

OUT="$ROOT/captures/sim"
mkdir -p "$OUT"

# Un simulateur laisse par une execution precedente attend souvent
# indefiniment sans rien afficher. On repart propre, une seule fois pour toute
# la serie : le relancer entre chaque modele couterait vingt secondes chacun.
if tasklist 2>/dev/null | grep -qi simulator; then
  log "Arret du simulateur precedent…"
  taskkill //IM simulator.exe //F >/dev/null 2>&1
  sleep 3
fi
log "Demarrage du simulateur…"
"$SDK/bin/connectiq.bat" >/dev/null 2>&1 &
sleep 22

fail=0
for dev in "${DEVICES[@]}"; do
  log "$dev…"
  ( cd "$ROOT/$DIR" && monkeyc -f "monkey.jungle;sim.jungle" \
      -o "bin/sim-$dev.prg" -y "$KEY" -d "$dev" ) >/dev/null 2>&1 \
    || { printf '  %-14s ECHEC compilation\n' "$dev"; fail=$((fail + 1)); continue; }

  # monkeydo ne rend la main qu'a la fermeture de l'application : on le laisse
  # en tache de fond, on capture, puis on passe au suivant — le chargement
  # suivant remplace celui-ci dans le meme simulateur.
  monkeydo "$ROOT/$DIR/bin/sim-$dev.prg" "$dev" >/dev/null 2>&1 &
  sleep 12
  powershell -NoProfile -File "$WROOT\\tools\\sim-shot.ps1" \
      -Out "$WROOT\\captures\\sim\\$DIR-$dev.png" \
    || { printf '  %-14s ECHEC capture\n' "$dev"; fail=$((fail + 1)); }
done

echo
[ "$fail" -eq 0 ] || die "$fail modele(s) en echec."
log "Captures dans captures/sim/."
