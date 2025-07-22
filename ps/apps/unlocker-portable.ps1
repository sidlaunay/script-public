# DESCRIPTION: Unlocker Portable 1.9.2 permet de supprimer les fichiers verrouillés.

# Auto-élévation (compatible exécution web/pipeline)
function Test-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-Admin)) {
    Write-Host "🔄 Relance du script en mode administrateur..." -ForegroundColor Yellow
    $scriptUrl = "https://dev.slaunay.com/ps/unlocker/unlocker.ps1"  # <= Mets bien l'URL réelle ici !
    Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", "irm $scriptUrl | iex" -Verb RunAs
    Read-Host -Prompt "Appuyez sur Entrée pour quitter cette fenêtre (la nouvelle va s'ouvrir en admin)"
    exit
}

Write-Host "`n==== Démarrage du script UnlockerPortable ====" -ForegroundColor Cyan

# URL de téléchargement
$url = "http://dev.slaunay.com/soft/UnlockerPortable_1.9.2.zip"

# Chemins
$tempDir = "$env:TEMP\UnlockerPortable"
$zipPath = "$tempDir\UnlockerPortable.zip"

Write-Host "Dossier temporaire utilisé : $tempDir"
Write-Host "Fichier zip téléchargé : $zipPath"

# Suppression dossier temporaire si déjà présent
if (Test-Path -Path $tempDir) {
    Write-Host "Suppression de l'ancien dossier temporaire..."
    try {
        Get-Process -Name "unlocker" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 1
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
        Write-Host "Ancien dossier supprimé."
    } catch {
        Write-Host "⚠ Impossible de supprimer $tempDir immédiatement. On continue..."
    }
}

# Recrée le dossier temporaire
Write-Host "Création du dossier temporaire..."
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

# Télécharge Unlocker Portable
Write-Host "Téléchargement d'Unlocker Portable..."
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Décompresse l’archive
Write-Host "Décompression de l'archive..."
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
Remove-Item -Path $zipPath -Force

# Cherche l’exécutable Unlocker dans tous les sous-dossiers
Write-Host "Recherche de UnlockerPortable.exe dans $tempDir (récursif)..."
$exePath = Get-ChildItem -Path $tempDir -Filter "UnlockerPortable.exe" -Recurse | Select-Object -First 1

if ($exePath) {
    Write-Host "Fichier trouvé : $($exePath.FullName)"
    try {
        # Lance UnlockerPortable.exe (affiche la fenêtre)
        Write-Host "Lancement d'UnlockerPortable.exe..."
        Start-Process -FilePath $exePath.FullName -Wait
        Write-Host "Unlocker terminé."
    } catch {
        Write-Host "⚠ Erreur lors de l'exécution d'Unlocker : $_"
    }
    Start-Sleep -Seconds 2
} else {
    Write-Host "❌ Impossible de trouver UnlockerPortable.exe après extraction."
}

# Nettoie les fichiers temporaires
Write-Host "Suppression du dossier temporaire..."
try {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Dossier temporaire supprimé : $tempDir"
} catch {
    Write-Host "⚠️ Erreur lors de la suppression des fichiers temporaires : $_"
}

Write-Host "`n==== Script Unlocker terminé ====" -ForegroundColor Cyan
Read-Host -Prompt "`nAppuyez sur Entrée pour quitter"
