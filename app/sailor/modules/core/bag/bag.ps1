

class Item {
    [string] $name
    [string] $description
    [int] $price
    [int] $quantity
    [Hashtable] $Metadata

    Item([string] $name, [string] $description, [int] $price, [Hashtable] $metadata) {
        $this.name = $name
        $this.description = $description
        $this.price = $price
        $this.quantity = 1
        $this.Metadata = $metadata
    }

    Item([string] $name, [string] $description, [int] $price, [int] $quantity, [Hashtable] $metadata) {
        $this.name = $name
        $this.description = $description
        $this.price = $price
        $this.quantity = $quantity
        $this.Metadata = $metadata
    }

    [bool] IsAvailable() {
        return $this.quantity -gt 0
    }
    [bool] isAffordable() {
        $account = 0 
        if($global:sailor_wallet.valeur) {
            $account = $global:sailor_wallet.valeur
        }
        return $account -ge $this.price
    }
}


class BagRenderer {
    [void] RenderHeader() {
        Write-Host ""
        Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║ ~ MON INVENTAIRE ~                    ║" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
    }

    [void] RenderItems([Item[]] $items) {
        if ($items.Count -eq 0) {
            Write-Host "  ▢ Votre sac est vide..." -ForegroundColor Gray
            Write-Host ""
            return
        }

        foreach ($item in $items) {
            $this.RenderItem($item)
        }
        Write-Host ""
    }

    [void] RenderItem([Item] $item) {
        $statusColor = if ($item.IsAvailable()) { "Yellow" } else { "DarkGray" }
        $statusText = if ($item.IsAvailable()) { "✓ $($item.name) (x$($item.quantity)) - $($item.price)\" } else { "✗ $($item.name) - INDISPONIBLE" }
        
        Write-Host "  $statusText" -ForegroundColor $statusColor
        
        $descColor = if ($item.IsAvailable()) { "Gray" } else { "DarkGray" }
        Write-Host "    └─ $($item.description)" -ForegroundColor $descColor
        
        if ($item.metadata.Count -gt 0) {
            Write-Host "    └─ Propriétés :" -ForegroundColor $(if ($item.IsAvailable()) { "Magenta" } else { "DarkGray" })
            $item.metadata.GetEnumerator() | ForEach-Object {
                Write-Host "       • $($_.Key) : $($_.Value)" -ForegroundColor $(if ($item.IsAvailable()) { "White" } else { "DarkGray" })
            }
        }
    }

    [void] RenderFooter([int] $totalItems, [int] $capacity) {
        Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
        if ($capacity -eq 0) {
            Write-Host "║ Total: $($totalItems) items (capacité illimitée)      " -ForegroundColor Cyan
        } else {
            $percentFull = [int]($totalItems / $capacity * 100)
            Write-Host "║ Total: $($totalItems)/$($capacity) items ($($percentFull)% plein)            " -ForegroundColor Cyan
        }
        Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
    }

    [void] RenderBag([Bag] $bag) {
        $this.RenderHeader()
        $this.RenderItems($bag.items)
        $this.RenderFooter($bag.GetItemCount(), $bag.maxCapacity)
    }
}

class Bag {
    [System.Collections.Generic.List[Item]] $items
    [int] $maxCapacity
    [string] $SavePath
    [Hashtable] $stats

    Bag([string] $savePath) {
        $this.SavePath = $savePath
        $this.items = @()
        $this.maxCapacity = 0  # 0 = illimité
        $this.stats = @{
            totalAcquired = 0
            lastModified = (Get-Date -AsUTC).ToString("o")
        }

        if (Test-Path $savePath) {
            $this.Load()
        }
    }

    [void] Load() {
        if (-not (Test-Path $this.SavePath)) {
            return
        }

        try {
            $data = Get-Content $this.SavePath | ConvertFrom-Json
            
            $this.items = @()
            if ($data.items) {
                $data.items | ForEach-Object {
                    $md = [Hashtable]::new()
                    if ($_.metadata) {
                        $_.metadata.PSObject.Properties | ForEach-Object {
                            $md[$_.Name] = $_.Value
                        }
                    }
                    $qty = if ($_.quantity) { $_.quantity } else { 1 }
                    $item = [Item]::new($_.name, $_.description, $_.price, $qty, $md)
                    $this.items += $item
                }
            }

            $this.maxCapacity = if ($data.maxCapacity) { $data.maxCapacity } else { 0 }
            
            if ($data.stats) {
                if ($data.stats.totalAcquired) { $this.stats.totalAcquired = $data.stats.totalAcquired }
                if ($data.stats.lastModified) { $this.stats.lastModified = $data.stats.lastModified }
            }
        }
        catch {
            Write-Host "⚠ Erreur lors du chargement du sac: $_" -ForegroundColor Red
        }
    }

    [void] Save() {
        try {
            @{
                items = $this.items
                maxCapacity = $this.maxCapacity
                stats = $this.stats
            } | ConvertTo-Json -Depth 10 | Set-Content $this.SavePath
            $this.stats.lastModified = (Get-Date -AsUTC).ToString("o")
        }
        catch {
            Write-Host "⚠ Erreur lors de la sauvegarde du sac: $_" -ForegroundColor Red
        }
    }

    [void] AddItem([Item] $item) {
        $existingItem = $this.items | Where-Object { $_.name -eq $item.name }
        
        if ($existingItem) {
            $existingItem.quantity += 1
        }
        else {
            $item.quantity = 1
            $this.items += $item
            $this.stats.totalAcquired++
        }
        
        $this.Save()
    }

    [void] RemoveItem([string] $itemName, [int] $quantity = 1) {
        $item = $this.items | Where-Object { $_.name -eq $itemName }
        
        if ($null -eq $item) {
            Write-Host "✗ Item '$itemName' non trouvé" -ForegroundColor Red
            return
        }

        if ($item.quantity -le $quantity) {
            $this.items = $this.items | Where-Object { $_.name -ne $itemName }
            Write-Host "✓ $($itemName) retiré de l'inventaire" -ForegroundColor Green
        }
        else {
            $item.quantity -= $quantity
            Write-Host "✓ $($itemName) x$quantity retiré (reste: x$($item.quantity))" -ForegroundColor Green
        }
        
        $this.Save()
    }

    [Item] GetItem([string] $itemName) {
        return $this.items | Where-Object { $_.name -eq $itemName }
    }

    [Item[]] ListItems() {
        return $this.items
    }

    [int] GetItemCount() {
        $total = 0
        $this.items | ForEach-Object { $total += $_.quantity }
        return $total
    }

    [bool] IsFull() {
        if ($this.maxCapacity -eq 0) {
            return $false  # Illimité
        }
        return $this.GetItemCount() -ge $this.maxCapacity
    }
}



# Set-Alias bd Bag
