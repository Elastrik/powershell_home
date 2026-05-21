class Welcome {  
    static [void] RenderLogo (){
        if($global:profile_logo -and $global:profile_logo_colors){
             for ($i = 0; $i -lt $Global:profile_logo.Length; $i++) {
                Write-Host $Global:profile_logo[$i] -ForegroundColor $Global:profile_logo_colors[$i]
            }
        }else {
            Write-Host "Bienvenue !" -ForegroundColor Green
        }
    }
    static [void] RenderSystemInfo(){
        $date = Get-Date -Format "dddd dd/MM/yyyy  HH:mm"
        # $psVersion = $PSVersionTable.PSVersion.ToString()
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  user     " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host "VICTOR"           -ForegroundColor Magenta
        Write-Host "  machine  " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $env:COMPUTERNAME  -ForegroundColor Cyan
        # Write-Host "  shell    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host "PowerShell $psVersion" -ForegroundColor Green
        Write-Host "  heure    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $date              -ForegroundColor Yellow
    } 
    static [void] RenderMeteo([string] $location){
        $meteo_chezy = (Invoke-WebRequest "wttr.in/$($location)?format=3" -UseBasicParsing).Content.Trim()

        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  météo    " -ForegroundColor DarkGray -NoNewline; Write-Host "❯ " -NoNewline; Write-Host $meteo_chezy       -ForegroundColor Cyan

    }
    static [void] RenderDiskInfo (){
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  Etat des disques : " -ForegroundColor DarkGray
        diskbar
    } 
    static [void] RenderMessage([sTring] $msg){
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  $msg" -ForegroundColor Magenta
    }
}