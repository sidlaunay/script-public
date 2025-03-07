# DESCRIPTION: Sauvegarde un profil utilisateur en ZIP, compatible avec les dossiers locaux et réseau.

# Vérifier si PowerShell est en mode administrateur
function Test-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Redémarrer en mode administrateur si nécessaire
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

    # Demander la destination du fichier ZIP
    $destinationFolder = Read-Host "📁 Entrez le chemin de destination (ex: D:\Backups ou \\SERVEUR\Sauvegardes)"
    
    # Vérifier si c'est un dossier réseau
    if ($destinationFolder -match "^\\\\") {
        Write-Host "🔍 Vérification du dossier réseau..."
        if (-not (Test-Path -Path $destinationFolder)) {
            Write-Host "⚠️ Le dossier réseau n'est pas accessible ! Vérifiez votre connexion."
            exit
        }
    } elseif (-not (Test-Path -Path $destinationFolder)) {
        Write-Host "❌ Le dossier de destination n'existe pas. Vérifiez votre saisie."
        exit
    }

    # Demander le nom du fichier ZIP
    $zipFileName = Read-Host "📌 Entrez le nom du fichier ZIP (ex: sauvegarde_$selectedProfile)"
    $zipPath = "$destinationFolder\$zipFileName.zip"

    # Vérifier si le fichier existe déjà
    if (Test-Path -Path $zipPath) {
        $overwrite = Read-Host "⚠️ Le fichier existe déjà. Voulez-vous l'écraser ? (O/N)"
        if ($overwrite -ne "O") {
            Write-Host "❌ Opération annulée."
            exit
        }
        Remove-Item -Path $zipPath -Force
    }

    # Création de l'archive ZIP
    Write-Host "⏳ Compression du profil $selectedProfile en $zipPath..."
    Compress-Archive -Path "$profilePath\*" -DestinationPath $zipPath -Force

    # Vérification et confirmation
    if (Test-Path -Path $zipPath) {
        Write-Host "✅ Sauvegarde terminée avec succès ! Fichier créé : $zipPath"
    } else {
        Write-Host "❌ Erreur lors de la sauvegarde."
    }
} catch {
    Write-Host "⚠️ Une erreur s'est produite : $_"
}

# Garder PowerShell ouvert pour afficher les erreurs
Read-Host "Appuyez sur Entrée pour fermer la fenêtre..."
