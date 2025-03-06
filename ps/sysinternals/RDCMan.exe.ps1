# DESCRIPTION: Gère plusieurs connexions Bureau à Distance.

$url = "https://live.sysinternals.com/RDCMan.exe"
$tempFile = "$env:TEMP\RDCMan.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de RDCMan.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ RDCMan.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ RDCMan.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger RDCMan.exe."
}
