# DESCRIPTION: Génère une charge CPU pour les tests de performance.

$url = "https://live.sysinternals.com/CPUSTRES64.EXE"
$tempFile = "$env:TEMP\CPUSTRES64.EXE"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de CPUSTRES64.EXE..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ CPUSTRES64.EXE téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ CPUSTRES64.EXE supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger CPUSTRES64.EXE."
}
