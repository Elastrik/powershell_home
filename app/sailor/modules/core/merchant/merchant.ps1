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
    [System.Collections.Generic.List[Item]] $itemsAvailable;
    [System.Collections.Generic.List[Item]] $itemsSold;
    [string] $SavePath

    static [Merchant] GetInstance() {
        if ($null -eq $global:sailor_merchant) {
            $merch_prf_path = Join-Path $global:persistent_data "merchant.json"
            $global:sailor_merchant = [Merchant]::New($merch_prf_path)
        }
        return $global:Sailor_merchant
    }

    Merchant([string] $savePath) {
        $this.SavePath = $savePath
        $this.itemsAvailable = @()
        $this.itemsSold = @()

        if (Test-Path $savePath) {
            $data = Get-Content $savePath | ConvertFrom-Json
        }
        else {
            Copy-Item (Join-Path $global:sailor_merchant_path "merchant.json") $savePath
            $data = Get-Content $savePath | ConvertFrom-Json
        }
        
           
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
                # write-host "Merchant Loading Available : $($_.name) - Cat: $($_.category)"
                $item = [Item]::new($_.name, $_.description, $_.category, $_.price, $qty, $md)
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
                $item = [Item]::new($_.name, $_.description, $_.category, $_.price, $qty, $md) 
                $this.itemsSold += $item
            }
        }
        
        
    }

    [void]  SellItem([string] $itemName, [Bag] $bag, [Wallet] $wallet) {
        write-host "Selling : $itemName" -ForegroundColor Green

        $item = $this.itemsAvailable | Where-Object { $_.name -eq $itemName }
        if ($item -and $item.IsAvailable()) {
            # write-host "SellItem - Decrementing" -ForegroundColor Green
            $this.DecrementQuantity($itemName)
            # write-host "SellItem - qty : $($item.quantity)" -ForegroundColor Green
            
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

        # debug
        # write-host "Decrement quantity : $($itemName)" -foregroundColor Yellow
        
        if ($item) {
        
            # debug
            # write-host "Decrement quantity - item exist qty - : $($item.quantity)" -foregroundColor Yellow
        
            $item.quantity = [Math]::Max(0, $item.quantity - 1)
            # debug
            # write-host "Decrement quantity - threasholmd - : $($item.quantity)" -foregroundColor Yellow
        
            if ($item.quantity -eq 0) {
                # debug
                # write-host "Decrement quantity - removing Item - : $($item.name)" -foregroundColor Yellow
        
                $this.itemsAvailable.remove($item)

                # adding to itemSold
                
                $soldItem = $this.itemsSold | Where-Object { $_.name -eq $itemName }
                
                
                if ($solditem) {
                    # debug
                    # write-host "Decrement quantitys - olditem exist : $($soldItem.name) qty:$($soldItem.quantity)" -foregroundColor Yellow
                    
                    $solditem.quantity += 1
                    # debug
                    # write-host "Decrement quantity - solditem  $($soldItem.name) new qty:$($soldItem.quantity)" -foregroundColor Yellow
                   
                }
                else {
                    
                    $soldItem = [Item]::New($item.name, $item.description, $item.category, $item.price, $item.metadata)
                    
                    # debug
                    # write-host "Decrement quantity - solditem not exist creating: $($soldItem.name) qty:$($soldItem.quantity)" -foregroundColor Yellow
                    
                    $soldItem.quantity = 1
                    # debug
                    # write-host "Decrement quantity - solditem set: $($soldItem.name) qty:$($soldItem.quantity)" -foregroundColor Yellow
                    
                    
                    $this.itemsSold.add($soldItem)

                    # debug
                    # write-host "Decrement quantity - added to itemsSold: $($soldItem.name) qty:$($soldItem.quantity)" -foregroundColor Yellow
                    
                }

            }

        }
        # debug
        # write-host "Decrement quantity - New Qty $($item.quantity)" -foregroundColor Yellow
        # debug
        # write-host "Decrement quantity - Saving state " -foregroundColor Yellow
                    
        $this.Save()

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
            subtitle = "solde :  $([Wallet]::GetInstance().valeur) $([Wallet]::GetInstance().devise)"
            color    = "DarkYellow"
            options  = @()
        }
        $categoryColors = @{
            "sailor"  = "White"
            "bigfish" = "Cyan"
            "Cargo"   = "DarkYellow"
            
            
        }

        $optionIndex = 1
        $this.itemsAvailable 
        | Sort-Object -Property { $_.category + ' ' + ([String] $_.price).PadLeft(9, ' ') } 
        | ForEach-Object {
             
            if ($_.IsAvailable()) {
                if ($_.isAffordable()) {
                    $optionColor = $categoryColors[$_.category]
                    $option = @{
                        key     = $optionIndex.ToString()
                        label   = "$($_.name) - $($_.price) $(if ([Wallet]::GetInstance().devise) { [Wallet]::GetInstance().devise } else { '$' }) (x$($_.quantity))"
                        command = @("[Merchant]::MerchantSell( '$($_.name)')", "exit")    
                        color   = "$($optionColor)"
                    }
                }
                else {
                    $optionColor = "Gray"

                    $option = @{
                        key     = $optionIndex.ToString()
                        label   = "$($_.name) - $($_.price) $(if ([Wallet]::GetInstance().devise) { [Wallet]::GetInstance().devise } else { '$' }) (x$($_.quantity))"
                        command = @("Write-host 'Solde insuffisant' -ForegroundColor Red")
                        color   = "$($optionColor)"
                    }
                
                }
                $menu.options += $option
                $optionIndex++
            }
        
        }

        # Afficher les items indisponibles en grisé (optionnel)
        foreach ($item in $this.itemsSold) {

            if (-not $this.isAvailable($item.name)) {
                $option = @{
                    key   = '' # Pas de clé sélectionnable
                    label = "$($item.name) - épuisé"
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
        
        $merchant = [Merchant]::GetInstance()
        $bag = [Bag]::GetInstance()

        $wallet = [Wallet]::GetInstance()

        if ($merchant.IsAvailable($itemName)) {
            $merchant.SellItem($itemName, $bag, $wallet)
            Write-Host " ** Vous avez acheté : $itemName" -ForegroundColor Green
        }
        else {
            Write-Host "Désolé, cet article n'est pas disponible." -ForegroundColor Red
        }
    }

}


