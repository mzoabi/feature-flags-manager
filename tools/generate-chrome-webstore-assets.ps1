param(
  [string]$OutputDir = "store/chrome-webstore-assets"
)

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root $OutputDir
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-Font($size, $style = [System.Drawing.FontStyle]::Regular) {
  return New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-Brush($r, $g, $b, $a = 255) {
  return New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, $r, $g, $b))
}

function New-Pen($r, $g, $b, $a = 255, $width = 1) {
  return New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($a, $r, $g, $b), $width)
}

function New-RoundRectPath($x, $y, $w, $h, $radius) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $radius * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Fill-RoundRect($g, $brush, $x, $y, $w, $h, $radius) {
  $path = New-RoundRectPath $x $y $w $h $radius
  $g.FillPath($brush, $path)
  $path.Dispose()
}

function Stroke-RoundRect($g, $pen, $x, $y, $w, $h, $radius) {
  $path = New-RoundRectPath $x $y $w $h $radius
  $g.DrawPath($pen, $path)
  $path.Dispose()
}

function Draw-Background($g, $w, $h) {
  $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(12, 53, 101), [System.Drawing.Color]::FromArgb(84, 158, 242), 18)
  $blend = New-Object System.Drawing.Drawing2D.ColorBlend
  $blend.Positions = @(0.0, 0.52, 1.0)
  $blend.Colors = @(
    [System.Drawing.Color]::FromArgb(16, 58, 106),
    [System.Drawing.Color]::FromArgb(55, 105, 181),
    [System.Drawing.Color]::FromArgb(75, 149, 235)
  )
  $brush.InterpolationColors = $blend
  $g.FillRectangle($brush, $rect)
  $brush.Dispose()

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse([int]($w * 0.52), [int](-$h * 0.46), [int]($w * 0.58), [int]($h * 1.06))
  $glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $glow.CenterColor = [System.Drawing.Color]::FromArgb(76, 132, 202, 255)
  $glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 132, 202, 255))
  $g.FillPath($glow, $path)
  $glow.Dispose()
  $path.Dispose()
}

function Draw-Pill($g, $text, $x, $y, $fontSize, $padX) {
  $font = New-Font $fontSize
  $format = New-Object System.Drawing.StringFormat
  $size = $g.MeasureString($text, $font)
  $w = [int]($size.Width + ($padX * 2))
  $h = [int]($fontSize + 22)
  $fill = New-Brush 255 255 255 24
  $stroke = New-Pen 255 255 255 75 1
  $textBrush = New-Brush 255 255 255 245
  Fill-RoundRect $g $fill $x $y $w $h ([int]($h / 2))
  Stroke-RoundRect $g $stroke $x $y $w $h ([int]($h / 2))
  $g.DrawString($text, $font, $textBrush, ($x + $padX), ($y + 9))
  $font.Dispose(); $fill.Dispose(); $stroke.Dispose(); $textBrush.Dispose(); $format.Dispose()
}

function Draw-FlagPanel($g, $x, $y, $w, $scale) {
  $panelH = [int](230 * $scale)
  $white = New-Brush 255 255 255
  $shadow = New-Brush 0 0 0 42
  Fill-RoundRect $g $shadow ($x + [int](8 * $scale)) ($y + [int](14 * $scale)) $w $panelH ([int](18 * $scale))
  Fill-RoundRect $g $white $x $y $w $panelH ([int](18 * $scale))

  $rows = @(
    @("exp.InlineChecks", "true"),
    @("feature.privateOffers", "true"),
    @("feature.customportal", "false")
  )

  $rowFont = New-Font ([int](18 * $scale))
  $valueFont = New-Font ([int](18 * $scale)) ([System.Drawing.FontStyle]::Bold)
  $dark = New-Brush 32 31 30
  $blue = New-Brush 44 95 166
  $border = New-Pen 202 202 202 255 1
  $rowY = $y + [int](24 * $scale)
  $rowH = [int](38 * $scale)
  $gap = [int](10 * $scale)
  $pad = [int](16 * $scale)

  foreach ($row in $rows) {
    Stroke-RoundRect $g $border ($x + $pad) $rowY ($w - ($pad * 2)) $rowH ([int](6 * $scale))
    $g.DrawString($row[0], $rowFont, $dark, ($x + $pad + [int](10 * $scale)), ($rowY + [int](8 * $scale)))
    $valueSize = $g.MeasureString($row[1], $valueFont)
    $g.DrawString($row[1], $valueFont, $blue, ($x + $w - $pad - [int]($valueSize.Width) - [int](10 * $scale)), ($rowY + [int](8 * $scale)))
    $rowY += $rowH + $gap
  }

  $btnFont = New-Font ([int](18 * $scale)) ([System.Drawing.FontStyle]::Bold)
  $button = New-Brush 55 111 189
  $buttonText = New-Brush 255 255 255
  $btnX = $x + $pad
  $btnY = $y + $panelH - [int](54 * $scale)
  Fill-RoundRect $g $button $btnX $btnY ([int](62 * $scale)) ([int](38 * $scale)) ([int](8 * $scale))
  $g.DrawString("Go!", $btnFont, $buttonText, ($btnX + [int](15 * $scale)), ($btnY + [int](8 * $scale)))

  $white.Dispose(); $shadow.Dispose(); $rowFont.Dispose(); $valueFont.Dispose(); $dark.Dispose(); $blue.Dispose(); $border.Dispose(); $btnFont.Dispose(); $button.Dispose(); $buttonText.Dispose()
}

