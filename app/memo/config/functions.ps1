############
# modules  #
############

### core
$memo_class = Join-Path $global:memo_core_path "memo.ps1"
. $memo_class

$global:memo_store = $null

function memo {
    $choice = ""
    while ($choice -ne "Q" -and $choice -ne "q") {
        $menu = [Menu]::New([MemoMenu]::Main())
        $choice = $menu.Show()
    }
}

# Affiche la liste des memos dont le rappel est echu (date/heure <= maintenant).
# Utilisable en standalone (ex: dans un welcome.ps1 de profil) ou via le menu memo.
function memoRappels {
    [MemoApp]::VoirRappels()
}

# Affichage compact et non interactif (pas de Read-Host) des memos dont le
# rappel est echu uniquement : une ligne de texte brut par memo.
# Utilisable en standalone (ex: dans un welcome.ps1 de profil).
function memoRappelsEchus {
    [MemoApp]::ListerRappelsEchus()
}
