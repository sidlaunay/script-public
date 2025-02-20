# =============================
# Execution
# =============================
#
#  irm https://dev.slaunay.com/ps | iex
#
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
    Write-Host " =========++++++=:::::::::-                     @@@@                                                                 "
    Write-Host "=============++-::::::------        @@@@@@@@@  @@@@@                                                                 "
    Write-Host "===============-::-------===       @@@@@@@@@   @@@@@                                                                 "
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
        $FileList = (Invoke-RestMethod -Uri "$RepoBaseUrl/index.txt") -split "\r?\n"
    } catch {
        Write-Host "❌ ERREUR : Impossible de charger la liste des scripts"
        exit
    }

    return $FileList | Where-Object {
        $_ -match "^[^\|]+\.ps1\|" -and 
        $_ -notmatch "index\.ps1\|" -and 
        $_ -ne ""
    } | ForEach-Object { $_.Trim() }
}

# =============================
# Construire l'arborescence avec descriptions
# =============================
function Build-Tree {
    param([string[]]$Files)

    $Tree = @{ "Folders" = @{}; "Files" = @() }
    $AllFolders = @{}

    # Première passe: traiter les fichiers et collecter les dossiers
    foreach ($Entry in $Files) {
        if ($Entry -match "^([^\|]+\.ps1)\|(.+)") {
            $FilePath = $matches[1]
            $Description = $matches[2]

            $Parts = $FilePath -split "/"
            $Current = $Tree

            # Ajouter chaque segment du chemin
            for ($i = 0; $i -lt $Parts.Count; $i++) {
                $Part = $Parts[$i]
                if ($i -eq $Parts.Count - 1) {
                    $Current["Files"] += @{ Name = $Part; Description = $Description }
                }
                else {
                    if (-not $Current["Folders"].ContainsKey($Part)) {
                        $Current["Folders"][$Part] = @{ "Folders" = @{}; "Files" = @() }
                    }
                    $Current = $Current["Folders"][$Part]
                }
            }
        }
    }

    # Deuxième passe: ajouter les dossiers manquants
    $Files | ForEach-Object {
        if ($_ -match "^([^\|]+)/") {
            $dirPath = $matches[1] -split "/" | Where-Object { $_ -ne "" }
            $current = $Tree
            foreach ($dir in $dirPath) {
                if (-not $current["Folders"].ContainsKey($dir)) {
                    $current["Folders"][$dir] = @{ "Folders" = @{}; "Files" = @() }
                }
                $current = $current["Folders"][$dir]
            }
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
        if ($Node.Folders.Count -gt 0) {
            $Node.Folders.Keys | Sort-Object | ForEach-Object {
                $Items += @{ 
                    Type = "Folder" 
                    Name = $_ 
                    Node = $Node.Folders[$_] 
                }
            }
        }
        if ($Node.Files.Count -gt 0) {
            $Node.Files | Sort-Object Name | ForEach-Object {
                $Items += @{ 
                    Type = "File" 
                    Name = $_.Name 
                    Description = $_.Description 
                }
            }
        }

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $Num = $i + 1
            if ($Items[$i].Type -eq "Folder") {
                Write-Host "$Num) 📁 [Dossier] $($Items[$i].Name)"
            }
            else {
                Write-Host "$Num) 📄 $($Items[$i].Name) - $($Items[$i].Description)"
            }
        }

        Write-Host "`n0) 🔙 Revenir en arrière"
        Write-Host "Q) ❌ Quitter"

        $Choice = Read-Host "`n📌 Choisissez une option"

        if ($Choice -eq "Q") {
            Write-Host "`n👋 Fermeture du programme."
            exit
        }
        elseif ($Choice -eq "0") {
            return
        }
        elseif ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $Items.Count) {
            $Selected = $Items[[int]$Choice - 1]

            if ($Selected.Type -eq "Folder") {
                Browse-Folder -Node $Selected.Node -Path "$Path/$($Selected.Name)".Trim('/')
            }
            else {
                $FilePath = "$Path/$($Selected.Name)".Trim('/')
                Write-Host "▶️ Exécution du script : $FilePath ..."
                try {
                    Invoke-Expression (Invoke-RestMethod -Uri "$RepoBaseUrl/$FilePath")
                }
                catch {
                    Write-Host "❌ Erreur lors de l'exécution du script : $_"
                }
            }
        }
        else {
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





# 21.02.25 00.33
