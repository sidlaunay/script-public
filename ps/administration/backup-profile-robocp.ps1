# DESCRIPTION: Sauvegarde rapide un profil utilisateur en le copiant avec Robocopy puis en le compressant avec 7-Zip.

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

# Lister les profils utilisateur
$userProfiles = Get-ChildItem -Path "C:\Users" -Directory | Select-Object -ExpandProperty Name
if ($userProfiles.Count -eq 0) {
    Write-Host "❌ Aucun profil utilisateur trouvé dans C:\Users"
    exit
}

# Afficher la liste des profils et demander à l'utilisateur d'en choisir un
Write-Host "📂 Profils utilisateurs trouvés dans C:\Users :"
for ($i = 0; $i -lt $userProfiles.Count; $i++) {
    Write-Host "$($i+1)) $($userProfiles[$i])"
}

$choice = Read-Host "🔍 Entrez le numéro du profil à sauvegarder"
if (-not ($choice -match "^\d+$") -or [int]$choice -lt 1 -or [int]$choice -gt $userProfiles.Count) {
    Write-Host "❌ Sélection invalide."
    exit
}
$selectedProfile = $userProfiles[[int]$choice - 1]
$profilePath = "C:\Users\$selectedProfile"

# Demander la destination pour la sauvegarde
$destinationFolder = Read-Host "📁 Entrez le chemin de destination pour la sauvegarde (ex: D:\Backups ou \\SERVEUR\Sauvegardes)"
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "❌ Le dossier de destination n'existe pas."
    exit
}

# Vérifier si 7-Zip est déjà présent
$sevenZipUrl = "https://www.7-zip.org/a/7z2301-extra.7z"
$sevenZipDir = "$env:TEMP\7ZipPortable"
$sevenZipExe = "$sevenZipDir\7z.exe"
$sevenZipZip = "$env:TEMP\7zPortable.7z"

if (-not (Test-Path $sevenZipExe)) {
    Write-Host "🔄 Téléchargement de 7-Zip Portable..."
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipZip
    Write-Host "⏳ Extraction de 7-Zip Portable..."
    Expand-Archive -Path $sevenZipZip -DestinationPath $sevenZipDir -Force
    Remove-Item -Path $sevenZipZip -Force
}

# Demander le nom du fichier final
$backupName = Read-Host "📌 Entrez le nom du fichier de sauvegarde (ex: Backup_User1)"
$backupPath = "$destinationFolder\$backupName"

# Étape 1: Copier le profil utilisateur avec Robocopy (exclut les fichiers verrouillés)
Write-Host "⏳ Copie du profil utilisateur en cours..."
$robocopyLog = "$env:TEMP\robocopy_log.txt"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c robocopy `"$profilePath`" `"$backupPath`" /E /COPY:DAT /XJ /R:1 /W:1 /LOG:`"$robocopyLog`"" -Wait -NoNewWindow

# Étape 2: Compresser avec 7-Zip
Write-Host "⏳ Compression en cours..."
$zipFile = "$destinationFolder\$backupName.7z"
Start-Process -FilePath $sevenZipExe -ArgumentList "a -t7z `"$zipFile`" `"$backupPath`" -mx=9" -Wait -NoNewWindow

# Supprimer le dossier temporaire après compression
Remove-Item -Path $backupPath -Recurse -Force

# Vérification et confirmation
if (Test-Path -Path $zipFile) {
    Write-Host "✅ Sauvegarde terminée avec succès ! Fichier créé : $zipFile"
} else {
    Write-Host "❌ Erreur lors de la sauvegarde."
}

# Garder PowerShell ouvert pour voir les erreurs
Write-Host "Appuyez sur Entrée pour fermer la fenêtre..."
Read-Host
