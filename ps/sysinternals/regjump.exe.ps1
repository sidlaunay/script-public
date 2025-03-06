# DESCRIPTION: Ouvre un chemin de registre directement dans l’éditeur de registre.

$url = "https://live.sysinternals.com/regjump.exe"
$tempFile = "$env:TEMP\regjump.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de regjump.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ regjump.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ regjump.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger regjump.exe."
}
