############
# modules  #
############

### core
# wallet
$wallet_class = Join-Path $global:sailor_wallet_path "wallet.ps1"
. $wallet_class


$global:sailor_wallet = $null

function Wallet() {
    if ($null -eq $global:sailor_wallet) {
        $wallet_prf_path = Join-Path $global:persistent_data "wallet.json"
        $global:sailor_wallet = [Wallet]::New($wallet_prf_path)
    }
    $wrender = [WalletRenderer]::new()
    $wrender.RenderWallet($global:sailor_wallet)
}


# bag
$bag_class = Join-Path $global:sailor_bag_path "bag.ps1"
. $bag_class
$global:sailor_bag = $null
function Bag {
    if ($null -eq $global:sailor_bag) {
        $bag_prf_path = Join-Path $global:persistent_data "bag.json"
        $global:sailor_bag = [Bag]::New($bag_prf_path)
    }

    $bag = $global:sailor_bag
    
    if ($null -eq $bag) {
        Write-Host "✗ Le sac n'est pas initialisé" -ForegroundColor Red
        return
    }

    $renderer = [BagRenderer]::new()
    $renderer.RenderBag($bag)
}


# merchant
$merchant_class = Join-Path $global:sailor_merchant_path "merchant.ps1"
. $merchant_class

$global:sailor_merchant = $null
function Merchant {
    if ($null -eq $global:sailor_merchant) {
        $merch_prf_path = Join-Path $global:persistent_data "merchant.json"
        $global:sailor_merchant = [Merchant]::New($merch_prf_path)
    }
    $merchant = $global:sailor_merchant_profile
    if ($merchant.itemsAvailable.Count -eq 0) {
        Write-Host "Le marchand n'a rien à vendre pour le moment." -ForegroundColor Gray
        return
    }
    $menuData = $merchant.GetJsonMenu()
    $menu = [Menu]::new($menuData)
    $choice = $menu.Show()
    while ($choice -ne "Q") {
        $menuData = $merchant.GetJsonMenu()
        $menu = [Menu]::new($menuData)
        $choice = $menu.Show()
    }
}



### app
# bigfish
$bigfish_class = Join-Path $global:sailor_bigfish_path  "bigfish.ps1" 
. $bigfish_class

# - fonction associées
$global:sailor_bigfish_instance = $null
function bigfish {
    if ($null -eq $global:sailor_bag) {
        $bag_prf_path = Join-Path $global:persistent_data "bag.json"
        $global:sailor_bag = [Bag]::New($bag_prf_path)
    }
    if ($null -eq $global:sailor_merchant) {
        $merch_prf_path = Join-Path $global:persistent_data "merchant.json"
        $global:sailor_merchant = [Merchant]::New($merch_prf_path)
    }
    if ($null -eq $global:sailor_wallet) {
        $wallet_prf_path = Join-Path $global:persistent_data "wallet.json"
        $global:sailor_wallet = [Wallet]::New($wallet_prf_path)
    }
    if ($null -eq $global:sailor_bigfish_instance ) {
        $global:sailor_bigfish_instance = [BigFish]::new()
    }
    $global:sailor_bigfish_instance.Execute($args)
}
