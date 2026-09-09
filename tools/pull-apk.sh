#!/usr/bin/env bash
#
# Extrait l'APK de l'app iGPSPORT depuis un téléphone Android connecté en USB.
#
#   bash tools/pull-apk.sh [motif]
#
# Le motif par défaut est "igpsport". L'app doit être installée sur le téléphone,
# mais il n'est pas nécessaire d'avoir la lampe : on récupère le paquet, pas des
# données d'exécution.
#
# Récupérer l'APK depuis son propre téléphone évite d'aller le télécharger sur un
# site miroir — on est sûr de la provenance et de la version.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATTERN="${1:-igpsport}"
OUT="$REPO/captures/apk"

. "$REPO/tools/_adb.sh"
log() { _c_log "$@"; }
die() { _c_die "$@"; }

adb_select_device

log "Recherche d'un paquet correspondant à « $PATTERN »…"
PKGS="$(adb_ shell pm list packages 2>/dev/null | tr -d '\r' | sed 's/^package://' | grep -i "$PATTERN" || true)"

if [ -z "$PKGS" ]; then
  die "Aucun paquet ne correspond. Listez-les avec :
    adb shell pm list packages | grep -i sport
puis relancez avec le nom trouvé :
    bash tools/pull-apk.sh <motif>"
fi

echo "$PKGS" | sed 's/^/    /'
PKG="$(echo "$PKGS" | head -1)"
log "Paquet retenu : $PKG"

VER="$(adb_ shell dumpsys package "$PKG" 2>/dev/null | tr -d '\r' | grep -m1 versionName | sed 's/.*versionName=//' || true)"
[ -n "$VER" ] && log "Version installée : $VER"

mkdir -p "$OUT"
PATHS="$(adb_ shell pm path "$PKG" 2>/dev/null | tr -d '\r' | sed 's/^package://')"
[ -n "$PATHS" ] || die "Impossible de localiser l'APK de $PKG."

N=0
while IFS= read -r P; do
  [ -n "$P" ] || continue
  BASE="$(basename "$P")"
  DEST="$OUT/${PKG}-${VER:-unknown}-${BASE}"
  if adb_ pull "$P" "$DEST" >/dev/null 2>&1; then
    log "Récupéré : $BASE → $(basename "$DEST")"
    N=$((N + 1))
  fi
done <<< "$PATHS"

[ "$N" -gt 0 ] || die "Aucun fichier récupéré."

echo
log "Fichiers dans $OUT :"
ls -lh "$OUT" | tail -n +2 | sed 's/^/    /'

MAIN="$(ls -1S "$OUT"/*base.apk 2>/dev/null | head -1)"
[ -n "$MAIN" ] || MAIN="$(ls -1S "$OUT"/*.apk 2>/dev/null | head -1)"

echo
log "Analyser :"
echo "    python tools/scan-apk.py \"$MAIN\""
