

$global:desk =  "C:\Users\victo\Desktop"
$global:jahbless = "E:\"
$global:docs = "D:\documents" 
$global:soft = "F:\"
$global:down = "C:\Users\victo\Downloads" 
# Définir les chemins globaux relatifs à la racine du projet

$global:powershell_folder = $global:PSConfigRoot                  # Racine du projet (powershell/)
$global:powershell_home = Join-path $global:powershell_folder "home"
$global:tradsh_path = Join-Path $global:PSConfigRoot "config\tradsh.ps1"  # Chemin relatif vers tradsh.ps1
$global:menu_path = Join-Path $global:PSConfigRoot "app\menu" 
$global:bigfish_path = Join-Path $global:PSConfigRoot "app\bigfish"  # Chemin relatif vers tradsh.ps1
$global:wallet_class_path = Join-Path $global:PSConfigRoot "app\wallet"
$global:wallet_path = Join-path $global:powershell_home 'persistent'
$global:config_path = Join-path $global:PSConfigRoot 'config'


# repertoire par défaut
$global:main_menu = Join-path $powershell_home 'menus\maison.json'
$global:default_location = $global:powershell_home