# commande Cargo ->
# Initialise [Cargo] -> $global:sailor_cargo
#    
# Class [Cargo] : 
# - [CargoShip] $cargoShip
#
# - Execute([String[]] $param){
#       - pas de param : maimmenu
#       - load <[String] $filename> : $this.cargoShip.load() 
#       - deliver : $this.cargoShip.deliver()
# - }
# - load($filename)
#
# 
# Class [Parcel]
#   - [System.IO.FileInfo] $file
#
#   - Parcel([String] $fiename){} 
#   - Move([String] $locaton)
#
#
#
# Class [CargoShip]
# - [int] $nitialcapacity = 5
# - [System.Collections.Generic.List[Parcel]] $payload
#
# - GetCapacity() {this.initialCapacity + Bag}
# - Load([String $filname]){$this.payload.add([Parcel::New([String] $filename)])}
# - Deliver()
# 

# Class [CargoPrices] # gere les prix de transport
# - static [double] getOilPrice()
# - static [double] getTransportPrice()



# ### CargoUi.ps1 
# Class [CargoMenu] : 
# - static [String] GetMainMenu)([Cargo] $cargo) {}
# - static [String] GetSailingMenu([Cargo] $cargo) {}
# - static [String] GetLoadMenu([Cargo] $cargo) {}
# 

# Class [CargoRenderer] : 
#   RenderCargo() 
#   RenderCargoLoad()


# CLASSE PRINCIPALE DU JEU 
Class Cargo {
    [CargoShip]     $cargoShip

    static [Cargo] GetInstance() {
        if ($null -eq $global:sailor_cargo) {
            $global:sailor_cargo = [Cargo]::New()
        }
        return $global:sailor_cargo
    }

    Cargo() {
        $this.cargoShip = [CargoShip]::New()
    }

    [void] Execute([String[]] $param) {
        switch ($param[0]) {
            "load" { $this.Load(($param[1])) }
            "deliver" { $this.Deliver() }
            # "help" { $this.Renderer.RenderHelp($this) }
            default { 
                $this.List()
            }
        }
    }
    [void] List() {
        write-host "Cargo Payload : "
        $this.cargoShip.payload | ForEach-Object {
            Write-Host ": $($_.startLocation) - $($_.price)  "
        }
    }

    [void] Load([string] $param) {
        if (-not $param) {
            write-host "[Cargo].Load() - no parameter"  
        }
        else {

            if (Test-Path $param) {
                $this.cargoShip.Load($param)
            }
            else {
                Write-Host "[Cargo].Load() - file not found : $($param)"
            }
        }
    }

    [void] Deliver() {
        # debug
        write-host "[Cargo] Deliver()" -ForegroundColor Yellow

        $wallet = [Wallet]::GetInstance()
        # debug
        write-host "[Cargo] Deliver() wallet loaded - value : $($wallet.Valeur)" -ForegroundColor Yellow

        $valueDelivered = $this.cargoShip.Deliver()
        # debug
        write-host "[Cargo] Deliver() wallet loaded - Value Delivered : $($valueDelivered)" -ForegroundColor Yellow

        $wallet.addValue($valueDelivered)

        # debug
        write-host "[Cargo] Deliver() wallet updated  -wallet :  : $($wallet.valeur)" -ForegroundColor Yellow


    } 


} 


# gere les prix de transport
Class CargoPrices {
    static [double] getOilPrice() {
        $today = [int]::Parse((Get-Date -Format "yyyyMMdd"))
        $rng = [System.Random]::new($today)
        
        $min = 1.5
        $max = 2.5
        $price = $min + ($rng.NextDouble() * ($max - $min))
    
        # Arrondi à 2 décimales
        return [math]::Round($price, 2) 
    }

    # prix par mouvement
    static [double] getTransportPrice() {
        # Minimum
        $TransportPrice = 1
        # ajout du prix du pétrole
        $TransportPrice += [CargoPrices]::getOilPrice()

        return $TransportPrice
    }


} 
    



Class Parcel {
    [String]    $startLocation = ''
    [String]    $filename = ''
    [float]     $length = 0
    [int]       $price = 0
    [int]       $route = 0


    Parcel([String] $filename) {
        $file = Get-ChildItem -File | Where-Object { $_.Name -eq $filename } 
        if ($null -eq $file) {
            Write-Host "[Parcel] -> Parcel(<filename>) File $($filename) not found" -ForegroundColor "Red"
        }
        else {
            $this.startLocation = $file.fullName
            $this.filename = $file.Name
            $this.length = $file.Length
            
            $this.price = [math]::Ceiling($this.Length / 1MB / 10) 
            if ($this.price -eq 0) { $this.price = 1 } 

            $this.route = 0
        }
        
    } 

    [bool] StillThere() {
        return (Test-Path $this.fullName)
    }

    [int] GetTransportPrice() {
        $total = $this.price
        
        # transport price 
        $routePrice = $this.route * [CargoPrices]::getTransportPrice() 
        $total += $routePrice

        return [Math]::round($total)
    }

    [int] Deliver() {
        $totalGain = 0
        if ($this.stillThere) {
            $totalGain += $this.GetTransportPrice()
            $this.Move()

        }
        return $totalGain
    }

    Move() {
        Move-Item -Path $this.filename -Destination (Get-Location).Path
    }
}


Class CargoShip {

    [int] $nitialcapacity = 5
    [System.Collections.Generic.List[Parcel]] $payload
    
    CargoShip() {
        $this.payload = [System.Collections.Generic.List[Parcel]]::New()
    
    }

    #  Needs the bag to be loaded
    #  cargo main function declared in sailor/config/functions.ps1 should test if the bag is loaded
    [int] GetCapacity() {
        $capacity = $this.initialCapacity

        $modifiers = 0
        [Bag]::GetInstance().items | ForEach-Object {
            if ($_.Metadata["CargoCapacity"]) {
                $modifiers += ([int]$_.Metadata["CargoCapacity"] * $_.quantity)
            }
        }
        $capacity += $modifiers
        
        return $capacity
    }

    [void] Load([String] $filename) {
        Write-Host "[Cargoship].Load() - $filename"

        if (-not $this.payload.contains($filename)) {
            Write-Host "[Cargoship].Load() - Loading the new file"
            $this.payload.add([Parcel]::New($filename)) 
        }
    }


    [int] Deliver() {
        $gain = 0
        7
        foreach ($parcel in $this.payload) {
           
            $gain += $parcel.Deliver()

            #  on retire le parce le la liste
            Remove-Item $parcel
        } 

        return $gain
    }

}

    
