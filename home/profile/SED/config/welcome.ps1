

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
    Write-Host "$global:profile_name " -ForegroundColor Cyan -NoNewline
    # Affiche le chemin avec les couleurs
    foreach ($part in $shortPathParts) {
        Write-Host $part.Text -ForegroundColor $part.Color -NoNewline
    }
    return " > "
}

