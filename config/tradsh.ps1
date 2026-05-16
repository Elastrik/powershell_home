<#
.SYNOPSIS
    Traducteur Bash → PowerShell.
.DESCRIPTION
    Ce script prend une commande Bash en entrée et retourne son équivalent PowerShell,
    un exemple d'utilisation, et l'aide associée (Get-Help).
.EXAMPLE
    .\tradsh.ps1 cd
    .\tradsh.ps1 grep
    .\tradsh.ps1 ls -l
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$BashCommand
)

# Dictionnaire des correspondances Bash → PowerShell
$BashToPowerShell = @{
    # Navigation et fichiers
    "cd"               = @{ PSCommand = "Set-Location"; Alias = "cd"; Example = "Set-Location C:\Temp" };
    "pwd"              = @{ PSCommand = "Get-Location"; Alias = "pwd"; Example = "Get-Location" };
    "ls"               = @{ PSCommand = "Get-ChildItem"; Alias = "gci, dir, ls"; Example = "Get-ChildItem" };
    "ls -l"            = @{ PSCommand = "Get-ChildItem | Format-Table Name, Length, LastWriteTime"; Alias = "gci | ft"; Example = "Get-ChildItem | Format-Table Name, Length, LastWriteTime" };
    "ls -a"            = @{ PSCommand = "Get-ChildItem -Force"; Alias = "gci -Force"; Example = "Get-ChildItem -Force" };
    "mkdir"            = @{ PSCommand = "New-Item -ItemType Directory"; Alias = "md, mkdir"; Example = "New-Item -Path C:\Temp\NouveauDossier -ItemType Directory" };
    "rmdir"            = @{ PSCommand = "Remove-Item -Recurse"; Alias = "rmdir, rd"; Example = "Remove-Item -Path C:\Temp\Dossier -Recurse" };
    "rm"               = @{ PSCommand = "Remove-Item"; Alias = "rm, del, erase"; Example = "Remove-Item -Path C:\Temp\fichier.txt" };
    "cp"               = @{ PSCommand = "Copy-Item"; Alias = "cp, copy"; Example = "Copy-Item -Path C:\Temp\fichier.txt -Destination C:\Backup\" };
    "mv"               = @{ PSCommand = "Move-Item"; Alias = "mv, move, ren"; Example = "Move-Item -Path C:\Temp\fichier.txt -Destination C:\Backup\" };
    "touch"            = @{ PSCommand = "New-Item -ItemType File"; Alias = "ni"; Example = "New-Item -Path C:\Temp\nouveau.txt -ItemType File" };
    "cat"              = @{ PSCommand = "Get-Content"; Alias = "gc, type, cat"; Example = "Get-Content -Path C:\Temp\fichier.txt" };
    "echo"             = @{ PSCommand = "Write-Output"; Alias = "echo"; Example = "Write-Output 'Bonjour'" };
    "grep"             = @{ PSCommand = "Select-String"; Alias = "sls"; Example = "Get-Content C:\Temp\fichier.txt | Select-String -Pattern 'recherche'" };
    "find"             = @{ PSCommand = "Get-ChildItem -Recurse"; Alias = "gci -Recurse"; Example = "Get-ChildItem -Path C:\ -Recurse -Filter '*.txt'" };
    "chmod"            = @{ PSCommand = "icacls"; Alias = ""; Example = "icacls C:\Temp\fichier.txt /grant Utilisateur:(R)" };

    # Processus
    "ps"               = @{ PSCommand = "Get-Process"; Alias = "gps"; Example = "Get-Process" };
    "kill"             = @{ PSCommand = "Stop-Process"; Alias = ""; Example = "Stop-Process -Id 1234" };
    "top"              = @{ PSCommand = "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10"; Alias = ""; Example = "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10" };

    # Réseau
    "ping"             = @{ PSCommand = "Test-Connection"; Alias = ""; Example = "Test-Connection -ComputerName google.com -Count 4" };
    "ifconfig"         = @{ PSCommand = "Get-NetIPAddress"; Alias = "ipconfig"; Example = "Get-NetIPAddress" };
    "netstat"          = @{ PSCommand = "Get-NetTCPConnection"; Alias = ""; Example = "Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' }" };
    "wget"             = @{ PSCommand = "Invoke-WebRequest"; Alias = "iwr"; Example = "Invoke-WebRequest -Uri https://exemple.com -OutFile C:\Temp\fichier.html" };
    "curl"             = @{ PSCommand = "Invoke-WebRequest"; Alias = "iwr"; Example = "Invoke-WebRequest -Uri https://exemple.com" };

    # Système
    "df"               = @{ PSCommand = "Get-PSDrive"; Alias = ""; Example = "Get-PSDrive" };
    "free"             = @{ PSCommand = "Get-WmiObject Win32_OperatingSystem | Select-Object FreePhysicalMemory, TotalVisibleMemorySize"; Alias = ""; Example = "Get-WmiObject Win32_OperatingSystem | Select-Object FreePhysicalMemory, TotalVisibleMemorySize" };
    "uname"            = @{ PSCommand = "Get-ComputerInfo"; Alias = ""; Example = "Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion" };

    # Texte
    "head"             = @{ PSCommand = "Get-Content -TotalCount"; Alias = ""; Example = "Get-Content C:\Temp\fichier.txt -TotalCount 10" };
    "tail"             = @{ PSCommand = "Get-Content | Select-Object -Last"; Alias = ""; Example = "Get-Content C:\Temp\fichier.txt | Select-Object -Last 10" };
    "sort"             = @{ PSCommand = "Sort-Object"; Alias = ""; Example = "Get-Content C:\Temp\fichier.txt | Sort-Object" };
    "wc"               = @{ PSCommand = "(Get-Content [fichier]).Count"; Alias = ""; Example = "(Get-Content C:\Temp\fichier.txt).Count" };

    # Archives
    "tar"              = @{ PSCommand = "Compress-Archive / Expand-Archive"; Alias = ""; Example = "Compress-Archive -Path C:\Temp\Dossier -DestinationPath C:\Temp\archive.zip" };
    "gzip"             = @{ PSCommand = "Compress-Archive"; Alias = ""; Example = "Compress-Archive -Path C:\Temp\fichier.txt -DestinationPath C:\Temp\archive.zip" };

    # Services
    "service"          = @{ PSCommand = "Get-Service"; Alias = ""; Example = "Get-Service | Where-Object { $_.Status -eq 'Running' }" };
    "systemctl"        = @{ PSCommand = "Start-Service / Stop-Service / Restart-Service"; Alias = ""; Example = "Restart-Service -Name 'Spouleur d'impression'" };

    # Utilisateurs
    "whoami"           = @{ PSCommand = "WhoAmI"; Alias = ""; Example = "WhoAmI" };
    "id"               = @{ PSCommand = "[System.Security.Principal.WindowsIdentity]::GetCurrent()"; Alias = ""; Example = "[System.Security.Principal.WindowsIdentity]::GetCurrent()" };
}

# Fonction pour afficher l'aide
function Show-Help {
    param (
        [string]$Command
    )
    try {
        $help = Get-Help -Name $Command -ErrorAction Stop
        Write-Host "`n--- Aide pour $Command ---" -ForegroundColor Cyan
        Write-Host $help.Synopsis
        Write-Host "`nDescription :"
        Write-Host $help.Description.Text
    } catch {
        Write-Host "`n[Aide] : Aucune aide disponible pour '$Command' (module non chargé ?)." -ForegroundColor Yellow
        Write-Host "Essayez : Get-Help $Command -Online" -ForegroundColor DarkGray
    }
}

# Fonction pour afficher les résultats
function Display-Result {
    param (
        [string]$BashCommand,
        [hashtable]$PSData
    )

    Write-Host "`n=== Équivalent PowerShell pour '$BashCommand' ===" -ForegroundColor Green

    # Afficher la commande PowerShell
    Write-Host "`nCommande PowerShell : " -ForegroundColor Magenta
    Write-Host $PSData.PSCommand -ForegroundColor White

    # Afficher les alias
    if ($PSData.Alias) {
        Write-Host "`nAlias : " -ForegroundColor Magenta
        Write-Host $PSData.Alias -ForegroundColor White
    }

    # Afficher un exemple
    Write-Host "`nExemple : " -ForegroundColor Magenta
    Write-Host $PSData.Example -ForegroundColor White

    # Afficher l'aide
    $psCommandName = ($PSData.PSCommand -split '[| ]')[0]  # Extraire la première commande
    Show-Help -Command $psCommandName
}

# Logique principale
if ($BashCommand -eq "help" -or $BashCommand -eq "--help" -or $BashCommand -eq "-h") {
    Write-Host "Utilisation : .\tradsh.ps1 [commande_bash]" -ForegroundColor Yellow
    Write-Host "`nExemples :"
    Write-Host "  .\tradsh.ps1 cd"
    Write-Host "  .\tradsh.ps1 grep"
    Write-Host "  .\tradsh.ps1 ls -l"
    Write-Host "`nPour lister toutes les commandes disponibles : .\tradsh.ps1 list"
    exit
}

if ($BashCommand -eq "list") {
    Write-Host "`n=== Liste des commandes Bash prises en charge ===" -ForegroundColor Green
    $BashToPowerShell.Keys | Sort-Object | ForEach-Object {
        Write-Host "- $_" -ForegroundColor White
    }
    exit
}

# Rechercher la commande dans le dictionnaire
if ($BashToPowerShell.ContainsKey($BashCommand)) {
    Display-Result -BashCommand $BashCommand -PSData $BashToPowerShell[$BashCommand]
} else {
    # Essayer de trouver une correspondance partielle (ex: "ls -l" si "ls" n'est pas trouvé)
    $found = $false
    foreach ($key in $BashToPowerShell.Keys) {
        if ($BashCommand -like "*$key*") {
            Display-Result -BashCommand $BashCommand -PSData $BashToPowerShell[$key]
            $found = $true
            break
        }
    }

    if (-not $found) {
        Write-Host "`n[Erreur] : La commande '$BashCommand' n'est pas encore dans la base de données." -ForegroundColor Red
        Write-Host "Essayez '.\tradsh.ps1 list' pour voir les commandes disponibles." -ForegroundColor Yellow
    }
}