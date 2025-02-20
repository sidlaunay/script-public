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
        [string]$PathInRepo  # chemin relatif (ex: "ps", "ps/Administration" etc.)
    )

    # 1) Construire l'URL de l'API GitHub
    $apiUrl = "https://api.github.com/repos/$GithubUser/$GithubRepo/contents/$PathInRepo"

    # 2) Appeler l'API
    Write-Host "`n--- Lecture du dossier '$PathInRepo' ---`n"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
    }
    catch {
        Write-Host "Erreur d'accès à l'API GitHub pour $apiUrl : $($_.Exception.Message)"
        return
    }

    # Filtrer dossiers vs fichiers
    $directories = $response | Where-Object { $_.type -eq 'dir' }
    $files       = $response | Where-Object { $_.type -eq 'file' }

    # Exclure éventuellement index.ps1 / index.html si tu ne veux jamais les voir
    # $files = $files | Where-Object { $_.name -notin 'index.ps1', 'index.html' }

    if (($directories.Count + $files.Count) -eq 0) {
        Write-Host "Aucun sous-dossier ni fichier ici."
        return
    }

    # 3) Construire un menu
    #    On va faire une liste de tous les items (dossiers + fichiers).
    #    On les stocke dans un tableau [Item], où on garde le type et le nom.
    $menuItems = New-Object System.Collections.Generic.List[PSObject]

    # Ajouter d'abord les dossiers
    foreach ($dir in $directories) {
        $obj = [PSCustomObject]@{
            Type = "dir"
            Name = $dir.name
        }
        $menuItems.Add($obj)
    }

    # Ensuite les fichiers
    foreach ($f in $files) {
        $obj = [PSCustomObject]@{
            Type = "file"
            Name = $f.name
        }
        $menuItems.Add($obj)
    }

    # Afficher le menu
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        $num = $i + 1
        $type = $menuItems[$i].Type
        $name = $menuItems[$i].Name

        if ($type -eq "dir") {
            Write-Host "$num) [Dossier] $name"
        } else {
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

    # 4) Action selon le type
    if ($selectedItem.Type -eq "dir") {
        # => On descend dans ce dossier
        $subFolder = "$PathInRepo/$($selectedItem.Name)"
        Browse-GitHubDirectory -GithubUser $GithubUser -GithubRepo $GithubRepo -PathInRepo $subFolder
    }
    else {
        # => C'est un fichier: on l'exécute
        $fileName = $selectedItem.Name
        $fullPath = "$PathInRepo/$fileName"  # Ex: "ps/Administration/printer.ps1"
        Write-Host "Chargement de $fullPath ..."

        # On télécharge et exécute via l'URL (reverse-proxy)
        iex (irm "$RawBaseUrl/$fullPath")
    }
}

# =========================
# Point d'entrée du script
# =========================
Write-Host "=== Menu SLAUNAY script ==="
Browse-GitHubDirectory -GithubUser $User -GithubRepo $Repo -PathInRepo $MainFolderPath
