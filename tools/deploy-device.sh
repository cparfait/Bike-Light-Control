#!/usr/bin/env bash
#
# Installe les deux binaires sur un appareil Garmin branche en USB (MTP, sans
# lettre de lecteur), puis liste ce qui est dans GARMIN/Apps.
#
#   bash tools/deploy-device.sh            # edge1050
#   bash tools/deploy-device.sh edge830
#   bash tools/deploy-device.sh venu445mm  # une montre, meme procedure
#
# L'appareil n'est PAS reconnu a son nom. Il l'etait — « Edge* » — et une montre
# branchee n'etait alors tout simplement pas vue. On cherche desormais le
# premier appareil MTP qui contient un dossier GARMIN/Apps : c'est la
# caracteristique qui compte, et elle vaut pour toute la gamme.
#
# Les deux builds s'appellent <appareil>.prg : on les renomme, sinon le second
# ecrase le premier. L'appareil consomme les fichiers au redemarrage — ne pas
# s'etonner qu'ils disparaissent de GARMIN/Apps ensuite.
#
# Le fichier de symboles (<appareil>.prg.debug.xml) correspond a CE build :
# le garder, c'est lui qui traduit les adresses de CIQ_LOG.YML (voir
# tools/pull-ciq-log.sh).
#
# Relancer le script sans avoir redemarre l'appareil ne fait rien : les binaires
# sont encore dans Apps, on compare les tailles et on s'arrete la. Sans cette
# comparaison, la suppression des anciens fichiers ouvrait une boite de dialogue
# Windows qui attendait une reponse sur le bureau — le script paraissait alors
# bloque, sans dire pourquoi.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="${1:-edge1050}"
STAGE="$(cygpath -w "$(mktemp -d)")"

# Les noms de fichier reprennent ceux des applications : sur un appareil qui n'est
# pas le sien, il faut pouvoir retrouver et effacer ce qu'on y a mis.
cp "$ROOT/app/bin/$DEV.prg"    "$(cygpath -u "$STAGE")/BikeLightControl.prg"
cp "$ROOT/widget/bin/$DEV.prg" "$(cygpath -u "$STAGE")/BikeLightPanel.prg"

# Tailles locales, pour savoir si l'appareil a deja ce build.
CTRL_SIZE=$(stat -c %s "$ROOT/app/bin/$DEV.prg")
PANEL_SIZE=$(stat -c %s "$ROOT/widget/bin/$DEV.prg")

powershell -NoProfile -Command "
\$sh=New-Object -ComObject Shell.Application
# On parcourt les appareils MTP et on garde le premier qui expose GARMIN/Apps.
# Une montre peut presenter plusieurs volumes (memoire interne, carte) : on les
# essaie tous, au lieu de prendre le premier comme avant.
\$dst=\$null; \$found=''
foreach(\$d in @(\$sh.NameSpace(17).Items())){
  foreach(\$st in @(\$d.GetFolder.Items())){
    if(-not \$st.IsFolder){ continue }
    \$g=\$st.GetFolder.Items() | Where-Object { \$_.Name -eq 'GARMIN' }
    if(-not \$g){ continue }
    \$apps=\$g.GetFolder.Items() | Where-Object { \$_.Name -eq 'Apps' }
    if(\$apps){ \$dst=\$apps.GetFolder; \$found=\$d.Name; break }
  }
  if(\$dst){ break }
}
if(-not \$dst){ Write-Error 'Aucun appareil Garmin avec GARMIN/Apps detecte en USB.'; exit 1 }
'Appareil : ' + \$found
\$src=\$sh.NameSpace('$STAGE')

# Ce qui est deja la, et sa taille.
\$present=@{}
foreach(\$i in @(\$dst.Items())){
  if(\$i.Name -like '*.prg'){ \$present[\$i.Name] = [int]\$i.ExtendedProperty('Size') }
}

# **Deja a jour : on ne touche a rien.** Les fichiers restent dans Apps tant que
# l'appareil n'a pas redemarre, et relancer le deploiement declenchait alors une
# suppression — donc la boite de dialogue Windows « Confirmer la suppression du
# fichier », qui attend une reponse sur le bureau pendant que le script, lui,
# semble bloque. Comparer les tailles evite tout cela dans le cas courant :
# reinstaller ce qui est deja installe.
if(\$present['BikeLightControl.prg'] -eq $CTRL_SIZE -and
   \$present['BikeLightPanel.prg'] -eq $PANEL_SIZE){
  '  BikeLightControl.prg  $CTRL_SIZE o   deja a jour'
  '  BikeLightPanel.prg  $PANEL_SIZE o   deja a jour'
  'Rien a copier. Redemarrer l''appareil pour charger ces applications.'
  exit 0
}

# Effacer avant de copier. Sans cela, un fichier de meme nom deja present n'est
# PAS ecrase par CopyHere, malgre l'option 16 (« repondre Oui a tout »). On
# croyait alors installer la derniere version alors que l'ancienne restait en
# place, ce qui s'est produit et a coute une session d'essai sur un binaire
# perime.
#
# La suppression sur un appareil MTP passe par le shell, et le shell demande
# confirmation : il n'existe pas d'equivalent silencieux. On previent donc.
if(\$present.Count -gt 0){
  ''
  '  Windows va demander confirmation de la suppression des anciens fichiers.'
  '  Repondre Oui dans la boite de dialogue, sinon ce script attendra.'
  ''
}
foreach(\$old in @(\$dst.Items())){
  if(\$old.Name -like '*.prg'){ \$old.InvokeVerb('delete') }
}
Start-Sleep -Seconds 3
foreach(\$f in @(\$src.Items())){ \$dst.CopyHere(\$f, 16) }

# **On attend de VOIR les fichiers, on ne dort pas dix secondes.** CopyHere est
# asynchrone et ne rend aucun code d'erreur sur un appareil MTP : le script
# annoncait « redemarrer l'appareil » sans avoir rien verifie, et une copie qui
# n'avait pas abouti passait pour une reussite. C'est arrive, sur une montre, et
# l'application manquante s'est decouverte a la main.
\$seen=@()
for(\$i=0; \$i -lt 12; \$i++){
  Start-Sleep -Seconds 5
  \$seen=@(\$dst.Items() | Where-Object { \$_.Name -like '*.prg' })
  if(\$seen.Count -ge 2){ break }
}
foreach(\$i in \$seen){ '  installe : ' + \$i.Name + '  ' + \$i.ExtendedProperty('Size') + ' o' }
if(\$seen.Count -lt 2){
  Write-Error ('Copie incomplete : ' + \$seen.Count + ' fichier(s) sur 2 apres une minute.')
  exit 1
}
'Redemarrer l''appareil pour charger les applications.'
"
