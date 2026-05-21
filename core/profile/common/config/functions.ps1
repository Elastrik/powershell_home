
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


function mainmenu {
    
    $mm = [Menu]::New($global:main_menu)
    $mm.show()
}

function ShowColors() {
    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors) {
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    }
}


# Ouvre Microsoft Outlook (application de bureau)
