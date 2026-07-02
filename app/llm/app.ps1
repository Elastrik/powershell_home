$llm_config  = Join-Path $global:PSScriptRoot "config"


$variables      = Join-Path $llm_config "variables.ps1"
$functions       = Join-Path $llm_config "functions.ps1"
$alias          = Join-Path $llm_config "alias.ps1"

. $variables
. $functions
. $alias