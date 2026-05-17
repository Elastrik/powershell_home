# execution automatique de BigFish
. "E:\powershell\app\bigfish\bigfish.ps1"
$bf = [BigFish]::new()
set-Location 'D:\Downloads'

$bf.Execute('fish' '10');
$bf.Execute('sell')

Set-Content -path 'E:\powershell\app\bigfish\dailyTask.log' -value "OK"

