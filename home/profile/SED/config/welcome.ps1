class welcome {
    
    [void] RenderLogo (){
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
    }
     [void] RenderLogoSed (){
           $logo = @(
            "   ███████╗███████╗██████╗ "
            "   ██╔════╝██╔════╝██╔══██╗"
            "   ███████╗█████╗  ██║  ██║"
            "   ╚════██║██╔══╝  ██║  ██║"
            "   ███████║███████╗██████╔╝"
            "   ╚══════╝╚══════╝╚═════╝"
        )

        $colors = @("DarkBlue", "DarkBlue", "Cyan", "Cyan", "Yellow", "Yellow")

        for ($i = 0; $i -lt $logo.Length; $i++) {
            Write-Host $logo[$i] -ForegroundColor $colors[$i]
        }
    }
    [void] RenderSystemInfo(){
        $date = Get-Date -Format "dddd dd/MM/yyyy  HH:mm"
        # $psVersion = $PSVersionTable.PSVersion.ToString()

        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  user     " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host "VICTOR"           -ForegroundColor Magenta
        Write-Host "  machine  " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $env:COMPUTERNAME  -ForegroundColor Cyan
        # Write-Host "  shell    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host "PowerShell $psVersion" -ForegroundColor Green
        Write-Host "  heure    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $date              -ForegroundColor Yellow
    } 
    [void] RenderMeteo([string] $location){
        $meteo_chezy = (Invoke-WebRequest "wttr.in/$($location)?format=3" -UseBasicParsing).Content.Trim()

        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  météo    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $meteo_chezy       -ForegroundColor Cyan

    }
    [void] RenderDiskInfo (){
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  Etat des disques : " -ForegroundColor DarkGray
        diskbar
    } 
    [void] RenderWallet(){
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray    
        wallet        
    
    }
    [void] RenderMessage([sTring] $msg){
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  $msg" -ForegroundColor Magenta
    }
}


function Welcome (){
    
    
    if ($Host.UI.RawUI) {
        
        $welcome = [Welcome]::New()
       
        $welcome.RenderLogoSed()
        $welcome.RenderSystemInfo()
        $welcome.RenderDiskInfo()
        $welcome.RenderMeteo("moussy-le-vieux")
        $welcome.RenderMessage("Encore du travail ? ")        
        $welcome.RenderWallet()
      
        # mainmenu
        
    }

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

