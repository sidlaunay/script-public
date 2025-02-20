# =============================
# Paramètres
# =============================
$RepoBaseUrl = "https://dev.slaunay.com/ps"

# =============================
# Récupération de la liste des fichiers
# =============================
Write-Host "🔄 Récupération de la liste des scripts disponibles..."
try {
    $FileList = Invoke-RestMethod -Uri "$RepoBaseUrl"
} catch {
    Write-Host "❌ ERREUR : Impossible de charger la liste des scripts. Vérifiez l'accès à $RepoBaseUrl"
    exit
}

if (-not $FileList) {
    Write-Host "❌ Aucun script trouvé sur le serveur."
    exit
}

$Scripts = $FileList -split "`n" | Where-Object { $_ -match "\.ps1$" }
if ($Scripts.Count -eq 0) {
    Write-Host "❌ Aucun script PowerShell trouvé."
    exit
}

# =============================
# Affichage du menu
# =============================
Write-Host "`n📜 Liste des scripts disponibles :"
for ($i = 0; $i -lt $Scripts.Count; $i++) {
    Write-Host "$($i+1)) $($Scripts[$i])"
}

Write-Host "`n🔙 Q) Quitter"
$Choice = Read-Host "`n📌 Choisissez un script à exécuter (1-$($Scripts.Count))"

if ($Choice -eq "Q") {
    Write-Host "👋 Fin du programme."
    exit
}

if ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $Scripts.Count) {
    $ScriptToRun = $Scripts[[int]$Choice - 1]
    Write-Host "▶️ Exécution du script : $ScriptToRun ..."
    Invoke-Expression (Invoke-RestMethod -Uri "$RepoBaseUrl/$ScriptToRun")
} else {
    Write-Host "❌ Choix invalide."
}



# 20.02.25 21.23
