# =============================
# Configuration
# =============================
$RepoBaseUrl = "https://dev.slaunay.com/ps"

# =============================
# Afficher le logo ASCII (toujours visible en haut)
# =============================
function Show-Logo {
    Write-Host "`n"
    Write-Host "       ++************                                                                                                 "
    Write-Host "    =++++++*************                                                                                              "
    Write-Host "  =====++++++++*****+=-:::                                                                                            "
    Write-Host " =========++++++=:::::::::-                     @@@@                                                                  "
    Write-Host "=============++-::::::------        @@@@@@@@@  @@@@@                                                                  "
    Write-Host "===============-::-------===       @@@@@@@@@   @@@@@                                                                  "
    Write-Host "---==============----========      @@@@@       @@@@@   @@@@@@@@@   @@@@  @@@@   @@@@@@@@@     @@@@@ @@@  @@@@    @@@@ "
    Write-Host "------=======================      @@@@@@@@    @@@@  @@@@@@@@@@@@ @@@@@  @@@@  @@@@@@@@@@@  @@@@@@@@@@@@ @@@@@  @@@@@ "
    Write-Host ":--------====================        @@@@@@@  @@@@@ @@@@@@  @@@@  @@@@@  @@@@  @@@@@ @@@@@  @@@@@  @@@@   @@@@@@@@@@  "
    Write-Host ":::::--------============+++       @@   @@@@  @@@@@ @@@@@   @@@@  @@@@@  @@@@  @@@@  @@@@@ @@@@@   @@@@    @@@@@@@@   "
    Write-Host "::::::::--------=======+++++     @@@@@@@@@@@  @@@@@  @@@@@@@@@@@  @@@@@@@@@@@  @@@@  @@@@@  @@@@@@@@@@@    @@@@@@@    "
    Write-Host " ::::::::::--------==+++***       @@@@@@@@@   @@@@    @@@@@@@@@@   @@@@@@@@@   @@@@  @@@@    @@@@@@@@@     @@@@@@     "
    Write-Host "  ::::::::::::-----=******                                                                                @@@@@       "
    Write-Host "    ::::::::::::-=******                                                                                 @@@@@        "
    Write-Host "       :::::::-+*****                                                                                    @@@@         "
    Write-Host "`n"
    Write-Host "========================================"
    Write-Host "         MENU SLAUNAY SCRIPT            "
    Write-Host "========================================`n"
}

# =============================
# Récupération de la liste des fichiers
# =============================
function Load-Files {
    Write-Host "Chargement de la liste des scripts disponibles..."
    try {
        $FileList = Invoke-RestMethod -Uri "$RepoBaseUrl/index.txt"
    } catch {
        Write-Host "ERREUR : Impossible de charger la liste des scripts depuis $RepoBaseUrl/index.txt"
        exit
    }

    if (-not $FileList) {
        Write-Host "Aucun script trouvé sur le serveur."
        exit
    }

    return $FileList -split "`n" | Where-Object { $_ -match "\.ps1$" -and $_ -ne "index.ps1" }
}

# =============================
# Construction de l'arborescence
# =============================
function Build-Tree {
    param([string[]]$Files)

    $Tree = @{}

    foreach ($File in $Files) {
        $Parts = $File -split "/"
        $Current = $Tree

        for ($i = 0; $i -lt $Parts.Count; $i++) {
            $Part = $Parts[$i]

            if ($i -eq $Parts.Count - 1) {
                if (-not $Current.ContainsKey("Files")) { $Current["Files"] = @() }
                $Current["Files"] += $Part
            } else {
                if (-not $Current.ContainsKey("Folders")) { $Current["Folders"] = @{} }
                if (-not $Current["Folders"].ContainsKey($Part)) { $Current["Folders"][$Part] = @{} }
                $Current = $Current["Folders"][$Part]
            }
        }
    }

    return $Tree
}

# =============================
# Fonction de navigation (conserve le logo en haut)
# =============================
function Browse-Folder {
    param(
        [Hashtable]$Node,
        [String]$Path = ""
    )

    while ($true) {
        Clear-Host  # Nettoie l'écran sauf le logo
        Show-Logo   # Réaffiche le logo à chaque retour de menu

        Write-Host "`nContenu de: $Path"
        
        $Items = @()
        if ($Node.ContainsKey("Folders")) {
            foreach ($Folder in $Node["Folders"].Keys) {
                $Items += @{ Type = "Folder"; Name = $Folder; Node = $Node["Folders"][$Folder] }
            }
        }
        if ($Node.ContainsKey("Files")) {
            foreach ($File in $Node["Files"]) {
                $Items += @{ Type = "File"; Name = $File }
            }
        }

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $Num = $i + 1
            if ($Items[$i].Type -eq "Folder") {
                Write-Host "$Num) [Dossier] $($Items[$i].Name)"
            } else {
                Write-Host "$Num) $($Items[$i].Name)"
            }
        }

        Write-Host "`n0) Revenir en arrière"
        Write-Host "Q) Quitter"

        $Choice = Read-Host "`nChoisissez une option"

        if ($Choice -eq "Q") {
            Write-Host "`nFermeture du programme."
            exit
        } elseif ($Choice -eq "0") {
            return
        } elseif ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $Items.Count) {
            $Selected = $Items[[int]$Choice - 1]

            if ($Selected.Type -eq "Folder") {
                Browse-Folder -Node $Selected.Node -Path ("$Path/$($Selected.Name)").TrimStart("/")
            } else {
                $FilePath = ("$Path/$($Selected.Name)").TrimStart("/")
                Write-Host "Exécution du script : $FilePath ..."
                try {
                    Invoke-Expression (Invoke-RestMethod -Uri "$RepoBaseUrl/$FilePath")
                } catch {
                    Write-Host "ERREUR : Impossible d'exécuter le script : $($_.Exception.Message)"
                }
            }
        } else {
            Write-Host "Choix invalide."
        }
    }
}

# =============================
# Démarrer la navigation
# =============================
Show-Logo  # 🔥 Affiche le logo une fois au début
$Files = Load-Files
$Tree = Build-Tree -Files $Files
Browse-Folder -Node $Tree






# 20.02.25 22.11
