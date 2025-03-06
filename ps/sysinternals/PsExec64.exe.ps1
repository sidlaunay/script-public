# DESCRIPTION: Exécute des processus sur un ordinateur distant.

$url = "https://live.sysinternals.com/PsExec64.exe"
$tempFile = "$env:TEMP\PsExec64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de PsExec64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ PsExec64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ PsExec64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger PsExec64.exe."
}
