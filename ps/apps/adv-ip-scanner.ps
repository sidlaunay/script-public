# DESCRIPTION: Advanced IP Scanner permet d'analyser le réseau local et de détecter les périphériques connectés

# Définir l'URL de téléchargement d'Advanced IP Scanner
$url = "https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe"

# Définir le chemin du répertoire temporaire
$tempDir = "$env:TEMP\AdvancedIPScanner"
$exePath = "$tempDir\Advanced_IP_Scanner.exe"

# Vérifier si le dossier temporaire existe et le supprimer proprement
if (Test-Path -Path $tempDir) {
    try {
        Get-Process -Name "Advanced_IP_Scanner" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 1
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠ Impossible de supprimer $tempDir immédiatement. Essai après exécution..."
    }
}

# Recréer le répertoire temporaire
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Télécharger Advanced IP Scanner
Invoke-WebRequest -Uri $url -OutFile $exePath

# Exécuter Advanced IP Scanner
try {
    Start-Process -FilePath $exePath -NoNewWindow -Wait
} catch {
    Write-Host "⚠ Erreur lors de l'exécution de Advanced IP Scanner : $_"
}

# Attendre quelques secondes pour s'assurer que le programme est bien terminé
Start-Sleep -Seconds 2

# Vérifier si Advanced IP Scanner est encore en cours d'exécution avant suppression
$process = Get-Process -Name "Advanced_IP_Scanner" -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name "Advanced_IP_Scanner" -Force
    Start-Sleep -Seconds 1
}

# Supprimer les fichiers temporaires après exécution
try {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Dossier temporaire supprimé : $tempDir"
} catch {
    Write-Host "⚠️ Erreur lors de la suppression des fichiers temporaires : $_"
}
