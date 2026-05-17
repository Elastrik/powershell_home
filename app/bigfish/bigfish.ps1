
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
    [String] $color
    
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
    [long]               $valeur

    # constructeur
    FishFile([System.IO.FileInfo] $file) {
        $this.file = $file
        $this.fishType = New-Object -TypeName FishType -ArgumentList $file
        $this.valeur = [math]::Ceiling($this.file.Length / 1MB / 10) 
        if ($this.valeur -eq 0) { $this.valeur = 1 }
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
        $this.net.Add($fish)
        $this.net.GetEnumerator() | ForEach-Object {
        }
        return $this
    }
    [Fishnet] Sell([fishWallet] $wallet) {

        $this.net.GetEnumerator() | ForEach-Object {
            $wallet.AddCatch($_)
            Remove-Item $_.file

        }
        $this.net.clear()
        return $this
    }

    [FishNet] SellByType([string] $typename, [FishWallet] $wallet) {
        $toSell = $this.net | Where-Object { $_.fishType.name -eq $typename }
        $toSell | ForEach-Object {
            $wallet.AddCatch($_)
            Remove-Item $_.file
        }
        $this.net.RemoveAll({ param($f) $f.fishType.name -eq $typename })
        return $this
    }

    [Fishnet] empty() {

        $this.net.clear()
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
                $this.net.AddFish($fish)
            }
        }
        return $this
    }
    [Fisher] DeepFishByCount([int] $count = 5) {
            
        Get-ChildItem -Recurse -File |
        Sort-Object Length -Descending |
        Select-Object -First $count |
        ForEach-Object {
            $fish = New-Object -TypeName FishFile -ArgumentList $_
            $this.net.AddFish($fish)
        }
        return $this
    }
    [Fisher] DeepFishByType([string] $typename) {
        Get-ChildItem -File -Recurse |
        Sort-Object Length -Descending |
        ForEach-Object {
            $fish = New-Object -TypeName FishFile -ArgumentList $_
            if ($fish.fishType.name -eq $typename) {
                $this.net.AddFish($fish)
            }
        }
        return $this
    }


    [Fisher] Sell([fishWallet] $wallet) {
        $this.net.Sell($wallet)
        return $this
    }
    [Fisher] SellByType([string] $typename, [FishWallet] $wallet) {
        $this.net.SellByType($typename, $wallet)
        return $this
    }

}

class FishRenderer {

    [void] RenderNet([BigFish] $bf, [bool] $selling = $false, [string] $type) {
        $this.RenderHeader($bf)
        $netColor = 'Cyan'
        Write-Host ""
        if ($selling) {
            $netColor = 'Red'
            Write-Host "~~ A VENDRE ~~" -ForegroundColor $netColor    
        }
        Write-Host "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#" -ForegroundColor $netColor
        Write-Host "-#-#-#- [$(([String]$bf.fisher.net.net.count).PadLeft(4,' '))] poissons dans le filet -#-#-#-" -ForegroundColor $netColor
        if ([string]::IsNullOrEmpty($type)) {

            foreach ($fish in $bf.Fisher.net.net) {
                $this.RenderFish($fish)
            }
        }
        else {
            foreach ($fish in $bf.Fisher.net.net) {
                if ($fish.fishtype.name -eq $type) {
                    $this.RenderFish($fish)
                }
            }
        }
        Write-Host "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#" -ForegroundColor $netColor
        if ($selling -eq $false) { $this.RenderFooter() }
    }
    # surcharge pour le mode par défaut
    [void] RenderNet([BigFish] $bf) {
        $this.RenderNet($bf, $false, $null)
    }

