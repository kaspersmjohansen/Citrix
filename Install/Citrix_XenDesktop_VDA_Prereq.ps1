<#
**********************************************************************************************

Unattended installation of Citrix XenDesktop 7.x VDA Prerequisites
The script assumes the XenDesktop 7.x source files are copied to a subfolder called XenDesktop
 
For more information about which values are acceptable, please visit the Citrix eDocs:
http://support.citrix.com/proddocs/topic/xenapp-xendesktop-76/xad-install-command.html
 
Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 01-06-2015

***********************************************************************************************
#>

# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

Push-Location $InstallDir
cd..

clear

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x VDA Prerequisites"
Write-Host
Write-Host
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Operating System - $OSArchitecture $OS"
Write-Host

# Install XenDesktop 7.x Desktop OS VDA - 64-bit
If ($OSArchitecture -eq "64-bit"){
Start-Process -Wait ".\Support\VcRedist_2005\vcredist_x86.exe" -ArgumentList "/Q"
Start-Process -Wait ".\Support\VcRedist_2005\vcredist_x64.exe" -ArgumentList "/Q"
Start-Process -Wait ".\Support\VcRedist_2008_SP1\vcredist_x86.exe" -ArgumentList "/q /norestart"
Start-Process -Wait ".\Support\VcRedist_2008_SP1\vcredist_x64.exe" -ArgumentList "/q /norestart"
Start-Process -Wait ".\Support\VcRedist_2010_RTM\vcredist_x86.exe" -ArgumentList "/q /norestart"
Start-Process -Wait ".\Support\VcRedist_2010_RTM\vcredist_x64.exe" -ArgumentList "/q /norestart"
Start-Process -Wait ".\Support\VcRedist_2013\vcredist_x86.exe" -ArgumentList "/quiet /norestart"
Start-Process -Wait ".\Support\VcRedist_2013\vcredist_x64.exe" -ArgumentList "/quiet /norestart"

}

# Install XenDesktop 7.x Desktop OS VDA - 32-bit
If ($OSArchitecture -eq "32-bit"){
Start-Process -Wait ".\Support\VcRedist_2005\vcredist_x86.exe" -ArgumentList "/Q"
Start-Process -Wait ".\Support\VcRedist_2008_SP1\vcredist_x86.exe" -ArgumentList "/q /norestart"
Start-Process -Wait ".\Support\VcRedist_2010_RTM\vcredist_x86.exe" -ArgumentList "/q /norestart"
Start-Process -Wait ".\Support\VcRedist_2013\VcRedist_2013\vcredist_x86.exe" -ArgumentList "/quiet /norestart"
}

Pop-Location