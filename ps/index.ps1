# =============================
# Paramètres à personnaliser
# =============================
$Owner         = "sidlaunay"
$Repo          = "script-public"
$Branch        = "main"
$BasePath      = "ps"  # On s'intéresse aux fichiers sous ps/
$RawBaseUrl    = "https://dev.slaunay.com/ps"   # Pour exécuter (reverse proxy)
# =============================

# Optionnel : gérer un token GitHub si tu veux éviter le rate-limit
$token = $Env:GITHUB_TOKEN  # Ou commente si pas besoin
$headers = @{
    "User-Agent" = "SidLaunayPowerShellScript-TREE"
}
if ($token) {
    $headers["Authorization"] = "token $token"
}

# On force TLS1.2 si PowerShell 5.x
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# =============================
# 1) Charger la liste TOTALE via l'API "git/trees"
# =============================
Write-Host "Chargement de l'arborescence complète '$Owner/$Repo' (branche $Branch) ..."

$treeUrl = "https://api.github.com/repos/$Owner/$Repo/git/trees/$Branch?recursive=1"
try {
    $allData = Invoke-RestMethod -Uri $treeUrl -Headers $headers
} catch {
    Write-Host "ERREUR : Impossible de charger l'arborescence. $($_.Exception.Message)"
    return
}

if (-not $allData.tree) {
    Write-Host "Aucune donnée 'tree' trouvée. Arborescence vide ou erreur ?"
    return
}

# On récupère tous les items
$allItems = $allData.tree

# =============================
# 2) Construire une structure en mémoire
# =============================

# Filtrer uniquement le sous-dossier ps/ (si tu ne veux pas tout le repo)
# Et ignorer éventuellement les .gitignore ou autres
$filtered = $allItems | Where-Object {
    $_.path -like "$BasePath/*" -and
    ($_.type -in @("blob","tree"))   # "blob" = fichier, "tree" = dossier
}

# Chaque élément ressemble à : 
# {
#   "path": "ps/administration/printer.ps1",
#   "mode": "...",
#   "type": "blob",   # ou "tree"
#   "sha":  "...",
#   ...
# }

# Nous allons construire une "arborescence" sous forme d'objets (ou un simple dictionnaire).
# Ex.: root
#      └─ ps
#         ├─ administration (type=tree)
#         │   └─ printer.ps1 (type=blob)
#         ├─ test1.ps1
#         └─ test2

function New-Node($name, $isDir) {
    [PSCustomObject]@{
        Name     = $name
        IsDir    = $isDir
        Children = @()
        # On pourra rajouter d'autres champs si besoin
    }
}

# On crée un "RootNode" fictif qui contiendra "ps" en sous-dossier, etc.
$RootNode = New-Node -name "ROOT" -isDir $true

# Un hashtable pour accéder rapidement à un chemin -> le node
# clé = "ps/administration" etc.
$nodeByPath = @{}
$nodeByPath[""] = $RootNode  # racine

# On boucle sur chaque élément
foreach ($item in $filtered) {
    $fullPath = $item.path  # ex: ps/administration/printer.ps1
    $parts    = $fullPath.Split("/")
    # ex: ["ps","administration","printer.ps1"]

    # On va construire pas à pas
    $currentPath = ""
    $parentNode  = $RootNode

    for ($i=0; $i -lt $parts.Count; $i++) {
        $p = $parts[$i]
        $isLast = ($i -eq ($parts.Count - 1))

        $currentPath = if ($currentPath) { "$currentPath/$p" } else { $p }

        if (-not $nodeByPath.ContainsKey($currentPath)) {
            # Créer un nouveau node
            $isDir = if ($isLast) { $item.type -eq "tree" } else { $item.type -eq "tree" -and $i -lt ($parts.Count - 1) }
            if ($item.type -eq "blob" -and -not $isLast) {
                # c'est bizarre, un "blob" qui n'est pas le dernier ?
                # on ignore, ou on corrige
            }
            $newNode = New-Node -name $p -isDir ($item.type -eq "tree" -and $isLast -eq $true)
            $nodeByPath[$currentPath] = $newNode
            # On l'ajoute comme enfant du parentNode
            $parentNode.Children += $newNode
        }

        # Avancer le parentNode
        $parentNode = $nodeByPath[$currentPath]
    }
}

