$fishtypes = @{
    'krill'     = 0KB
    'maquereau' = 100MB
    'saumon'    = 500MB
    'thon'      = 1GB
    'orque'     = 10GB
    'baleine'   = 9900GB
}

function bigFish {
    $action = $args[0]

    switch ($action) {
        "remove"  {
            if ($action -match '^\d+$') { bigFish-Remove $args[1] }
            else {
                bigFish-RemoveType $args[1]
            }
        }
        default   { 
            if ($action -match '^\d+$') { bigFish-List $action }
            else {  bigFish-List 5 } 
        } 
    }
}

function bigFish-list ($n = 5){
    Write-Host "************************************************" -ForegroundColor Cyan
    Write-Host "***** " -ForegroundColor Cyan -NoNewline
    Write-Host "~ Big-Fisher à la pêche au gros ~" -ForegroundColor Magenta -NoNewline
    Write-Host " ********"  -ForegroundColor Cyan
    Write-Host "************************************************" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Les $n plus gros poissons sont : " -ForegroundColor Gray
    Write-Host ""

    Get-ChildItem -File |
    Sort-Object Length -Descending |
    Select-Object -First $n |
    ForEach-Object {
      writeFish($_)
    }
    Write-Host ""
    Write-Host "~ Belle prise ? ~" -ForegroundColor Cyan
}

function writeFish($element){
    $result = ""
    $sizeMo = [math]::Round($element.Length / 1MB, 2)
    $size = $sizeMo
    $padding = 50
    $filler = '-'
    $color = "DarkGray"
    $sizeUnit = 'Ko'
    $fishLabel = ''
    

    if ($sizeMo -lt 1) {
        # on compte en Ko
        $size = [math]::Round($element.Length / 1KB, 2)
        
        $fishType = 'krill'
    }else{
        # on compte en Mo
        $sizeUnit = 'Mo'

        if ($sizeMo -lt 100) {
            $color = "Gray";
            $fishType = 'maquereau'
        }
        else{
            if ($sizeMo -lt 500) {
                $color = "White";
                $fishType = 'saumon'
            }
            else {
                if ($sizeMo -lt 1000) { 
                    $color = "Yellow"
                    $fishType = 'thon'
                }
                else{
                    # on compte en Go
                    $sizeUnit = 'Go'
                    $size = [math]::Round($element.Length / 1GB, 2)
                    if ($size -lt 10) {
                        $color = "red";
                        $fishType = 'orque'
                    }  
                    else {
                        $color = "Magenta";
                        $fishType = 'baleine'
                
                    }
                }
            }
        }
    }
    $fishLabel = "[$fishtype]" 
    Write-Host "~>$($fishLabel.padRight(12,'~'))> " -ForegroundColor $color -NoNewline
    Write-Host "$($element.Name.PadRight($padding,$filler))" -ForegroundColor $color -NoNewline
    Write-Host " — $size $sizeUnit" -ForegroundColor $color 
}


function bigFish-remove ($n = 5){
    Write-Host "************************************************" -ForegroundColor Red
    Write-Host "****** " -ForegroundColor Red -NoNewline
    Write-Host "~  Big-Fisher vends ses prises ~" -ForegroundColor Magenta -NoNewline
    Write-Host " ********"  -ForegroundColor Red
    Write-Host "************************************************" -ForegroundColor Red
    Write-Host ""
    Write-Host "Les $n plus gros poissons sont : " -ForegroundColor Gray
    Write-Host ""

    Get-ChildItem -File |
    Sort-Object Length -Descending |
    Select-Object -First $n |
    ForEach-Object {
        Write-Host "~~~~~~~~"
        $filePath = "$($_.Directory)\$($_.Name)" 
        Write-Host "> Supprimer ? " -ForegroundColor Red -NoNewline
        writeFish($_)       
        Remove-Item $_ -confirm
        Write-Host ""
    }
    Write-Host ""
    Write-Host "~ La pêche a été bonne ?  ~" -ForegroundColor Red
}


function bigFish-removeType ($type){
    $types = @('krill','maquereau','saumon','thon','orque','baleine')
    if($types -contains $type){
        Write-Host "******************** ****************************" -ForegroundColor yellow
        Write-Host "****** " -ForegroundColor yellow -NoNewline
        Write-Host "~  Big-Fisher part a la pêche aux $($type.PadRight(12)) ~" -ForegroundColor Magenta -NoNewline
        Write-Host " ********"  -ForegroundColor yellow
        Write-Host "************************************************" -ForegroundColor yellow
        Write-Host ""
        Write-Host " Une belle liste de $type :  " -ForegroundColor Gray
        Write-Host ""

        Get-ChildItem -File | Where-Object {$_.Length -lt $fishtypes[$type] }
        Sort-Object Length -Descending |
        ForEach-Object {
            Write-Host "~~~~~~~~"
            $filePath = "$($_.Directory)\$($_.Name)" 
            Write-Host "> Supprimer ? " -ForegroundColor Red -NoNewline
            writeFish($_)       
            # Remove-Item $_ -confirm
            Write-Host ""
        }
        Write-Host ""
        Write-Host "~ La pêche au $type a été bonne ?  ~" -ForegroundColor Red
    }else{
        Write-Host "~* Bigfish ne connait pas ce type de poison *~" -ForegroundColor Red
        Write-Host "Essayez donc un de ceux la : " -ForegroundColor Cyan
        $fishtypes.Keys | ForEach-Object {
            Write-Host "> $_" -ForegroundColor Cyan
        }
    }
  
}
