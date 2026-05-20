# Obtenir la racine du projet (dossier parent de config/)

# Définir les chemins globaux relatifs à la racine du projet

$global:desk = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..\Documents\OneDrive - SED\Bureau\")  # Remonte de 3 niveaux depuis powershell/ pour atteindre Bureau
$global:jahbless = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..")      # Remonte de 3 niveaux pour atteindre C:\Users\vledoux\
$global:docs = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..\Documents")             # Utilise jahbless comme base
$global:soft = Resolve-path( Join-Path $global:PSConfigRoot "..\Soft")        # Remonte de 2 niveaux depuis powershell/ pour atteindre Soft
$global:down = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..\Downloads")  

$global:powershell_folder = $global:PSConfigRoot                  # Racine du projet (powershell/)
$global:powershell_home = Join-path $global:powershell_folder "home"
$global:powershell_app = Join-path $global:powershell_folder "app"
$global:powershell_core = Join-path $global:powershell_folder "core"
# Core 
$global:menu_class_path = Join-Path $global:powershell_core "menu" 
$global:wallet_class_path = Join-Path $global:powershell_core "wallet"
$global:bag_class_path = Join-Path $global:powershell_core "bag"
$global:merchant_class_path = Join-Path $global:powershell_core "merchant"

# applications
$global:bigfish_path = Join-Path $global:powershell_app  "bigfish"  # Chemin relatif vers tradsh.ps1


# $global:tradsh_path = Join-Path $global:PSConfigRoot "config\tradsh.ps1"  # Chemin relatif vers tradsh.ps1
$global:persistent_home_path = Join-path $global:powershell_home 'persistent'
$global:config_path = Join-path $global:PSConfigRoot 'config'


# repertoire par défaut
$global:main_menu = Join-path $global:powershell_home 'menus\boulot.json'
$global:default_location = $global:powershell_home