<#
*********************************************************************************************

Unattended installation of Citrix XenDesktop 7.x Controller and prerequisites for PoC use
The script assumes the XenDesktop 7.x source files are in a subfolder called XenDesktop
The script also installs SQL Express

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 25-06-2015

*********************************************************************************************
#>

# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (Get-WmiObject Win32_OperatingSystem).Caption
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

Push-Location $InstallDir
cd..

clear

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x Controller Prerequisites"
Write-Host
Write-Host
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Operating System - $OSArchitecture $OS"
Write-Host

# Install Microsoft Visual C++ Redistributables Prerequisites
Start-Process -Wait ".\Support\VcRedist_2008_SP1\vcredist_x86.exe" -ArgumentList "/q /l $LogDir\vcredist_2008SP1_x86.log"
Start-Process -Wait ".\Support\VcRedist_2008_SP1\vcredist_x64.exe" -ArgumentList "/q /l $LogDir\vcredist_2008SP1_x64.log"
Start-Process -Wait ".\Support\VcRedist_2010_SP1\vcredist_x86.exe" -ArgumentList "/q /norestart /log $LogDir\vcredist_2010SP1_x86.log"
Start-Process -Wait ".\Support\VcRedist_2010_SP1\vcredist_x64.exe" -ArgumentList "/q /norestart /log $LogDir\vcredist_2010SP1_x64.log"
Start-Process -Wait ".\Support\VcRedist_2013_RTM\vcredist_x86.exe" -ArgumentList "/q /norestart /log $LogDir\vcredist_2013_x86.log"
Start-Process -Wait ".\Support\VcRedist_2013_RTM\vcredist_x64.exe" -ArgumentList "/q /norestart /log $LogDir\vcredist_2013_x64.log"

# Install .NET Framework 4 Prerequisite 
If ($OS -Like "*Windows Server 2008 R2*"){
Start-Process -Wait ".\Support\DotNet451\NDP451-KB2858728-x86-x64-AllOS-ENU.exe" -ArgumentList "/norestart /q /log $LogDir\.NET_Framework_451.log"
}

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x Controller"
Write-Host
Write-Host
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Operating System - $OSArchitecture $OS"
Write-Host

# Install XenDesktop 7.x Controller
Start-Process -Wait ".\x64\XenDesktop Setup\xendesktopserversetup.exe" -ArgumentList "/components CONTROLLER /configure_firewall /quiet /noreboot"

Pop-Location