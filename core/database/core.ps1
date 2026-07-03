$database_config = join-path $global:powershell_core "database/config"

# variables
$var = join-path $database_config "variables.ps1"
if (Test-Path $var) {
    . $var
}

# classes
# the db Manager
$database_manager = join-path $global:powershell_core "database/dbmanager.ps1"
. $database_manager



# fonctions
$fun = join-path $database_config "functions.ps1"
if (Test-Path $fun) {
    . $fun
}
# alias
$alias = join-path $database_config "alias.ps1"
if (Test-Path $alias) {
    . $alias
}