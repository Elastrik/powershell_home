$sailor_config  = Join-Path $global:PSScriptRoot "config"

$variables      = Join-Path $sailor_config "variables.ps1"
$function       = Join-Path $sailor_config "functions.ps1"
$alias          = Join-Path $sailor_config "alias.ps1"

. $variables
. $functions
. $alias