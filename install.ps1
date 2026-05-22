# install.ps1 - A lancer une seule fois pour creer un profil

$root = Split-Path $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |   Installation du terminal PowerShell   |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""

# 1. Nom du profil
$name = Read-Host "  Nom du profil (ex: Elastrik)"
if ([string]::IsNullOrEmpty($name)) {
    Write-Host "  Nom invalide." -ForegroundColor Red
    exit
}

# 2. Verifie que le profil n'existe pas deja
$profilePath = Join-Path $root "home\profile\$name"
if (Test-Path $profilePath) {
    Write-Host "  Le profil '$name' existe deja." -ForegroundColor Yellow
    exit
}

# 3. Cree l'arborescence
$folders = @(
    $profilePath,
    (Join-Path $profilePath "config"),
    (Join-Path $profilePath "persistent")
)
$folders | ForEach-Object { New-Item -ItemType Directory -Path $_ | Out-Null }

# 4. app.txt
Set-Content (Join-Path $profilePath "app.txt") @"
# Applications a charger pour le profil $name
# Une ligne par app (chemin relatif depuis app/)
sailor
"@

# 5. core.txt
Set-Content (Join-Path $profilePath "core.txt") @"
# Modules core a charger
# Une ligne par module (chemin relatif depuis core/)
menu
welcome
"@

# 6. config\variable.ps1
Set-Content (Join-Path $profilePath "config\variable.ps1") @"
`$global:profile_name     = "$name"
`$global:profile_path     = "`$global:PSConfigRoot\home\profile\$name"
`$global:default_location = "`$global:PSConfigRoot\home"
`$global:MenusPath        = "`$global:PSConfigRoot\home\menus"
"@

# 7. config\alias.ps1
Set-Content (Join-Path $profilePath "config\alias.ps1") "# Alias du profil $name"

# 8. config\functions.ps1
Set-Content (Join-Path $profilePath "config\functions.ps1") "# Fonctions du profil $name"

# 9. config\logo.ps1
Set-Content (Join-Path $profilePath "config\logo.ps1") @"
`$logo = @(
    " ██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ",
    " ██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ",
    " ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     ",
    " ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ",
    " ██║     ██║  ██║╚██████╔╝██║     ██║███████╗",
    " ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝"
)
`$colors = @("Cyan","Cyan","Blue","Blue","Magenta","Magenta")
for (`$i = 0; `$i -lt `$logo.Length; `$i++) {
    Write-Host `$logo[`$i] -ForegroundColor `$colors[`$i]
}
"@

# 10. config\welcome.ps1
Set-Content (Join-Path $profilePath "config\welcome.ps1") @"
if (`$Host.UI.RawUI) {
    . "`$global:profile_path\config\logo.ps1"
    Write-Host ""
    Write-Host "  Bonjour `$global:profile_name !" -ForegroundColor Magenta
    Write-Host ""
}
"@

# 11. config\main.menu.json
@{
    title    = "~~ $name ~~"
    subtitle = "Que souhaitez-vous faire ?"
    color    = "Cyan"
    options  = @(
        @{ key = "Q"; label = "Quitter"; command = "exit"; color = "Gray" }
    )
} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $profilePath "config\main.menu.json")

# 12. Ecrit le $PROFILE Windows
$profileContent = ". `"$root\launcher.ps1`" -ProfileName `"$name`""

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir | Out-Null
}

Set-Content $PROFILE $profileContent

Write-Host ""
Write-Host "  OK Profil '$name' cree"               -ForegroundColor Green
Write-Host "  OK PROFILE configure"                 -ForegroundColor Green
Write-Host "  OK Dossier : $profilePath"            -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Relance PowerShell pour demarrer !"   -ForegroundColor Yellow
Write-Host ""