# DESCRIPTION: Script PowerShell pour désactiver Windows Defender

# Vérification des droits d'administration
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Ce script doit être exécuté en tant qu'administrateur !" -ForegroundColor Red
    Exit
}

# Désactivation de Windows Defender via les stratégies de groupe (GPO)
Write-Host "Désactivation de Windows Defender..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableScriptScanning $true

# Désactivation du service Windows Defender
Write-Host "Arrêt et désactivation du service Windows Defender..." -ForegroundColor Yellow
Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
Set-Service -Name WinDefend -StartupType Disabled

# Désactivation via le registre pour empêcher la réactivation après redémarrage
Write-Host "Modification du registre pour empêcher la réactivation..." -ForegroundColor Yellow
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f

Write-Host "Windows Defender est maintenant désactivé." -ForegroundColor Green
