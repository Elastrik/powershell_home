class DataBaseManager {
    [string] $DbPath
    $Connection
    [bool]   $Verbose = $false

    # Constructeur standard (silencieux)
    DataBaseManager([string] $dbPath) {
        $this.Init($dbPath, $false)
    }

    # Constructeur avec contrôle explicite de la verbosité (usage CLI)
    DataBaseManager([string] $dbPath, [bool] $verbose) {
        $this.Init($dbPath, $verbose)
    }

    hidden [void] Init([string] $dbPath, [bool] $verbose) {
        $this.Verbose = $verbose
        $this.Connection = $null
        $this.DbPath = $dbPath
        if (-not (Test-Path $this.DbPath)) {
            New-Item -Path $this.DbPath -ItemType File -Force | Out-Null
            if ($this.Verbose) {
                Write-Host "Base de données créée : $($this.DbPath)" -ForegroundColor Green
            }
        }
    }

    [bool] CheckConfig() {
        if (-not (Test-Path $this.DbPath)) {
            Write-Host "Base de données introuvable : $($this.DbPath)" -ForegroundColor Red
            return $false
        }
        if (-not $this.IsConnected()) {
            Write-Host "Connexion à la base de données introuvable : $($this.DbPath)" -ForegroundColor Red
            return $false
        }
        return $true
    }

    [bool] IsConnected() {
        return ($null -ne $this.Connection)
    }

    [void] Connect() {
        if ($this.IsConnected()) {
            return
        }
        try {
            $this.Connection = New-SQLiteConnection -DataSource $this.DbPath
            if ($this.Verbose) {
                Write-Host "Connexion à la base de données établie : $($this.DbPath)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "Erreur de connexion : $($_.Exception.Message)" -ForegroundColor Red
            $this.Connection = $null
        }
    }

    [void] Disconnect() {
        if (-not $this.IsConnected()) {
            return
        }
        try {
            $this.Connection.Close()
        }
        catch {
            # connexion déjà fermée / invalide : ignoré volontairement
        }
        $this.Connection = $null
        if ($this.Verbose) {
            Write-Host "Connexion fermée : $($this.DbPath)" -ForegroundColor DarkGray
        }
    }

    # Exécute une requête SQL simple (SELECT ou écriture). Connecte automatiquement si besoin.
    [object[]] Query([string] $sql) {
        return $this.Query($sql, $null)
    }

    # Exécute une requête SQL paramétrée (protection anti-injection via -SqlParameters).
    [object[]] Query([string] $sql, [hashtable] $parameters) {
        if (-not $this.IsConnected()) {
            $this.Connect()
        }
        if (-not $this.IsConnected()) {
            Write-Host "Impossible d'exécuter la requête : pas de connexion active." -ForegroundColor Red
            return $null
        }

        if ($this.Verbose) {
            Write-Host "Executing query : $sql" -ForegroundColor White
        }

        $result = $null
        try {
            if ($null -ne $parameters) {
                $result = Invoke-SqliteQuery -SQLiteConnection $this.Connection -Query $sql -SqlParameters $parameters
            }
            else {
                $result = Invoke-SqliteQuery -SQLiteConnection $this.Connection -Query $sql
            }
        }
        catch {
            Write-Host "Erreur SQL : $($_.Exception.Message)" -ForegroundColor Red
            return $null
        }

        if ($this.Verbose) {
            if ($null -ne $result) {
                Write-Host "Query result : $(@($result).Count) ligne(s)" -ForegroundColor Cyan
            }
            else {
                Write-Host "Query executed (no data)" -ForegroundColor Yellow
            }
        }

        return $result
    }

    # --- Transactions ---

    [void] BeginTransaction() {
        $this.Query("BEGIN TRANSACTION;") | Out-Null
    }

    [void] Commit() {
        $this.Query("COMMIT;") | Out-Null
    }

    [void] Rollback() {
        $this.Query("ROLLBACK;") | Out-Null
    }

    # --- Utilitaires métier ---

    [bool] TableExists([string] $tableName) {
        $result = $this.Query(
            "SELECT name FROM sqlite_master WHERE type='table' AND name = @name;",
            @{ name = $tableName }
        )
        return ($null -ne $result -and @($result).Count -gt 0)
    }

    [string[]] GetTables() {
        $result = $this.Query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
        if ($null -eq $result) {
            return @()
        }
        return @($result | ForEach-Object { $_.name })
    }

    # --- Affichage CLI (prend directement des objets, plus de JSON intermédiaire) ---

    [void] DisplayResult([object[]] $rows) {
        if ($null -eq $rows -or @($rows).Count -eq 0) {
            Write-Host "Aucun résultat." -ForegroundColor Yellow
            return
        }
        Write-Host "`nRésultats ($(@($rows).Count) ligne(s)) :" -ForegroundColor Cyan
        $rows | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    }
}