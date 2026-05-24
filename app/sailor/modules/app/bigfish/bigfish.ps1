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
        [Bag]::GetInstance().items | ForEach-Object {
            
            if ($_.Metadata["NetCapacity"]) {
                $modifiers += ([int]$_.Metadata["NetCapacity"] * $_.quantity)
            }
        }
        return $this.capacity + $modifiers
    }
    [bool] canGoDeep() {
        $canGoDeep = $false
        [Bag]::GetInstance().items | ForEach-Object {
            if ($_.Metadata["CanGoDeep"] -and $_.Metadata["CanGoDeep"] -eq "true") {
                $canGoDeep = $true
            }
        }
        return $canGoDeep
    }
    [bool] canFishByType() {
        $canFishByType = $false
        [Bag]::GetInstance().items | ForEach-Object {
            if ($_.Metadata["CanFishByType"] -and $_.Metadata["CanFishByType"] -eq "true") {
                $canFishByType = $true
            }
        }
        return $canFishByType
    }
    [bool] CanDeepScan() {
        $CanDeepScan = $false
        [Bag]::GetInstance().items | ForEach-Object {
            if ($_.Metadata["CanDeepScan"] -and $_.Metadata["CanDeepScan"] -eq "true") {
                $CanDeepScan = $true
            }
        }
        return $CanDeepScan
    }
    [bool] CanScan() {
        $CanScan = $false
        [Bag]::GetInstance().items | ForEach-Object {
            if ($_.Metadata["CanScan"] -and $_.Metadata["CanScan"] -eq "true") {
                $CanScan = $true
            }
        }
        return $CanScan
    }
    [bool] CanSetDock() {
        $CanSetDock = $false
        $b = [Bag]::GetInstance()
        # write-Host $b
        $b.items | ForEach-Object {
            if ($_.Metadata["CanSetDock"] -and $_.Metadata["CanSetDock"] -eq "true") {
                $CanSetDock = $true
            }
        }
        return $CanSetDock
    }
    [bool] CanShowMap() {
        $canShowMap = $false
        $b = [Bag]::GetInstance()
        $b.items | ForEach-Object {
            if ($_.Metadata["CanShowMap"] -and $_.Metadata["CanShowMap"] -eq "true") {
                $canShowMap = $true
            }
        }
        return $canShowMap
    }


}
# Le pecheur
class Fisher {
    [FishNet]   $net
    
