# DESCRIPTION: Teste la connexion réseau vers une IP spécifique avec des détails sur la latence et la connectivité.
$hostToTest = "8.8.8.8"
Write-Host "Test de ping vers $hostToTest..." -ForegroundColor Yellow
Test-NetConnection -ComputerName $hostToTest -InformationLevel Detailed
