param([string] $ProfileName = "Elastrik")

$global:PSConfigRoot = $PSScriptRoot
$global:profile_name = $ProfileName
$global:profile_path = Join-Path $global:PSConfigRoot "home\profile\$ProfileName"
$global:powershell_core   = Join-Path $global:PSConfigRoot "core"     # ← manquait
$global:powershell_app    = Join-Path $global:PSConfigRoot "app"      # ← manquait

$apploader = Join-Path $global:PSConfigRoot "core\profile\apploader.ps1"
. $apploader

Set-Location $global:default_location
welcome