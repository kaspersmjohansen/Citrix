<#
*********************************************************************************************

Unattended installation of Citrix XenDesktop 7.x Controller and prerequisites
The script assumes the XenDesktop 7.x source files are in a subfolder called XenDesktop

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 27-03-2014

*********************************************************************************************
#>

# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

Push-Location $InstallDir
cd..

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x Controller"
Write-Host

# Install Microsoft Visual C++ Redistributables Prerequisites
Start-Process -Wait ".\Support\VcRedist_2005\vcredist_x64.exe" -ArgumentList "/q:a /l $LogDir\vcredist_2005_x64_log.txt"
Start-Process -Wait ".\Support\VcRedist_2008_SP1\vcredist_x64.exe" -ArgumentList "/q /l $LogDir\vcredist_2008_x64_log.txt"
Start-Process -Wait ".\Support\VcRedist_2010_RTM\vcredist_x64.exe" -ArgumentList "/q /norestart /log $LogDir\vcredist_2010_x64_log.txt"

# Install .NET Framework 4 Prerequisite 
If ($OS -Like "Windows Server 2008 R2*"){
Start Process -Wait ".\Support\DotNet4\dotNetFx40_Full_x86_x64.exe" -ArgumentList "/norestart /quiet /q:a"
}

# Install XenDesktop 7.x Controller
Start-Process -Wait ".\x64\XenDesktop Setup\xendesktopserversetup.exe" -ArgumentList "/components CONTROLLER /configure_firewall /quiet /noreboot /nosql /logpath $LogDir"

Pop-Location