    [void] RenderFish([FishFile] $fish) {
        $padding = 50
        $filler = '-'
        $fishLabel = "[$($fish.fishType.name)]" 

        $color = $fish.fishType.color

        Write-Host "~>$($fishLabel.padRight(12,'~')) " -ForegroundColor $color -NoNewline
        Write-Host "$($fish.file.Name.PadRight($padding,$filler))" -ForegroundColor $color -NoNewline
        Write-Host " — $($fish.displaySize) -$($fish.valeur)€" -ForegroundColor $color 
    }
    [void] RenderWallet([BigFish] $bf) {
        Write-Host "  █████" -ForegroundColor Cyan -NoNewline
        Write-Host ' WALLET : [' -ForegroundColor White -NoNewline
        Write-Host "$($bf.wallet.valeur)€" -ForegroundColor Yellow -NoNewline
        Write-Host "] - Fish count : " -ForegroundColor White -NoNewline
        Write-Host "$($bf.wallet.FishCount)  " -ForegroundColor Cyan -NoNewline
        Write-Host "█████" -ForegroundColor Cyan 

        
    }

    [void] RenderHeader([BigFish] $bf) {
        $logo = @(
            "  ██████╗ ██╗ ██████╗     ███████╗██╗███████╗██╗  ██╗"
            "  ██╔══██╗██║██╔════╝     ██╔════╝██║██╔════╝██║  ██║"
            "  ██████╔╝██║██║  ███╗    █████╗  ██║███████╗███████║"
            "  ██╔══██╗██║██║   ██║    ██╔══╝  ██║╚════██║██╔══██║"
            "  ██████╔╝██║╚██████╔╝    ██║     ██║███████║██║  ██║"
            "  ╚═════╝ ╚═╝ ╚═════╝     ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝"
        )

        $colors = @("Cyan", "Cyan", "Blue", "Blue", "Magenta", "Magenta")

        for ($i = 0; $i -lt $logo.Length; $i++) {
            Write-Host $logo[$i] -ForegroundColor $colors[$i]
        }
        $this.renderWallet($bf)
     
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

    [void] RenderHelp([Bigfish] $bf) {
        $this.RenderHeader($bf)
        Write-Host ""
        Write-Host "  COMMANDES DISPONIBLES" -ForegroundColor White
        Write-Host "  ──────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "fish <n>         " -ForegroundColor Yellow -NoNewline
        Write-Host "Peche les n plus gros fichiers du repertoire" -ForegroundColor Gray

        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "fish <type>      " -ForegroundColor Yellow -NoNewline
        Write-Host "Peche les fichiers d'un type donne" -ForegroundColor Gray

        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "deepfish <n>     " -ForegroundColor Yellow -NoNewline
        Write-Host "Peche les n plus gros fichiers du repertoire et sous dossier" -ForegroundColor Gray

        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "deepfish <type>  " -ForegroundColor Yellow -NoNewline
        Write-Host "Peche les fichiers d'un type donne du repertoire et sous dossier" -ForegroundColor Gray


        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "net              " -ForegroundColor Yellow -NoNewline
        Write-Host "Affiche le contenu du filet" -ForegroundColor Gray

        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "net empty        " -ForegroundColor Yellow -NoNewline
        Write-Host "Vide le filet sans supprimer les fichiers" -ForegroundColor Gray

        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "sell             " -ForegroundColor Yellow -NoNewline
        Write-Host "Supprime les fichiers du filet et credite le wallet" -ForegroundColor Gray

        Write-Host "  bigfish " -ForegroundColor Cyan -NoNewline
        Write-Host "help             " -ForegroundColor Yellow -NoNewline
        Write-Host "Affiche cette aide" -ForegroundColor Gray

        Write-Host "  ──────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  TYPES DE POISSONS" -ForegroundColor White
        Write-Host "  ──────────────────────────────────────────────────────" -ForegroundColor DarkGray

        $types = @(
            @{ Name = "krill"; Size = "< 10 Ko"; Color = "DarkGray" }
            @{ Name = "maquereau"; Size = "> 10 Ko"; Color = "Gray" }
            @{ Name = "saumon"; Size = "> 1 Mo"; Color = "White" }
            @{ Name = "daurade"; Size = "> 100 Mo"; Color = "Green" }
            @{ Name = "thon"; Size = "> 500 Mo"; Color = "Yellow" }
            @{ Name = "orque"; Size = "> 1 Go"; Color = "Red" }
            @{ Name = "baleine"; Size = "> 10 Go"; Color = "Magenta" }
        )
        foreach ($t in $types) {
            Write-Host "  ~>[$($t.Name.PadRight(10))]  $($t.Size)" -ForegroundColor $t.Color
        }
        Write-Host "  ──────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""
    }
}

class fishWallet {
    [long]   $valeur;
    [int]           $FishCount
    [string]        $SavePath

