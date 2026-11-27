# modules/core/memo/memo.ps1
# Entites : MEMO_ENTETE / MEMO_LIGNE / MEMO_INFO / MEMO_LIGNE_INFO (reservee)
# MemoStore  : acces base de donnees (DataBaseManager du core database)
# MemoRenderer : rendu ecran synthwave (Write-Host uniquement)
# MemoApp    : orchestration des ecrans / boucles de saisie
# MemoMenu   : menu principal (core menu : classe Menu)

class MemoStore {
    [DataBaseManager] $Db

    static [MemoStore] GetInstance() {
        if ($null -eq $global:memo_store) {
            $dbPath = Join-Path $global:persistent_data "database/memo.sqlite"
            $global:memo_store = [MemoStore]::New($dbPath)
        }
        return $global:memo_store
    }

    MemoStore([string] $dbPath) {
        $this.Db = [DataBaseManager]::New($dbPath)
        $this.Db.Connect()
        $this.EnsureSchema()
    }

    [void] EnsureSchema() {
        if (-not $this.Db.TableExists("MEMO_ENTETE")) {
            $this.Db.Query(@"
CREATE TABLE MEMO_ENTETE (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    titre             TEXT NOT NULL,
    date_creation     TEXT NOT NULL,
    date_modification TEXT NOT NULL
);
"@) | Out-Null
        }
        if (-not $this.Db.TableExists("MEMO_LIGNE")) {
            $this.Db.Query(@"
CREATE TABLE MEMO_LIGNE (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    memo_id           INTEGER NOT NULL,
    contenu           TEXT NOT NULL,
    date_creation     TEXT NOT NULL,
    date_modification TEXT NOT NULL,
    FOREIGN KEY(memo_id) REFERENCES MEMO_ENTETE(id)
);
"@) | Out-Null
        }
        if (-not $this.Db.TableExists("MEMO_INFO")) {
            $this.Db.Query(@"
CREATE TABLE MEMO_INFO (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    memo_id INTEGER NOT NULL,
    cle     TEXT NOT NULL,
    valeur  TEXT,
    FOREIGN KEY(memo_id) REFERENCES MEMO_ENTETE(id)
);
"@) | Out-Null
        }
        # Reservee a une evolution future : aucun ecran ne l'exploite pour l'instant.
        if (-not $this.Db.TableExists("MEMO_LIGNE_INFO")) {
            $this.Db.Query(@"
CREATE TABLE MEMO_LIGNE_INFO (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    ligne_id INTEGER NOT NULL,
    cle      TEXT NOT NULL,
    valeur   TEXT,
    FOREIGN KEY(ligne_id) REFERENCES MEMO_LIGNE(id)
);
"@) | Out-Null
        }
    }

    static [string] Now() {
        return (Get-Date -AsUTC).ToString("o")
    }

    # --- MEMO_ENTETE ---

    [int] CreateMemo([string] $titre) {
        $now = [MemoStore]::Now()
        $this.Db.Query(
            "INSERT INTO MEMO_ENTETE (titre, date_creation, date_modification) VALUES (@t, @d, @d);",
            @{ t = $titre; d = $now }
        ) | Out-Null
        $row = $this.Db.Query("SELECT last_insert_rowid() AS id;") | Select-Object -First 1
        return [int] $row.id
    }

    [object[]] GetMemoListe() {
        $rows = $this.Db.Query("SELECT id, titre, date_creation, date_modification FROM MEMO_ENTETE ORDER BY date_modification DESC;")
        if ($null -eq $rows) { return @() }
        return @($rows)
    }

    [object] GetMemo([int] $memoId) {
        $rows = $this.Db.Query("SELECT id, titre, date_creation, date_modification FROM MEMO_ENTETE WHERE id = @id;", @{ id = $memoId })
        return $rows | Select-Object -First 1
    }

    [void] TouchMemo([int] $memoId) {
        $this.Db.Query(
            "UPDATE MEMO_ENTETE SET date_modification = @d WHERE id = @id;",
            @{ d = [MemoStore]::Now(); id = $memoId }
        ) | Out-Null
    }

    [void] UpdateTitre([int] $memoId, [string] $titre) {
        $this.Db.Query(
            "UPDATE MEMO_ENTETE SET titre = @t, date_modification = @d WHERE id = @id;",
            @{ t = $titre; d = [MemoStore]::Now(); id = $memoId }
        ) | Out-Null
    }

    [void] DeleteMemo([int] $memoId) {
        $this.Db.Query(
            "DELETE FROM MEMO_LIGNE_INFO WHERE ligne_id IN (SELECT id FROM MEMO_LIGNE WHERE memo_id = @id);",
            @{ id = $memoId }
        ) | Out-Null
        $this.Db.Query("DELETE FROM MEMO_LIGNE WHERE memo_id = @id;", @{ id = $memoId }) | Out-Null
        $this.Db.Query("DELETE FROM MEMO_INFO WHERE memo_id = @id;", @{ id = $memoId }) | Out-Null
        $this.Db.Query("DELETE FROM MEMO_ENTETE WHERE id = @id;", @{ id = $memoId }) | Out-Null
    }

    # --- MEMO_LIGNE ---

    [object[]] GetLignes([int] $memoId) {
        $rows = $this.Db.Query("SELECT id, contenu FROM MEMO_LIGNE WHERE memo_id = @id ORDER BY id ASC;", @{ id = $memoId })
        if ($null -eq $rows) { return @() }
        return @($rows)
    }

    [void] AddLigne([int] $memoId, [string] $contenu) {
        $now = [MemoStore]::Now()
        $this.Db.Query(
            "INSERT INTO MEMO_LIGNE (memo_id, contenu, date_creation, date_modification) VALUES (@m, @c, @d, @d);",
            @{ m = $memoId; c = $contenu; d = $now }
        ) | Out-Null
        $this.TouchMemo($memoId)
    }

    [void] UpdateLigne([int] $ligneId, [string] $contenu) {
        $row = $this.Db.Query("SELECT memo_id FROM MEMO_LIGNE WHERE id = @id;", @{ id = $ligneId }) | Select-Object -First 1
        $this.Db.Query(
            "UPDATE MEMO_LIGNE SET contenu = @c, date_modification = @d WHERE id = @id;",
            @{ c = $contenu; d = [MemoStore]::Now(); id = $ligneId }
        ) | Out-Null
        if ($row) { $this.TouchMemo([int] $row.memo_id) }
    }

    [void] DeleteLigne([int] $ligneId) {
        $row = $this.Db.Query("SELECT memo_id FROM MEMO_LIGNE WHERE id = @id;", @{ id = $ligneId }) | Select-Object -First 1
        $this.Db.Query("DELETE FROM MEMO_LIGNE_INFO WHERE ligne_id = @id;", @{ id = $ligneId }) | Out-Null
        $this.Db.Query("DELETE FROM MEMO_LIGNE WHERE id = @id;", @{ id = $ligneId }) | Out-Null
        if ($row) { $this.TouchMemo([int] $row.memo_id) }
    }

    # --- MEMO_INFO ---

    [object[]] GetInfos([int] $memoId) {
        $rows = $this.Db.Query("SELECT id, cle, valeur FROM MEMO_INFO WHERE memo_id = @id ORDER BY id ASC;", @{ id = $memoId })
        if ($null -eq $rows) { return @() }
        return @($rows)
    }

    [void] AddInfo([int] $memoId, [string] $cle, [string] $valeur) {
        $this.Db.Query(
            "INSERT INTO MEMO_INFO (memo_id, cle, valeur) VALUES (@m, @c, @v);",
            @{ m = $memoId; c = $cle; v = $valeur }
        ) | Out-Null
        $this.TouchMemo($memoId)
    }

    [void] UpdateInfo([int] $infoId, [string] $valeur) {
        $row = $this.Db.Query("SELECT memo_id FROM MEMO_INFO WHERE id = @id;", @{ id = $infoId }) | Select-Object -First 1
        $this.Db.Query("UPDATE MEMO_INFO SET valeur = @v WHERE id = @id;", @{ v = $valeur; id = $infoId }) | Out-Null
        if ($row) { $this.TouchMemo([int] $row.memo_id) }
    }

    [void] DeleteInfo([int] $infoId) {
        $row = $this.Db.Query("SELECT memo_id FROM MEMO_INFO WHERE id = @id;", @{ id = $infoId }) | Select-Object -First 1
        $this.Db.Query("DELETE FROM MEMO_INFO WHERE id = @id;", @{ id = $infoId }) | Out-Null
        if ($row) { $this.TouchMemo([int] $row.memo_id) }
    }

    # --- Rappels (MEMO_INFO avec cle = 'RAPPEL') ---

    # Un seul rappel actif par memo : remplace l'eventuel rappel existant.
    [void] SetRappel([int] $memoId, [string] $valeur) {
        $existant = $this.Db.Query(
            "SELECT id FROM MEMO_INFO WHERE memo_id = @m AND cle = 'RAPPEL';",
            @{ m = $memoId }
        ) | Select-Object -First 1

        if ($existant) {
            $this.UpdateInfo([int] $existant.id, $valeur)
        }
        else {
            $this.AddInfo($memoId, "RAPPEL", $valeur)
        }
    }

    [object] GetRappel([int] $memoId) {
        $row = $this.Db.Query(
            "SELECT id, valeur FROM MEMO_INFO WHERE memo_id = @m AND cle = 'RAPPEL';",
            @{ m = $memoId }
        ) | Select-Object -First 1
        return $row
    }

    # Tous les memos portant un rappel (echu ou a venir), du plus eloigne dans le
    # futur au plus en retard : les rappels les plus prioritaires (les plus en
    # retard) sont ainsi affiches en dernier, visibles en bas du terminal apres
    # defilement d'une longue liste.
    [object[]] GetTousLesRappels() {
        $rows = $this.Db.Query(
            "SELECT e.id AS memo_id, e.titre AS titre, i.valeur AS date_rappel " +
            "FROM MEMO_INFO i " +
            "JOIN MEMO_ENTETE e ON e.id = i.memo_id " +
            "WHERE i.cle = 'RAPPEL' " +
            "ORDER BY i.valeur DESC;"
        )
        if ($null -eq $rows) { return @() }
        return @($rows)
    }

    # Memos dont le rappel est echu uniquement (valeur <= maintenant),
    # du plus recent (le moins en retard) au plus ancien (le plus en retard).
    [object[]] GetRappelsEchus() {
        $now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
        $rows = $this.Db.Query(
            "SELECT e.id AS memo_id, e.titre AS titre, i.valeur AS date_rappel " +
            "FROM MEMO_INFO i " +
            "JOIN MEMO_ENTETE e ON e.id = i.memo_id " +
            "WHERE i.cle = 'RAPPEL' AND i.valeur <= @now " +
            "ORDER BY i.valeur DESC;",
            @{ now = $now }
        )
        if ($null -eq $rows) { return @() }
        return @($rows)
    }
}

# ============================================================
# Rendu synthwave / cyberpunk (Write-Host uniquement, pas d'emoji)
# ============================================================
class MemoRenderer {

    # Cadre d'entete generique : largeur calculee dynamiquement a partir du
    # texte reellement affiche (meme principe que Menu.Render() du core menu),
    # pour garantir un alignement correct du cadre quel que soit le titre.
    static [void] RenderBox([string] $title) {
        $minWidth = 40
        $width = [math]::Max($minWidth, $title.Length + 4)
        $line = "═" * $width

        Write-Host ""
        Write-Host "  ╔$line╗" -ForegroundColor Magenta
        Write-Host "  ║ " -ForegroundColor Magenta -NoNewline
        Write-Host $title.PadRight($width - 1) -ForegroundColor Cyan -NoNewline
        Write-Host "║" -ForegroundColor Magenta
        Write-Host "  ╚$line╝" -ForegroundColor Magenta
        Write-Host ""
    }

    static [string] FormatDate([string] $isoDate) {
        try {
            $d = [datetime]::Parse($isoDate, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
            return $d.ToLocalTime().ToString("yyyy-MM-dd HH:mm")
        }
        catch {
            return $isoDate
        }
    }

    # Les rappels sont stockes au format triable "yyyy-MM-dd HH:mm" (heure locale).
    # Affichage utilisateur au format "dd/MM/yyyy HH:mm".
    static [string] FormatRappel([string] $valeur) {
        try {
            $d = [datetime]::ParseExact($valeur, "yyyy-MM-dd HH:mm", $null)
            return $d.ToString("dd/MM/yyyy HH:mm")
        }
        catch {
            return $valeur
        }
    }

    static [void] RenderSeparator() {
        Write-Host "  ──────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
    }

    static [void] RenderListeMemos([object[]] $memos) {
        [MemoRenderer]::RenderBox("CONSULTER LES MEMOS")
        [MemoRenderer]::RenderSeparator()

        if (@($memos).Count -eq 0) {
            Write-Host "  (( aucun memo enregistre pour le moment ))" -ForegroundColor DarkGray
        }
        else {
            Write-Host ("  {0,-5} {1,-35} {2}" -f "ID", "Titre", "Cree le") -ForegroundColor DarkMagenta
            foreach ($m in $memos) {
                $titre = [string] $m.titre
                if ($titre.Length -gt 33) { $titre = $titre.Substring(0, 30) + "..." }
                Write-Host ("  #{0,-4} " -f $m.id) -ForegroundColor Yellow -NoNewline
                Write-Host ("{0,-35} " -f $titre) -ForegroundColor White -NoNewline
                Write-Host ([MemoRenderer]::FormatDate($m.date_creation)) -ForegroundColor DarkCyan
            }
        }

        [MemoRenderer]::RenderSeparator()
        Write-Host "  [ ID ] Afficher   " -ForegroundColor Green -NoNewline
        Write-Host "[ S ] Supprimer   "    -ForegroundColor Red -NoNewline
        Write-Host "[ M ] Modifier   "     -ForegroundColor Yellow -NoNewline
        Write-Host "[ I ] Informations"    -ForegroundColor Magenta
        Write-Host "  [ Autre touche ] Retour" -ForegroundColor DarkGray
        [MemoRenderer]::RenderSeparator()
    }

    static [void] RenderMemoDetail([object] $memo, [object[]] $lignes, [object] $rappel) {
        [MemoRenderer]::RenderBox("DETAIL DU MEMO")
        Write-Host "  Titre : " -ForegroundColor DarkMagenta -NoNewline
        Write-Host $memo.titre -ForegroundColor Cyan
        Write-Host "  Cree le : " -ForegroundColor DarkMagenta -NoNewline
        Write-Host ([MemoRenderer]::FormatDate($memo.date_creation)) -ForegroundColor White -NoNewline
        Write-Host "   Modifie le : " -ForegroundColor DarkMagenta -NoNewline
        Write-Host ([MemoRenderer]::FormatDate($memo.date_modification)) -ForegroundColor White
        if ($null -ne $rappel) {
            Write-Host "  Rappel : " -ForegroundColor DarkMagenta -NoNewline
            Write-Host ([MemoRenderer]::FormatRappel($rappel.valeur)) -ForegroundColor Yellow
        }
        [MemoRenderer]::RenderSeparator()

        if (@($lignes).Count -eq 0) {
            Write-Host "  (( memo vide, aucune ligne ))" -ForegroundColor DarkGray
        }
        else {
            $num = 1
            foreach ($l in $lignes) {
                Write-Host ("  {0,3}. " -f $num) -ForegroundColor DarkCyan -NoNewline
                Write-Host $l.contenu -ForegroundColor White
                $num++
            }
        }
        [MemoRenderer]::RenderSeparator()
        Write-Host "  [ I ] Informations du memo   " -ForegroundColor Magenta -NoNewline
        Write-Host "[ R ] Rappel   "                 -ForegroundColor Yellow -NoNewline
        Write-Host "[ Autre touche ] Retour a la liste" -ForegroundColor DarkGray
        [MemoRenderer]::RenderSeparator()
    }

    static [void] RenderMemoEdition([object] $memo, [object[]] $lignes) {
        [MemoRenderer]::RenderBox("MODIFICATION DU MEMO")
        Write-Host "  Titre : " -ForegroundColor DarkMagenta -NoNewline
        Write-Host $memo.titre -ForegroundColor Cyan
        [MemoRenderer]::RenderSeparator()

        if (@($lignes).Count -eq 0) {
            Write-Host "  (( memo vide, aucune ligne ))" -ForegroundColor DarkGray
        }
        else {
            $num = 1
            foreach ($l in $lignes) {
                Write-Host ("  {0,3}. " -f $num) -ForegroundColor DarkCyan -NoNewline
                Write-Host $l.contenu -ForegroundColor White
                $num++
            }
        }
        [MemoRenderer]::RenderSeparator()
        Write-Host "  [ numero ] Modifier la ligne   " -ForegroundColor Cyan -NoNewline
        Write-Host "[ A ] Ajouter   "    -ForegroundColor Green -NoNewline
        Write-Host "[ D ] Supprimer"     -ForegroundColor Red
        Write-Host "  [ T ] Modifier le titre   " -ForegroundColor Yellow -NoNewline
        Write-Host "[ Q ] Retour"               -ForegroundColor DarkGray
        [MemoRenderer]::RenderSeparator()
    }

    static [void] RenderInfos([object] $memo, [object[]] $infos) {
        [MemoRenderer]::RenderBox("INFORMATIONS")
        Write-Host "  Memo : " -ForegroundColor DarkMagenta -NoNewline
        Write-Host $memo.titre -ForegroundColor Cyan
        [MemoRenderer]::RenderSeparator()

        if (@($infos).Count -eq 0) {
            Write-Host "  (( aucune information enregistree ))" -ForegroundColor DarkGray
        }
        else {
            foreach ($i in $infos) {
                Write-Host ("  #{0,-4} " -f $i.id) -ForegroundColor Yellow -NoNewline
                Write-Host "$($i.cle)" -ForegroundColor Cyan -NoNewline
                Write-Host " -> " -ForegroundColor DarkGray -NoNewline
                Write-Host "$($i.valeur)" -ForegroundColor White
            }
        }
        [MemoRenderer]::RenderSeparator()
        Write-Host "  [ A ] Ajouter   " -ForegroundColor Green -NoNewline
        Write-Host "[ #id ] Modifier (ex: #3)   " -ForegroundColor Yellow -NoNewline
        Write-Host "[ -#id ] Supprimer (ex: -3)" -ForegroundColor Red
        Write-Host "  [ Autre touche ] Retour" -ForegroundColor DarkGray
        [MemoRenderer]::RenderSeparator()
    }

    static [void] RenderRappels([object[]] $rappels) {
        [MemoRenderer]::RenderBox("VOIR LES RAPPELS")

        if (@($rappels).Count -eq 0) {
            Write-Host "  (( aucun rappel programme ))" -ForegroundColor DarkGray
        }
        else {
            $now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
            foreach ($r in $rappels) {
                $estEchu = $r.date_rappel -le $now
                $couleurDate = if ($estEchu) { "Red" } else { "Cyan" }

                Write-Host ("  {0}  " -f [MemoRenderer]::FormatRappel($r.date_rappel)) -ForegroundColor $couleurDate -NoNewline
                Write-Host ": " -ForegroundColor DarkGray -NoNewline
                Write-Host "$($r.titre) " -ForegroundColor White -NoNewline
                Write-Host "[#$($r.memo_id)]" -ForegroundColor Yellow
            }
        }
        [MemoRenderer]::RenderSeparator()
    }

    # Affichage compact, sans cadre ni pause utilisateur : une ligne de texte
    # brut par memo en rappel echu. Destine a un usage non interactif
    # (fonction standalone, appel depuis un script de demarrage/welcome).
    static [void] RenderRappelsEchusCompact([object[]] $rappels) {
        Write-Host "~ Rappels echus : ~" -ForegroundColor Magenta

        if (@($rappels).Count -eq 0) {
            Write-Host "  (( aucun rappel echu ))" -ForegroundColor DarkGray
            return
        }

        foreach ($r in $rappels) {
            Write-Host ("  {0}  " -f [MemoRenderer]::FormatRappel($r.date_rappel)) -ForegroundColor Red -NoNewline
            Write-Host ": " -ForegroundColor DarkGray -NoNewline
            Write-Host "$($r.titre) " -ForegroundColor White -NoNewline
            Write-Host "[#$($r.memo_id)]" -ForegroundColor Yellow
        }
    }
}

# ============================================================
# Orchestration des ecrans (boucles de saisie Read-Host)
# ============================================================
class MemoApp {

    static [void] CreerMemo() {
        $store = [MemoStore]::GetInstance()

        [MemoRenderer]::RenderBox("CREER UN MEMO")
        [MemoRenderer]::RenderSeparator()

        $titre = Read-Host "  Titre du memo"
        $memoId = $store.CreateMemo($titre)

        Write-Host ""
        Write-Host "  Saisissez les lignes du memo. Tapez " -ForegroundColor DarkGray -NoNewline
        Write-Host "!Q" -ForegroundColor Yellow -NoNewline
        Write-Host " pour terminer." -ForegroundColor DarkGray
        Write-Host ""

        while ($true) {
            $ligne = Read-Host "  Ligne"
            if ($ligne -eq "!Q") { break }
            $store.AddLigne($memoId, $ligne)
        }

        Write-Host ""
        Write-Host "  Memo cree (#$memoId) !" -ForegroundColor Green
        Start-Sleep -Milliseconds 800
    }

    static [void] ConsulterMemos() {
        $store = [MemoStore]::GetInstance()
        $continue = $true

        while ($continue) {
            $memos = $store.GetMemoListe()
            [MemoRenderer]::RenderListeMemos($memos)

            Write-Host "  Votre choix" -ForegroundColor Yellow -NoNewline
            $choice = Read-Host " "

            if ([string]::IsNullOrWhiteSpace($choice)) {
                $continue = $false
                continue
            }

            $memoId = 0
            if ([int]::TryParse($choice, [ref] $memoId)) {
                $memo = $store.GetMemo($memoId)
                if ($null -eq $memo) {
                    Write-Host "  Memo introuvable." -ForegroundColor Red
                    Start-Sleep -Milliseconds 800
                }
                else {
                    [MemoApp]::AfficherMemo($memoId)
                }
                continue
            }

            switch ($choice.ToUpper()) {
                "S" { [MemoApp]::SupprimerMemoDepuisListe() }
                "M" { [MemoApp]::ModifierMemoDepuisListe() }
                "I" { [MemoApp]::InfosMemoDepuisListe() }
                default { $continue = $false }
            }
        }
    }

    static [void] SupprimerMemoDepuisListe() {
        $idStr = Read-Host "  ID du memo a supprimer"
        $memoId = 0
        if (-not [int]::TryParse($idStr, [ref] $memoId)) {
            Write-Host "  ID invalide." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            return
        }
        [MemoApp]::SupprimerMemo($memoId)
    }

    static [void] ModifierMemoDepuisListe() {
        $idStr = Read-Host "  ID du memo a modifier"
        $memoId = 0
        if (-not [int]::TryParse($idStr, [ref] $memoId)) {
            Write-Host "  ID invalide." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            return
        }
        [MemoApp]::ModifierMemo($memoId)
    }

    static [void] InfosMemoDepuisListe() {
        $idStr = Read-Host "  ID du memo"
        $memoId = 0
        if (-not [int]::TryParse($idStr, [ref] $memoId)) {
            Write-Host "  ID invalide." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            return
        }
        [MemoApp]::GererInfos($memoId)
    }

    static [void] AfficherMemo([int] $memoId) {
        $store = [MemoStore]::GetInstance()
        $continue = $true

        while ($continue) {
            $memo = $store.GetMemo($memoId)
            if ($null -eq $memo) { return }

            $lignes = $store.GetLignes($memoId)
            $rappel = $store.GetRappel($memoId)
            [MemoRenderer]::RenderMemoDetail($memo, $lignes, $rappel)

            Write-Host "  Votre choix" -ForegroundColor Yellow -NoNewline
            $choice = Read-Host " "

            switch ($choice.ToUpper()) {
                "I" { [MemoApp]::GererInfos($memoId) }
                "R" { [MemoApp]::PoserRappel($memoId) }
                default { $continue = $false }
            }
        }
    }

    static [void] PoserRappel([int] $memoId) {
        $store = [MemoStore]::GetInstance()
        $today = Get-Date

        Write-Host ""
        Write-Host "  ~ Poser un rappel ~" -ForegroundColor Yellow
        $dateStr = Read-Host "  Date du rappel (jj/mm/aaaa)"

        $dateChoisie = $today.Date
        $dateInvalide = $false
        if ([string]::IsNullOrWhiteSpace($dateStr)) {
            $dateInvalide = $true
        }
        else {
            $parsed = [datetime]::MinValue
            if ([datetime]::TryParseExact($dateStr, "dd/MM/yyyy", $null, [System.Globalization.DateTimeStyles]::None, [ref] $parsed)) {
                $dateChoisie = $parsed.Date
            }
            else {
                $dateInvalide = $true
            }
        }

        $heureStr = Read-Host "  Heure du rappel (hh:mm, vide = 00:00)"

        $heureChoisie = [timespan]::Zero
        $heureInvalide = $false
        if (-not [string]::IsNullOrWhiteSpace($heureStr)) {
            $parsedHeure = [datetime]::MinValue
            if ([datetime]::TryParseExact($heureStr, "HH:mm", $null, [System.Globalization.DateTimeStyles]::None, [ref] $parsedHeure)) {
                $heureChoisie = $parsedHeure.TimeOfDay
            }
            else {
                $heureInvalide = $true
            }
        }

        $dateTimeFinal = $dateChoisie.Add($heureChoisie)
        $valeur = $dateTimeFinal.ToString("yyyy-MM-dd HH:mm")

        $store.SetRappel($memoId, $valeur)

        Write-Host ""
        if ($dateInvalide -or $heureInvalide) {
            Write-Host "  Date/heure invalide ou vide : rappel pose a la date/heure du jour ($($dateTimeFinal.ToString('dd/MM/yyyy HH:mm')))." -ForegroundColor Red
        }
        else {
            Write-Host "  Rappel pose au $($dateTimeFinal.ToString('dd/MM/yyyy HH:mm'))." -ForegroundColor Green
        }
        Start-Sleep -Milliseconds 900
    }

    static [void] SupprimerMemo([int] $memoId) {
        $store = [MemoStore]::GetInstance()
        $memo = $store.GetMemo($memoId)
        if ($null -eq $memo) {
            Write-Host "  Memo introuvable." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            return
        }

        Write-Host ""
        Write-Host "  Supprimer le memo '$($memo.titre)' (#$memoId) ?" -ForegroundColor Red
        $confirm = Read-Host "  Confirmer [O/N]"
        if ($confirm.ToUpper() -eq "O") {
            $store.DeleteMemo($memoId)
            Write-Host "  Memo supprime." -ForegroundColor Green
        }
        else {
            Write-Host "  Suppression annulee." -ForegroundColor DarkGray
        }
        Start-Sleep -Milliseconds 800
    }

    static [void] ModifierMemo([int] $memoId) {
        $store = [MemoStore]::GetInstance()
        $continue = $true

        while ($continue) {
            $memo = $store.GetMemo($memoId)
            if ($null -eq $memo) { return }

            $lignes = $store.GetLignes($memoId)
            [MemoRenderer]::RenderMemoEdition($memo, $lignes)

            Write-Host "  Votre choix" -ForegroundColor Yellow -NoNewline
            $choice = Read-Host " "

            $numLigne = 0
            if ([int]::TryParse($choice, [ref] $numLigne) -and $numLigne -ge 1 -and $numLigne -le @($lignes).Count) {
                $cible = $lignes[$numLigne - 1]
                Write-Host "  Contenu actuel : " -ForegroundColor DarkGray -NoNewline
                Write-Host $cible.contenu -ForegroundColor White
                $nouveauContenu = Read-Host "  Nouveau contenu"
                $store.UpdateLigne([int] $cible.id, $nouveauContenu)
                continue
            }

            switch ($choice.ToUpper()) {
                "A" {
                    $contenu = Read-Host "  Contenu de la nouvelle ligne"
                    $store.AddLigne($memoId, $contenu)
                }
                "D" {
                    $numStr = Read-Host "  Numero de la ligne a supprimer"
                    $num = 0
                    if ([int]::TryParse($numStr, [ref] $num) -and $num -ge 1 -and $num -le @($lignes).Count) {
                        $cible = $lignes[$num - 1]
                        $store.DeleteLigne([int] $cible.id)
                    }
                    else {
                        Write-Host "  Numero de ligne invalide." -ForegroundColor Red
                        Start-Sleep -Milliseconds 800
                    }
                }
                "T" {
                    $nouveauTitre = Read-Host "  Nouveau titre"
                    $store.UpdateTitre($memoId, $nouveauTitre)
                }
                default { $continue = $false }
            }
        }
    }

    static [void] GererInfos([int] $memoId) {
        $store = [MemoStore]::GetInstance()
        $continue = $true

        while ($continue) {
            $memo = $store.GetMemo($memoId)
            if ($null -eq $memo) { return }

            $infos = $store.GetInfos($memoId)
            [MemoRenderer]::RenderInfos($memo, $infos)

            Write-Host "  Votre choix" -ForegroundColor Yellow -NoNewline
            $choice = Read-Host " "

            if ($choice.ToUpper() -eq "A") {
                $cle = Read-Host "  Cle"
                $valeur = Read-Host "  Valeur"
                $store.AddInfo($memoId, $cle, $valeur)
                continue
            }

            if ($choice.StartsWith("-")) {
                $idStr = $choice.Substring(1).TrimStart("#")
                $infoId = 0
                if ([int]::TryParse($idStr, [ref] $infoId)) {
                    $store.DeleteInfo($infoId)
                }
                else {
                    Write-Host "  ID invalide." -ForegroundColor Red
                    Start-Sleep -Milliseconds 800
                }
                continue
            }

            $idStr2 = $choice.TrimStart("#")
            $infoId2 = 0
            if ([int]::TryParse($idStr2, [ref] $infoId2)) {
                $valeur2 = Read-Host "  Nouvelle valeur"
                $store.UpdateInfo($infoId2, $valeur2)
                continue
            }

            $continue = $false
        }
    }

    # Ecran autonome : liste des memos dont le rappel est echu.
    # Appelable depuis le menu principal ou en standalone (fonction memoRappels).
    static [void] VoirRappels() {
        $store = [MemoStore]::GetInstance()
        $rappels = $store.GetTousLesRappels()
        [MemoRenderer]::RenderRappels($rappels)
        Read-Host "  [Entree pour continuer]" | Out-Null
    }

    # Affichage compact et non interactif des rappels echus uniquement
    # (aucun Read-Host, aucun cadre) : appelable en standalone depuis le
    # terminal (fonction memoRappelsEchus) ou un script (ex: welcome.ps1).
    static [void] ListerRappelsEchus() {
        $store = [MemoStore]::GetInstance()
        $rappels = $store.GetRappelsEchus()
        [MemoRenderer]::RenderRappelsEchusCompact($rappels)
    }
}

# ============================================================
# Menu principal de l'app (core menu : classe Menu)
# ============================================================
class MemoMenu {
    static [string] Main() {
        $menu = @{
            title    = "~~ M E M O ~~"
            subtitle = "Que souhaitez-vous faire ?"
            color    = "Magenta"
            options  = @(
                @{ key = "1"; label = "Consulter les memos"; command = "[MemoApp]::ConsulterMemos()"; color = "Cyan" },
                @{ key = "2"; label = "Creer un memo"; command = "[MemoApp]::CreerMemo()"; color = "Green" },
                @{ key = "R"; label = "Voir les rappels"; command = "[MemoApp]::VoirRappels()"; color = "Yellow" },
                @{ key = "Q"; label = "Quitter"; command = "exit"; color = "Gray" }
            )
        }
        return $menu | ConvertTo-Json -Depth 5
    }
}
