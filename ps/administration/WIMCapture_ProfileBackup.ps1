# DESCRIPTION: Crée une image WIM complète du profil utilisateur en évitant les fichiers verrouillés.

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
$destinationFolder = Read-Host "📁 Entrez le chemin de destination pour l'image WIM (ex: D:\Backups ou \\SERVEUR\Sauvegardes)"
if (-not (Test-Path -Path $destinationFolder)) {
    Write-Host "❌ Le dossier de destination n'existe pas."
    exit
}

# Demander le nom du fichier WIM
$backupName = Read-Host "📌 Entrez le nom du fichier de sauvegarde (ex: Backup_User1)"
$wimPath = "$destinationFolder\$backupName.wim"

# Créer une image WIM du profil utilisateur
Write-Host "⏳ Création de l'image WIM..."
dism /Capture-Image /ImageFile:"$wimPath" /CaptureDir:"$profilePath" /Name:"Backup_$selectedProfile" /Compress:max

# Vérification et confirmation
if (Test-Path -Path $wimPath) {
    Write-Host "✅ Sauvegarde terminée avec succès ! Fichier créé : $wimPath"
} else {
    Write-Host "❌ Erreur lors de la sauvegarde."
}

# Garder PowerShell ouvert pour voir les erreurs
Write-Host "Appuyez sur Entrée pour fermer la fenêtre..."
Read-Host