    Fisher() {
        $this.net = [Fishnet]::New()
    }
    [Fisher] Fish() {
        $capacity = $this.net.getCapacity()
        Get-ChildItem -File 
        | Sort-Object Length -Descending 
        | Select-Object -First $capacity 
        | ForEach-Object {
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
        } 
        | Sort-Object Length -Descending 
        | Select-Object -First $n 
        | ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)

        }
        return $this
    }
    [Fisher] DeepFish() {
        $count = $this.net.getCapacity()
        Get-ChildItem -Recurse -File 
        | Sort-Object Length -Descending 
        | Select-Object -First $count 
        | ForEach-Object {
            $fish = [FishFile]::new($_)
            $this.net.AddFish($fish)
        }
        return $this
    }
    [Fisher] DeepFishByType([string] $typename) {
        Get-ChildItem -File -Recurse 
        | Where-Object { 
            $fish = [FishFile]::new($_)
            $fish.fishType.name -eq $typename
        } 
        | Sort-Object Length -Descending 
        | Select-Object -First $this.net.getCapacity() 
        | ForEach-Object {
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
    [System.Collections.Generic.List[FishFile]] Scan() {
        $result = [System.Collections.Generic.List[FishFile]]::new()
        

        Get-ChildItem -File 
        | Sort-Object Length -Descending 
        | ForEach-Object {
            $fish = [FishFile]::new($_)
            $result.add($fish)

        }
        Write-host "Scan made " -ForegroundColor Green
        return $result 
    }
    [System.Collections.Generic.List[FishFile]] DeepScan() {
        $result = [System.Collections.Generic.List[FishFile]]::new()
        

        Get-ChildItem -File -Recurse 
        | Sort-Object DirectoryName -Descending 
        | ForEach-Object {
            $fish = [FishFile]::new($_)
            $result.add($fish)

        }
        Write-host "Scan made " -ForegroundColor Green
        return $result 
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
        Read-Host "[Entrée pour continuer]"
    }

    [void] RenderFish([FishFile] $fish) {
        $padding = 50
        $filler = '-'
        $fishLabel = "[$($fish.fishType.name)]" 

        $color = $fish.fishType.color

        Write-Host "~>$($fishLabel.padRight(12,'~')) " -ForegroundColor $color -NoNewline
        Write-Host "$($fish.file.Name.PadRight($padding,$filler))" -ForegroundColor $color -NoNewline
        Write-Host " — $($fish.displaySize) -$($fish.valeur)$([Wallet]::GetInstance().devise)" -ForegroundColor $color 
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
    [void] RenderScan([System.Collections.Generic.List[FishFile]] $scan, [BigFish] $bf) {
        
        $this.RenderHeader($bf)
        
        Write-Host ""
        Write-Host "~ Résultat du scan  ~" -ForegroundColor Yellow
        
        $count = 0
        $savedLocation = ""
        $value = 0
        $length = 0
        foreach ($fish in $scan) {
            $count++
            $location = $fish.file.DirectoryName
            $value += $fish.valeur
            $length += $fish.file.length

            if ($location -ne $savedLocation) {
                if ($savedLocation -ne "") {
                    $unit = 'Go'
                    $size = [math]::Round($length / 1GB, 2)
                    if ($size -lt 1) { 
                        $unit = 'Mo'
                        $size = [math]::Round($length / 1MB, 2)
                        if ($size -lt 1) { 
                            $unit = 'Ko'
                            $size = [math]::Round($length / 1KB, 2)
                        } 
                    }
                    $displaysize = "$size" + $unit
                    Write-Host "Valeur totale : $($value) $([Wallet]::GetInstance().devise) ($($displaysize)) "  -ForegroundColor DarkRed
                }

                Write-Host ""
                Write-Host "Emplacement : [$($location)] " -ForegroundColor Magenta
            }

            $this.RenderFish($fish)
            $savedLocation = $location
        }
        # dernier enreg
        $unit = 'Go'
        $size = [math]::Round($length / 1GB, 2)
        if ($size -lt 1) { 
            $unit = 'Mo'
            $size = [math]::Round($length / 1MB, 2)
            if ($size -lt 1) { 
                $unit = 'Ko'
                $size = [math]::Round($length / 1KB, 2)
            } 
        }
        $displaysize = "$size" + $unit
        Write-Host "Valeur totale : $($value) $([Wallet]::GetInstance().devise) ($($displaysize)) "  -ForegroundColor DarkRed
                    
        Write-Host "~ Total : $count poissons  ~" -ForegroundColor Yellow
        Read-Host "[Entrée pour continuer]"        

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
        $bf = [BigFish]::GetInstance()
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
            command = "bigfish fish"
            color   = "Yellow"
        }
        $menu.options += $options


        # peche en profondeur
        $canGoDeep = $bf.fisher.net.canGoDeep()
        if ($canGoDeep) {
            $options = @{
                key     = ($optionKey++).toString()
                label   = "Pêcher en profondeur (capacité:$($capacity))" + ($canGoDeep ? "" : " - REQUIERT UN OBJET POUR ALLER EN PROFONDEUR")
                command = "bigfish deepfish"
                color   = "DarkYellow"
            }
            $menu.options += $options
        }
        $canFishByType = $bf.Fisher.net.canFishByType()
        if ($canFishByType) {
            $options = @{
                key     = ($optionKey++).toString()
                label   = "Pêcher par type de poisson" 
                command = "[Menu]::New([BigFishMenu]::FishByTypeMenu()).show()"
                color   = "yellow"
            }
            $menu.options += $options
        }
        $canScan = $bf.Fisher.net.canScan()
        if ($canScan) {
            $options = @{
                key     = ($optionKey++).toString()
                label   = "Scanner cet enmplacement" 
                command = "bigfish scan"
                color   = "yellow"
            }
            $menu.options += $options
        }
        $canDeepScan = $bf.Fisher.net.canDeepScan()
        if ($canDeepScan) {
            $options = @{
                key     = ($optionKey++).toString()
                label   = "Scanner en profondeur" 
                command = "bigfish deepscan"
                color   = "Darkyellow"
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
            key     = "V"
            label   = "Vider le filet"
            command = "bigfish net empty"
            color   = "Gray"
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

    static [string] FishByTypeMenu() {
        $menu = @{
            title    = "~~ BIGFISH - Peche par type ~~"
            subtitle = "Emplacement : $((Get-Location).Path)"
            color    = "DarkBlue"
            options  = @()
        }

        $optionKey = 1

        [FishType]::fishSize.GetEnumerator() |
        Sort-Object { $_.Value } |
        ForEach-Object {
           
            $options = @{

                key     = ($optionKey++).toString()
                label   = "$($_.key)"
                command = "bigfish fish $($_.key)"
                color   = "$([FishType]::fishColor[$_.key])"

            }
            $menu.options += $options

        }

        $options = @{
            key     = "R"
            label   = "Retour"
            command = "back"
            color   = "DarkYellow"
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
        $b = [Bag]::GetInstance()
        if ([BigFish]::GetInstance().Fisher.Net.CanShowMap()) {
            $options = @{
                key     = "M"
                label   = "Afficher la carte"
                command = "dock"
                color   = "DarkYellow"
            }
            $menu.options += $options
        }

        $optionKey = 1
        $options = @{
            key     = ".."
            label   = "Demi-tour (..)"
            command = @("set-Location ..", "exit", "[Menu]::New([BigFishMenu]::SailingMenu()).show()")
            color   = "Blue"
        }
        $menu.options += $options

        Get-ChildItem -Directory | ForEach-Object {
            $location = $_.FullName
            if ([DockMap]::isDock($location)) {
                $label = "$($_.Name) [PORT]"
                $color = "Green"
            }
            else {
                $label = $_.Name
                $color = "Blue"
            }
            $options = @{
                key     = ($optionKey++).toString()
                label   = $label
                command = @("set-Location '$_'", "exit", "[Menu]::New([BigFishMenu]::SailingMenu()).show()")
                color   = $color
            }
            $menu.options += $options
        }    
        
      

        # write-host " is dock ? $((Get-Location).Path)"
        $location = "$((Get-Location).Path)"
        $isDock = ([DockMap]::isDock($location) )
        if ($isDock) {
            $options = @{
                key     = "P"
                label   = "Aller au port"
                command = @("[Menu]::New([DockMenu]::Main()).show()")
                color   = "Green"
            }
            $menu.options += $options
        }
        else {
            if ([BigFish]::GetInstance().Fisher.Net.CanSetDock()) {
                $options = @{
                    key     = "S"
                    label   = "Poser un quai d'appoint"
                    command = @("setdock", "exit", "[Menu]::New([BigFishMenu]::SailingMenu()).show()")
                    color   = "DarkGreen"
                }
                $menu.options += $options
            }
        }

        $options = @{
            key     = "R"
            label   = "Poser l'ancre"
            command = "back"
            color   = "DarkYellow"
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
        $this.Wallet = [Wallet]::GetInstance()
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

    static [BigFish] GetInstance() {
        if ($null -eq $global:sailor_bigfish_instance ) {
            $global:sailor_bigfish_instance = [BigFish]::new()
        }
        return $global:sailor_bigfish_instance
    }

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
            "scan" { $this.Scan($cmd[1]) }
            "deepscan" { $this.DeepScan($cmd[1]) }
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
        if (-not $param) {
            write-host "Fisher.fish()" 
            $this.Fisher.Fish()
        }
        else {
            # arg peut être un nombre ou un type de poisson

            if ($param -match '^\d+$') {
                # $this.Fisher.FishByCount([int]$param)
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
            $this.Fisher.DeepFish()
        }
        else {
            $this.Fisher.DeepFishByType($param)
        }
        $this.Renderer.RenderNet($this)
    }
    [void] Scan([string] $param) {
        $this.Renderer.RenderScan($this.Fisher.Scan(), $this)
    }

    [void] DeepScan([string] $param) {
        $this.Renderer.RenderScan($this.Fisher.DeepScan(), $this)
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
