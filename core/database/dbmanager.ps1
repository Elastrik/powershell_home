class DataBaseManager {
    [string]           $dbPath
    $connection

    DataBaseManager([string] $dbpath) {
        $this.connection = $null
        $this.dbPath = $dbpath
        if ( -not (Test-Path  $this.dbPath ) ) {
            write-host "Creating file : $($this.dbPath)" -ForegroundColor Green
            New-Item -Path $this.dbPath -ItemType File -Force
            
            write-host "Base de données createe : $($this.dbPath)" -ForegroundColor Green
        }        
    }

    [bool] checkConfig() {
        if ( -not (Test-Path  $this.dbPath ) ) {
            write-host " Base de données introuvable : $($this.dbPath)" -ForegroundColor Red
   
            return $false
        }
        if ($null -eq $this.connection) {
            write-host " Connexion a la base de données introuvable : $($this.dbPath)" -ForegroundColor Red
            return $false
        }
        return $true
    }

    connect() {
        if ( $null -eq $this.connection ) {
            $this.connection = New-SQLiteConnection -DataSource $this.dbPath

            write-host "Connexion a la base de données établie : $($this.dbPath)" -ForegroundColor Green
        }
        # return $this.connection
    }

    [string] query([string] $query) {
        $json =$null
        if ( $null -eq $this.connection ) {
            $this.connect()
        }

        write-host "Executing query : $($query)" -ForegroundColor White

        $result = Invoke-SqliteQuery -SQLiteConnection $this.connection -Query $query
        
        if ($null -ne $result) {
            write-host "Query result:" -ForegroundColor Cyan
            $json = $result | ConvertTo-Json -Depth 100
            write-host $json -ForegroundColor Cyan
            
        } else {
            write-host "Query executed (no data)" -ForegroundColor Yellow
        }
        return $json
    }

    [void] displayResult($json) {
        try {
            if ([string]::IsNullOrWhiteSpace($json)) {
                write-host "No data returned" -ForegroundColor Yellow
                return
            }
            
            $parsed = $json | ConvertFrom-Json
            
            if ($null -eq $parsed) {
                write-host "Empty result set" -ForegroundColor Yellow
                return
            }
            
            if ($parsed -is [array]) {
                if ($parsed.Count -lt 1) {
                    write-host "Empty result set" -ForegroundColor Yellow
                    return
                }
                
                $firstIsObject = ($parsed[0] -is [pscustomobject] -or $parsed[0] -is [hashtable])
                
                if ($firstIsObject) {
                    write-host "`nResults ($($parsed.Count) rows):" -ForegroundColor Cyan
                    
                    if ($parsed.Count -eq 1) {
                        $headers = $parsed[0].PSObject.Properties.Name
                        foreach ($h in $headers) {
                            write-host "$h : $($parsed[0].$h)" -ForegroundColor Cyan
                        }
                    } else {
                        $headers = $parsed[0].PSObject.Properties.Name
                        
                        if ($headers.Count -eq 0) {
                            write-host "Empty result set" -ForegroundColor Yellow
                            return
                        }
                        
                        # Build simple header line using explicit string building for compatibility
                        $headerLine = ""
                        for ($i = 0; $i -lt $headers.Count; $i++) {
                            if ($i -gt 0) { 
                                $headerLine += "       " 
                            }
                            $hName = $headers[$i]
                            # Calculate padding and build with explicit string operations
                            if ([int]$hName.Length -le 15) {
                                $pad = " ".PadRight((15 - [int]$hName.Length))
                            } else {
                                $pad = ""
                            }
                            $headerLine += "$hName" + $pad
                        }
                        write-host $headerLine -ForegroundColor White
                        
                        # Print each row using explicit string building for compatibility
                        for ($i = 0; $i -lt $parsed.Count; $i++) {
                            $rowObj = $parsed[$i]
                            $rowLine = ""
                            foreach ($h in $headers) {
                                if ($null -eq $rowObj.$h) {
                                    $vStr = "NULL"
                                } else {
                                    $vStr = $rowObj.$h
                                }
                                # Safe length check and padding calculation
                                $checkLen = 15 - [int]$vStr.Length
                                if ($checkLen -gt 0) {
                                    $pad = " ".PadRight($checkLen)
                                } else {
                                    $pad = ""
                                }
                                if ([int]$vStr.Length -le 13) {
                                    $rowLine += "$vStr" + $pad
                                } else {
                                    # Second column needs different padding (13 chars max for display)
                                    $checkLen2 = 13 - [int]$vStr.Length
                                    if ($checkLen2 -gt 0) {
                                        $pad2 = " ".PadRight($checkLen2)
                                    } else {
                                        $pad2 = ""
                                    }
                                    $rowLine += "       " + "$vStr" + $pad2
                                }
                            }
                            write-host $rowLine -ForegroundColor White
                        }
                    }
                } else {
                    write-host "Results ($($parsed.Count) items):" -ForegroundColor Cyan
                    for ($i = 0; $i -lt $parsed.Count; $i++) {
                        write-host "[{$i}] $($parsed[$i])" -ForegroundColor Cyan
                    }
                }
            } elseif ($parsed -is [pscustomobject] -or $parsed -is [hashtable]) {
                write-host "Results (1 row):" -ForegroundColor Cyan
                $headers = $parsed.PSObject.Properties.Name
                foreach ($header in $headers) {
                    write-host "$header : $($parsed.$header)" -ForegroundColor Cyan
                }
            } else {
                write-host "Result: $($parsed)" -ForegroundColor Cyan
            }
        } catch {
            write-host "Error parsing JSON result: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

}