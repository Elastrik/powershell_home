# variables
# Charger la configuration depuis un fichier externe
$tradsh = $tradsh_path
if (Test-Path -Path $tradsh) {
    Set-Alias tradsh $tradsh
}
else {
    Write-Host "⚠️  Fichier tradsh introuvable : $externalProfilePath" -ForegroundColor Yellow
    Write-Host "Vérifiez que le disque externe est connecté." -ForegroundColor Yellow
}

function browser($url) { Start-Process $url }

# Raccourcis
function youtube { browser "https://www.youtube.com/" }
Set-Alias yt youtube
# Ouvre la bibliothèque
function steam { Start-Process "steam://open/games" }
function musique { browser "https://music.youtube.com/" }
function keep { browser "https://keep.google.com/u/1/" }
function gmail { browser "https://mail.google.com/mail/u/1/" }
function sheet { browser "https://docs.google.com/spreadsheets/u/1/" }

function tickets { browser "https://sedgroupe.zendesk.com/agent/filters/29563385036817" }

function teams {
    Start-Process "ms-teams:"
}
# Ouvre Microsoft Outlook (application de bureau)
function outlook {
    Start-Process "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
}
function gitHubDesktop {
    Start-Process "C:\Users\vledoux\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
}


# Ouvre une session RDP via un fichier .rdp
function Start-RDP {
    param(
        [string]$RdpFile = ""
    )
    if ([string]::IsNullOrEmpty($RdpFile)) {
        $RdpFile = Join-Path $global:desk "Adelia V14_sed02.rdp"
    }

    if (Test-Path -Path $RdpFile) {
        Start-Process -FilePath $RdpFile
    }
    else {
        Write-Host " Fichier RDP introuvable : $RdpFile" -ForegroundColor Red
    }
}
function adelia14 {
    Start-RDP
}
Set-Alias a14 adelia14
function adelia12 {
    Start-RDP   "C:\Users\vledoux\Documents\OneDrive - SED\Bureau\srv-adelia.rdp"
}
Set-Alias a12 adelia12

function Start-IBM {
    param(
        [string]$File = ""
    )
    if ([string]::IsNullOrEmpty($File)) {
        $File = Join-Path $global:desk "MESNIL_new.HOD"
    }


    if (Test-Path -Path $File) {
        Start-Process -FilePath $File
    }
    else {
        Write-Host "❌ Fichier introuvable : $File" -ForegroundColor Red
    }
}
function Mesnil400 {
    Start-IBM
}

function Marly400 {
    $marly = Join-Path $global:desk "MARLY_new.HOD"
    Start-IBM $marly
}

function diskbar {
    $drives = @("C", "D", "E", "F")

    foreach ($letter in $drives) {
        $drive = Get-PSDrive -Name $letter -ErrorAction SilentlyContinue
        if (-not $drive) { continue }

        $used = $drive.Used
        $free = $drive.Free
        $total = $used + $free
        $pct = [math]::Round(($used / $total) * 100)

        # Couleur selon le remplissage
        $color = if ($pct -ge 80) { "Red" } elseif ($pct -ge 60) { "Yellow" } else { "Green" }

        # Barre ASCII
        $barWidth = 30
        $filled = [math]::Round($pct * $barWidth / 100)
        $empty = $barWidth - $filled
        $bar = ("█" * $filled) + ("░" * $empty)

        $usedGo = [math]::Round($used / 1GB, 1)
        $totalGo = [math]::Round($total / 1GB, 1)

        Write-Host "  ${letter}:\ " -NoNewline -ForegroundColor DarkGray
        Write-Host $bar -NoNewline -ForegroundColor $color
        Write-Host " $pct% " -NoNewline -ForegroundColor White
        Write-Host "($usedGo Go / $totalGo Go)" -ForegroundColor DarkGray
    }
}

#menus 
$menu_class = Join-Path $global:menu_path "menu.ps1" 
. $menu_class

$wallet_class = Join-Path $global:wallet_class_path "wallet.ps1"
. $wallet_class
# programme bigfish

$bigfish_class = Join-Path $global:bigfish_path  "bigfish.ps1" 
. $bigfish_class


# main menu
function mainmenu {
    
    $mm = [Menu]::New($global:main_menu)
    $mm.show()
}

Set-Alias mm mainmenu



function codeWS ($workspace) {
    switch ($workspace) {
        'SQL' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\SQL_WORKSPACE.code-workspace" }
        'SSH' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\SSH_WORKSPACE.code-workspace" }
        'EXT' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\VSCODE_EXTENSIONS.code-workspace" }
        'ZPL' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\ZPL_WORKSPACE.code-workspace" }
        'WEB' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\htdocs.code-workspace" }
        'PYT' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\Python.code-workspace" }
        'PSH' { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\Powershell.code-workspace" }
        Default { $path = "C:\Users\vledoux\OneDrive - SED\home\VSCODE\BIDOUILLE_WORKSPACE.code-workspace" }
    }
    code --new-window $path
}

function ShowColors() {
    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors) {
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    }
}


. $global:powershell_folder\app\merchant\merchant.ps1
