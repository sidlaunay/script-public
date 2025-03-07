# DESCRIPTION: Sauvegarde un profil utilisateur sous forme d'image WIM avec DISM.

# Empêcher la fermeture brutale de la console et enregistrer un log
$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Sauvegarde Profil - Ne Fermez Pas"
Start-Transcript -Path "$env:TEMP\backup_log.txt" -Append

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

try {
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

    # Demander la destination pour le fichier WIM
    $destinationFolder = Read-Host "📁 Entrez le chemin de destination pour l'image (ex: D:\Backups ou \\SERVEUR\Sauvegardes)"
    if (-not (Test-Path -Path $destinationFolder)) {
        Write-Host "❌ Le dossier de destination n'existe pas."
        exit
    }

    # Demander le nom du fichier WIM
    $wimFileName = Read-Host "📌 Entrez le nom du fichier image (ex: sauvegarde_$selectedProfile)"
    $wimPath = "$destinationFolder\$wimFileName.wim"

    # Vérifier si le fichier existe déjà
    if (Test-Path -Path $wimPath) {
        $overwrite = Read-Host "⚠️ Le fichier existe déjà. Voulez-vous l'écraser ? (O/N)"
        if ($overwrite -ne "O") {
            Write-Host "❌ Opération annulée."
            exit
        }
        Remove-Item -Path $wimPath -Force
    }

    # Créer l'image avec DISM
    Write-Host "⏳ Création de l'image WIM..."
    $dismCommand = "dism /Capture-Image /ImageFile:`"$wimPath`" /CaptureDir:`"$profilePath`" /Name:`"$selectedProfile`""
    Write-Host "📌 Commande exécutée : $dismCommand"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $dismCommand" -Wait -NoNewWindow

    # Vérification et confirmation
    if (Test-Path -Path $wimPath) {
        Write-Host "✅ Sauvegarde terminée avec succès ! Fichier créé : $wimPath"
    } else {
        Write-Host "❌ Erreur lors de la sauvegarde."
    }

} catch {
    Write-Host "⚠️ Une erreur s'est produite : $_"
}

# Empêcher la fermeture automatique et afficher le log en cas d'erreur
Write-Host "`n⚠️ Une erreur s'est produite ? Consultez le log ici : $env:TEMP\backup_log.txt"
Write-Host "Appuyez sur Entrée pour fermer la fenêtre..."
Read-Host
Stop-Transcript
