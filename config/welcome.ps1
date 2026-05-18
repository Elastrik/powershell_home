

if ($Host.UI.RawUI) {
    Write-Host ""
    $meteo_chezy = (Invoke-WebRequest "wttr.in/Chezy-sur-Marne?format=3" -UseBasicParsing).Content.Trim()
    $date = Get-Date -Format "dddd dd/MM/yyyy  HH:mm"
    $psVersion = $PSVersionTable.PSVersion.ToString()

    $logo = @(
        " ███████╗██╗      █████╗ ███████╗████████╗██████╗ ██╗██╗  ██╗"
        " ██╔════╝██║     ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝"
        " █████╗  ██║     ███████║███████╗   ██║   ██████╔╝██║█████╔╝ "
        " ██╔══╝  ██║     ██╔══██║╚════██║   ██║   ██╔══██╗██║██╔═██╗ "
        " ███████╗███████╗██║  ██║███████║   ██║   ██║  ██║██║██║  ██╗"
        " ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝"
    )

    $colors = @("Magenta", "Magenta", "Cyan", "Cyan", "Green", "Green")

    for ($i = 0; $i -lt $logo.Length; $i++) {
        Write-Host $logo[$i] -ForegroundColor $colors[$i]
    }
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  user     " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host "VICTOR"           -ForegroundColor Magenta
    Write-Host "  machine  " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $env:COMPUTERNAME  -ForegroundColor Cyan
    Write-Host "  shell    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host "PowerShell $psVersion" -ForegroundColor Green
    Write-Host "  heure    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $date              -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  météo    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $meteo_chezy       -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  Etat des disques : " -ForegroundColor DarkGray
    diskbar
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray    
    Write-Host ""
    Write-Host "  Bonjour VICTOR, donne moi des ordres." -ForegroundColor Magenta
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray

}


function prompt {
    $time = Get-Date -Format "HH:mm:ss"
    $path = (Get-Location).Path  # ajoute .Path pour avoir une vraie string

    # Définis tes alias de dossiers avec des couleurs
    $pathAliases = @(
        # @{ Key = $env:SHELL_HOME; Value = "~HOME"; Color = "Magenta" },  # Magenta
        @{ Key = $desk; Value = "~DESKTOP\"; Color = "Cyan" }, # Cyan
        @{ Key = $jahbless; Value = "~JAHBLESS\"; Color = "Yellow" },          # Jaune
        @{ Key = $docs; Value = "~DOCS\"; Color = "Green" },          # Vert
        @{ Key = $soft; Value = "~SOFT\"; Color = "Magenta" }         
    )

    # Trie les alias par longueur de clé (du plus long au plus court)
    $sortedAliases = $pathAliases | Sort-Object { $_.Key.Length } -Descending

    # Remplace les chemins par leurs alias (avec couleurs)
    $shortPathParts = @()
    $remainingPath = $path
    foreach ($alias in $sortedAliases) {
        if ($remainingPath -like "$($alias.Key)*") {
            $shortPathParts += @{ Text = $alias.Value; Color = $alias.Color }
            $remainingPath = $remainingPath.Substring($alias.Key.Length)
        }
    }
    if ($remainingPath) {
        $shortPathParts += @{ Text = $remainingPath; Color = "White" }  # Blanc par défaut
    }



    # Affiche le reste du prompt
    Write-Host "[$time] " -ForegroundColor DarkGray -NoNewline
    Write-Host "ELASTRIK " -ForegroundColor Cyan -NoNewline
    # Affiche le chemin avec les couleurs
    foreach ($part in $shortPathParts) {
        Write-Host $part.Text -ForegroundColor $part.Color -NoNewline
    }
    return " > "
}


Set-location $docs

mainmenu