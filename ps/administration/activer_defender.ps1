# DESCRIPTION: Script PowerShell pour réactiver Windows Defender

# Vérification des droits d'administration
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Ce script doit être exécuté en tant qu'administrateur !" -ForegroundColor Red
    Exit
}

# Réactivation de Windows Defender via les stratégies de groupe (GPO)
Write-Host "Réactivation de Windows Defender..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableIOAVProtection $false
Set-MpPreference -DisableScriptScanning $false

# Activation du service Windows Defender
Write-Host "Activation du service Windows Defender..." -ForegroundColor Yellow
Set-Service -Name WinDefend -StartupType Automatic
Start-Service -Name WinDefend

# Suppression des entrées de registre qui empêchent la réactivation
Write-Host "Suppression des modifications du registre..." -ForegroundColor Yellow
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableBehaviorMonitoring" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /f

Write-Host "Windows Defender est maintenant activé." -ForegroundColor Green
