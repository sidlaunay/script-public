# DESCRIPTION:The Ultimate Windows Utility - Clean up Windows 10 PowerShell Script
# Ce script demande l'élévation de privilèges avant d'exécuter le script de Chris Titus.

# Vérifie si le script est exécuté en mode administrateur
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# Si le script n'est pas exécuté en tant qu'administrateur, il relance PowerShell en mode admin
if (-Not $isAdmin) {
    Write-Host "Demande d'élévation des privilèges..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Télécharge et exécute le script de Chris Titus
Write-Host "Exécution du script The Ultimate Windows Utility..." -ForegroundColor Cyan
iwr -useb https://christitus.com/win | iex
