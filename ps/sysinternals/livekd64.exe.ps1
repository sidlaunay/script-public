# DESCRIPTION: Utilise un débogueur noyau sur un système en cours d’exécution.

$url = "https://live.sysinternals.com/livekd64.exe"
$tempFile = "$env:TEMP\livekd64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de livekd64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ livekd64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ livekd64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger livekd64.exe."
}
