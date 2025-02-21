# DESCRIPTION: The Ultimate Windows Utility - Clean up Windows 10 PowerShell Script
# Ce script demande l'élévation de privilèges avant d'exécuter le script de Chris Titus.

# Vérifie si le script est exécuté en mode administrateur
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# Si ce n'est pas le cas, relance PowerShell avec élévation des privilèges
if (-Not $isAdmin) {
    Write-Host "Demande d'élévation des privilèges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Exécution du script Chris Titus en mode administrateur
Write-Host "Téléchargement et exécution du script The Ultimate Windows Utility..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb https://christitus.com/win | iex`"" -Verb RunAs
