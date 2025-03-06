# DESCRIPTION: Surveille l’activité des ports série et parallèle.

$url = "https://live.sysinternals.com/portmon.exe"
$tempFile = "$env:TEMP\portmon.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de portmon.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ portmon.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ portmon.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger portmon.exe."
}
