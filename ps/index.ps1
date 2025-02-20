Write-Host "=== Menu scripts PowerShell ==="
Write-Host

# URL de l'API GitHub pour lister le contenu du dossier ps/ de 'script-public'
$apiUrl = "https://api.github.com/repos/sidlaunay/script-public/contents/ps"

# On interroge l'API GitHub
$response = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing

# On garde uniquement les 'files', on exclut index.ps1 et index.html
# (ici, on prend tout ce qui est 'type = file', s'il y a des dossiers on les ignore)
$files = $response | Where-Object { 
    $_.type -eq 'file' -and 
    $_.name -notin 'index.ps1', 'index.html'
}

if ($files.Count -eq 0) {
    Write-Host "Aucun script disponible."
    return
}

# On affiche un menu numéroté
for ($i = 0; $i -lt $files.Count; $i++) {
    $n = $i + 1
    Write-Host "$n) $($files[$i].name)"
}

Write-Host
$choice = Read-Host "Tapez un numéro pour lancer le script (1-$($files.Count))"
if ([int]$choice -lt 1 -or [int]$choice -gt $files.Count) {
    Write-Host "Choix invalide."
    return
}

# On récupère le nom du fichier choisi
$selected = $files[[int]$choice - 1].name
Write-Host "Chargement de $selected ..."

# Exécution
iex (irm "https://dev.slaunay.com/ps/$selected")
