Add-Type -AssemblyName System.Drawing
$width = 256
$height = 256
$bmp = New-Object System.Drawing.Bitmap $width, $height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::White)

$font1 = New-Object System.Drawing.Font("Arial", 46, [System.Drawing.FontStyle]::Bold)
$font2 = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Bold)
$brushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(237, 27, 36))

$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center

$g.DrawString("Vietjet", $font1, $brushRed, (New-Object System.Drawing.RectangleF(0, 60, $width, 70)), $format)
$g.DrawString("Air.com", $font2, $brushRed, (New-Object System.Drawing.RectangleF(0, 130, $width, 60)), $format)

$bmp.Save("d:\AndroidStudioProject\OnlineTravelAgent\assets\images\vj_logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
