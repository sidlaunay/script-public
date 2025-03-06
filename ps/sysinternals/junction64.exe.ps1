# DESCRIPTION: Crée des liens symboliques NTFS.

$url = "https://live.sysinternals.com/junction64.exe"
$tempFile = "$env:TEMP\junction64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de junction64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ junction64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ junction64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger junction64.exe."
}
