### core ###
$global:sailor_app      = Join-Path $global:powershell_app "sailor"
$global:sailor_modules  = Join-Path $global:sailor_app "modules"

# Wallet
$global:sailor_wallet_path      = Join-Path $global:sailor_modules "core/wallet"
# bag
$global:sailor_bag_path         = Join-Path $global:sailor_modules "core/bag"
# merchant
$global:sailor_merchant_path    = Join-Path $global:sailor_modules "core/merchant"

### app ###
# bigfish
$global:sailor_bigfish_path     = Join-Path $global:sailor_modules "app/bigfish"
