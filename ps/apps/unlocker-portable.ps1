# Vérifie si PowerShell est en mode administrateur
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

# URL de téléchargement
$url = "http://dev.slaunay.com/soft/UnlockerPortable_1.9.2.zip"

# Chemins
$tempDir = "$env:TEMP\UnlockerPortable"
$zipPath = "$tempDir\UnlockerPortable.zip"

# Supprime le dossier temporaire s'il existe
if (Test-Path -Path $tempDir) {
    try {
        Get-Process -Name "unlocker" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 1
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠ Impossible de supprimer $tempDir immédiatement. On continue..."
    }
}

# Recrée le dossier temporaire
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

# Télécharge Unlocker Portable
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Décompresse l’archive
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
Remove-Item -Path $zipPath -Force

# Cherche l’exécutable Unlocker dans tous les sous-dossiers
$exePath = Get-ChildItem -Path $tempDir -Filter "UnlockerPortable.exe" -Recurse | Select-Object -First 1

if ($exePath) {
    try {
        # Lance UnlockerPortable.exe (avec fenêtre, sinon ça ne s'affiche pas)
        Start-Process -FilePath $exePath.FullName -Wait
    } catch {
        Write-Host "⚠ Erreur lors de l'exécution d'Unlocker : $_"
    }
    Start-Sleep -Seconds 2
} else {
    Write-Host "❌ Impossible de trouver UnlockerPortable.exe après extraction."
}

# Nettoie les fichiers temporaires
try {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Dossier temporaire supprimé : $tempDir"
} catch {
    Write-Host "⚠️ Erreur lors de la suppression des fichiers temporaires : $_"
}
