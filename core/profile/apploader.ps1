## d'abord on load les communs 
$config = Join-Path $global:PSConfigRoot  "core/profile/common/config"
# write-host "loading common $config" -ForegroundColor Cyan

if (Test-Path $config) {

    $var = Join-Path $config "variables.ps1"
    if (Test-Path $var) {
        . $var
        # write-host "loaded $var" -ForegroundColor Cyan

    }
    $fun = Join-Path $config "functions.ps1"
    if (Test-Path $fun) {   
        . $fun
        # write-host "loaded $fun" -ForegroundColor Cyan
    }
    $alias = Join-Path $config "alias.ps1"
    if (Test-Path $alias) {  
        . $alias
        # write-host "loaded $alias" -ForegroundColor Cyan
    }
    $welcome = Join-Path $config "welcome.ps1"
    if (Test-Path $welcome) {   
        . $welcome
        # write-host "loaded $welcome" -ForegroundColor Cyan
    }
}



$corelist = Join-Path $global:profile_path "core.txt"

if (Test-Path $corelist) {
    $cores = Get-Content $corelist
    foreach ($core in $cores) {
        $core_path = Join-Path $global:powershell_core $core
        $core_loader = Join-Path $core_path "core.ps1"
        if (Test-Path $core_loader) {
            . $core_loader
            # write-host "loaded $core_loader" -ForegroundColor Cyan
        }
    }
}

$applist = Join-Path $global:profile_path "app.txt" 
if (Test-Path $applist) {
    $apps = Get-Content $applist
    foreach ($app in $apps) {
        $app_path = Join-Path $global:powershell_app $app
        $app_loader = Join-Path $app_path "app.ps1"
        if (Test-Path $app_loader) {
            . $app_loader
            # write-host "loaded $app_loader" -ForegroundColor Cyan
        }
    }
}

# write-host "Loading profile from $global:profile_path" -ForegroundColor Cyan

$config = Join-Path $global:profile_path "config"
# write-host "Loading profile configuration from $config" -ForegroundColor Cyan

if (Test-Path $config) {



    $var = Join-Path $config "variable.ps1"
    if (Test-Path $var) {
        . $var
        # write-host "loaded $var" -ForegroundColor Cyan

    }
    $fun = Join-Path $config "functions.ps1"
    if (Test-Path $fun) {   
        . $fun
        # write-host "loaded $fun" -ForegroundColor Cyan
    }
    $alias = Join-Path $config "alias.ps1"
    if (Test-Path $alias) {  
        . $alias
        # write-host "loaded $alias" -ForegroundColor Cyan
    }
    $logo = Join-Path $config "logo.ps1"
    if (Test-Path $logo) {
        . $logo
    }
    $welcome = Join-Path $config "welcome.ps1"
    if (Test-Path $welcome) {   
        . $welcome
        # write-host "loaded $welcome" -ForegroundColor Cyan
    }
}
