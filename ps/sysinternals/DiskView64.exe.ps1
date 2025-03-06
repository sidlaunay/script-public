# DESCRIPTION: Affiche graphiquement la structure des secteurs d’un disque.

$url = "https://live.sysinternals.com/DiskView64.exe"
$tempFile = "$env:TEMP\DiskView64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de DiskView64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ DiskView64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ DiskView64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger DiskView64.exe."
}
