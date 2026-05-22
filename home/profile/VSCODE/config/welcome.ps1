if ($Host.UI.RawUI) {
    . "$global:profile_path\config\logo.ps1"
    Write-Host ""
    Write-Host "  Bonjour $global:profile_name !" -ForegroundColor Magenta
    Write-Host ""
}
