class MenuItem {
    [string] $Key
    [string] $Label
    [string] $Command
    [string] $Submenu
    [string] $Color

    MenuItem([PSCustomObject] $data) {
        $this.Key = $data.key
        $this.Label = $data.label
        $this.Command = if ($data.command) { $data.command } else { "" }
        $this.Submenu = if ($data.submenu) { $data.submenu } else { "" }
        $this.Color = if ($data.color) { $data.color } else { "White" }
    }
}

class Menu {
    [string]      $Title
    [string]      $Subtitle
    [string]      $Header
    [MenuItem[]]  $Options
    [scriptblock] $HeaderBlock   # bloc de code à exécuter avant le rendu
    [string]      $Color


    Menu([string] $input) {
        if (Test-Path $input -PathType Leaf) {
            # C'est un fichier, on le lit
            $data = Get-Content $input | ConvertFrom-Json
        } else {
            # On suppose que c'est une chaîne JSON
            try {
                $data = $input | ConvertFrom-Json
            } catch {
                throw "L'entrée n'est ni un chemin de fichier valide ni un JSON valide : $_"
            }
        }
        $this.Title = $data.title
        $this.Subtitle = $data.subtitle
        $this.Header = $data.header
        $this.Options = $data.options | ForEach-Object { [MenuItem]::new($_) }
        $this.HeaderBlock = $null
        $this.Color = $data.color     
    }

    Menu([string] $jsonPath, [scriptblock] $block) {
        $data = Get-Content $jsonPath | ConvertFrom-Json
        $this.Title = $data.title
        $this.Subtitle = $data.subtitle
        $this.Header = $data.header
        $this.Options = $data.options | ForEach-Object { [MenuItem]::new($_) }
        $this.HeaderBlock = $block
        $this.Color = $data.color
    }


    [void] SetHeader([scriptblock] $block) {
        Write-Host "setHeader : $block" 
        $this.HeaderBlock = $block
    }


    static [string] ResolvePath([string]$path) {
        if ($path -like "*:*") {
            # Chemin absolu (ex: C:\...)
            return $path
        }
        return Join-Path $global:PSConfigRoot $path
    }

    [void] Render() {
        # exécute le header custom si défini
        if ($null -ne $this.HeaderBlock) {
            & $this.HeaderBlock
        }

        $width = 50
        $this.options | ForEach-Object {
            $optionLength = $_.Label.Length + 4
            if ($optionLength -gt $width) {
                $width = $optionLength
            }
        }
        $width += 4
        $Width = [math]::Max($width, [math]::Max($this.Title.Length + 4, $this.Subtitle.Length + 4))


        $line = "═" * $width

        $cadre_color = if ($this.Color) { $this.Color } else { "Blue" } 

        Write-Host "╔$line╗" -ForegroundColor $cadre_color

        Write-Host "║ " -ForegroundColor $cadre_color -NoNewline 
        write-host "$($this.Title.PadRight($width - 1))" -ForegroundColor Cyan -NoNewline
        write-host "║" -ForegroundColor $cadre_color

        Write-Host "║ " -ForegroundColor $cadre_color -NoNewline
        Write-Host "$($this.Subtitle.PadRight($width - 1))" -ForegroundColor white -NoNewline
        Write-Host "║" -ForegroundColor $cadre_color
        Write-Host "╠$line╣" -ForegroundColor $cadre_color
        foreach ($option in $this.Options) {
            $label = "  $($option.Key).  $($option.Label)"
            Write-Host "║ " -ForegroundColor  $cadre_color -NoNewline
            Write-Host "$($label.PadRight($width - 1))" -ForegroundColor $option.Color -NoNewline
            Write-Host "║" -ForegroundColor $cadre_color
        }
        Write-Host "╚$line╝" -ForegroundColor $cadre_color
        Write-Host ""
    }

    [void] Show() {
        $stop = $false
        while ($true -and -not $stop) {
            
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
                $submenuPath = [Menu]::ResolvePath($selected.Submenu)
                if (-not [string]::IsNullOrEmpty($selected.Command)) {
                    $sub = [Menu]::new($submenuPath, $selected.Command)
                }
                else {
                    $sub = [Menu]::new($submenuPath)
                }
                $sub.Show()
                continue
            }
            
            Invoke-Expression $selected.Command
            # Commande normale
            if ( $selected.Command.startsWith("ssh")) {
                $stop = $true
            }else{
                Read-Host "  [Entrée pour revenir]"
            }


        }
    }
}