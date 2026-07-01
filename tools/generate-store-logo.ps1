# Generates the 300x300 store logo for Microsoft Edge Add-ons / Chrome Web Store.
# Run:  pwsh -File tools/generate-store-logo.ps1
Add-Type -AssemblyName System.Drawing

$s = 300
$dir = Join-Path $PSScriptRoot "..\store"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$bmp = New-Object System.Drawing.Bitmap($s, $s)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

# Rounded background in Microsoft blue (#0F6CBD)
$bg = [System.Drawing.Color]::FromArgb(255, 15, 108, 189)
$brush = New-Object System.Drawing.SolidBrush($bg)
$rad = [int]($s * 0.18)
$d = $rad * 2
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddArc(0, 0, $d, $d, 180, 90)
$path.AddArc($s - $d, 0, $d, $d, 270, 90)
$path.AddArc($s - $d, $s - $d, $d, $d, 0, 90)
$path.AddArc(0, $s - $d, $d, $d, 90, 90)
$path.CloseFigure()
$g.FillPath($brush, $path)

# White flag (pole + banner)
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$poleW = [int]($s * 0.06)
$poleX = [int]($s * 0.30)
$poleTop = [int]($s * 0.20)
$poleBottom = [int]($s * 0.82)
$g.FillRectangle($white, $poleX, $poleTop, $poleW, $poleBottom - $poleTop)

$flagX = $poleX + $poleW
$flagY = $poleTop
$flagW = [int]($s * 0.42)
$flagH = [int]($s * 0.28)
$g.FillRectangle($white, $flagX, $flagY, $flagW, $flagH)

$g.Dispose()
$out = Join-Path $dir "logo-300.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Wrote $out"
