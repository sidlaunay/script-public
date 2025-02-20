# =============================
# Configuration
# =============================
$RepoBaseUrl = "https://dev.slaunay.com/ps"

# =============================
# Afficher le logo ASCII (toujours visible en haut)
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

    # Supprimer index.ps1 de la liste
    return $FileList -split "`n" | Where-Object { $_ -match "\.ps1\|" -and $_ -notmatch "index.ps1\|" }
}

# =============================
# Afficher la liste des fichiers (sans arborescence)
# =============================
function Show-Files {
    param([string[]]$Files)

    Show-Logo  # Affiche le logo en haut

    Write-Host "`nListe des scripts disponibles :`n"

    $ScriptList = @()

    foreach ($Entry in $Files) {
        if ($Entry -match "(.+?)\|(.+)") {
            $ScriptPath = $matches[1]
            $Description = $matches[2]
            $ScriptList += @{ Path = $ScriptPath; Description = $Description }
        }
    }

    for ($i = 0; $i -lt $ScriptList.Count; $i++) {
        $Num = $i + 1
        Write-Host "$Num) $($ScriptList[$i].Path) - $($ScriptList[$i].Description)"
    }

    Write-Host "`n0) Quitter"

    $Choice = Read-Host "`nChoisissez un script à exécuter (1-$($ScriptList.Count))"

    if ($Choice -eq "0") {
        Write-Host "`nFermeture du programme."
        exit
    }

    if ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $ScriptList.Count) {
        $SelectedScript = $ScriptList[[int]$Choice - 1]
        Write-Host "Exécution du script : $($SelectedScript.Path) ..."
        Invoke-Expression (Invoke-RestMethod -Uri "$RepoBaseUrl/$($SelectedScript.Path)")
    } else {
        Write-Host "Choix invalide."
    }
}

# =============================
# Démarrer le programme
# =============================
$Files = Load-Files
Show-Files -Files $Files






# 20.02.25 23.18
