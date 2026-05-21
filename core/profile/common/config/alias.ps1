# --- Navigation ---
Set-Alias .. cd..
function ... { Set-Location ..\.. }
Set-Alias ls Get-ChildItem
function ll  { Get-ChildItem $args | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
function la  { Get-ChildItem -Force $args }
function pwd { (Get-Location).Path }

# --- Fichiers ---
function touch($file) { New-Item -ItemType File -Name $file | Out-Null }
function mkdir { New-Item -ItemType Directory -Name $args[0] | Out-Null }
function mkcd($dir) { New-Item -ItemType Directory -Name $dir | Out-Null; Set-Location $dir }
function cp  { Copy-Item $args }
function mv  { Move-Item $args }
function rm  { Remove-Item $args }
function rmrf($path) { Remove-Item -Recurse -Force $path }
function cat { Get-Content $args }
function head($file, $n = 10) { Get-Content $file | Select-Object -First $n }
function tail($file, $n = 10) { Get-Content $file | Select-Object -Last $n }
function tailf($file) { Get-Content $file -Wait -Tail 20 }  # tail -f
function grep($pattern, $file) { Select-String -Pattern $pattern -Path $file }
function find($name) { Get-ChildItem -Recurse -Filter $name }
function wc($file) { (Get-Content $file).Count }            # nb de lignes
function which($cmd) { Get-Command $cmd | Select-Object -ExpandProperty Source }

# --- Réseau ---
function myip   { (Invoke-WebRequest "ifconfig.me" -UseBasicParsing).Content.Trim() }
function ports  { netstat -ano | findstr LISTENING }
function ping   { Test-Connection $args }

# --- Système ---
function df     { Get-PSDrive | Where-Object { $_.Used -gt 0 } | Format-Table Name, @{L="Used(GB)";E={[math]::Round($_.Used/1GB,1)}}, @{L="Free(GB)";E={[math]::Round($_.Free/1GB,1)}} }
function free   { $os = Get-CimInstance Win32_OperatingSystem; Write-Host "Total : $([math]::Round($os.TotalVisibleMemorySize/1MB,1)) GB  |  Libre : $([math]::Round($os.FreePhysicalMemory/1MB,1)) GB" }
function ps     { Get-Process $args }
function kill   { Stop-Process -Name $args }
function uptime { (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime }
function clear  { Clear-Host }

function man($cmd){
    get-help $cmd -Full
}

# --- Historique ---
function hist($search) {
    if ($search) {
        Get-Content (Get-PSReadlineOption).HistorySavePath | Where-Object { $_ -like "*$search*" } | Select-Object -Last 20
    } else {
        Get-Content (Get-PSReadlineOption).HistorySavePath | Select-Object -Last 50
    }
}

# --- Utilitaires ---
function meteo($ville = "Chezy-sur-Marne") { (Invoke-WebRequest "wttr.in/$ville/?format=3" -UseBasicParsing).Content.Trim() }
function extract($file) {
    switch -Regex ($file) {
        "\.zip$"    { Expand-Archive $file }
        "\.tar.gz$" { tar -xzf $file }
        "\.tar$"    { tar -xf $file }
        default     { Write-Host "Format non reconnu" }
    }
}
