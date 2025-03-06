# DESCRIPTION: TCPView.exe
# Définir l'URL de téléchargement de Tcpview.exe depuis Sysinternals Live
$url = "https://live.sysinternals.com/Tcpview.exe"

# Définir le chemin du fichier temporaire
$tempFile = "$env:TEMP\Tcpview.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger Tcpview.exe
Write-Host "🔄 Téléchargement de Tcpview..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ Tcpview téléchargé avec succès !"
    
    # Lancer Tcpview
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture de Tcpview
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ Tcpview supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger Tcpview."
}
