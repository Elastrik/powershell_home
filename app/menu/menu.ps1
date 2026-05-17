class MenuItem {
    [string] $Key
    [string] $Label
    [string] $Command
    [string] $Submenu

    MenuItem([PSCustomObject] $data) {
        $this.Key = $data.key
        $this.Label = $data.label
        $this.Command = if ($data.command) { $data.command } else { "" }
        $this.Submenu = if ($data.submenu) { $data.submenu } else { "" }
    }
}

class Menu {
    [string]      $Title
    [string]      $Subtitle
    [string]      $Header
    [MenuItem[]]  $Options
    [scriptblock] $HeaderBlock   # bloc de code à exécuter avant le rendu

    Menu([string] $jsonPath) {
        $data = Get-Content $jsonPath | ConvertFrom-Json
        $this.Title = $data.title
        $this.Subtitle = $data.subtitle
        $this.Header = $data.header
        $this.Options = $data.options | ForEach-Object { [MenuItem]::new($_) }
        $this.HeaderBlock = $null
    }
    Menu([string] $jsonPath, [scriptblock] $block) {
        $data = Get-Content $jsonPath | ConvertFrom-Json
        $this.Title = $data.title
        $this.Subtitle = $data.subtitle
        $this.Header = $data.header
        $this.Options = $data.options | ForEach-Object { [MenuItem]::new($_) }
        $this.HeaderBlock = $block
    }


    [void] SetHeader([scriptblock] $block) {
        Write-Host "setHeader : $block" 
        $this.HeaderBlock = $block
    }

    [void] Render() {
        # exécute le header custom si défini
        if ($null -ne $this.HeaderBlock) {
            & $this.HeaderBlock
        }

        $width = 50
        $line = "═" * $width
        Write-Host "╔$line╗" -ForegroundColor Blue

        Write-Host "║ " -ForegroundColor Blue -NoNewline 
        write-host "$($this.Title.PadRight($width - 1))" -ForegroundColor Cyan -NoNewline
        write-host "║" -ForegroundColor Blue

        Write-Host "║ " -ForegroundColor Blue -NoNewline
        Write-Host "$($this.Subtitle.PadRight($width - 1))" -ForegroundColor white -NoNewline
        Write-Host "║" -ForegroundColor Blue
        Write-Host "╠$line╣" -ForegroundColor Blue
        foreach ($option in $this.Options) {
            $label = "  $($option.Key).  $($option.Label)"
            Write-Host "║ " -ForegroundColor  Blue -NoNewline
            Write-Host "$($label.PadRight($width - 1))" -ForegroundColor white -NoNewline
            Write-Host "║" -ForegroundColor Blue
        }
        Write-Host "╚$line╝" -ForegroundColor Blue
        Write-Host ""
    }

    [void] Show() {
        while ($true) {
            
            $this.Render()
        
            $choice = Read-Host "  Votre choix"
            $selected = $this.Options | Where-Object { $_.Key -eq $choice }

            if ($null -eq $selected) {
                Write-Host "  Choix invalide" -ForegroundColor Red
                Start-Sleep 1
                continue
            }

            # Quitter
            if ($selected.Command -eq "exit") { return }

            # Retour menu parent
            if ($selected.Command -eq "back") { return }

            # Sous-menu via instance déjà créée dans le profil
            if (-not [string]::IsNullOrEmpty($selected.Instance)) {
                $subMenu = (Get-Variable -Name $selected.Instance -ErrorAction SilentlyContinue).Value
                if ($null -ne $subMenu) { $subMenu.Show() }
                continue
            }

            # Sous-menu via fichier JSON
            if (-not [string]::IsNullOrEmpty($selected.Submenu)) {
                if(-not [string]::IsNullOrEmpty($selected.Command)){

                    $sub = [Menu]::new($selected.Submenu,$selected.Command)
                }else{
                    $sub = [Menu]::new($selected.submenu)

                }
             
                $sub.Show()
                continue
            }

            # Commande normale
            Invoke-Expression $selected.Command
            Read-Host "  [Entrée pour revenir]"
        }
    }
}