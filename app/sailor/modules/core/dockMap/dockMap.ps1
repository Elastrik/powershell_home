
class DockMap {
    static [System.Collections.Generic.List[String]]    $dockLocations
    static [string]                                     $SavePath

    static [void] init() {
        if (-not [DockMap]::SavePath) {
            $dockPath = Join-Path $global:persistent_data "docks.json"
            [DockMap]::SavePath = $dockPath
        }
        [DockMap]::dockLocations = [System.Collections.Generic.List[String]]::new()
        
        if (Test-Path "$([DockMap]::SavePath)") {
            $data = Get-Content "$([DockMap]::SavePath)" | ConvertFrom-Json
            if ($data.DockLocations) {
                [DockMap]::dockLocations = [System.Collections.Generic.List[String]]::new()
                $data.DockLocations | ForEach-Object {
                    [DockMap]::dockLocations.Add($_)
                }
            }
        }
    }

    static [void] Save() {
        if (-not [DockMap]::SavePath) {
            [DockMap]::SavePath = Join-Path $global:persistent_data "docks.json"
        }
        if ($null -eq [DockMap]::dockLocations) {
            [DockMap]::init()
        }
        $data = @{
            DockLocations = [DockMap]::dockLocations
        }  | ConvertTo-Json -Depth 10 | Set-Content ([DockMap]::SavePath)
    }
   
    static [void] listDocks() {
        if ($null -eq [DockMap]::dockLocations) {
            [DockMap]::init()
        }
        
        [DockMap]::dockLocations | ForEach-Object {
            Write-Host $_
        }
    }
    static [bool] isDock([string] $path) {

        if ($null -eq [DockMap]::dockLocations) {
            [DockMap]::init()
        }
        
        $isDock = [DockMap]::dockLocations.Contains($path)
        return $isDock
    }
    static [void] addDock([string] $path) {
        if ($null -eq [DockMap]::dockLocations) {
            [DockMap]::init()
        }
        if (-not [DockMap]::dockLocations.Contains($path)) {
            [DockMap]::dockLocations.Add($path)
            [DockMap]::Save()
        }
    }

}

class DockMapRenderer {
    static [void] RenderDockMap() {
        if ($null -eq [DockMap]::dockLocations) { [DockMap]::init() }

        $current = (Get-Location).Path

        Write-Host ""
        Write-Host " ╔══════════════════════════════════════════  " -ForegroundColor DarkYellow
        Write-Host " ║" -ForegroundColor DarkYellow -NoNewLine
        Write-Host "    ~  C A R T E   D E S   P O R T S  ~"          -ForegroundColor Magenta
        Write-Host " ╠══════════════════════════════════════════  " -ForegroundColor DarkYellow
        Write-Host " ║" -ForegroundColor DarkYellow
        Write-Host " ║--> Emplacement actuel :" -ForegroundColor DarkYellow
        Write-Host " ║" -ForegroundColor DarkYellow -NoNewLine
        Write-Host "   $current"              -ForegroundColor White
        Write-Host " ║" -ForegroundColor DarkYellow
        Write-Host " ║~~ Ports connus :"         -ForegroundColor Yellow
        Write-Host " ║" -ForegroundColor DarkYellow

        $closest = ""
        $closestDepth = [int]::MaxValue

        [DockMap]::dockLocations | ForEach-Object {
            $dock = $_
            $isCurrent = $dock -eq $current

            # calcule la distance dans l'arborescence
            $depth = [math]::Abs(($current.Split('\').Count) - ($dock.Split('\').Count))
            if ($depth -lt $closestDepth) {
                $closestDepth = $depth
                $closest = $dock
            }

            $color = if ($isCurrent) { "Green" } else { "White" }
            $tag = if ($isCurrent) { " ◄ vous êtes ici" } else { "" }

            Write-Host " ║> " -ForegroundColor Yellow -NoNewline
            Write-Host $dock  -ForegroundColor $color -NoNewline
            Write-Host $tag   -ForegroundColor Green
        }

        Write-Host " ║" -ForegroundColor DarkYellow
        Write-Host " ╠≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈" -ForegroundColor DarkYellow
        if ($closest -ne "" -and $closest -ne $current) {
            Write-Host " ║  Port le plus proche : " -ForegroundColor DarkGray -NoNewline
            Write-Host $closest                   -ForegroundColor Green
        }
        elseif ($closest -eq $current) {
            Write-Host " ║  " -ForegroundColor DarkYellow -NoNewLine
            Write-Host "Vous êtes dans un port !" -ForegroundColor Magenta
        }
        else {
            Write-Host " ║ " -ForegroundColor DarkYellow - NoNewLine
            Write-Host "Aucun port enregistré."   -ForegroundColor Red
        }
        Write-Host " ╚≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈" -ForegroundColor DarkYellow
        Write-Host ""

        read-Host "[Entrée pour continuer]"
    }
}

Class DockMenu {
    static [string] main() {
        $menu = @{
            title    = "~~ BIGFISH ~~"
            subtitle = "Bienvenue au port [$((Get-Location).Path)]"
            color    = "Green"
            options  = @()
        }
        $optionIndex = 1

        $options = @{
            key     = ($optionIndex++).ToString()
            label   = "Aller au marchand"
            command = "merchant"
            color   = "DarkYellow"
        }
        $menu.options += $options

        
        $options = @{
            key     = ($optionIndex++).ToString()
            label   = "Vendre les poissons"
            command = "bigfish sell"
            color   = "DarkRed"
        }
        $menu.options += $options

        $options = @{
            key     = "R"
            label   = "Retour"
            command = "back"
            color   = "Gray"
        }
        $menu.options += $options

        # Quitter
        $options = @{
            key     = "Q"
            label   = "Quitter le programme"
            command = "exit"
            color   = "Gray"
        }
        $menu.options += $options
        return $menu | ConvertTo-Json -Depth 5
    }
}