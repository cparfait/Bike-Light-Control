#!/usr/bin/env bash
#
# Liste les appareils Garmin dont la définition d'API contient réellement le
# rôle central BLE, en interrogeant les profils du SDK installés localement.
#
#   bash tools/check-ble-devices.sh [motif]      # motif par défaut : edge
#
# À relancer après chaque mise à jour du SDK ou ajout d'appareils : la
# documentation en ligne et le compilateur ne sont pas fiables pour ça (voir
# docs/compatibilite-edge.md), alors que la définition d'API l'est.

set -uo pipefail

PATTERN="${1:-edge}"
# $APPDATA est en forme Windows (C:\...) : on le convertit en chemin POSIX,
# sinon ni ls ni grep ne le suivent depuis MSYS.
DEVICES="${APPDATA:-}"
if [ -n "$DEVICES" ] && command -v cygpath >/dev/null 2>&1; then
  DEVICES="$(cygpath -u "$DEVICES")"
else
  DEVICES="$HOME/AppData/Roaming"
fi
DEVICES="$DEVICES/Garmin/ConnectIQ/Devices"

[ -d "$DEVICES" ] || { echo "Répertoire des appareils introuvable : $DEVICES" >&2; exit 1; }

printf '%-22s %-8s %-11s %s\n' "PROFIL" "CIQ" "DATA FIELD" "CENTRAL BLE"
printf '%-22s %-8s %-11s %s\n' "----------------------" "--------" "-----------" "-----------"

ok=0; ko=0
for dev in $(ls "$DEVICES" | grep -i "$PATTERN" | sort); do
  api=$(ls "$DEVICES/$dev/"*.api.debug.xml 2>/dev/null | head -1)
  cfg="$DEVICES/$dev/compiler.json"

  ciq="?"; mem="?"
  if [ -f "$cfg" ]; then
    ciq=$(python -c "
import json,sys
j=json.load(open(sys.argv[1],encoding='utf-8'))
v=[p.get('connectIQVersion','?') for p in j.get('partNumbers',[])]
print(min(v) if v else '?')" "$cfg" 2>/dev/null || echo "?")
    mem=$(python -c "
import json,sys
j=json.load(open(sys.argv[1],encoding='utf-8'))
d={a['type']:a['memoryLimit'] for a in j.get('appTypes',[])}
print(str(d['datafield']//1024)+'K' if 'datafield' in d else '-')" "$cfg" 2>/dev/null || echo "?")
  fi

  # Discriminant : les méthodes du rôle central, et pas la simple mention du
  # nom de la permission — que tous les appareils contiennent.
  if [ -n "$api" ] && grep -q "setScanState" "$api" && grep -q "registerProfile" "$api"; then
    printf '%-22s %-8s %-11s OUI\n' "$dev" "$ciq" "$mem"; ok=$((ok + 1))
  else
    printf '%-22s %-8s %-11s non\n' "$dev" "$ciq" "$mem"; ko=$((ko + 1))
  fi
done

echo
echo "$ok compatible(s), $ko non compatible(s)."
echo "Les profils marqués OUI sont ceux à déclarer en <iq:product> dans le manifeste."
