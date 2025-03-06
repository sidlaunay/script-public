# DESCRIPTION: Windows Office activator

# Check massgrave.dev for more details

# Vérifie si PowerShell est exécuté en mode administrateur
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-Not $isAdmin) {
    Write-Host "Demande d'élévation des privilèges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
    Exit
}

# Exécute directement le script en mode administrateur
Write-Host "Téléchargement et exécution du script The Ultimate Windows Utility..." -ForegroundColor Cyan
irm https://get.activated.win | iex
