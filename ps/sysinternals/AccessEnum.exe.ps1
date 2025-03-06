# DESCRIPTION: Affiche les permissions sur les dossiers et le registre.

$url = "https://live.sysinternals.com/AccessEnum.exe"
$tempFile = "$env:TEMP\AccessEnum.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de AccessEnum.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ AccessEnum.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ AccessEnum.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger AccessEnum.exe."
}
