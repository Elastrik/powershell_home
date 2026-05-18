# config/wallet.ps1
class Wallet {
    [long] $valeur
    [string] $SavePath
    [hashtable] $Metadata
    [string] $devise = '$'

    Wallet([string] $savePath) {
        $this.SavePath = $savePath
        $this.Metadata = @{}
        if (Test-Path $savePath) {
            $data = Get-Content $savePath | ConvertFrom-Json
            $this.valeur = $data.valeur

            $this.Metadata = @{}
            if ($data.Metadata) {
                 $data.Metadata.PSObject.Properties | ForEach-Object {
                    $this.Metadata[$_.Name] = $_.Value
                 }
            }
        } else {
            $this.valeur = 0
        }
    }

    [void] Save() {
        @{
            valeur    = $this.valeur
            Metadata = $this.Metadata
        } | ConvertTo-Json | Set-Content $this.SavePath
    }

    [void] AddValue([long] $amount) {
        $this.valeur += $amount
        $this.Save()
    }

    [void] SetMetadata([string] $key, [object] $value) {
        $this.Metadata[$key] = $value
        $this.Save()
    }

    [object] GetMetadata([string] $key) {
        return $this.Metadata[$key]
    }
}

class WalletRenderer{
    [void] RenderWallet ([Wallet] $w){
        $border_color = "Gray"
        Write-Host "  ██████████████████████████████████████████████████" -ForegroundColor $border_color 
        Write-Host "  █" -ForegroundColor $border_color 
        Write-Host "  █" -ForegroundColor $border_color -NoNewline
        Write-Host " ** Wallet : ($($w.valeur) $($w.devise))" -ForegroundColor Yellow
        if ($w.Metadata.Count -gt 0) {
            # Write-Host "# Métadonnées #" -ForegroundColor White
            $w.Metadata.GetEnumerator() | ForEach-Object {
                Write-Host "  █" -ForegroundColor $border_color -NoNewline
                Write-Host "   - $($_.Key) : " -ForegroundColor Magenta -NoNewline
                Write-Host  " $($_.Value)" -ForegroundColor White
            }
        } 
        Write-Host "  █" -ForegroundColor $border_color 
        Write-Host "  ██████████████████████████████████████████████████" -ForegroundColor $border_color
    }
}