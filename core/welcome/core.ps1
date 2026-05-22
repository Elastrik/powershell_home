
$welcome_class = join-path $global:powershell_core "welcome/welcome.ps1"
. $welcome_class 


$config = join-path $global:powershell_core "welcome/config"

# fonctions
$fun = join-path $config "functions.ps1"
if (Test-Path $fun) {
    . $fun
}