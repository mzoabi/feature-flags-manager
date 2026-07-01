# Generates PNG icons (16/32/48/128) for the extension using System.Drawing.
# Run:  pwsh -File tools/generate-icons.ps1
Add-Type -AssemblyName System.Drawing

$sizes   = 16, 32, 48, 128
$iconDir = Join-Path $PSScriptRoot "..\icons"
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null

foreach ($s in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap($s, $s)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Rounded background in Microsoft blue (#0F6CBD)
    $bg = [System.Drawing.Color]::FromArgb(255, 15, 108, 189)
    $brush = New-Object System.Drawing.SolidBrush($bg)
    $rad = [Math]::Max(2, [int]($s * 0.18))
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
    $poleW = [Math]::Max(1, [int]($s * 0.07))
    $poleX = [int]($s * 0.30)
    $poleTop = [int]($s * 0.20)
    $poleBottom = [int]($s * 0.82)
    $g.FillRectangle($white, $poleX, $poleTop, $poleW, $poleBottom - $poleTop)

    $flagX = $poleX + $poleW
    $flagY = $poleTop
    $flagW = [int]($s * 0.40)
    $flagH = [int]($s * 0.26)
    $g.FillRectangle($white, $flagX, $flagY, $flagW, $flagH)

    $g.Dispose()
    $outPath = Join-Path $iconDir "icon$s.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Wrote $outPath"
}
