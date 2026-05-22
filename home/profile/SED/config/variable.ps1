
$global:desk = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..\Documents\OneDrive - SED\Bureau\")  # Remonte de 3 niveaux depuis powershell/ pour atteindre Bureau
$global:jahbless = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..")      # Remonte de 3 niveaux pour atteindre C:\Users\vledoux\
$global:docs = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..\Documents")             # Utilise jahbless comme base
$global:soft = Resolve-path( Join-Path $global:PSConfigRoot "..\Soft")        # Remonte de 2 niveaux depuis powershell/ pour atteindre Soft
$global:down = Resolve-path( Join-Path $global:PSConfigRoot "..\..\..\Downloads")  


# $global:main_menu = Join-path $global:powershell_home 'menus\boulot.json'

$global:welcome_message = "Encore du travail ?"
$global:welcome_location = "moussy-le-vieux"


# repertoire par défaut
$global:default_location = $global:powershell_home