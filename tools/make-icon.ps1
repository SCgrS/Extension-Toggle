# Creates icon.ico: A yellow folder with glasses in front of it. Each size is drawn separately.
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File tools\make-icon.ps1
param([string]$Output = (Join-Path (Split-Path $PSScriptRoot -Parent) 'icon.ico'))

Add-Type -AssemblyName System.Drawing

# A relative -Output path is resolved against the PowerShell location (.NET would use its own current folder).
$Output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output)

function Color([string]$hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Brush([string]$hex) { New-Object System.Drawing.SolidBrush (Color $hex) }
function Point([double]$x, [double]$y) { New-Object System.Drawing.PointF ([single]$x), ([single]$y) }

# Pen with round ends. Stays at least one pixel wide at small sizes.
function Pen([string]$hex, [double]$width, [double]$scale) {
    $pen = New-Object System.Drawing.Pen (Color $hex), ([single][Math]::Max($width, 1.0 / $scale))
    $pen.LineJoin = 'Round'; $pen.StartCap = 'Round'; $pen.EndCap = 'Round'
    $pen
}

function RoundedRectangle([double]$x, [double]$y, [double]$width, [double]$height, [double]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $path.AddArc([single]$x, [single]$y, [single]$d, [single]$d, 180, 90)
    $path.AddArc([single]($x + $width - $d), [single]$y, [single]$d, [single]$d, 270, 90)
    $path.AddArc([single]($x + $width - $d), [single]($y + $height - $d), [single]$d, [single]$d, 0, 90)
    $path.AddArc([single]$x, [single]($y + $height - $d), [single]$d, [single]$d, 90, 90)
    $path.CloseFigure()
    $path
}

# Draws on a 256-unit canvas and scales it to the requested size.
function Draw([int]$size) {
    $image = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($image)
    $g.SmoothingMode = 'AntiAlias'
    $g.PixelOffsetMode = 'HighQuality'
    $k = $size / 256.0
    $g.ScaleTransform($k, $k)

    # Folder: A dark yellow back with a tab, a light yellow front.
    $back = Brush '#D99A17'
    $g.FillPath($back, (RoundedRectangle 16 34 100 60 16))
    $g.FillPath($back, (RoundedRectangle 16 54 224 170 18))
    $front = New-Object System.Drawing.Drawing2D.LinearGradientBrush (Point 0 76), (Point 0 224), (Color '#FFD966'), (Color '#F4B11F')
    $g.FillPath($front, (RoundedRectangle 16 78 224 146 18))

    # Glasses: Two lenses centered at (77, 164) and (179, 164), a bridge and two temples. The temples and the shine on
    # the lenses are not drawn below 32 pixels.
    $frame = Pen '#0B1F3F' 14 $k
    if ($size -ge 32) {
        $g.DrawLine($frame, 35, 158, 21, 134)
        $g.DrawLine($frame, 221, 158, 235, 134)
    }
    $glass = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(225, 222, 237, 255))
    foreach ($x in 77, 179) {
        $g.FillEllipse($glass, $x - 42, 122, 84, 84)
        if ($size -ge 32) {
            $g.DrawArc((Pen '#FFFFFF' 6.7 $k), $x - 26, 138, 52, 52, 200, 60)
        }
        $g.DrawEllipse($frame, $x - 42, 122, 84, 84)
    }
    $bridge = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bridge.AddBezier((Point 119 156), (Point 124.4 138), (Point 131.6 138), (Point 137 156))
    $g.DrawPath($frame, $bridge)

    $g.Dispose()
    $image
}

# 256 pixels is stored as PNG, smaller sizes as 32-bit BMP that every program can read.
function BmpData([System.Drawing.Bitmap]$image) {
    $n = $image.Width
    $lock = $image.LockBits((New-Object System.Drawing.Rectangle 0, 0, $n, $n), 'ReadOnly',
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $pixels = New-Object byte[] ($n * $n * 4)
    [System.Runtime.InteropServices.Marshal]::Copy($lock.Scan0, $pixels, 0, $pixels.Length)
    $image.UnlockBits($lock)
    $maskRow = [int]([Math]::Ceiling($n / 32.0) * 4)
    $stream = New-Object System.IO.MemoryStream
    $writer = New-Object System.IO.BinaryWriter $stream
    $writer.Write([uint32]40); $writer.Write([int32]$n); $writer.Write([int32]($n * 2))
    $writer.Write([uint16]1); $writer.Write([uint16]32); $writer.Write([uint32]0)
    $writer.Write([uint32]($pixels.Length + $maskRow * $n))
    $writer.Write([int32]0); $writer.Write([int32]0); $writer.Write([uint32]0); $writer.Write([uint32]0)
    for ($row = $n - 1; $row -ge 0; $row--) { $writer.Write($pixels, $row * $n * 4, $n * 4) }
    $writer.Write((New-Object byte[] ($maskRow * $n)))
    $writer.Flush()
    , $stream.ToArray()
}

$sizes = 16, 20, 24, 32, 40, 48, 64, 256
$images = foreach ($size in $sizes) {
    $image = Draw $size
    if ($size -ge 256) {
        $stream = New-Object System.IO.MemoryStream
        $image.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
        $data = $stream.ToArray()
    } else {
        $data = BmpData $image
    }
    $image.Dispose()
    , $data
}

$file = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter $file
$writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $edge = if ($sizes[$i] -ge 256) { 0 } else { $sizes[$i] }
    $writer.Write([byte]$edge); $writer.Write([byte]$edge); $writer.Write([byte]0); $writer.Write([byte]0)
    $writer.Write([uint16]1); $writer.Write([uint16]32)
    $writer.Write([uint32]$images[$i].Length); $writer.Write([uint32]$offset)
    $offset += $images[$i].Length
}
foreach ($data in $images) { $writer.Write([byte[]]$data) }
$writer.Flush()
[System.IO.File]::WriteAllBytes($Output, $file.ToArray())
"Written: $Output"
