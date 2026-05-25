# Fonctions du profil VSCODE
function codeWS ($workspace) {
    switch ($workspace) {
        'EXT' { $path = "D:\documents\VSCODE\VSCODE_EXTENSIONS.code-workspace" }
        'PSH' { $path = "D:\documents\VSCODE\powershell.code-workspace" }
        Default { $path = "D:\documents\VSCODE\powershell.code-workspace" }
    }
    code --new-window $path
}



function PriscillaStructure() {
    $arboRef = [System.Collections.Generic.List[String]]::New()
    $arbo_path = "C:\Users\vledoux\SED\SCINFO - Documents\02_Logistique\98_REFERENTIEL_SHAREPOINT\01_TEMPLATE\02_NOUVELLE_ARBORESCENCE_MODELE" 

    Get-ChildItem -Directory -Path $arbo_path | ForEach-Object {
        $arboRef.add($_.Name)
    }
    $Client_path = "C:\Users\vledoux\SED\SCINFO - Documents\02_Logistique\00_CLIENTS" 
    $savedLocation = (Get-Location).path
    set-Location $Client_path

    Write-Host "~~ Demarrage du programme Priscilla ~~ " -ForegroundColor Magenta
    Get-ChildItem -Directory | ForEach-Object {

        #" Write-Host "#Debug" : $($_.Name)"

        $label = "-> Scan du Repertoire Client : $($_.Name)"
        Write-Host "$($label.PadRight(60,'-'))" -ForegroundColor Yellow -NoNewline

        $DirList1 = [System.Collections.Generic.List[hashtable]]::New()  
        $Niv1Good = $true
        
        $Client_dir = Join-Path $Client_path $_.Name
       
        # Write-Host "#Debug Client Dir: $($Client_dir)"

        # Scan du Niveau 1
        Get-ChildItem -Directory $Client_dir | ForEach-Object {

            # Write-Host "#Debug Client Rub : $($_.name)"

            $Client_rubrique_dir = Join-Path $Client_dir $_.Name

            # Write-Host "#Debug Client Rub path : $($Client_rubrique_dir)"


            $Rubrique_name = $_.name
            $good = $arboRef.Contains($_.Name)
            $dir1 = @{
                path     = $_.Name
                ok       = $good
                hasError = $good
                niv2     = [System.Collections.Generic.List[hashtable]]::New()  
            }
 

            if (-not $good) {
                $Niv1Good = $false
            }
            else {
                #  Scan du Niveau 2
                # arborescence de reference
                $Niv2Good = $true
                $Niv2Ref = [System.Collections.Generic.List[String]]::New() 
                $arbo_path_n2 = Join-Path $arbo_path $Rubrique_name
                Get-ChildItem -Directory -Path $arbo_path_n2 | ForEach-Object {
                    $Niv2Ref.add($_.Name)
                }

                # Scan du repertoire de niveau 2
                Get-ChildItem -Directory $Client_rubrique_dir | ForEach-Object {
                    $good = $Niv2Ref.Contains($_.Name)
                    $dir2 = @{
                        path = $_.Name
                        ok   = $good
                    }
                    if(-not $good) {$dir1["hasError"] = $true}
                    $dir1["niv2"] = $dir2


                    if (-not $good) {
                        $Niv2Good = $false
                    }

                }     


            }
            $DirList1.add($dir1)

        }

        if ($Niv1Good) {
            if ($DirList1["hasError"]) {

                Write-Host "-> Erreur dans les sous dossiers" -ForegroundColor Yellow
                $DirList1 | ForEach-Object {
                    
                    $color = $_["ok"] ? "Green" : "Red"
                    Write-Host ">$($_.path) hasError ? $($_.hasError ? "Oui" : "Non")" -ForegroundColor $color
                    $_.niv2 | ForEach-Object {
                        $color = $_["ok"] ? "Green" : "Red"
                        Write-Host ">   >$($_.path)" -ForegroundColor $color
                    }
                  
                }
            }
            else {
                Write-Host "-> Tout est bon !" -ForegroundColor Green

            }
        }
        else {
            Write-Host '-> Des erreurs sont présentes' -ForegroundColor Red
            $DirList1 | ForEach-Object {
                $color = $_["ok"] ? "Green" : "Red"
                Write-Host ">$($_.path)" -ForegroundColor $color
            }
        }

    }

    Set-Location -path $savedLocation

}



function sharePointPolice {
    param(
        $recurse = $false
    )
    # ===== CONFIGURATION =====
    
    $validDSIs = @("DSI", "RH", "LOG")  # Liste des codes service valides
    
    # Pattern regex pour valider le nom : SED_<DSI>_<libelle>_C1|C2|C3
    $pattern = '^SED_([A-Za-z0-9]+)_.*_C[1-3]$'
    $pattern_1 = '^SED_.*'
    $pattern_2 = '^.*(DSI[_-]).*'
    $pattern_3 = '^.*(C[1-3]).*'

    $location = ""
    # ===== SCRIPT =====
    # Récupérer tous les fichiers du répertoire
    Get-ChildItem -File -Recurse:$recurse 
    | Sort-Object -Property DirectoryName 
    | ForEach-Object {
        $ok = $true
        write-host "_________________________________________"
        if ($location -ne $_.DirectoryName) {
            Write-Host " " 
            Write-Host "Repertoire : $($_.DirectoryName)" -ForegroundColor Yellow 
        }

        $name = $_.BaseName
        if ($name -notmatch $pattern_1) {
            Write-Host " SED absent : $name" -ForegroundColor Red
            $ok = $false
        }
    
        if ($name -notmatch $pattern_2) {
            Write-Host " DSI invalide :  $name" -ForegroundColor Red
            $ok = $false
        }
        
        if ($name -notmatch $pattern_3) {
            Write-Host " Cx invalide :  $name" -ForegroundColor Red
            $ok = $false
        }

        if ($ok) {
            Write-Host "Fichier Valide : $name" -ForegroundColor Green
        }
        else {
            Write-Host "Fichiers mal nommés : " -ForegroundColor Red -NoNewline
            Write-Host " $($_.Name)" -ForegroundColor Magenta
        }

        
        $location = $_.DirectoryName

    }

}