############
# modules  #
############

### core
# wallet
$wallet_class = Join-Path $global:sailor_wallet_path "wallet.ps1"
. $wallet_class
function Wallet() {
    $wrender = [WalletRenderer]::new()
    $wrender.RenderWallet($global:wallet)
}


# bag
$bag_class = Join-Path $global:sailor_bag_path "bag.ps1"
. $bag_class
function Bag {
    $bag = $global:bag
    
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

function Merchant {
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
$global:sailor_bigFish_instance = $null
function bigfish {
    if ($null -eq $global:sailor_bigFish_instance ) {
        $global:sailor_bigFish_instance = [BigFish]::new()
    }
    $global:sailor_bigFish_instance.Execute($args)
}
