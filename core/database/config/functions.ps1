
function testDb ($db_name, $query = $null){
    
    $db_path = Join-Path $global:persistent_data 'database'
    $db_path = Join-Path $db_path $db_name
    write-host "Database path : $($db_path)" -ForegroundColor White
    $db = [DataBaseManager]::New($db_path)
    $db.connect()   
    if($null -ne $query){
        $result = $db.query($query)
        $db.displayResult($result)
    }
    $db.checkConfig()
}