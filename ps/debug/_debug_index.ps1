# =============================
# Paramètres à personnaliser
# =============================
$User = "sidlaunay"
$Repo = "script-public"
$MainFolderPath = "ps"  # Le dossier de départ dans le repo
$RawBaseUrl = "https://dev.slaunay.com/ps"  # L'URL reverse-proxy vers GitHub (Nginx)
# =============================

function Browse-GitHubDirectory {
    param(
        [string]$GithubUser,
        [string]$GithubRepo,
        [string]$PathInRepo  # chemin relatif (ex: "ps", "ps/administration" etc.)
    )

    # -- Forcer le protocole TLS 1.2 pour éviter les soucis sur Windows anciens --
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # -- Définir un User-Agent explicite pour l'API GitHub --
    $headers = @{
        "User-Agent" = "SidLaunayPowerShellScript"
    }

    # 1) Construire l'URL de l'API GitHub
    $apiUrl = "https://api.github.com/repos/$GithubUser/$GithubRepo/contents/$PathInRepo"

    Write-Host "`n--- Lecture du dossier '$PathInRepo' ---`n"
    Write-Host "DEBUG: Appel API => $apiUrl"

    try {
        # 2) Appeler l'API (sans -UseBasicParsing)
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    }
    catch {
        Write-Host "Erreur d'accès à l'API GitHub pour $apiUrl : $($_.Exception.Message)"
        return
    }

    # -- DEBUG : Afficher le contenu brut renvoyé par l'API --
    Write-Host "`n=== DEBUG : Contenu brut renvoyé par l'API ==="
    try {
        # Convertir la réponse en JSON (si c'est un tableau d'objets) pour l'afficher joliment
        $jsonDebug = $response | ConvertTo-Json -Depth 10
        Write-Host $jsonDebug
    }
    catch {
        Write-Host "Impossible de convertir en JSON. Réponse brute :"
        $response | Out-Host
    }
    Write-Host "=============================================`n"

    # 3) Filtrer dossiers vs fichiers
    $directories = $response | Where-Object { $_.type -eq 'dir' }
    $files       = $response | Where-Object { $_.type -eq 'file' }

    # (Optionnel) Exclure index.ps1, index.html pour ne pas les lister
    # $files = $files | Where-Object { $_.name -notin 'index.ps1', 'index.html' }

    if (($directories.Count + $files.Count) -eq 0) {
        Write-Host "Aucun sous-dossier ni fichier ici."
        return
    }

    # 4) Construire un menu (dossiers + fichiers)
    $menuItems = New-Object System.Collections.Generic.List[PSObject]

    # Ajouter d'abord les dossiers
    foreach ($dir in $directories) {
        $menuItems.Add([PSCustomObject]@{
            Type = "dir"
            Name = $dir.name
        })
    }

    # Ensuite les fichiers
    foreach ($f in $files) {
        $menuItems.Add([PSCustomObject]@{
            Type = "file"
            Name = $f.name
        })
    }

    # 5) Afficher le menu
    Write-Host "Contenu de '$PathInRepo' :"
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        $num = $i + 1
        $type = $menuItems[$i].Type
        $name = $menuItems[$i].Name

        if ($type -eq "dir") {
            Write-Host "$num) [Dossier] $name"
        }
        else {
            Write-Host "$num) $name"
        }
    }

    Write-Host
    $choice = Read-Host "Tapez un numéro pour ouvrir un dossier ou exécuter un fichier (1-$($menuItems.Count)) - ou Q pour quitter"

    if ($choice -eq 'Q') {
        Write-Host "Quitter."
        return
    }

    if ([int]$choice -lt 1 -or [int]$choice -gt $menuItems.Count) {
        Write-Host "Choix invalide."
        return
    }

    $selectedItem = $menuItems[[int]$choice - 1]

    # 6) Action selon le type (dossier ou fichier)
    if ($selectedItem.Type -eq "dir") {
        # => On descend dans ce dossier
        $subFolder = "$PathInRepo/$($selectedItem.Name)"
        Browse-GitHubDirectory -GithubUser $GithubUser -GithubRepo $GithubRepo -PathInRepo $subFolder
    }
    else {
        # => C'est un fichier : on l'exécute
        $fileName = $selectedItem.Name
        $fullPath = "$PathInRepo/$fileName"  # ex: "ps/administration/printer.ps1"
        Write-Host "Chargement de $fullPath ..."

        # On télécharge et exécute via l'URL reverse-proxy (raw)
        iex (irm "$RawBaseUrl/$fullPath")
    }
}


# =========================
# Point d'entrée du script
# =========================
Write-Host "=== Menu SLAUNAY script ==="
Browse-GitHubDirectory -GithubUser $User -GithubRepo $Repo -PathInRepo $MainFolderPath
