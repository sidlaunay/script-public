Write-Host "=== Menu scripts PowerShell ==="
Write-Host

# Liste statique :
$scripts = @(
    "test1.ps1",
    "test2.ps1"
)

for ($i = 0; $i -lt $scripts.Count; $i++) {
    $n = $i + 1
    Write-Host "$n) $($scripts[$i])"
}

$choice = Read-Host "Tapez un numéro pour lancer le script"
if ($choice -lt 1 -or $choice -gt $scripts.Count) {
    Write-Host "Choix invalide."
    return
}

$selected = $scripts[$choice - 1]
Write-Host "Chargement de $selected ..."
iex (irm "https://dev.slaunay.com/ps/$selected")
