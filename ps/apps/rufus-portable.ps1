# DESCRIPTION: Rufus Portable créer des média USB démarrables

# Définir l'URL de téléchargement de Rufus Portable
$url = "https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6p.exe"

# Définir le chemin du répertoire temporaire
$tempDir = "$env:TEMP\RufusPortable"
$exePath = "$tempDir\rufus.exe"

# Vérifier si le dossier temporaire existe et le supprimer proprement
if (Test-Path -Path $tempDir) {
    try {
        Get-Process -Name "rufus" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 1
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠ Impossible de supprimer $tempDir immédiatement. Essai après exécution..."
    }
}

# Recréer le répertoire temporaire
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Télécharger Rufus Portable
Invoke-WebRequest -Uri $url -OutFile $exePath

# Exécuter Rufus Portable
try {
    Start-Process -FilePath $exePath -NoNewWindow -Wait
} catch {
    Write-Host "⚠ Erreur lors de l'exécution de Rufus : $_"
}

# Attendre quelques secondes pour s'assurer que le programme est bien terminé
Start-Sleep -Seconds 2

# Vérifier si Rufus est encore en cours d'exécution avant suppression
$process = Get-Process -Name "rufus" -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name "rufus" -Force
    Start-Sleep -Seconds 1
}

# Supprimer les fichiers temporaires après exécution
try {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Dossier temporaire supprimé : $tempDir"
} catch {
    Write-Host "⚠️ Erreur lors de la suppression des fichiers temporaires : $_"
}
