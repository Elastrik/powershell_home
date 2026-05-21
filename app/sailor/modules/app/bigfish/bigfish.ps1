#######################
# CLASSES PRINCIPALES #
#######################
# Type de poisson
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
# Poissons
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

# Filet de poisson 
class FishNet {
    [System.Collections.Generic.List[FishFile]] $net
    [int] $capacity = 1
  

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

        # $this.net.GetEnumerator() | ForEach-Object {
            
        # }
        foreach ($fish in $this.net) {
            $wallet.AddCatch($fish)
            Remove-Item $fish.file

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
    [int] getCapacity() {
        $modifiers = 0
        $global:sailor_bag.items | ForEach-Object {
            
            if ($_.Metadata["NetCapacity"]) {
                $modifiers += ([int]$_.Metadata["NetCapacity"] * $_.quantity)
            }
        }
        return $this.capacity + $modifiers
    }
    [bool] canGoDeep() {
        $canGoDeep = $false
        $global:sailor_bag.items | ForEach-Object {
            if ($_.Metadata["CanGoDeep"] -and $_.Metadata["CanGoDeep"] -eq "true") {
                $canGoDeep = $true
            }
        }
        return $canGoDeep
    }

}
# Le pecheur
class Fisher {
    [FishNet]   $net
    
    Fisher() {
        $this.net = [Fishnet]::New()
    }
    [Fisher] FishByCapacity() {
        $capacity = $this.net.getCapacity()
        Get-ChildItem -File |
        Sort-Object Length -Descending |
        Select-Object -First $capacity |
        ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)

        }
        return $this
    }

    [Fisher] FishByCount([int] $n = 5) {
        if ($n -gt $this.net.getCapacity()) {
            $n = $this.net.getCapacity()
        }
        Get-ChildItem -File |
        Sort-Object Length -Descending |
        Select-Object -First $n |
        ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)

        }
        return $this
    }
    [Fisher] FishByType([string] $typename) {
        $n = $this.net.getCapacity()
        Get-ChildItem -File | Where-Object { 
            $fish = [FishFile]::new($_)
            $fish.fishType.name -eq $typename
        } |
        Sort-Object Length -Descending | Select-Object -First $n |
        ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)

        }
        return $this
    }
    [Fisher] DeepFishByCount([int] $count = 5) {
        if ($count -gt $this.net.getCapacity()) {
            $count = $this.net.getCapacity()
        }
        Get-ChildItem -Recurse -File |
        Sort-Object Length -Descending |
        Select-Object -First $count |
        ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)
        }
        return $this
    }
    [Fisher] DeepFishByType([string] $typename) {
        Get-ChildItem -File -Recurse | Where-Object { 
            $fish = [FishFile]::new($_)
            $fish.fishType.name -eq $typename
        } |
        Sort-Object Length -Descending | Select-Object - First $this.net.getCapacity()
        ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)
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


########################
# CLASSES DE RENDERING #
########################
class FishRenderer {

