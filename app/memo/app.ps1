$memo_config  = Join-Path $global:PSScriptRoot "config"


$variables      = Join-Path $memo_config "variables.ps1"
$functions      = Join-Path $memo_config "functions.ps1"
$alias          = Join-Path $memo_config "alias.ps1"

. $variables
. $functions
. $alias
