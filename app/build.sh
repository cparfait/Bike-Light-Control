#!/usr/bin/env bash
#
# Construit les deux binaires pour les appareils cibles, ou lance les tests.
#
#   bash app/build.sh            # release, data field + widget, les 13 cibles
#   bash app/build.sh edge1050   # release, un seul appareil
#   bash app/build.sh test       # tests unitaires dans le simulateur (edge1050)
#   bash app/build.sh test edge530   # tests sur un autre profil d'appareil
#   bash app/build.sh debug      # build de debogage pour l'Edge 1050
#   bash app/build.sh package    # paquets .iq pour le Connect IQ Store
#
# Deux binaires sont produits : le data field (app/bin/) tourne pendant
# l'activite, le widget (widget/bin/) pilote la lampe a l'arret et sur les Edge
# a boutons. Ils partagent le code de shared/.
#
# La liste des cibles vient de docs/compatibilite-edge.md ; la regenerer avec
# tools/check-ble-devices.sh apres une mise a jour du SDK.

set -uo pipefail
APP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$APP")"

TARGETS="edge530 edge540 edge550 edge830 edge840 edge850 edge1030 edge1030plus \
edge1040 edge1050 edgeexplore edgeexplore2 edgemtb"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m!!!\033[0m %s\n' "$*" >&2; exit 1; }

# --- Localisation du JDK et du SDK -------------------------------------------
if [ -z "${JAVA_HOME:-}" ] || [ ! -x "${JAVA_HOME}/bin/java" ]; then
  JAVA_HOME=$(ls -d "/c/Program Files/Eclipse Adoptium/jdk-"*"-hotspot" 2>/dev/null | sort -V | tail -1)
fi
[ -n "${JAVA_HOME:-}" ] || die "JDK introuvable. Installer un JDK 11+ (winget install EclipseAdoptium.Temurin.21.JDK)."
export JAVA_HOME

# $APPDATA est en forme Windows (C:\...) : inutilisable tel quel dans le PATH
# de MSYS, qui attend /c/... — d'ou la conversion par cygpath.
SDK_ROOT="${APPDATA:-}"
if [ -n "$SDK_ROOT" ] && command -v cygpath >/dev/null 2>&1; then
  SDK_ROOT="$(cygpath -u "$SDK_ROOT")"
else
  SDK_ROOT="$HOME/AppData/Roaming"
fi
SDK_ROOT="$SDK_ROOT/Garmin/ConnectIQ/Sdks"
SDK=$(ls -d "$SDK_ROOT"/connectiq-sdk-* 2>/dev/null | sort -V | tail -1)
[ -n "$SDK" ] || die "SDK Connect IQ introuvable dans $SDK_ROOT."
export PATH="$JAVA_HOME/bin:$SDK/bin:$PATH"

KEY="$ROOT/developer_key.der"
[ -f "$KEY" ] || die "Cle developpeur absente : $KEY
  openssl genrsa -out developer_key.pem 4096
  openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt"

cd "$APP"
mkdir -p bin
log "SDK $(basename "$SDK")"
log "JDK $("$JAVA_HOME/bin/java" -version 2>&1 | head -1)"

MODE="${1:-all}"

# --- Tests unitaires ----------------------------------------------------------
if [ "$MODE" = "test" ]; then
  # Un appareil peut etre passe en second argument : les tests de mise en page
  # valent pour les 13 cibles, mais le reste du binaire s'execute sur celui-la.
  #   bash app/build.sh test edge530
  DEV="${2:-edge1050}"
  log "Compilation des tests ($DEV)…"
  monkeyc -f monkey.jungle -o bin/test.prg -y "$KEY" -d "$DEV" --unit-test || die "compilation en echec"
  # Un simulateur laisse par une execution precedente reste souvent dans un
  # etat ou monkeydo attend indefiniment sans rien afficher. On repart propre.
  if tasklist 2>/dev/null | grep -qi simulator; then
    log "Arret du simulateur precedent…"
    taskkill //IM simulator.exe //F >/dev/null 2>&1
    sleep 3
  fi
  log "Demarrage du simulateur…"
  "$SDK/bin/connectiq.bat" >/dev/null 2>&1 &
  sleep 22
  log "Execution…"
  exec monkeydo bin/test.prg "$DEV" -t
fi

# --- Build de debogage --------------------------------------------------------
if [ "$MODE" = "debug" ]; then
  log "Build de debogage (edge1050)…"
  exec monkeyc -f monkey.jungle -o bin/lampe-debug.prg -y "$KEY" -d edge1050
fi

# --- Paquet de distribution ---------------------------------------------------
# Un fichier .iq contient les binaires de TOUS les appareils declares au
# manifeste : c'est ce qu'on depose sur le Connect IQ Store, et l'utilisateur
# n'installe qu'une seule application. Les .prg par appareil ne sont qu'un
# artefact de compilation, pas des versions differentes.
if [ "$MODE" = "package" ]; then
  mkdir -p "$ROOT/dist"
  # Un nom de paquet par binaire : les deux fiches du store sont distinctes,
  # et « iG-Edge » ne peut pas servir de titre (marques Garmin et iGPSPORT).
  for dir in app widget; do
    case "$dir" in
      app)    name="bike-light-control" ;;
      widget) name="bike-light-panel" ;;
    esac
    log "Paquet $dir ($name.iq)…"
    ( cd "$ROOT/$dir" && monkeyc -e -f monkey.jungle -y "$KEY"         -o "$ROOT/dist/$name.iq" -r -O 2 ) || die "paquet $dir en echec"
    printf '  %-24s %8d octets
' "$name.iq" "$(stat -c %s "$ROOT/dist/$name.iq")"
  done
  log "Paquets prets dans dist/."
  exit 0
fi

# --- Build release ------------------------------------------------------------
[ "$MODE" = "all" ] || TARGETS="$MODE"

fail=0

# -r retire les symboles de debogage : 110 Ko -> 16 Ko, ce qui compte face a la
# limite de 128 Ko des data fields. -O 2 plutot que -O z, qui produit
# paradoxalement un binaire plus gros sur ce code.
build_one() {
  ( cd "$ROOT/$1" && mkdir -p bin     && monkeyc -f monkey.jungle -o "bin/$2.prg" -y "$KEY" -d "$2" -r -O 2 ) >/dev/null 2>&1
}

printf '  %-14s %12s %12s
' "APPAREIL" "DATA FIELD" "WIDGET"
for dev in $TARGETS; do
  if build_one app "$dev"; then a="$(stat -c %s "$ROOT/app/bin/$dev.prg") o"
  else a="ECHEC"; fail=$((fail + 1)); fi
  if build_one widget "$dev"; then w="$(stat -c %s "$ROOT/widget/bin/$dev.prg") o"
  else w="ECHEC"; fail=$((fail + 1)); fi
  printf '  %-14s %12s %12s
' "$dev" "$a" "$w"
done

echo
if [ "$fail" -eq 0 ]; then
  log "Construits dans app/bin/ (data field) et widget/bin/ (widget)."
else
  die "$fail construction(s) en echec."
fi
