class MerchantItemRenderer {
    [void] RenderItem([Item] $item) {
        $statusColor = if ($item.IsAvailable()) { "Yellow" } else { "DarkGray" }
        $statusText = if ($item.IsAvailable()) { "$($item.name) - $($item.price)\ (x$($item.quantity))" } else { "$($item.name) - INDISPONIBLE" }
        
        Write-Host "  $statusText" -ForegroundColor $statusColor
        
        $descColor = if ($item.IsAvailable()) { "Gray" } else { "DarkGray" }
        Write-Host "    $($item.description)" -ForegroundColor $descColor
        
        if ($item.Metadata.Count -gt 0) {
            Write-Host "    Détails :" -ForegroundColor $(if ($item.IsAvailable()) { "Magenta" } else { "DarkGray" })
            $item.Metadata.GetEnumerator() | ForEach-Object {
                Write-Host "      $($_.Key) : $($_.Value)" -ForegroundColor $(if ($item.IsAvailable()) { "White" } else { "DarkGray" })
            }
        }
    }
}

class Merchant {
    [Item[]] $itemsAvailable;
    [Item[]] $itemsSold;
    [string] $SavePath

    Merchant([string] $savePath) {
        $this.SavePath = $savePath
        $this.itemsAvailable = @()
        $this.itemsSold = @()

        if (Test-Path $savePath) {
            $data = Get-Content $savePath | ConvertFrom-Json
           
            if ($data.ItemsAvailable) {
                $data.ItemsAvailable | ForEach-Object {

                    $md = [Hashtable]::new()
                    if ($_.Metadata) {
                        $_.Metadata.PSObject.Properties | ForEach-Object {
                            $md[$_.Name] = $_.Value
                        }
                    }
                    # Retrocompatibilité: si quantity manque, par défaut 1
                    $qty = if ($_.quantity) { $_.quantity } else { 1 }

                    $item = [Item]::new($_.name, $_.description, $_.price, $qty, $md)
                    $this.itemsAvailable += $item
                }
            }
            if ($data.ItemsSold) {
                $data.ItemsSold | ForEach-Object {

                    $md = [Hashtable]::new()
                    if ($_.Metadata) {
                        $_.Metadata.PSObject.Properties | ForEach-Object {
                            $md[$_.Name] = $_.Value
                        }
                    }
                    $qty = if ($_.quantity) { $_.quantity } else { 1 }
                    $item = [Item]::new($_.name, $_.description, $_.price, $qty, $md) 
                    $this.itemsSold += $item
                }
            }
        }
        
    }

    [void]  SellItem([string] $itemName, [Bag] $bag, [Wallet] $wallet) {
        $item = $this.itemsAvailable | Where-Object { $_.name -eq $itemName }
        if ($item -and $item.IsAvailable()) {
            $this.DecrementQuantity($itemName)
            $bag.AddItem($item)
            $wallet.AddValue(- $item.price)
            $this.Save()
        }
    }

    [void] Save() {
        @{
            ItemsAvailable = $this.itemsAvailable
            ItemsSold      = $this.itemsSold
        } | ConvertTo-Json -Depth 5 | Set-Content $this.SavePath
        $global:sailor_merchant = $this

    }

    [void] DecrementQuantity([string] $itemName) {
        $item = $this.itemsAvailable | Where-Object { $_.name -eq $itemName }
        if ($item) {
            $item.quantity = [Math]::Max(0, $item.quantity - 1)
            $this.Save()
        }
        $found = $false
        $this.itemsSold | ForEach-Object {
            if ($_.name -eq $itemName) {
                $_.quantity += 1
                $found = $true
            }
        }
        if(! $found){
            $this.itemsSold += [Item]::new($item.name, $item.description, $item.price, 1, $item.Metadata)
        }
    }

    [bool] IsAvailable([string] $itemName) {
        $item = $this.itemsAvailable | Where-Object { $_.name -eq $itemName }
        return $item -and $item.IsAvailable()
    }

    [int] GetQuantity([string] $itemName) {
        $item = $this.itemsAvailable | Where-Object { $_.name -eq $itemName }
        return if ($item) { $item.quantity } else { 0 }
    }
    [string] GetJsonMenu() {
        $menu = @{
            title    = "Marchand"
            subtitle = "solde :  $($global:wallet.valeur) $($global:wallet.devise)"
            color    = "DarkYellow"
            options  = @()
        }

        $optionIndex = 1
        foreach ($item in $this.itemsAvailable) {
             
            if ($item.IsAvailable()) {
                if($item.isAffordable()) {
                    $optionColor = "Yellow"
                    $option = @{
                        key     = $optionIndex.ToString()
                        label   = "$($item.name) - $($item.price) $(if ($global:wallet.devise) { $global:wallet.devise } else { '$' }) (x$($item.quantity))"
                        command = @("[Merchant]::MerchantSell() '$($item.name)'", "exit")    
                        color   = "$($optionColor)"
                    }
                } else {
                    $optionColor = "Gray"

                    $option = @{
                        key     = $optionIndex.ToString()
                        label   = "$($item.name) - $($item.price) $(if ($global:wallet.devise) { $global:wallet.devise } else { '$' }) (x$($item.quantity))"
                        command = @("Write-host 'Solde insuffisant' -ForegroundColor Red")
                        color   = "$($optionColor)"
                    }
                
                }
                $menu.options += $option
                $optionIndex++
            }
        
        }

        # Afficher les items indisponibles en grisé (optionnel)
        foreach ($item in $this.itemsAvailable) {
            if (-not $item.IsAvailable()) {
                $option = @{
                    key   = "x"  # Pas de clé sélectionnable
                    label = "$($item.name) - INDISPONIBLE"
                    color = "DarkGray"
                }
                $menu.options += $option
            }
        }

        $options = @{
            key     = "R"
            label   = "Au revoir !"
            command = "back"
            color   = "Gray"
        }
        $menu.options += $options
        return $menu | ConvertTo-Json -Depth 5
    }

    static [void ] MerchantSell ([string] $itemName) {
        
        $merchant = $global:sailor_merchant
        $bag = $global:sailor_bag
        $wallet = $global:sailor_wallet

        if ($merchant.IsAvailable($itemName)) {
            $merchant.SellItem($itemName, $bag, $wallet)
            Write-Host " ** Vous avez acheté : $itemName" -ForegroundColor Green
        }
        else {
            Write-Host "Désolé, cet article n'est pas disponible." -ForegroundColor Red
        }
    }

}


