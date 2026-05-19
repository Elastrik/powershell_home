$merch_prf_path = Join-Path $global:powershell_folder "app\merchant\persistent\profile.json"
$global:Merchant_profile = [Merchant]::New($merch_prf_path)

class MerchantItem {
    [string] $name
    [string] $description
    [int] $price
    [Hashtable] $Metadata

    MerchantItem([string] $name, [string] $description, [int] $price, [Hashtable] $metadata) {
        $this.name = $name
        $this.description = $description
        $this.price = $price
        $this.Metadata = $metadata
    }
}

class MerchantItemRenderer {
    [void] RenderItem([MerchantItem] $item) {
        Write-Host "  $($item.name) - $($item.price)\$" -ForegroundColor Yellow
        Write-Host "    $($item.description)" -ForegroundColor Gray
        if ($item.Metadata.Count -gt 0) {
            Write-Host "    Détails :" -ForegroundColor Magenta
            $item.Metadata.GetEnumerator() | ForEach-Object {
                Write-Host "      $($_.Key) : $($_.Value)" -ForegroundColor White
            }
        }
    }
}

class Merchant {
    [MerchantItem[]] $itemsAvailable;
    [MerchantItem[]] $itemsSold;
    [string] $SavePath

    Merchant([string] $savePath) {
        $this.SavePath = $savePath
        $this.itemsAvailable = @()
        $this.itemsSold = @()

        if (Test-Path $savePath) {
            $data = Get-Content $savePath | ConvertFrom-Json
           
            if ($data.itemsAvailable) {
                $data.itemsAvailable | ForEach-Object {
                    $md = [Hashtable]::new()
                    if ($_.Metadata) {
                        $_.Metadata.PSObject.Properties | ForEach-Object {
                            $md[$_.Name] = $_.Value
                        }
                    }
                    $item = [MerchantItem]::new($_.name, $_.description, $_.price,$md)
                    $this.itemsAvailable += $item
                }
            }
            if ($data.itemsSold) {
                $data.itemsSold | ForEach-Object {
                    $md = [Hashtable]::new()
                    if ($_.Metadata) {
                        $_.Metadata.PSObject.Properties | ForEach-Object {
                            $md[$_.Name] = $_.Value
                        }
                    }
                    $item = [MerchantItem]::new($_.name, $_.description, $_.price,$md) 
                    $this.itemsSold += $item
                }
                $this.itemsSold = $data.itemsSold
            }
        }
    }

    [void] Save() {
        @{
            ItemsAvailable = $this.itemsAvailable
            ItemsSold = $this.itemsSold
        } | ConvertTo-Json | Set-Content $this.SavePath
        $global:Merchant_profile = $this
    }
    [string] GetJsonMenu(){
        $menu = @{
            title = "Marchand"
            subtitle = "Que souhaitez-vous acheter ?"
            color = "DarkYellow"
            options = @()
        }
        foreach ($item in $this.itemsAvailable) {
            $option = @{
                key = ($menu.options.Count + 1).ToString()
                label = "$($item.name) - $($item.price) $($global:wallet.devise ? $global:wallet.devise : '$')"
                command = "merchant Buy-Item '$($item.name)'"
                color = "Yellow"
            }
            $menu.options += $option
        }
        $options = @{
            key = "Q"
            label = "Au revoir"
            command = "exit"
            color = "Gray"
        }
        $menu.options += $options
        return $menu | ConvertTo-Json
    }

    
}


function Merchant {
        $merchant = $global:Merchant_profile
        if ($merchant.itemsAvailable.Count -eq 0) {
            Write-Host "Le marchand n'a rien à vendre pour le moment." -ForegroundColor Gray
            return
        }
    
        $menuData = $merchant.GetJsonMenu()
       
        $menu = [Menu]::new($menuData)
        $menu.Show()
}