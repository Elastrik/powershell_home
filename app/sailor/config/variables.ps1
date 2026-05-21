$global:sailor_path     = Join-Path $global:powershell_app "Sailor"
$global:sailor_modules  = Join-Path $global:sailor_path "modules"

# core
$global:sailor_wallet_path     = Join-Path $global:sailor_modules "core/wallet"
$global:sailor_merchant_path   = Join-Path $global:sailor_modules "core/merchant"
$global:sailor_bag_path        = Join-Path $global:sailor_modules "core/bag"
$global:sailor_dock_path       = Join-Path $global:sailor_modules "core/dock"


#app
$global:sailor_bigfish_path = Join-Path $global:sailor_modules "app/bigfish"


