# DESCRIPTION: Restaure les objets Active Directory supprimés.

$url = "https://live.sysinternals.com/adrestore64.exe"
$tempFile = "$env:TEMP\adrestore64.exe"

# Vérifier si un fichier existe déjà et le supprimer
if (Test-Path -Path $tempFile) {
    Remove-Item -Path $tempFile -Force
}

# Télécharger l'outil
Write-Host "🔄 Téléchargement de adrestore64.exe..."
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Vérifier si le fichier a bien été téléchargé
if (Test-Path -Path $tempFile) {
    Write-Host "✅ adrestore64.exe téléchargé avec succès !"
    
    # Lancer l'outil
    Start-Process -FilePath $tempFile -Wait
    
    # Supprimer le fichier après fermeture
    Remove-Item -Path $tempFile -Force
    Write-Host "🗑️ adrestore64.exe supprimé après exécution."
} else {
    Write-Host "❌ Erreur : Impossible de télécharger adrestore64.exe."
}
