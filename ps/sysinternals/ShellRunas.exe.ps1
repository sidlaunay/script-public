# DESCRIPTION: Ajoute une option pour exécuter en tant qu’un autre utilisateur.

$url = "https://live.sysinternals.com/ShellRunas.exe"
$tempFile = "$env:TEMP\ShellRunas.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de ShellRunas.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ ShellRunas.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ ShellRunas.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger ShellRunas.exe."
}
