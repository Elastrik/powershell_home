
function testDb ($db_name, $query = $null){
    
    $db_path = Join-Path $global:persistent_data 'database'
    $db_path = Join-Path $db_path $db_name
    write-host "Database path : $($db_path)" -ForegroundColor White
    $db = [DataBaseManager]::New($db_path, $true)
    $db.Connect()
    if($null -ne $query){
        $result = $db.Query($query)
        $db.DisplayResult($result)
    }
    $db.CheckConfig()
    $db.Disconnect()
}

# Normalise le nom de fichier d'une base de données : impose l'extension .sqlite
function db_normalizeName ([string] $db_name) {
    if ($db_name -notmatch '\.sqlite$') {
        $db_name = "$db_name.sqlite"
    }
    return $db_name
}

# Retourne le repertoire des bases de donnees (sous le persistent du profil actif)
function db_getDirectory {
    return Join-Path $global:persistent_data 'database'
}

# Cree une base de donnees SQLite. Si $db_name n'est pas fourni, le demande a l'utilisateur.
function db_create ($db_name) {

    if ([string]::IsNullOrWhiteSpace($db_name)) {
        $db_name = Read-Host "Nom de la base de données à créer"
    }

    if ([string]::IsNullOrWhiteSpace($db_name)) {
        write-host "Nom invalide." -ForegroundColor Red
        return
    }

    $db_name = db_normalizeName $db_name
    $db_dir = db_getDirectory

    if (-not (Test-Path $db_dir)) {
        New-Item -Path $db_dir -ItemType Directory -Force | Out-Null
        write-host "Répertoire créé : $($db_dir)" -ForegroundColor Green
    }

    $db_path = Join-Path $db_dir $db_name

    if (Test-Path $db_path) {
        write-host "La base de données '$db_name' existe déjà : $($db_path)" -ForegroundColor Yellow
        return
    }

    [DataBaseManager]::New($db_path, $true) | Out-Null
    write-host "Base de données '$db_name' créée : $($db_path)" -ForegroundColor Green
}

# Propose a l'utilisateur la liste des bases de donnees existantes et retourne le nom choisi
function db_selectDatabase {

    $db_dir = db_getDirectory

    if (-not (Test-Path $db_dir)) {
        write-host "Aucun répertoire de bases de données trouvé : $($db_dir)" -ForegroundColor Red
        return $null
    }

    $databases = @(Get-ChildItem -Path $db_dir -Filter '*.sqlite' -File)

    if ($databases.Count -eq 0) {
        write-host "Aucune base de données trouvée dans $($db_dir)" -ForegroundColor Red
        return $null
    }

    write-host "`nBases de données disponibles :" -ForegroundColor Cyan
    for ($i = 0; $i -lt $databases.Count; $i++) {
        write-host "[$i] $($databases[$i].Name)" -ForegroundColor Cyan
    }

    write-Host "Votre choix" -ForegroundColor Yellow -NoNewline
    $choice = Read-Host " "

    $index = 0
    if (-not [int]::TryParse($choice, [ref] $index) -or $index -lt 0 -or $index -ge $databases.Count) {
        write-host "Choix invalide." -ForegroundColor Red
        return $null
    }

    return $databases[$index].Name
}

# Liste les tables d'une base de donnees. Si $db_name n'est pas fourni, propose un choix.
function db_listTables ($db_name) {

    if ([string]::IsNullOrWhiteSpace($db_name)) {
        $db_name = db_selectDatabase
    }

    if ([string]::IsNullOrWhiteSpace($db_name)) {
        return
    }

    $db_name = db_normalizeName $db_name
    $db_dir = db_getDirectory
    $db_path = Join-Path $db_dir $db_name

    if (-not (Test-Path $db_path)) {
        write-host "Base de données introuvable : $($db_path)" -ForegroundColor Red
        return
    }

    $db = [DataBaseManager]::New($db_path, $true)
    $db.Connect()

    $tables = $db.GetTables()
    if ($tables.Count -eq 0) {
        write-host "Aucune table dans $($db_name)." -ForegroundColor Yellow
    }
    else {
        write-host "`nTables de $($db_name) :" -ForegroundColor Cyan
        $tables | ForEach-Object { write-host " - $_" -ForegroundColor White }
    }

    $db.Disconnect()
}