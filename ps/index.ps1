# =============================
# Configuration
# =============================
$RepoBaseUrl = "https://dev.slaunay.com/ps"

# =============================
# Charger les fichiers avec description
# =============================
Write-Host "Chargement de la liste des scripts disponibles..."
try {
    $FileList = Invoke-RestMethod -Uri "$RepoBaseUrl/index.txt"
} catch {
    Write-Host "ERREUR : Impossible de charger la liste des scripts depuis $RepoBaseUrl/index.txt"
    exit
}

if (-not $FileList) {
    Write-Host "Aucun script trouvé sur le serveur."
    exit
}

# =============================
# Construire la liste avec descriptions
# =============================
$Scripts = @()
$FileList -split "`n" | ForEach-Object {
    if ($_ -match "(.+?)\|(.+)") {
        $Scripts += [PSCustomObject]@{
            Path = $matches[1]
            Description = $matches[2]
        }
    }
}

if ($Scripts.Count -eq 0) {
    Write-Host "Aucun script PowerShell trouvé."
    exit
}

# =============================
# Affichage du menu
# =============================
Write-Host "`nListe des scripts disponibles :"
for ($i = 0; $i -lt $Scripts.Count; $i++) {
    Write-Host "$($i + 1)) $($Scripts[$i].Path) - $($Scripts[$i].Description)"
}

Write-Host "`n0) Quitter"
$Choice = Read-Host "`nChoisissez un script à exécuter (1-$($Scripts.Count))"

if ($Choice -eq "0") {
    Write-Host "Fermeture du programme."
    exit
}

if ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $Scripts.Count) {
    $ScriptToRun = $Scripts[[int]$Choice - 1]
    Write-Host "▶️ Exécution du script : $($ScriptToRun.Path)"
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "$RepoBaseUrl/$($ScriptToRun.Path)")
    } catch {
        Write-Host "ERREUR : Impossible d'exécuter le script : $($_.Exception.Message)"
    }
} else {
    Write-Host "Choix invalide."
}







# 20.02.25 22.16