# =============================
# 3) Parcours / menu interactif local
# =============================

function Browse-Node($node, $parentPath) {
    # $node: un PSCustomObject {Name,IsDir,Children}
    # $parentPath: ex "ps/administration"

    Write-Host "`n=== Dossier: $($node.Name) (chemin: $parentPath) ==="

    # Lister tous les enfants, d'abord dossiers, puis fichiers
    $dirs  = $node.Children | Where-Object { $_.IsDir -eq $true }
    $files = $node.Children | Where-Object { $_.IsDir -eq $false }

    if (($dirs.Count + $files.Count) -eq 0) {
        Write-Host "(Aucun sous-dossier ni fichier)"
    }
    else {
        $menuItems = New-Object System.Collections.Generic.List[PSObject]
        foreach ($d in $dirs) {
            $menuItems.Add([PSCustomObject]@{
                Type = "dir"
                Node = $d
            })
        }
        foreach ($f in $files) {
            $menuItems.Add([PSCustomObject]@{
                Type = "file"
                Node = $f
            })
        }

        # Afficher le menu
        for ($i=0; $i -lt $menuItems.Count; $i++) {
            $num = $i+1
            if ($menuItems[$i].Type -eq "dir") {
                Write-Host "$num) [Dossier] $($menuItems[$i].Node.Name)"
            }
            else {
                Write-Host "$num) $($menuItems[$i].Node.Name)"
            }
        }

        # Option: remonter ?
        Write-Host "R) Revenir au dossier parent"
        Write-Host "Q) Quitter"

        $choice = Read-Host "`nTapez un numéro, R ou Q"

        if ($choice -eq 'Q') {
            Write-Host "Quitter."
            return $null  # signal de sortie
        }
        elseif ($choice -eq 'R') {
            return "UP"
        }
        elseif ($choice -as [int] -ge 1 -and $choice -as [int] -le $menuItems.Count) {
            $selected = $menuItems[[int]$choice -1]
            if ($selected.Type -eq "dir") {
                # On descend
                $subNode    = $selected.Node
                $subPath    = if ($parentPath) { "$parentPath/$($subNode.Name)" } else { $subNode.Name }
                $res = Browse-Node $subNode $subPath
                if ($res -eq "UP") {
                    # On remonte
                    return "DOWNCANCELED"
                }
            }
            else {
                # c'est un fichier
                $fileNode   = $selected.Node
                $filePath   = if ($parentPath) { "$parentPath/$($fileNode.Name)" } else { $fileNode.Name }
                Write-Host "Exécution du fichier $filePath ..."
                # On appelle l'URL reverse-proxy
                iex (irm "$RawBaseUrl/$filePath")
            }
        }
        else {
            Write-Host "Choix invalide."
        }
    }

    return $null
}

# =============================
# 4) Lancer la navigation
# =============================

Write-Host "=== Arborescence chargée. Menu local sans requêtes supplémentaires. ==="
# Retrouver le noeud "ps" si tu veux démarrer direct dedans
$psNode = $nodeByPath["ps"]  # Car on a un noeud "ps"
if (-not $psNode) {
    Write-Host "Le dossier 'ps' n'existe pas dans l'arbre ?"
    return
}

# Navigation
$stack = New-Object System.Collections.Stack
$stack.Push("ps")

$currNode = $psNode
$currPath = "ps"

while($true) {
    $result = Browse-Node $currNode $currPath
    if ($result -eq "UP") {
        # Remonter
        # On enlève le dernier segment de $currPath
        if ($currPath -eq "ps") {
            Write-Host "Déjà au sommet, on ne peut plus remonter."
        }
        else {
            $parts = $currPath.Split("/")
            $up    = $parts[0..($parts.Count-2)] -join "/"
            $currPath = $up
            $currNode = $nodeByPath[$up]
        }
    }
    elseif ($result -eq $null) {
        # Soit quitter, soit descente finie
        break
    }
    elseif ($result -eq "DOWNCANCELED") {
        # L'utilisateur a fait "R" dans un sous-dossier
        # On ne bouge pas le path
    }
}

Write-Host "Fin de la navigation."
