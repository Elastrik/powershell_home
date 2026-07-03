class DataBaseManager {
    [string]           $dbPath
    $connection

    DataBaseManager([string] $dbpath) {
        $this.connection = $null
        $this.dbPath = $dbpath
        if ( -not (Test-Path  $this.dbPath ) ) {
            write-host "Creating file : $($this.dbPath)" -ForegroundColor Green
            New-Item -Path $this.dbPath -ItemType File -Force
            
            write-host "Base de données créée : $($this.dbPath)" -ForegroundColor Green
        }        
    }

    [bool] checkConfig() {
        if ( -not (Test-Path  $this.dbPath ) ) {
            write-host " Base de données introuvable : $($this.dbPath)" -ForegroundColor Red
 
            return $false
        }
        if ($null -eq $this.connection) {
            write-host " Connexion à la base de données introuvable : $($this.dbPath)" -ForegroundColor Red
            return $false
        }
        return $true
    }

    connect() {
        if ( $null -eq $this.connection ) {
            $this.connection = New-SQLiteConnection -DataSource $this.dbPath

            write-host "Connexion à la base de données établie : $($this.dbPath)" -ForegroundColor Green
        }
        # return $this.connection
    }

    query([string] $query) {
        if ( $null -eq $this.connection ) {
            $this.connect()
        }


        # Invoke-SqliteQuery -SQLiteConnection $this.connection -Query  "SELECT 1 FROM [@table] WHERE [@col] LIKE '@query' LIMIT 1;" -SqlParameters @{
        #     table='test';
        #     col='example';
        #     query='hello'
        # }
        write-host "Executing query : $($query)" -ForegroundColor White

        $result = Invoke-SqliteQuery -SQLiteConnection $this.connection -Query  $query
        $result | Format-List
        # return $this.connection
    }



}