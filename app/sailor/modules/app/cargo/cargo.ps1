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
            "load" { $this.Load($param[1]) }
            "deliver" { $this.Deliver() }
            "sail" {$this.Sail($param[1])}
            # "help" { $this.Renderer.RenderHelp($this) }
            default { 
                $this.List()
            }
        }
    }
    [void] List() {
        write-host "Cargo Payload : "
        $this.cargoShip.payload | ForEach-Object {
            Write-Host "Parcel : $($_.startLocation) - price : $($_.price) - Route: $($_.route)"
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
        # write-host "[Cargo] Deliver()" -ForegroundColor Yellow

        $wallet = [Wallet]::GetInstance()
        # debug
        # write-host "[Cargo] Deliver() wallet loaded - value : $($wallet.Valeur)" -ForegroundColor Yellow

        $valueDelivered = $this.cargoShip.Deliver()
        # debug
        # write-host "[Cargo] Deliver() wallet loaded - Value Delivered : $($valueDelivered)" -ForegroundColor Yellow

        $wallet.addValue($valueDelivered)

        # debug
        # write-host "[Cargo] Deliver() wallet updated  -wallet :  : $($wallet.valeur)" -ForegroundColor Yellow


    } 
    [Void] Sail([String] $param) {
        if (-not $param) {
            write-host "[Cargo].Sail() - no parameter"  
        }
        else {

            if (Test-Path $param) {
                $this.cargoShip.Sail($param)
            }
            else {
                Write-Host "[Cargo].Sail() - path not found : $($param)"
            }
        }
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
        # debug
        # write-host "[Parcel] cstor - Making Parcel from $($fileName)"
        
        $file = Get-ChildItem -File | Where-Object { $_.Name -eq $filename } 
        if ($null -eq $file) {
            Write-Host "[Parcel] -> Parcel(<filename>) File $($filename) not found" -ForegroundColor "Red"
        }
        else {
            # debug
            # write-host "[Parcel] cstor -File exist"
        

            $this.startLocation = $file.FullName
            $this.filename = $file.Name
            $this.length = $file.Length
            
            $this.price = [math]::Ceiling($this.Length / 1MB / 10) 
            if ($this.price -eq 0) { $this.price = 1 } 

            $this.route = 0
        }
        
    } 

    [bool] StillThere() {

        # debug
        # write-host "[Parcel] Stillthere() - $($this.startLocation)"
        
        $stillthere = Test-Path $this.startLocation
        
        # debug
        # write-host "[Parcel] Stillthere() ?  $($stillthere)"
        

        return $stillthere
    }

    [int] GetTransportPrice() {
        $total = $this.price
        
        # transport price 
        $routePrice = $this.route * [CargoPrices]::getTransportPrice() 
        $total += $routePrice

        return [Math]::round($total)
    }

    [int] Deliver() {

        # debug
        # write-host "[Parcel] Deliver() - $($this.filename)"
        

        $totalGain = 0
        if ($this.stillThere()) {

            # debug
            # write-host "[Parcel] Deliver() -FileStillThere"
            
            $totalGain += $this.GetTransportPrice()

            # debug
            # write-host "[Parcel] Deliver() -FileStillThere - Moving Item"
            
            $this.Move()

            $wallet = [Wallet]::GetInstance()
            $parcelCount  = $wallet.GetMetaData("ParcelCount")

            # debug
            write-host "[Parcel] Deliver() - Wallet ParcelCount loaded - $($parcelCount)"
            

            if($null -eq $parcelCount){
                $parcelCount = 1 
            }else{
                $parcelCount++
            }
            $wallet.SetMetadata("ParcelCount",$parcelCount)

        }
        return $totalGain
    }

    [void] Move() {
        # debug
        # write-host "[Parcel] Move() - from : $($this.startLocation) -to : $((Get-Location).Path) "
            
            
        Move-Item -Path $this.startLocation -Destination (Get-Location).Path
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
        
        # debug
        # write-host "[Cargoship] Deliver()"
        
        #  @() permet de passer une copie de l'obet car on ne peut pas moifier la liste quand on la lit avec forEach
        @($this.payload) | ForEach-Object {
            # debug
            # write-host "[Cargoship] Deliver() - Parcel filename : $($parcel.filename) delivering" 
        
            $gain += $_.Deliver()


            #  on retire le parce le la liste
            $this.payload.Remove($_)
        } 

        return $gain
    }

    [CargoShip] Sail([String] $location) {
        if (Test-Path $location) {
            $this.payload | ForEach-Object {
                $_.route++
            }
            Set-Location $location

        }
        else {
            Write-host "[Cargoship] Sail() - location not found : $location"
        }

        return $this
    }

}

    
