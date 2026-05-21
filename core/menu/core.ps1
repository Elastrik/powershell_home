$menu_config = join-path $global:powershell_core "menu/config"

$var = join-path $menu_config "variables.ps1"
if (Test-Path $var) {
    . $var
}

$menu_class = join-path $global:powershell_core "menu/menu.ps1"
. $menu_class 