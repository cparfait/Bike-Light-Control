#!/usr/bin/env bash
#
# Installe les deux binaires sur un Edge branche en USB (MTP, sans lettre de
# lecteur), puis liste ce qui est dans GARMIN/Apps.
#
#   bash tools/deploy-edge.sh            # edge1050
#   bash tools/deploy-edge.sh edge830
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

# Les noms de fichier reprennent ceux des applications : sur un Edge qui n'est
# pas le sien, il faut pouvoir retrouver et effacer ce qu'on y a mis.
cp "$ROOT/app/bin/$DEV.prg"    "$(cygpath -u "$STAGE")/BikeLightControl.prg"
cp "$ROOT/widget/bin/$DEV.prg" "$(cygpath -u "$STAGE")/BikeLightPanel.prg"

powershell -NoProfile -Command "
\$sh=New-Object -ComObject Shell.Application
\$dev=\$sh.NameSpace(17).Items() | Where-Object { \$_.Name -like 'Edge*' }
if(-not \$dev){ Write-Error 'Aucun Edge detecte en USB.'; exit 1 }
'Appareil : ' + \$dev.Name
\$st=\$dev.GetFolder.Items() | Select-Object -First 1
\$g=\$st.GetFolder.Items() | Where-Object { \$_.Name -eq 'GARMIN' }
\$dst=(\$g.GetFolder.Items() | Where-Object { \$_.Name -eq 'Apps' }).GetFolder
\$src=\$sh.NameSpace('$STAGE')
# Effacer avant de copier. Sans cela, un fichier de meme nom deja present —
# depose par un deploiement precedent et pas encore consomme, parce que l'Edge
# n'a pas redemarre entre-temps — n'est PAS ecrase par CopyHere, malgre l'option
# 16 (« repondre Oui a tout »). On croyait alors installer la derniere version
# alors que l'ancienne restait en place, ce qui s'est produit et a coute une
# session d'essai sur un binaire perime.
foreach(\$old in @(\$dst.Items())){
  if(\$old.Name -like '*.prg'){ \$old.InvokeVerb('delete') }
}
Start-Sleep -Seconds 3
foreach(\$f in \$src.Items()){ \$dst.CopyHere(\$f, 16) }
Start-Sleep -Seconds 10
foreach(\$i in \$dst.Items()){ if(\$i.Name -like '*.prg'){ '  installe : ' + \$i.Name + '  ' + \$i.ExtendedProperty('Size') + ' o' } }
'Redemarrer l''Edge pour charger les applications.'
"
