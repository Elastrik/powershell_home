
# Racine du projet (powershell/)
$global:powershell_folder = $global:PSConfigRoot                  
$global:powershell_home = Join-path $global:powershell_folder "home"
$global:powershell_app = Join-path $global:powershell_folder "app"
$global:powershell_core = Join-path $global:powershell_folder "core"

#
$global:persistent_data = Join-path $global:profile_path 'persistent'
