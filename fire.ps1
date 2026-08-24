$delayMs        = 25
$flickerChance  = 90
$blockChar      = [char]0x2588
$ESC            = [char]27

Add-Type -Name Console -Namespace Win32 -MemberDefinition @'
[DllImport("kernel32.dll")]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll")]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
[DllImport("kernel32.dll")]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
'@
$handle = [Win32.Console]::GetStdHandle(-11)
[uint32]$mode = 0
[Win32.Console]::GetConsoleMode($handle, [ref]$mode) | Out-Null
[Win32.Console]::SetConsoleMode($handle, $mode -bor 0x0004) | Out-Null

function Get-FireColor([double]$t) {
    $stops = @(
        @(0.00,   0,   0,   0),   # Fundo escuro
        @(0.15,  30,   0,  60),   # Roxo profundo
        @(0.30,  90,   0, 150),   # Violeta
        @(0.45, 200,   0, 180),   # Magenta
        @(0.60, 255,  20, 147),   # Rosa Choque
        @(0.75,   0, 230, 255),   # Ciano Brilhante
        @(0.87,  50, 255, 130),   # Verde Elétrico
        @(1.00, 230, 255, 255)    # Ápice Branco/Ciano
    )
    for ($i = 0; $i -lt $stops.Count - 1; $i++) {
        $a = $stops[$i]; $b = $stops[$i + 1]
        if ($t -ge $a[0] -and $t -le $b[0]) {
            $lt = if ($b[0] -eq $a[0]) { 0 } else { ($t - $a[0]) / ($b[0] - $a[0]) }
            $r  = [int]($a[1] + ($b[1] - $a[1]) * $lt)
            $g  = [int]($a[2] + ($b[2] - $a[2]) * $lt)
            $bl = [int]($a[3] + ($b[3] - $a[3]) * $lt)
            return "$r;$g;$bl"
        }
    }
    return "230;255;255"
}

$maxHeat = 36
$palette = New-Object string[] ($maxHeat + 1)
for ($i = 0; $i -le $maxHeat; $i++) {
    $palette[$i] = Get-FireColor($i / $maxHeat)
}

[console]::CursorVisible = $false
$host.UI.RawUI.WindowTitle = "Energia Paranormal - Tela Cheia"
Clear-Host

$rnd = New-Object System.Random
$sb  = New-Object System.Text.StringBuilder

$width = 0
$height = 0
$fire = @()

try {
    while ($true) {
        $currentWidth  = [console]::WindowWidth
        $currentHeight = [console]::WindowHeight

        if ($currentWidth -ne $width -or $currentHeight -ne $height) {
            $width  = $currentWidth
            $height = $currentHeight
            
            try {
                $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($width, $height)
            } catch {}

            $fire = New-Object int[] ($width * $height)
            Clear-Host
        }

        if ($width -le 0 -or $height -le 0) { continue }

        $bottomRow = $height - 1

        for ($x = 0; $x -lt $width; $x++) {
            if ($rnd.Next(100) -lt $flickerChance) {
                $fire[$bottomRow * $width + $x] = $maxHeat
            } else {
                $fire[$bottomRow * $width + $x] = $maxHeat - $rnd.Next(0, 6)
            }
        }

        for ($y = 1; $y -lt $height; $y++) {
            $rowOffset = $y * $width
            $aboveOffset = $rowOffset - $width
            for ($x = 0; $x -lt $width; $x++) {
                $src = $rowOffset + $x
                $pixel = $fire[$src]
                if ($pixel -le 0) {
                    $fire[$aboveOffset + $x] = 0
                } else {
                    $randIdx = $rnd.Next(4)
                    $newX = $x - $randIdx + 1
                    if ($newX -lt 0) { $newX = 0 }
                    elseif ($newX -ge $width) { $newX = $width - 1 }
                    $decay = $pixel - ($randIdx -band 1)
                    if ($decay -lt 0) { $decay = 0 }
                    $fire[$aboveOffset + $newX] = $decay
                }
            }
        }

        [void]$sb.Clear()
        [void]$sb.Append("$ESC[H")
        
        $prevColor = ""
        for ($y = 0; $y -lt $height; $y++) {
            $rowOffset = $y * $width
            for ($x = 0; $x -lt $width; $x++) {
                $v = $fire[$rowOffset + $x]
                $color = $palette[$v]
                if ($color -ne $prevColor) {
                    [void]$sb.Append("$ESC[38;2;${color}m")
                    $prevColor = $color
                }
                [void]$sb.Append($blockChar)
            }
        }
        [void]$sb.Append("$ESC[0m")

        [Console]::Out.Write($sb.ToString())
        Start-Sleep -Milliseconds $delayMs
    }
}
finally {
    [console]::CursorVisible = $true
    Write-Host "$ESC[0m"
    Clear-Host
}
