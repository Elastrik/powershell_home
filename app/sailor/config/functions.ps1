############
# modules  #
############

### core
# wallet
$wallet_class = Join-Path $global:sailor_wallet_path "wallet.ps1"
. $wallet_class


$global:sailor_wallet = $null

function Wallet() {
    $w = [Wallet]::GetInstance()
    $wrender = [WalletRenderer]::new()
    $wrender.RenderWallet($w)
}


# bag
$bag_class = Join-Path $global:sailor_bag_path "bag.ps1"
. $bag_class
$global:sailor_bag = $null
function Bag {


    $bag = [Bag]::GetInstance()
    

    $renderer = [BagRenderer]::new()
    $renderer.RenderBag($bag)
}


# merchant
$merchant_class = Join-Path $global:sailor_merchant_path "merchant.ps1"
. $merchant_class

$global:sailor_merchant = $null
function Merchant {
 
    $merchant = [Merchant]::GetInstance()
    $menuData = $merchant.GetJsonMenu()
    $menu = [Menu]::new($menuData)
    $choice = $menu.Show()
    while ($choice -ne "Q" -and $choice -ne "q" -and $choice -and "R" -and $choice -ne "r") {
        $menuData = $merchant.GetJsonMenu()
        $menu = [Menu]::new($menuData)
        $choice = $menu.Show()
    }
}

# dock 
$dock_class = Join-Path $global:sailor_dock_path "dockMap.ps1"
. $dock_class

function Dock {
    [DockMapRenderer]::RenderDockMap()
}

function setDock {
  
    if ([DockMap]::isDock((Get-Location).Path)) {
        Write-Host "Il y a deja un port ici" -ForegroundColor Red
    
    }
    else {
        $currentPath = (Get-Location).Path
        [DockMap]::addDock($currentPath) 
        Write-Host "Nouveau dock : $currentPath" -ForegroundColor Yellow
    }
}



### app
# bigfish
$bigfish_class = Join-Path $global:sailor_bigfish_path  "bigfish.ps1" 
. $bigfish_class

# - fonction associées
$global:sailor_bigfish_instance = $null
function bigfish {
    [BigFish]::GetInstance().Execute($args)
}


# cargo
$cargo_class = Join-Path $global:sailor_cargo_path  "cargo.ps1" 
. $cargo_class

$global:sailor_cargo = $null 
function cargo () {
    $cargo = [Cargo]::getInstance()
    # command controler
    $cargo.Execute($args)
}