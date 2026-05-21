# config/wallet.ps1
class Wallet {
    [long] $valeur
    [string] $SavePath
    [hashtable] $Metadata
    [string] $devise = '¥'

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
        $global:sailor_wallet = $this
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

class WalletRenderer {
    [void] RenderWallet([Wallet] $w) {
        $inner  = 40  # largeur intérieure fixe
        $top    = "═" * ($inner + 2)

        Write-Host ""
        Write-Host "  ╔══[ " -ForegroundColor DarkGray -NoNewline
        Write-Host "WALLET" -ForegroundColor Yellow -NoNewline
        Write-Host " ]$("═" * ($inner - 10))╗" -ForegroundColor DarkGray

        # solde
        $solde = "$($w.valeur) $($w.devise)"
        Write-Host "  ║  " -ForegroundColor DarkGray -NoNewline
        Write-Host "Solde      : " -ForegroundColor Gray -NoNewline
        Write-Host $solde.PadRight($inner - 13) -ForegroundColor Yellow -NoNewline
        Write-Host "║" -ForegroundColor DarkGray

        # metadata
        if ($w.Metadata.Count -gt 0) {
            Write-Host "  ╠$top╣" -ForegroundColor DarkGray
            $w.Metadata.GetEnumerator() | ForEach-Object {
                $val = "$($_.Value)"
                Write-Host "  ║  " -ForegroundColor DarkGray -NoNewline
                Write-Host "$($_.Key.PadRight(10)) : " -ForegroundColor Magenta -NoNewline
                Write-Host $val.PadRight($inner - 13) -ForegroundColor White -NoNewline
                Write-Host "║" -ForegroundColor DarkGray
            }
        }

        Write-Host "  ╚$top╝" -ForegroundColor DarkGray
        Write-Host ""
    }
}



