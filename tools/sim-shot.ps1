# Capture la fenetre du simulateur Connect IQ dans un PNG.
#
#   powershell -NoProfile -File tools/sim-shot.ps1 -Out captures/sim/edge1050.png
#
# Pourquoi une capture de fenetre et non de l'ecran entier : le simulateur se
# place ou le systeme veut, et une capture plein ecran ramene le bureau autour.
# On demande donc ses coordonnees a Windows et on ne copie que ce rectangle.
#
# **PrintWindow d'abord, l'ecran ensuite.** `CopyFromScreen` lit les pixels
# *affiches* : une fenetre passee derriere une autre — ce qui arrive des qu'on
# lance la capture depuis un terminal — donne l'image de celle de devant, et on
# se retrouve avec une capture du bureau en croyant tenir celle du simulateur.
# `PrintWindow` demande a la fenetre de se dessiner elle-meme dans un contexte
# hors ecran : elle n'a pas besoin d'etre visible, et le premier plan de
# l'utilisateur n'est pas vole. L'option `PW_RENDERFULLCONTENT` (2) est
# indispensable ici, le simulateur dessinant en accelere.
param(
  [string]$Out = "captures/sim/simulator.png",
  [int]$SettleMs = 600
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint flags);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
}
"@

$proc = Get-Process -Name simulator -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $proc) { Write-Error "Simulateur non demarre, ou sans fenetre."; exit 1 }

$h = $proc.MainWindowHandle
# Une fenetre reduite n'a plus de contenu a dessiner, meme pour PrintWindow :
# c'est le seul cas ou il faut la deranger.
if ([Win]::IsIconic($h)) { [void][Win]::ShowWindow($h, 9); Start-Sleep -Milliseconds 800 }
Start-Sleep -Milliseconds $SettleMs

$r = New-Object Win+RECT
[void][Win]::GetWindowRect($h, [ref]$r)
$w = $r.R - $r.L
$hh = $r.B - $r.T
if ($w -le 0 -or $hh -le 0) { Write-Error "Fenetre de taille nulle."; exit 1 }

$full = [System.IO.Path]::GetFullPath($Out)
$dir = Split-Path -Parent $full
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

$bmp = New-Object System.Drawing.Bitmap $w, $hh
$g = [System.Drawing.Graphics]::FromImage($bmp)
$dc = $g.GetHdc()
$ok = [Win]::PrintWindow($h, $dc, 2)     # 2 = PW_RENDERFULLCONTENT
$g.ReleaseHdc($dc)

# Repli : certaines fenetres ignorent PrintWindow et rendent un cadre noir. On
# le detecte sur un echantillon plutot que sur le seul code de retour, qui vaut
# « vrai » meme quand le dessin n'a rien produit.
$blank = $true
for ($y = 0; $y -lt $hh -and $blank; $y += 40) {
  for ($x = 0; $x -lt $w; $x += 40) {
    $p = $bmp.GetPixel($x, $y)
    if ($p.R -gt 12 -or $p.G -gt 12 -or $p.B -gt 12) { $blank = $false; break }
  }
}
if (-not $ok -or $blank) {
  $g.CopyFromScreen($r.L, $r.T, 0, 0, $bmp.Size)
  Write-Output "  (PrintWindow sans resultat, capture ecran)"
}

$bmp.Save($full, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output ("{0}  {1}x{2}" -f $Out, $w, $hh)
