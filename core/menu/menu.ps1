class MenuItem {
    [string] $Key
    [string] $Label
    [string[]] $Command
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


    Menu([string] $input_data) {
        $resolvedInput = $input_data
        $data = $null
        

        # Teste d'abord si ça ressemble à du JSON
        if ($input_data.TrimStart().StartsWith("{")) {
            try {
                $data = $input_data | ConvertFrom-Json
            }
            catch {
                throw "JSON invalide : $_"
            }
        }
        else {
            # C'est un chemin de fichier
            if (-not [System.IO.Path]::IsPathRooted($input_data)) {
                $resolvedInput = Join-Path $global:powershell_folder $input_data
            }

            if (Test-Path $resolvedInput -PathType Leaf) {
                $data = Get-Content $resolvedInput | ConvertFrom-Json
            }
            else {
                throw "Fichier introuvable : $resolvedInput"
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

        $bar = "_" * 80
        write-host $bar -ForegroundColor DarkGray

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

    [String] Show() {
        $stop = $false
        $choice = ""
        while ($true -and -not $stop) {
            
            $this.Render()
            write-Host "Votre choix" -ForegroundColor Yellow -NoNewline
            $choice = Read-Host " " 
                
            $bar = "_" * 80
            write-host $bar -ForegroundColor DarkGray
            
            $selected = $this.Options | Where-Object { $_.Key -eq $choice }

            if ($null -eq $selected) {
                Write-Host "  Choix invalide" -ForegroundColor Red
                Start-Sleep 1
                continue
            }

            if (-not [string]::IsNullOrEmpty($selected.Instance)) {
                $subMenu = (Get-Variable -Name $selected.Instance -ErrorAction SilentlyContinue).Value
                if ($null -ne $subMenu) { $subMenu.Show() }
                return $choice  
            }

            if (-not [string]::IsNullOrEmpty($selected.Submenu)) {
                $sub = [Menu]::new($selected.Submenu)
                $sub.Show()
                return $choice  
            }


            $shouldExit = $false
            
            $selected.Command | ForEach-Object {
                $cmd = $_
      
                if ($cmd -eq "exit" -or $cmd -eq "back") {
                    $shouldExit = $true
                    write-host "Returning $choice" -ForegroundColor Green

                    return $choice   # quitte le ForEach
                }

      
                # write-host "Exécution de la commande : $cmd" -ForegroundColor Green
                
                Write-Host "commande exec : $cmd" -ForegroundColor Green
                $cmdReturn = Invoke-Expression $cmd
                if ($cmdReturn -eq "Q" -or $cmdReturn -eq "q") {
                    $shouldExit = $true
                    return $choice   # quitte le ForEach
                }
            }

             if ($shouldExit) { 
                    return $choice
            }
     
        }

        return $choice   

    }
}