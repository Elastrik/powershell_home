
class FishType {
    static [Hashtable] $fishSize = @{
        'krill'     = 0KB
        'maquereau' = 10KB
        'saumon'    = 1MB
        'daurade'   = 100MB
        'thon'      = 500MB
        'orque'     = 1GB
        'baleine'   = 10GB
    }
    static [Hashtable] $fishColor = @{
        'krill'     = 'DarkGray'
        'maquereau' = 'Gray'
        'saumon'    = 'White'
        'daurade'   = 'Green'
        'thon'      = 'Yellow'
        'orque'     = 'Red'
        'baleine'   = 'Magenta'
    }
    [String] $name
    [String] $Color
    
    FishType([System.IO.FileInfo] $file) {
        $this.name = 'krill'  # valeur par défaut

        [FishType]::fishSize.GetEnumerator() |
        Sort-Object Value -Descending |
        ForEach-Object {
            if ($file.Length -ge $_.Value -and $this.name -eq 'krill') {
                $this.name = $_.Key
            }
        }
        $this.color = [FishType]::fishColor[$this.name]
    }

}

class FishFile {
    [System.IO.FileInfo] $file
    [FishType]           $fishType
    [string]             $displaySize

    # constructeur
    FishFile([System.IO.FileInfo] $file) {
        $this.file = $file
        $this.fishType = New-Object -TypeName FishType -ArgumentList $file

        $unit = 'Go'
        $size = [math]::Round($this.file.Length / 1GB, 2)
        if ($size -lt 1) { 
            $unit = 'Mo'
            $size = [math]::Round($this.file.Length / 1MB, 2)
            if ($size -lt 1) { 
                $unit = 'Ko'
                $size = [math]::Round($this.file.Length / 1KB, 2)
            } 
        }
        $this.displaySize = "$size" + $unit
    }


}


class FishNet {
    [System.Collections.Generic.List[FishFile]] $net

    FishNet() {
        $this.net = [System.Collections.Generic.List[FishFile]]::new()
    }

    [FishNet] AddFish([FishFile] $fish) {
        write-host "[addfish] fish added : $($fish.file.name)"
        $this.net.Add($fish)
        $this.net.GetEnumerator() | ForEach-Object {
           write-host "net contient $($_.file.name)"
        }
        return $this
    }
    [Fishnet] Sell() {
        $this.net.GetEnumerator() | ForEach-Object {
           Remove-Item $_.file
        }
        return $this
    }
}

class Fisher {
    [FishNet]   $net
    
    Fisher() {
        $this.net = New-Object -TypeName FishNet
    }

    [Fisher] FishByCount([int] $n = 5) {
        Get-ChildItem -File |
        Sort-Object Length -Descending |
        Select-Object -First $n |
        ForEach-Object {
            $fish = New-Object -TypeName FishFile -ArgumentList $_ 
            $this.net.AddFish($fish)

        }
        return $this
    }
    [Fisher] FishByType([string] $typename) {
        Get-ChildItem -File |
        Sort-Object Length -Descending |
        ForEach-Object {
            $fish = New-Object -TypeName FishFile -ArgumentList $_
            if ($fish.fishType.name -eq $typename) {
                $net.AddFish($fish)
            }
        }
        return $this
    }
    [Fisher] Sell() {
        $this.net.Sell()
        return $this
    }

}

class FishRenderer {

    [void] RenderNet([FishNet] $net) {
        $this.RenderHeader($net.Net.Count)
        foreach ($fish in $net.Net) {
            $this.RenderFish($fish)
        }
        $this.RenderFooter()
    }

    [void] RenderFish([FishFile] $fish) {
        $padding = 50
        $filler = '-'
        $fishLabel = ")>[$($fish.fishType.name)])°>" 

        $color = $fish.fishType.color

        Write-Host "~>$($fishLabel.padRight(16,'~')) " -ForegroundColor $color -NoNewline
        Write-Host "$($fish.file.Name.PadRight($padding,$filler))" -ForegroundColor $color -NoNewline
        Write-Host " — $($fish.displaySize)" -ForegroundColor $color 
    }

    [void] RenderHeader([int] $count) {
        Write-Host "************************************************" -ForegroundColor Cyan
        Write-Host "***** " -ForegroundColor Cyan -NoNewline
        Write-Host "~ Big-Fisher à la pêche au gros ~" -ForegroundColor Magenta -NoNewline
        Write-Host " ********"  -ForegroundColor Cyan
        Write-Host "************************************************" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Il y a $count poissons dans le filet " -ForegroundColor Gray
        Write-Host ""
    }

    [void] RenderFooter() {
        Write-Host ""
        Write-Host "~ Belle prise ? ~" -ForegroundColor Cyan
    }

    [void] RenderError([string] $message) {
        Write-Host "  ~* $message *~" -ForegroundColor Red
    }

    [void] RenderSuccess([string] $message) {
        Write-Host "  ~* $message *~" -ForegroundColor Green
    }
}

class BigFish {
    [Fisher]       $Fisher
    [FishRenderer] $Renderer

    BigFish() {
        $this.Fisher = [Fisher]::new()
        $this.Renderer = [FishRenderer]::new()
    }

    [void] Execute( $cmd) {
        switch ($cmd[0]) {
            "fish" { $this.Fish($cmd[1]) }
            "sell" { $this.Sell() }
            "net" { $this.Net() }
            default { $this.Fish(10) }
        }
    }

    [void] Fish([string] $param) {
        # arg peut être un nombre ou un type de poisson
        if ($param -match '^\d+$') {
            $net = $this.Fisher.FishByCount([int]$param).net
        }
        else {
            $net = $this.Fisher.FishByType($param).net
        }
        $this.Renderer.RenderNet($net)
    }

    [void] Sell() {
        $net = $this.Fisher.net
        $this.Renderer.RenderNet($net)
        # demande confirmation avant de supprimer
        $confirm = Read-Host "  Supprimer ces fichiers ? (o/n)"
        if ($confirm -eq 'o') {
            $this.Fisher.Sell()
            $this.Renderer.RenderSuccess("Fichiers supprimes !")
        }
    }
    [void] Net() {
        
        $this.Renderer.RenderNet($this.Fisher.net)
        
    }

}