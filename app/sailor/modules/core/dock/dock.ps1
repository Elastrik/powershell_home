
class DockMap {
    static [System.Collections.Generic.List[String]]    $dockLocations
    static [string]                                     $SavePath

    static [void] init() {
        if (-not [DockMap]::SavePath) {
            [DockMap]::SavePath = Join-Path $global:persistent_data "docks.json"
        }
        [DockMap]::dockLocations = [System.Collections.Generic.List[String]]::new()
        if (Test-Path [DockMap]::SavePath) {
            $data = Get-Content [DockMap]::SavePath | ConvertFrom-Json
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
        write-host 'Checking dock for path: ' $path
        if ($null -eq [DockMap]::dockLocations) {
            [DockMap]::init()
        }
        return [DockMap]::dockLocations.Contains($path)
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