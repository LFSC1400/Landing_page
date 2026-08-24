# bounce.ps1


$logoText = " ...
             . . . . . . . . . . .   		  .
              . . . . . . . . . . "      # texto/logo que vai quicar (pode trocar)
$delayMs  = 60          # velocidade da animacao (menor = mais rapido)
$cores = @('Red','Yellow','Green','Cyan','Magenta','White','DarkYellow','Blue')

[console]::CursorVisible = $false
$host.UI.RawUI.WindowTitle = "Bounce - estilo tela de tubo"

try {
    Clear-Host

    $width  = $Host.UI.RawUI.WindowSize.Width
    $height = $Host.UI.RawUI.WindowSize.Height - 1   # margem de seguranca

    $logoLen = $logoText.Length

    $x = Get-Random -Minimum 0 -Maximum ([Math]::Max(1, $width - $logoLen))
    $y = Get-Random -Minimum 0 -Maximum ([Math]::Max(1, $height))

    $dx = 1
    $dy = 1

    $corAtual = $cores[(Get-Random -Minimum 0 -Maximum $cores.Count)]

    while ($true) {
        # relê tamanho do console (caso o usuario redimensione a janela)
        $width  = $Host.UI.RawUI.WindowSize.Width
        $height = $Host.UI.RawUI.WindowSize.Height - 1

        [console]::SetCursorPosition($x, $y)
        Write-Host (" " * $logoLen) -NoNewline

        $x += $dx
        $y += $dy

        $bateu = $false

        if ($x -le 0) {
            $x = 0
            $dx = 1
            $bateu = $true
        }
        elseif ($x -ge ($width - $logoLen)) {
            $x = $width - $logoLen
            $dx = -1
            $bateu = $true
        }

        if ($y -le 0) {
            $y = 0
            $dy = 1
            $bateu = $true
        }
        elseif ($y -ge $height) {
            $y = $height
            $dy = -1
            $bateu = $true
        }

        if ($bateu) {
            $corAtual = $cores[(Get-Random -Minimum 0 -Maximum $cores.Count)]
        }

        [console]::SetCursorPosition($x, $y)
        Write-Host $logoText -NoNewline -ForegroundColor $corAtual

        Start-Sleep -Milliseconds $delayMs
    }
}
finally {
    [console]::CursorVisible = $true
}
