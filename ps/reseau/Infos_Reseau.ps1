# DESCRIPTION: Affiche les informations réseau de la machine, y compris IP, DNS et passerelle.
Write-Host "Informations réseau de la machine :" -ForegroundColor Cyan
Get-NetIPConfiguration
