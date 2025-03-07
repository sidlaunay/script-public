# DESCRIPTION: Sauvegarde un profil utilisateur en créant une image VHD avec Disk2VHD.

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
    # Télécharger Disk2VHD si nécessaire
    $disk2vhd_url = "https://live.sysinternals.com/disk2vhd64.exe"
    $disk2vhd_path = "$env:TEMP\disk2vhd64.exe"
    if (-not (Test-Path -Path $disk2vhd_path)) {
        Write-Host "🔄 Téléchargement de Disk2VHD..."
        Invoke-WebRequest -Uri $disk2vhd_url -OutFile $disk2vhd_path -ErrorAction Stop
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

    # Demander la destination pour le fichier VHD
    $destinationFolder = Read-Host "📁 Entrez le chemin de destination pour l'image disque (ex: D:\Backups ou \\SERVEUR\Sauvegardes)"
    if (-not (Test-Path -Path $destinationFolder)) {
        Write-Host "❌ Le dossier de destination n'existe pas."
        exit
    }

    # Demander le nom du fichier VHD
    $vhdFileName = Read-Host "📌 Entrez le nom du fichier disque virtuel (ex: sauvegarde_$selectedProfile)"
    $vhdPath = "$destinationFolder\$vhdFileName.vhd"

    # Vérifier si le fichier existe déjà
    if (Test-Path -Path $vhdPath) {
        $overwrite = Read-Host "⚠️ Le fichier existe déjà. Voulez-vous l'écraser ? (O/N)"
        if ($overwrite -ne "O") {
            Write-Host "❌ Opération annulée."
            exit
        }
        Remove-Item -Path $vhdPath -Force
    }

    # Lancer la création du VHD avec exclusion des autres utilisateurs
    Write-Host "⏳ Création de l'image disque VHD..."
    Start-Process -FilePath $disk2vhd_path -ArgumentList "C: $vhdPath" -Wait -NoNewWindow

    # Vérification et confirmation
    if (Test-Path -Path $vhdPath) {
        Write-Host "✅ Sauvegarde terminée avec succès ! Fichier créé : $vhdPath"
    } else {
        Write-Host "❌ Erreur lors de la sauvegarde."
    }

} catch {
    Write-Host "⚠️ Une erreur s'est produite : $_"
}

# Garder PowerShell ouvert pour afficher les erreurs
Read-Host "Appuyez sur Entrée pour fermer la fenêtre..."
