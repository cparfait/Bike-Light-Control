# Sélection d'appareil ADB — à sourcer depuis les autres scripts.
#
# Définit ADB_SERIAL et la fonction adb_() à utiliser partout à la place de adb.
# Nécessaire parce qu'un émulateur ou un appareil hors ligne qui traîne suffit à
# faire échouer `adb get-state`, qui refuse de choisir à notre place.
#
# Pour forcer un appareil : ANDROID_SERIAL=xxxx bash tools/<script>.sh

_c_log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
_c_warn() { printf '\033[1;33m /!\\\033[0m %s\n' "$*"; }
_c_die()  { printf '\033[1;31m!!!\033[0m %s\n' "$*" >&2; exit 1; }

adb_select_device() {
  command -v adb >/dev/null 2>&1 || _c_die "adb introuvable dans le PATH."

  local list ready count offline
  list="$(adb devices 2>/dev/null | tr -d '\r' | tail -n +2 | grep -v '^$' || true)"

  [ -n "$list" ] || _c_die "Aucun appareil détecté. Branchez le téléphone et vérifiez le débogage USB."

  if echo "$list" | grep -q 'unauthorized'; then
    _c_warn "Un appareil est 'unauthorized' : acceptez « Autoriser le débogage USB » sur son écran."
  fi

  # Ne garder que les appareils réellement prêts, en écartant émulateurs hors
  # ligne et appareils non autorisés.
  ready="$(echo "$list" | awk '$2 == "device" { print $1 }')"
  offline="$(echo "$list" | awk '$2 != "device" { print $1" ("$2")" }')"
  [ -n "$offline" ] && _c_warn "Ignoré(s) : $(echo "$offline" | tr '\n' ' ')"

  [ -n "$ready" ] || _c_die "Aucun appareil prêt. États vus :
$(echo "$list" | sed 's/^/    /')"

  if [ -n "${ANDROID_SERIAL:-}" ]; then
    echo "$ready" | grep -qx "$ANDROID_SERIAL" \
      || _c_die "ANDROID_SERIAL=$ANDROID_SERIAL n'est pas prêt. Disponibles : $(echo "$ready" | tr '\n' ' ')"
    ADB_SERIAL="$ANDROID_SERIAL"
  else
    count="$(echo "$ready" | wc -l | tr -d ' ')"
    if [ "$count" -gt 1 ]; then
      # Préférer un appareil physique à un émulateur.
      ADB_SERIAL="$(echo "$ready" | grep -v '^emulator-' | head -1)"
      [ -n "$ADB_SERIAL" ] || ADB_SERIAL="$(echo "$ready" | head -1)"
      _c_warn "Plusieurs appareils prêts, retenu : $ADB_SERIAL"
      _c_warn "Pour en choisir un autre : ANDROID_SERIAL=<serie> bash <script>"
    else
      ADB_SERIAL="$ready"
    fi
  fi

  export ADB_SERIAL
  _c_log "Appareil : $ADB_SERIAL"
  adb_ shell getprop ro.product.model 2>/dev/null | sed 's/^/    modele  : /'
  adb_ shell getprop ro.build.version.release 2>/dev/null | sed 's/^/    Android : /'
}

adb_() { adb -s "$ADB_SERIAL" "$@"; }