    # charge le wallet depuis le fichier ou repart de zéro
    FishWallet([string] $savePath) {
        $this.SavePath = $savePath
        if (Test-Path $savePath) {
            $data = Get-Content $savePath | ConvertFrom-Json
            $this.valeur = $data.valeur
            $this.FishCount = $data.FishCount
        }
        else {
            $this.FishCount = 0
            $this.valeur = 0
        }
    }

    [void] AddCatch([FishFile] $fish) {
        $this.valeur += $fish.valeur
        $this.FishCount++
        $this.Save()
    }

    [void] Save() {
        @{
            fishCount = $this.fishCount
            Valeur    = $this.valeur
        } | ConvertTo-Json | Set-Content $this.SavePath
    }
}

class BigFish {
    [Fisher]       $Fisher
    [FishRenderer] $Renderer
    [FishWallet]   $wallet

    BigFish() {
        $this.Fisher = [Fisher]::new()
        $this.Renderer = [FishRenderer]::new()
        $this.wallet = [FishWallet]::new("E:\powershell\app\bigfish\persistent\wallet.json")

    }

    [void] Execute( $cmd) {
        switch ($cmd[0]) {
            "fish" { $this.Fish($cmd[1]) }
            "deepfish" { $this.DeepFish($cmd[1]) }
            "sell" { $this.Sell($cmd[1]) }
            "net" { $this.Net($cmd[1]) }
            "help" { $this.Renderer.RenderHelp($this) }
            default { $this.Fish(10) }
        }
    }

    [void] Fish([string] $param) {
        # arg peut être un nombre ou un type de poisson
        if ($param -match '^\d+$') {
            $this.Fisher.FishByCount([int]$param)
        }
        else {
            $this.Fisher.FishByType($param)
        }
        $this.Renderer.RenderNet($this)
    }
    [void] DeepFish([string] $param) {
        # arg peut être un nombre ou un type de poisson
        if ($param -match '^\d+$') {
            $this.Fisher.DeepFishByCount([int]$param).net
        }
        else {
            $this.Fisher.DeepFishByType($param).net
        }
        $this.Renderer.RenderNet($this)
    }

    [void] Sell([string] $param) {
        $this.Renderer.RenderNet($this, $true, $param)
        Write-Host " "
        Write-Host "  Vendre ces beaux poissons ? (y/n)" -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host " " 
        if ($confirm -eq 'y') {
            if ($param -and $param -ne "") {
                $this.Fisher.SellByType($param, $this.wallet)
            }
            else {
                $this.Fisher.Sell($this.wallet)
            }
            $this.Renderer.RenderSuccess("Fichiers supprimes !")
        }
        if ( $this.Fisher.net.net.count -gt 0)
        {
            Write-Host " "
            Write-Host "  Relacher les autre ? (y/n)" -ForegroundColor Yellow -NoNewline
            $confirm = Read-Host " " 

            if ($confirm -eq 'y') {
                $this.Fisher.net.empty()
            }
        }
    }


    [void] Net([string] $param) {
        if ($param -eq "empty") {
            $this.fisher.net.empty()
        }
        $this.Renderer.RenderNet($this)
        
    }

}