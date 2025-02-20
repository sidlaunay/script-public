# =============================
# Paramètres à personnaliser
# =============================
$User = "sidlaunay"
$Repo = "script-public"
$MainFolderPath = "ps"  # Le dossier de départ dans le repo
$RawBaseUrl = "https://dev.slaunay.com/ps"  # L'URL reverse-proxy vers GitHub
# =============================

function Browse-GitHubDirectory {
    param(
        [string]$GithubUser,
        [string]$GithubRepo,
        [string]$PathInRepo
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $headers = @{
        "User-Agent" = "SidLaunayPowerShellScript"
    }

    $apiUrl = "https://api.github.com/repos/$GithubUser/$GithubRepo/contents/$PathInRepo"
    Write-Host "`n--- Lecture du dossier '$PathInRepo' ---`nDEBUG: Appel API => $apiUrl"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    }
    catch {
        Write-Host "Erreur d'accès à l'API GitHub pour $apiUrl : $($_.Exception.Message)"
        return
    }

    # Debug
    Write-Host "`n=== DEBUG : Contenu brut renvoyé par l'API ==="
    try {
        $jsonDebug = $response | ConvertTo-Json -Depth 10
        Write-Host $jsonDebug
    }
    catch {
        Write-Host "Impossible de convertir en JSON. Réponse brute :"
        $response | Out-Host
    }
    Write-Host "=============================================`n"

    # Forcer en tableau s'il n'y a qu'un seul fichier
    if ($null -ne $response -and -not ($response -is [System.Collections.IEnumerable])) {
        Write-Host "DEBUG: Forcing single object into array..."
        $response = ,$response
    }

    # === Approche 1 ===
    # On essaie $_."type" dans Where-Object
    $directories = $response | Where-Object { $_."type" -eq 'dir' }
    $files       = $response | Where-Object { $_."type" -eq 'file' }

    # Si ça ne fonctionne pas (aucun résultat alors qu'on devrait), on tente Approche 2
    if (($directories.Count + $files.Count) -eq 0 -and $response) {
        Write-Host "DEBUG: 'Approche 1' n'a rien trouvé alors qu'on a un objet. Tentons 'Approche 2'..."
        $directories = @()
        $files       = @()

        foreach ($item in $response) {
            $valType = $item.PSObject.Properties["type"].Value
            if ($valType -eq "dir") {
                $directories += $item
            }
            elseif ($valType -eq "file") {
                $files += $item
            }
        }
    }

    if (($directories.Count + $files.Count) -eq 0) {
        Write-Host "Aucun sous-dossier ni fichier ici."
        return
    }

    # Construction du menu
    $menuItems = New-Object System.Collections.Generic.List[PSObject]
    foreach ($dir in $directories) {
        $menuItems.Add([PSCustomObject]@{ Type = "dir"; Name = $dir.name })
    }
    foreach ($f in $files) {
        $menuItems.Add([PSCustomObject]@{ Type = "file"; Name = $f.name })
    }

    Write-Host "Contenu de '$PathInRepo' :"
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        $num  = $i + 1
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
    if ($selectedItem.Type -eq "dir") {
        $subFolder = "$PathInRepo/$($selectedItem.Name)"
        Browse-GitHubDirectory -GithubUser $GithubUser -GithubRepo $GithubRepo -PathInRepo $subFolder
    }
    else {
        $fileName = $selectedItem.Name
        $fullPath = "$PathInRepo/$fileName"
        Write-Host "Chargement de $fullPath ..."
        iex (irm "$RawBaseUrl/$fullPath")
    }
}

Write-Host "=== Menu SLAUNAY script ==="
Browse-GitHubDirectory -GithubUser $User -GithubRepo $Repo -PathInRepo $MainFolderPath
