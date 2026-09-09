#!/usr/bin/env bash
#
# Recupere le journal Connect IQ de l'Edge branche (GARMIN/Apps/LOGS) et
# traduit chaque adresse de plantage en fichier:ligne grace au fichier de
# symboles du build deploye.
#
#   bash tools/pull-ciq-log.sh            # edge1050
#   bash tools/pull-ciq-log.sh edge530
#
# C'est ce qui a permis de comprendre les deux plantages de la tuile de resume
# et le probleme des tapes : ni le compilateur ni le simulateur ne les voyaient.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="${1:-edge1050}"
OUT="$(mktemp -d)"
OUTW="$(cygpath -w "$OUT")"

powershell -NoProfile -Command "
\$sh=New-Object -ComObject Shell.Application
\$dev=\$sh.NameSpace(17).Items() | Where-Object { \$_.Name -like 'Edge*' }
if(-not \$dev){ Write-Error 'Aucun Edge detecte en USB.'; exit 1 }
\$st=\$dev.GetFolder.Items() | Select-Object -First 1
\$g=\$st.GetFolder.Items() | Where-Object { \$_.Name -eq 'GARMIN' }
\$apps=(\$g.GetFolder.Items() | Where-Object { \$_.Name -eq 'Apps' }).GetFolder
\$logs=(\$apps.Items() | Where-Object { \$_.Name -eq 'LOGS' })
if(-not \$logs){ 'Pas de dossier LOGS : aucun plantage enregistre.'; exit 0 }
\$dst=\$sh.NameSpace('$OUTW')
foreach(\$i in \$logs.GetFolder.Items()){ \$dst.CopyHere(\$i, 16) }
Start-Sleep -Seconds 5
"

shopt -s nullglob
for log in "$OUT"/CIQ_LOG.*; do
  echo "=== $(basename "$log") ==="
  cat "$log"; echo
done

python - "$ROOT" "$DEV" "$OUT" <<'PY'
import io, os, re, sys, glob
root, dev, out = sys.argv[1:4]
pcs = set()
for log in glob.glob(os.path.join(out, "CIQ_LOG.*")):
    for m in re.finditer(r"pc:\s*(0x[0-9a-fA-F]+)", io.open(log, encoding="utf-8", errors="replace").read()):
        pcs.add(int(m.group(1), 16))
if not pcs:
    sys.exit(0)
print("=== traduction des adresses ===")
for part in ("widget", "app"):
    path = os.path.join(root, part, "bin", dev + ".prg.debug.xml")
    if not os.path.exists(path):
        continue
    ents = []
    for m in re.finditer(r"<entry ([^>]*)/>", io.open(path, encoding="utf-8", errors="replace").read()):
        a = dict(re.findall(r'(\w+)="([^"]*)"', m.group(1)))
        if "pc" in a:
            ents.append((int(a["pc"]), a))
    ents.sort()
    for pc in sorted(pcs):
        best = None
        for addr, a in ents:
            if addr > pc:
                break
            best = a
        if best:
            print("  %-6s pc=0x%08x -> %s:%s  (%s.%s)" % (part, pc,
                  os.path.basename(best.get("filename", "?").replace("\\\\", "/")),
                  best.get("lineNum", "?"), best.get("parent", "?"), best.get("symbol", "?")))
print("Le journal ne dit pas quel binaire a plante quand les deux sont installes :")
print("regarder la ligne 'Filename:' du journal pour choisir la bonne traduction.")
PY
