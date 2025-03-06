# DESCRIPTION: Affiche les informations des fichiers chiffrés.

$url = "https://live.sysinternals.com/efsDump.exe"
$tempFile = "$env:TEMP\efsDump.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de efsDump.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ efsDump.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ efsDump.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger efsDump.exe."
}
