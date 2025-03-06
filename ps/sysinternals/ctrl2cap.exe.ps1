# DESCRIPTION: Remappe la touche Caps Lock en touche Ctrl.

$url = "https://live.sysinternals.com/ctrl2cap.exe"
$tempFile = "$env:TEMP\ctrl2cap.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de ctrl2cap.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ ctrl2cap.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ ctrl2cap.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger ctrl2cap.exe."
}
