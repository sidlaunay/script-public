# DESCRIPTION: Affiche les utilisateurs connectés à une machine.

$url = "https://live.sysinternals.com/PsLoggedon64.exe"
$tempFile = "$env:TEMP\PsLoggedon64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de PsLoggedon64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ PsLoggedon64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ PsLoggedon64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger PsLoggedon64.exe."
}
