# DESCRIPTION: Modifie les mots de passe des comptes.

$url = "https://live.sysinternals.com/pspasswd64.exe"
$tempFile = "$env:TEMP\pspasswd64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de pspasswd64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ pspasswd64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ pspasswd64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger pspasswd64.exe."
}
