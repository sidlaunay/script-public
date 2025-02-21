# Définir l'URL de téléchargement de Speedtest CLI
$url = "https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-win64.zip"

# Définir le chemin du répertoire temporaire
$tempDir = "$env:TEMP\SpeedtestCLI"
$zipPath = "$tempDir\speedtest.zip"
$exePath = "$tempDir\speedtest.exe"

# Vérifier si le dossier temporaire existe et le supprimer proprement
if (Test-Path -Path $tempDir) {
    try {
        Get-Process -Name "speedtest" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 1
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠ Impossible de supprimer $tempDir immédiatement. Essai après exécution..."
    }
}

# Recréer le répertoire temporaire
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Télécharger le fichier ZIP de Speedtest CLI
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Extraire le contenu du ZIP
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempDir)

# Supprimer le fichier ZIP après extraction
Remove-Item -Path $zipPath -Force

# Exécuter le test de débit directement dans la console PowerShell actuelle
& $exePath --accept-license --accept-gdpr

# Attendre quelques secondes pour s'assurer que le programme est bien terminé
Start-Sleep -Seconds 2

# Vérifier si Speedtest est encore en cours d'exécution avant suppression
$process = Get-Process -Name "speedtest" -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name "speedtest" -Force
    Start-Sleep -Seconds 1
}

# Supprimer les fichiers temporaires après exécution
try {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Dossier temporaire supprimé : $tempDir"
} catch {
    Write-Host "⚠️ Erreur lors de la suppression des fichiers temporaires : $_"
}
