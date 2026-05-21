
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

