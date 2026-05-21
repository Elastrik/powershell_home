
class SailorDock {

    static [System.Collections.Generic.List[System.String]]    $dockLocations
    static [string]                                            $SavePath

    [string] $location



    SailorDock([string] $location) {
        $this.location = $location
        if ($null -eq [SailorDock]::dockLocations) {
            [SailorDock]::initLocations()
        }
        if ([SailorDock]::dockLocations -notcontains $location) {
            [SailorDock]::dockLocations.Add($location)
            [SailorDock]::Save()
        }
    }

    static [void] initLocations() {
        if (-not [SailorDock]::SavePath) {
            [SailorDock]::SavePath = Join-Path $global:persistent_data "docks.json"
        }
        [SailorDock]::dockLocations = [System.Collections.Generic.List[System.String]]::new()
        if (Test-Path [SailorDock]::SavePath) {
            $data = Get-Content [SailorDock]::SavePath | ConvertFrom-Json
            if ($data.DockLocations) {
                [SailorDock]::dockLocations = [System.Collections.Generic.List[System.String]]::new()
                $data.DockLocations | ForEach-Object {
                    [SailorDock]::dockLocations.Add($_)
                }
            }
        }
    }

    static [void] Save() {
          if (-not [SailorDock]::SavePath) {
            [SailorDock]::SavePath = Join-Path $global:persistent_data "docks.json"
        }
        if ($null -eq [SailorDock]::dockLocations) {
            [SailorDock]::initLocations()
        }
        $data = @{
            DockLocations = [SailorDock]::dockLocations
        }
        $data | ConvertTo-Json -Depth 10 | Set-Content [SailorDock]::SavePath
    }
   
    static [void] listDocks() {
        if ($null -eq [SailorDock]::dockLocations) {
            [SailorDock]::initLocations()
        }
        [SailorDock]::dockLocations | ForEach-Object {
            Write-Host $_
        }
    }

    static [bool] isDock([string] $location) {
        if ($null -eq [SailorDock]::dockLocations) {
            [SailorDock]::initLocations()
        }
        return [SailorDock]::dockLocations -contains $location
    }



}