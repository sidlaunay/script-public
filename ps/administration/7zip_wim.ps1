# DESCRIPTION: Télécharge et lance 7-Zip Portable pour explorer un fichier .WIM.

# Définir l'URL de téléchargement de 7-Zip Portable
$zipUrl = "https://www.7-zip.org/a/7z2301-extra.7z"
$sevenZipDir = "$env:TEMP\7ZipPortable"
$sevenZipExe = "$sevenZipDir\7zFM.exe"
$zipPath = "$env:TEMP\7zPortable.7z"

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

# Vérifier si 7-Zip est déjà téléchargé
if (-not (Test-Path $sevenZipExe)) {
    Write-Host "🔄 Téléchargement de 7-Zip Portable..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
    Write-Host "⏳ Extraction de 7-Zip Portable..."

    # Extraire 7-Zip avec PowerShell
    try {
        if (-not (Test-Path -Path $sevenZipDir)) {
            New-Item -Path $sevenZipDir -ItemType Directory | Out-Null
        }
        Expand-Archive -Path $zipPath -DestinationPath $sevenZipDir -Force
    } catch {
        Write-Host "❌ Impossible d'extraire 7-Zip. Essaie de l'extraire manuellement : $zipPath"
        exit
    }

    # Vérifier si l'extraction a réussi
    if (-not (Test-Path $sevenZipExe)) {
        Write-Host "❌ Erreur : 7-Zip Portable n'a pas été trouvé après extraction."
        exit
    }

    # Nettoyer le fichier zip après extraction
    Remove-Item -Path $zipPath -Force
}

# Demander à l'utilisateur de sélectionner un fichier .WIM
Add-Type -AssemblyName System.Windows.Forms
$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.Filter = "Fichier WIM (*.wim)|*.wim"
$FileDialog.Title = "Sélectionner un fichier WIM à explorer"

if ($FileDialog.ShowDialog() -eq "OK") {
    $wimFile = $FileDialog.FileName
    Write-Host "📂 Fichier sélectionné : $wimFile"

    # Lancer 7-Zip pour explorer le fichier .WIM
    Start-Process -FilePath $sevenZipExe -ArgumentList "`"$wimFile`""
} else {
    Write-Host "❌ Aucun fichier sélectionné. Fermeture du script."
}
