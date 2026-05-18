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
            $this.Metadata = $data.Metadata
            if($null -eq $this.Metadata) {
                $this.Metadata = @{}
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
       Write-Host "💰 Wallet : $($w.valeur) pièces"
        if ($wallet.Metadata.Count -gt 0) {
            Write-Host "📊 Métadonnées :"
            $wallet.Metadata.GetEnumerator() | ForEach-Object {
                Write-Host "   - $($_.Key) : $($_.Value)"
            }
        } 
    }
}