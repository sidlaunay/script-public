# DESCRIPTION: Unlocker Portable 1.9.2 permet de supprimer les fichiers verrouillés.

# Vérifier si PowerShell est en mode administrateur
function Test-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "🔄 Redémarrage du script en mode administrateur..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Définir l'URL de téléchargement d'Unlocker Portable 1.9.2
$url = "http://dev.slaunay.com/soft/UnlockerPortable_1.9.2.zip"

# Définir le chemin du répertoire temporaire
$tempDir = "$env:TEMP\UnlockerPortable"
$zipPath = "$tempDir\UnlockerPortable.zip"
$exePath = "$tempDir\UnlockerPortable.exe"

# Vérifier si le dossier temporaire existe et le supprimer proprement
if (Test-Path -Path $tempDir) {
    try {
        Get-Process -Name "unlocker" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 1
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠ Impossible de supprimer $tempDir immédiatement. Essai après exécution..."
    }
}

# Recréer le répertoire temporaire
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Télécharger Unlocker Portable
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Décompresser si nécessaire
if ($zipPath -like "*.zip") {
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    Remove-Item -Path $zipPath -Force
    $exe = Get-ChildItem -Path $tempDir -Filter *.exe | Select-Object -First 1
    if ($exe) { $exePath = $exe.FullName }
}

# Exécuter Unlocker Portable
try {
    Start-Process -FilePath $exePath -NoNewWindow -Wait
} catch {
    Write-Host "⚠ Erreur lors de l'exécution d'Unlocker : $_"
}

# Attendre quelques secondes pour s'assurer que le programme est bien terminé
Start-Sleep -Seconds 2

# Supprimer les fichiers temporaires après exécution
try {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Dossier temporaire supprimé : $tempDir"
} catch {
    Write-Host "⚠️ Erreur lors de la suppression des fichiers temporaires : $_"
}