    [void] RenderNet([BigFish] $bf, [bool] $selling = $false, [string] $type) {
        $this.RenderHeader($bf)
        $this.renderWallet($bf)
        $netColor = 'Cyan'
        Write-Host ""
        if ($selling) {
            $netColor = 'Red'
            Write-Host "~~ A VENDRE ~~" -ForegroundColor $netColor    
        }
        Write-Host "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#" -ForegroundColor $netColor
        Write-Host "-#-#- [$(([String]$bf.fisher.net.net.count).PadLeft(4,' '))/$(([String]$bf.fisher.net.getCapacity()).PadLeft(4,' '))] poissons dans le filet -#-#-" -ForegroundColor $netColor
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
        $wr = [WalletRenderer]::new()
        $wr.renderWallet($bf.wallet.wallet)
        
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
        write-host ""
        for ($i = 0; $i -lt $logo.Length; $i++) {
            Write-Host $logo[$i] -ForegroundColor $colors[$i]
        }

      
     
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

class BigFishMenu {
    static [string] main() {
        $bf = $global:sailor_bigfish_instance
        $menu = @{
            title    = "~~ BIGFISH ~~"
            subtitle = "A la pêche au gros !"
            color    = "Cyan"
            options  = @()
        }
        $optionIndex = 1
        $options = @{
            key     = ($optionIndex++).ToString()
            label   = "Naviguer"
            command = "[Menu]::New([BigFishMenu]::SailingMenu()).show()"
            color   = "White"
        }
        $menu.options += $options

        
        $options = @{
            key     = ($optionIndex++).ToString()
            label   = "Pecher"
            command = "[Menu]::New([BigFishMenu]::FishingMenu()).show()"
            color   = "White"
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

    static [string] FishingMenu() {
        $bf = $global:sailor_bigfish_instance
        $menu = @{
            title    = "~~ BIGFISH - menu de pêche ~~"
            subtitle = "Emplacement : $((Get-Location).Path)"
            color    = "DarkCyan"
            options  = @()
        }

        $optionKey = 1

        # peche classique
        $capacity = $bf.fisher.net.getCapacity()
        $options = @{
            key     = ($optionKey++).toString()
            label   = "Remplir le filet (capacité:$($capacity))"
            command = "bigfish fish $($capacity)"
            color   = "Yellow"
        }
        $menu.options += $options

        # peche en profondeur
        $canGoDeep = $bf.fisher.net.canGoDeep()
        if ($canGoDeep) {
            $options = @{
                key     = ($optionKey++).toString()
                label   = "Pêcher en profondeur (capacité:$($capacity))" + ($canGoDeep ? "" : " - REQUIERT UN OBJET POUR ALLER EN PROFONDEUR")
                command = "bigfish deepfish $($capacity)"
                color   = "DarkYellow"
            }
            $menu.options += $options
        }

        
        $options = @{
            key     = "F"
            label   = "Consulter le Filet"
            command = "bigfish net"
            color   = "Cyan"
        }
        $menu.options += $options
            
        $options = @{
            key     = "R"
            label   = "Retour"
            command = "back"
            color   = "Gray"
        }
        $menu.options += $options

        $options = @{
            key     = "Q"
            label   = "Quitter le programme"
            command = "exit"
            color   = "Gray"
        }
        $menu.options += $options
        return $menu | ConvertTo-Json -Depth 5
    }
    static [string] SailingMenu() {
        $menu = @{
            title    = "~~ BIGFISH - menu de Navigation ~~"
            subtitle = "Emplacement : $((Get-Location).Path)"
            color    = "Blue"
            options  = @()
        }

        $optionKey = 1
        $options = @{
            key     = "B"
            label   = "Demi-tour"
            command = @("set-Location ..", "exit", "[Menu]::New([BigFishMenu]::SailingMenu()).show()")
            color   = "Gray"
        }
        $menu.options += $options

        Get-ChildItem -Directory | ForEach-Object {
            $options = @{
                key     = ($optionKey++).toString()
                label   = "$($_.name)"
                command = @("set-Location '$_'", "exit", "[Menu]::New([BigFishMenu]::SailingMenu()).show()")
                color   = "DarkGray"
            }
            $menu.options += $options
        }    
        $options = @{
            key     = "R"
            label   = "Retour"
            command = "back"
            color   = "Gray"
        }
        $menu.options += $options

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

#############################
# Classes de gestion du jeu #
#############################
class FishWallet {
    [Wallet] $Wallet

    FishWallet([string] $savePath) {
        $this.Wallet = [Wallet]::new($savePath)
    }

    [void] AddCatch([FishFile] $fish) {
        $this.Wallet.AddValue($fish.valeur)

        # Mettre à jour FishCount dans les métadonnées
        $currentCount = $this.Wallet.GetMetadata("FishCount")
        if ($null -eq $currentCount) { $currentCount = 0 }
        $this.Wallet.SetMetadata("FishCount", $currentCount + 1)
    }

    [int] GetFishCount() {
        $count = $this.Wallet.GetMetadata("FishCount")
        return if ($null -eq $count) { 0 } else { $count }
    }

    [long] GetValue() {
        return $this.Wallet.valeur
    }
}

class BigFish {
    [Fisher]       $Fisher
    [FishRenderer] $Renderer
    [FishWallet]   $wallet

    BigFish() {
        $this.Fisher = [Fisher]::new()
        $this.Renderer = [FishRenderer]::new()
        $wallet_path = Join-path $global:persistent_data 'wallet.json'
        $this.wallet = [FishWallet]::new($wallet_path)

    }

    [void] Execute( $cmd) {
        switch ($cmd[0]) {
            "fish" { $this.Fish($cmd[1]) }
            "deepfish" { $this.DeepFish($cmd[1]) }
            "sell" { $this.Sell($cmd[1]) }
            "net" { $this.Net($cmd[1]) }
            "help" { $this.Renderer.RenderHelp($this) }
            default { 
                $this.Renderer.RenderHeader($this)
                $menubf_path = [BigFishMenu]::main()
                $menuBigfish = [Menu]::new($menubf_path)
                $menuBigfish.show()
            }
        }
    }

    [void] Fish([string] $param) {
        if ($param) {
            $this.Fisher.FishByCapacity()
        }
        else {
            # arg peut être un nombre ou un type de poisson

            if ($param -match '^\d+$') {
                $this.Fisher.FishByCount([int]$param)
            }
            else {
                $this.Fisher.FishByType($param)
            }
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
        if ( $this.Fisher.net.net.count -gt 0) {
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
