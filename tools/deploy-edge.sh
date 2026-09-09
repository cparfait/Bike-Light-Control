#!/usr/bin/env bash
#
# Installe les deux binaires sur un Edge branche en USB (MTP, sans lettre de
# lecteur), puis liste ce qui est dans GARMIN/Apps.
#
#   bash tools/deploy-edge.sh            # edge1050
#   bash tools/deploy-edge.sh edge530
#
# Les deux builds s'appellent <appareil>.prg : on les renomme, sinon le second
# ecrase le premier. L'Edge consomme les fichiers au redemarrage — ne pas
# s'etonner qu'ils disparaissent de GARMIN/Apps ensuite.
#
# Le fichier de symboles (<appareil>.prg.debug.xml) correspond a CE build :
# le garder, c'est lui qui traduit les adresses de CIQ_LOG.YML (voir
# tools/pull-ciq-log.sh).

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="${1:-edge1050}"
STAGE="$(cygpath -w "$(mktemp -d)")"

cp "$ROOT/app/bin/$DEV.prg"    "$(cygpath -u "$STAGE")/iGEdge-DataField.prg"
cp "$ROOT/widget/bin/$DEV.prg" "$(cygpath -u "$STAGE")/iGEdge-App.prg"

powershell -NoProfile -Command "
\$sh=New-Object -ComObject Shell.Application
\$dev=\$sh.NameSpace(17).Items() | Where-Object { \$_.Name -like 'Edge*' }
if(-not \$dev){ Write-Error 'Aucun Edge detecte en USB.'; exit 1 }
'Appareil : ' + \$dev.Name
\$st=\$dev.GetFolder.Items() | Select-Object -First 1
\$g=\$st.GetFolder.Items() | Where-Object { \$_.Name -eq 'GARMIN' }
\$dst=(\$g.GetFolder.Items() | Where-Object { \$_.Name -eq 'Apps' }).GetFolder
\$src=\$sh.NameSpace('$STAGE')
foreach(\$f in \$src.Items()){ \$dst.CopyHere(\$f, 16) }
Start-Sleep -Seconds 10
foreach(\$i in \$dst.Items()){ if(\$i.Name -like '*.prg'){ '  installe : ' + \$i.Name + '  ' + \$i.ExtendedProperty('Size') + ' o' } }
'Redemarrer l''Edge pour charger les applications.'
"
