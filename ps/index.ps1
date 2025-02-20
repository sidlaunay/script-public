# =============================
# Configuration des paramètres GitHub et Proxy
# =============================
$Owner         = "sidlaunay"
$Repo          = "script-public"
$Branch        = "main"
$BasePath      = "ps"
$RawBaseUrl    = "https://dev.slaunay.com/ps"

$Headers = @{
    "User-Agent" = "SidLaunayPowerShellScript-TREE"
}

# =============================
# Vérification de la connexion à l'API GitHub
# =============================
if (-not $Branch -or $Branch -eq "") {
    Write-Host "❌ ERREUR : La variable `\$Branch` est vide. Vérifiez que la branche GitHub est bien définie."
    return
}

$TreeUrl = "https://api.github.com/repos/$Owner/$Repo/git/trees/$Branch?recursive=1"
Write-Host "🔄 Chargement de l'arborescence complète '$Owner/$Repo' (branche $Branch) ..."
Write-Host "DEBUG: URL API GitHub = $TreeUrl"

try {
    $AllData = Invoke-RestMethod -Uri $TreeUrl -Headers $Headers
} catch {
    Write-Host "❌ ERREUR : Impossible de charger l'arborescence depuis GitHub."
    Write-Host "   - Vérifiez l'URL GitHub : $TreeUrl"
    Write-Host "   - Vérifiez l'existence du repo '$Owner/$Repo'"
    Write-Host "   - Vérifiez que la branche '$Branch' existe bien"
    Write-Host "   - Si le repo est privé, ajoutez un token d'authentification"
    return
}

if (-not $AllData.tree) {
    Write-Host "❌ ERREUR : Aucune donnée 'tree' trouvée. L'arborescence est vide ou il y a une erreur."
    return
}

# =============================
# Filtrage des fichiers/dossiers sous "ps/"
# =============================
$AllItems = $AllData.tree | Where-Object {
    $_.path -like "$BasePath/*" -and ($_.type -in @("blob", "tree"))
}

# =============================
# Construction de l'arborescence en mémoire
# =============================
function New-Node($Name, $IsDir) {
    [PSCustomObject]@{
        Name     = $Name
        IsDir    = $IsDir
        Children = @()
    }
}

$RootNode = New-Node -Name "ROOT" -IsDir $true
$NodeByPath = @{"" = $RootNode}

foreach ($Item in $AllItems) {
    $FullPath = $Item.path
    $Parts    = $FullPath.Split("/")
    $CurrentPath = ""
    $ParentNode = $RootNode

    for ($i=0; $i -lt $Parts.Count; $i++) {
        $P = $Parts[$i]
        $IsLast = ($i -eq ($Parts.Count - 1))

        $CurrentPath = if ($CurrentPath) { "$CurrentPath/$P" } else { $P }

        if (-not $NodeByPath.ContainsKey($CurrentPath)) {
            $IsDir = ($Item.type -eq "tree" -or $IsLast -eq $false)
            $NewNode = New-Node -Name $P -IsDir $IsDir
            $NodeByPath[$CurrentPath] = $NewNode
            $ParentNode.Children += $NewNode
        }

        $ParentNode = $NodeByPath[$CurrentPath]
    }
}

# =============================
# Fonction de navigation
# =============================
function Browse-Node($Node, $ParentPath) {
    Write-Host "`n📂 === Dossier: $($Node.Name) (chemin: $ParentPath) ==="

    $Dirs  = $Node.Children | Where-Object { $_.IsDir -eq $true }
    $Files = $Node.Children | Where-Object { $_.IsDir -eq $false }

    if (($Dirs.Count + $Files.Count) -eq 0) {
        Write-Host "(Aucun sous-dossier ni fichier)"
    } else {
        $MenuItems = @()
        foreach ($D in $Dirs) { $MenuItems += [PSCustomObject]@{ Type = "dir"; Node = $D } }
        foreach ($F in $Files) { $MenuItems += [PSCustomObject]@{ Type = "file"; Node = $F } }

        for ($i=0; $i -lt $MenuItems.Count; $i++) {
            $Num = $i+1
            if ($MenuItems[$i].Type -eq "dir") {
                Write-Host "$Num) 📁 [Dossier] $($MenuItems[$i].Node.Name)"
            } else {
                Write-Host "$Num) 📄 $($MenuItems[$i].Node.Name)"
            }
        }

        Write-Host "`n🔙 R) Revenir en arrière"
        Write-Host "❌ Q) Quitter"

        $Choice = Read-Host "`n📌 Choisissez une option"

        if ($Choice -eq 'Q') {
            Write-Host "👋 Quitter."
            return $null
        } elseif ($Choice -eq 'R') {
            return "UP"
        } elseif ($Choice -match "^\d+$" -and [int]$Choice -gt 0 -and [int]$Choice -le $MenuItems.Count) {
            $Selected = $MenuItems[[int]$Choice -1]
            if ($Selected.Type -eq "dir") {
                $SubNode = $Selected.Node
                $SubPath = if ($ParentPath) { "$ParentPath/$($SubNode.Name)" } else { $SubNode.Name }
                $Res = Browse-Node $SubNode $SubPath
                if ($Res -eq "UP") { return "DOWNCANCELED" }
            } else {
                $FileNode = $Selected.Node
                $FilePath = if ($ParentPath) { "$ParentPath/$($FileNode.Name)" } else { $FileNode.Name }
                Write-Host "▶️ Exécution du fichier $FilePath ..."

                # Sécurisation : Exécute seulement si c'est un fichier .ps1
                if ($FilePath -match "\.ps1$") {
                    try {
                        iex (irm "$RawBaseUrl/$FilePath")
                    } catch {
                        Write-Host "❌ ERREUR : Impossible d'exécuter $FilePath"
                    }
                } else {
                    Write-Host "⚠️ Ce fichier ne peut pas être exécuté."
                }
            }
        } else {
            Write-Host "❌ Choix invalide."
        }
    }
    return $null
}

# =============================
# Lancer la navigation
# =============================
Write-Host "✅ Arborescence chargée. Naviguez avec le menu ci-dessous."

$PsNode = $NodeByPath["ps"]
if (-not $PsNode) {
    Write-Host "❌ Le dossier 'ps' n'existe pas."
    return
}

$CurrNode = $PsNode
$CurrPath = "ps"

while ($true) {
    $Result = Browse-Node $CurrNode $CurrPath
    if ($Result -eq "UP") {
        if ($CurrPath -eq "ps") {
            Write-Host "🔝 Déjà au sommet, impossible de remonter."
        } else {
            $Parts = $CurrPath.Split("/")
            $Up = $Parts[0..($Parts.Count-2)] -join "/"
            $CurrPath = $Up
            $CurrNode = $NodeByPath[$Up]
        }
    } elseif ($Result -eq $null) {
        break
    } elseif ($Result -eq "DOWNCANCELED") {
        continue
    }
}

Write-Host "👋 Fin de la navigation."

# 20.02.25 21.08
