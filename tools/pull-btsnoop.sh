#!/usr/bin/env bash
#
# Récupère le journal Bluetooth HCI snoop d'un téléphone Android.
#
#   bash tools/pull-btsnoop.sh [libellé]
#
# Le libellé (optionnel) est ajouté au nom du dossier de sortie, ex. "vitesse".
# Résultat : captures/<horodatage>[-libellé]/btsnoop_hci.log
#
# Deux stratégies, dans l'ordre :
#   1. copie directe depuis /sdcard (ROM anciens ou permissifs)
#   2. extraction depuis un `adb bugreport` (Android 8+, sans root)

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# MSYS convertit tout argument commençant par / en chemin Windows, ce qui
# casse les chemins Android passés à adb (/data/..., /sdcard/...).
export MSYS_NO_PATHCONV=1
LABEL="${1:-}"
STAMP="$(date +%Y%m%d-%H%M%S)"
[ -n "$LABEL" ] && STAMP="$STAMP-$LABEL"
OUT="$REPO/captures/$STAMP"

. "$REPO/tools/_adb.sh"
log()  { _c_log "$@"; }
warn() { _c_warn "$@"; }
die()  { _c_die "$@"; }

adb_select_device

mkdir -p "$OUT"
FOUND=0

# --- Stratégie 1 : chemins directement lisibles -------------------------------
log "Tentative de copie directe…"
for P in \
  /sdcard/btsnoop_hci.log \
  /sdcard/btsnoop_hci.log.last \
  /sdcard/Android/data/btsnoop_hci.log \
  /sdcard/Download/btsnoop_hci.log \
  /data/misc/bluetooth/logs/btsnoop_hci.log \
  /data/misc/bluetooth/logs/btsnoop_hci.log.last \
  /data/log/bt/btsnoop_hci.log
do
  if adb_ shell "test -r '$P'" 2>/dev/null; then
    if adb_ pull "$P" "$OUT/" >/dev/null 2>&1; then
      log "Récupéré : $P"
      FOUND=1
    fi
  fi
done

# --- Stratégie 2 : bugreport --------------------------------------------------
if [ "$FOUND" -eq 0 ]; then
  warn "Chemins directs inaccessibles (normal sur Android 8+)."

  # Indice sur l'etat du journal. ATTENTION : cette propriete est vide sur
  # Android 17 / Pixel alors que le journal fonctionne parfaitement — elle ne
  # peut donc PAS servir de condition bloquante, seulement d'indication.
  MODE="$(adb_ shell getprop persist.bluetooth.btsnooplogmode 2>/dev/null | tr -d '')"
  [ -n "$MODE" ] && log "Journal HCI, mode declare : $MODE"

  # Un dumpstate deja en cours fait echouer la demande avec « Connection
  # refused » : on attend qu'il se termine plutot que d'abandonner.
  for _ in 1 2 3 4 5 6; do
    adb_ shell ps -A 2>/dev/null | tr -d '
' | grep -q "[ ]dumpstate$" || break
    warn "Un bugreport est deja en cours, attente 30 s…"
    sleep 30
  done

  log "Génération d'un bugreport — comptez 1 à 3 minutes, ne débranchez pas…"

  # `adb bugreport <fichier>` echoue sur certains chemins ; lui donner un
  # REPERTOIRE le laisse nommer l'archive lui-meme, ce qui marche toujours.
  ( cd "$OUT" && adb -s "$ADB_SERIAL" bugreport . ) 2>&1 | tail -2
  ZIP="$(ls -1t "$OUT"/*.zip 2>/dev/null | head -1)"

  if [ -z "${ZIP:-}" ] || [ ! -f "$ZIP" ]; then
    die "Bugreport introuvable dans $OUT."
  fi

  # Une archive tronquee (copie pendant l'ecriture) se reconnait a l'echec de
  # lecture de son index — mieux vaut le dire que de chercher un fichier absent.
  if ! unzip -t "$ZIP" >/dev/null 2>&1; then
    die "Archive incomplete ($(stat -c %s "$ZIP") octets). Relancer le script."
  fi

  log "Extraction du journal HCI depuis l'archive…"
  MATCHES="$(unzip -Z1 "$ZIP" 2>/dev/null | grep -i 'btsnoop' || true)"
  if [ -z "$MATCHES" ]; then
    warn "Aucun fichier btsnoop dans le bugreport."
    warn "Cause la plus probable : le Bluetooth n'a pas ete redemarre apres"
    warn "activation du journal. Voir docs/phase1-procedure-capture-ble.md §2.4."
    die  "Rien à extraire."
  fi
  while IFS= read -r M; do
    [ -n "$M" ] || continue
    unzip -o -j "$ZIP" "$M" -d "$OUT" >/dev/null 2>&1 && log "Extrait : $M"
  done <<< "$MATCHES"
  FOUND=1
fi

# --- Contrôle -----------------------------------------------------------------
echo
LOGS="$(ls -1 "$OUT"/*btsnoop* 2>/dev/null || true)"
[ -n "$LOGS" ] || die "Aucun journal récupéré."

log "Fichiers dans $OUT :"
ls -lh "$OUT" | tail -n +2 | sed 's/^/    /'

echo
while IFS= read -r F; do
  SIZE=$(stat -c %s "$F" 2>/dev/null || echo 0)
  NAME="$(basename "$F")"
  if [ "$SIZE" -lt 1024 ]; then
    warn "$NAME fait $SIZE octets — capture probablement vide."
    warn "Vérifiez le cycle Bluetooth off/on après activation du journal (procédure §2.4)."
  else
    log "$NAME : $(( SIZE / 1024 )) Kio — exploitable."
  fi
done <<< "$LOGS"

echo
log "Ouvrir dans Wireshark :"
echo "    wireshark \"$(echo "$LOGS" | head -1)\""
log "Filtres et méthode de dépouillement : docs/phase1-procedure-capture-ble.md §6"
