$menu_config = join-path $global:powershell_core "menu/config"

# variables
$var = join-path $menu_config "variables.ps1"
if (Test-Path $var) {
    . $var
}

# classes
$menu_class = join-path $global:powershell_core "menu/menu.ps1"
. $menu_class 

# fonctions
$fun = join-path $menu_config "functions.ps1"
if (Test-Path $fun) {
    . $fun
}
# alias
$alias = join-path $menu_config "alias.ps1"
if (Test-Path $alias) {
    . $alias
}