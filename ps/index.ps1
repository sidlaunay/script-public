# =============================
# Configuration
# =============================
$RepoBaseUrl = "https://dev.slaunay.com/ps"

# =============================
# Afficher le logo ASCII
# =============================
function Show-Logo {
    Clear-Host
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
# Charger les fichiers avec description
# =============================
function Load-Files {
    Write-Host "🔄 Chargement de la liste des scripts disponibles..."
    try {
        $FileList = Invoke-RestMethod -Uri "$RepoBaseUrl/index.txt"
    } catch {
        Write-Host "❌ ERREUR : Impossible de charger la liste des scripts depuis $RepoBaseUrl/index.txt"
        exit
    }

    if (-not $FileList) {
        Write-Host "❌ Aucun script trouvé sur le serveur."
        exit
    }

    return $FileList -split "`n" | Where-Object { $_ -match "\.ps1\|" -and $_ -notmatch "index.ps1\|" }
}

# =============================
# Construire l'arborescence avec descriptions
# =============================
function Build-Tree {
    param([string[]]$Files)

    $Tree = @{ "Folders" = @{}; "Files" = @() }
    $AllFolders = @{}

    foreach ($Entry in $Files) {
        if ($Entry -match "(.+?)\|(.+)") {
            $FilePath = $matches[1]
            $Description = $matches[2]

            $Parts = $FilePath -split "/"
            $Current = $Tree

            # Ajouter les dossiers parents dans AllFolders
            $currentPath = ""
            for ($i = 0; $i -lt $Parts.Count - 1; $i++) {
                $currentPath = if ($i -eq 0) { $Parts[$i] } else { "$currentPath/$($Parts[$i])" }
                $AllFolders[$currentPath] = $true
            }

            # Construction de l'arborescence
            for ($i = 0; $i -lt $Parts.Count; $i++) {
                $Part = $Parts[$i]
                
                if ($i -eq $Parts.Count - 1) {
                    $Current["Files"] += @{ Name = $Part; Description = $Description }
                } else {
                    if (-not $Current["Folders"].ContainsKey($Part)) {
                        $Current["Folders"][$Part] = @{ "Folders" = @{}; "Files" = @() }
                    }
                    $Current = $Current["Folders"][$Part]
                }
            }
        }
    }

    # Ajouter les dossiers vides manquants
    foreach ($FolderPath in $AllFolders.Keys | Sort-Object) {
        $Parts = $FolderPath -split "/"
        $Current = $Tree
        
        foreach ($Part in $Parts) {
            if (-not $Current["Folders"].ContainsKey($Part)) {
                $Current["Folders"][$Part] = @{ "Folders" = @{}; "Files" = @() }
            }
            $Current = $Current["Folders"][$Part]
        }
    }

    return $Tree
}

# =============================
# Fonction de navigation
# =============================
function Browse-Folder {
    param(
        [Hashtable]$Node,
        [String]$Path = ""
    )

    while ($true) {
        Show-Logo

        Write-Host "`n📂 Contenu de: $Path"

        $Items = @()
        if ($Node.ContainsKey("Folders")) {
            foreach ($Folder in $Node["Folders"].Keys | Sort-Object) {
                $Items += @{ Type = "Folder"; Name = $Folder; Node = $Node["Folders"][$Folder] }
            }
        }
        if ($Node.ContainsKey("Files")) {
            foreach ($File in $Node["Files"] | Sort-Object Name) {
                $Items += @{ Type = "File"; Name = $File.Name; Description = $File.Description }
            }
        }

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $Num = $i + 1
            if ($Items[$i].Type -eq "Folder") {
                Write-Host "$Num) 📁 [Dossier] $($Items[$i].Name)"
            } else {
                Write-Host "$Num) 📄 $($Items[$i].Name) - $($Items[$i].Description)"
            }
        }

        Write-Host "`n0) 🔙 Revenir en arrière"
        Write-Host "Q) ❌ Quitter"

        $Choice = Read-Host "`n📌 Choisissez une option"

        if ($Choice -eq "Q") {
            Write-Host "`n👋 Fermeture du programme."
            exit
        } elseif ($Choice -eq "0") {
            return
        } elseif ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $Items.Count) {
            $Selected = $Items[[int]$Choice - 1]

            if ($Selected.Type -eq "Folder") {
                Browse-Folder -Node $Selected.Node -Path ("$Path/$($Selected.Name)").TrimStart("/")
            } else {
                $FilePath = ("$Path/$($Selected.Name)").TrimStart("/")
                Write-Host "▶️ Exécution du script : $FilePath ..."
                Invoke-Expression (Invoke-RestMethod -Uri "$RepoBaseUrl/$FilePath")
            }
        } else {
            Write-Host "❌ Choix invalide."
        }
    }
}

# =============================
# Démarrer la navigation
# =============================
Show-Logo  
$Files = Load-Files
$Tree = Build-Tree -Files $Files
Browse-Folder -Node $Tree






# 20.02.25 23.28
