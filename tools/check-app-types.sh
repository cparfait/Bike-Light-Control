#!/usr/bin/env bash
#
# Types d'application Connect IQ supportes par chaque appareil.
#
#   bash tools/check-app-types.sh [motif]      # motif par defaut : edge
#
# A verifier avant de choisir un type dans un manifeste : le compilateur
# accepte n'importe quel type sans le confronter aux capacites de l'appareil,
# exactement comme pour la permission BluetoothLowEnergy.
#
# Constat du 08/09/2026 : « widget » n'existe que sur les Edge 530, 830, 1030,
# 1030 Plus et Explore. Les modeles recents ont « glance » a la place.
# « watchApp » est le seul type commun aux 13 cibles.

set -uo pipefail

PATTERN="${1:-edge}"
DEVICES="${APPDATA:-}"
if [ -n "$DEVICES" ] && command -v cygpath >/dev/null 2>&1; then
  DEVICES="$(cygpath -u "$DEVICES")"
else
  DEVICES="$HOME/AppData/Roaming"
fi
DEVICES="$DEVICES/Garmin/ConnectIQ/Devices"

[ -d "$DEVICES" ] || { echo "Repertoire des appareils introuvable : $DEVICES" >&2; exit 1; }

printf '%-22s %s\n' "PROFIL" "TYPES SUPPORTES"
printf '%-22s %s\n' "----------------------" "---------------"
for dev in $(ls "$DEVICES" | grep -i "$PATTERN" | sort); do
  cfg="$DEVICES/$dev/compiler.json"
  [ -f "$cfg" ] || continue
  types=$(python -c "
import json,sys
j=json.load(open(sys.argv[1],encoding='utf-8'))
print(', '.join(sorted(a['type'] for a in j.get('appTypes',[]))))" "$cfg" 2>/dev/null)
  printf '%-22s %s\n' "$dev" "$types"
done