function Save-Jpeg($path, $w, $h, [scriptblock]$draw) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  & $draw $g $w $h

  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" } | Select-Object -First 1
  $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 95L)
  if (Test-Path $path) { Remove-Item -Force $path }
  $bmp.Save($path, $codec, $encParams)
  $g.Dispose()
  $bmp.Dispose()
}

Save-Jpeg (Join-Path $outDir "screenshot-1-1280x800.jpg") 1280 800 {
  param($g, $w, $h)
  Draw-Background $g $w $h
  $white = New-Brush 255 255 255
  $titleFont = New-Font 58 ([System.Drawing.FontStyle]::Bold)
  $subFont = New-Font 28
  $g.DrawString("Feature Flags Manager", $titleFont, $white, 72, 154)
  $g.DrawString("Control query-string features on any site without editing`nURLs by hand.", $subFont, $white, 74, 240)
  Draw-Pill $g "Toggle" 74 350 20 18
  Draw-Pill $g "Edit" 178 350 20 18
  Draw-Pill $g "Apply" 258 350 20 18
  Draw-FlagPanel $g 856 154 382 1.0
  $white.Dispose(); $titleFont.Dispose(); $subFont.Dispose()
}

Save-Jpeg (Join-Path $outDir "screenshot-2-640x400.jpg") 640 400 {
  param($g, $w, $h)
  Draw-Background $g $w $h
  $white = New-Brush 255 255 255
  $titleFont = New-Font 36 ([System.Drawing.FontStyle]::Bold)
  $subFont = New-Font 18
  $g.DrawString("Feature Flags`nManager", $titleFont, $white, 38, 70)
  $g.DrawString("Edit and apply URL flags`nfrom a clean popup UI.", $subFont, $white, 40, 160)
  Draw-Pill $g "https://example.com" 40 230 15 14
  Draw-FlagPanel $g 374 76 220 0.54
  $white.Dispose(); $titleFont.Dispose(); $subFont.Dispose()
}

Save-Jpeg (Join-Path $outDir "small-promo-440x280.jpg") 440 280 {
  param($g, $w, $h)
  Draw-Background $g $w $h
  $white = New-Brush 255 255 255
  $titleFont = New-Font 36 ([System.Drawing.FontStyle]::Bold)
  $subFont = New-Font 18
  $g.DrawString("Feature Flags`nManager", $titleFont, $white, 28, 42)
  $g.DrawString("Toggle, edit, and apply URL flags.", $subFont, $white, 30, 144)
  Draw-Pill $g "Developer Tools" 30 206 15 13
  Draw-FlagPanel $g 306 50 104 0.28
  $white.Dispose(); $titleFont.Dispose(); $subFont.Dispose()
}

Save-Jpeg (Join-Path $outDir "marquee-promo-1400x560.jpg") 1400 560 {
  param($g, $w, $h)
  Draw-Background $g $w $h
  $white = New-Brush 255 255 255
  $titleFont = New-Font 62 ([System.Drawing.FontStyle]::Bold)
  $subFont = New-Font 28
  $g.DrawString("Feature Flags Manager", $titleFont, $white, 74, 152)
  $g.DrawString("Control query-string features on any site without editing`nURLs by hand.", $subFont, $white, 76, 238)
  Draw-Pill $g "Toggle" 74 332 20 18
  Draw-Pill $g "Edit" 178 332 20 18
  Draw-Pill $g "Apply" 258 332 20 18
  Draw-FlagPanel $g 930 154 382 1.0
  $white.Dispose(); $titleFont.Dispose(); $subFont.Dispose()
}

Get-ChildItem $outDir -Filter *.jpg | ForEach-Object {
  $img = [System.Drawing.Image]::FromFile($_.FullName)
  try {
    Write-Output "$($_.Name) $($img.Width)x$($img.Height)"
  } finally {
    $img.Dispose()
  }
}
