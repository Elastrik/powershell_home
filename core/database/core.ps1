$database_config = join-path $global:powershell_core "database/config"

# variables
$var = join-path $database_config "variables.ps1"
if (Test-Path $var) {
    . $var
}

# dépendance externe : module PSSQLite (voir database/install.ps1)
if (-not (Get-Module -ListAvailable -Name PSSQLite)) {
    Write-Warning "Module PSSQLite introuvable. Exécuter core/database/install.ps1 pour l'installer."
}
else {
    Import-Module PSSQLite -ErrorAction SilentlyContinue
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