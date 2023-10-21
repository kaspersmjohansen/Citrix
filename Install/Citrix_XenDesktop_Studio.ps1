# *********************************************************************************************
#
# Unattended installation of Citrix XenDesktop 7.x Studio
# The script assumes the XenDesktop 7 source files are copied to a subfolder called XenDesktop
# 
# Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
# Date: 27-03-2014
#
#*********************************************************************************************

# script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

Push-Location $InstallDir
cd..

#Install Microsoft Group  Policy Management Console
If ($OS -Like "Windows Server 2008 R2*" -or $OS -Like "Windows Server 2012*"){
Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Microsoft Group Policy Management Console"
Write-Host

if ($OS -Like "Windows Server 2008 R2*"){
Import-Module ServerManager
Add-WindowsFeature GPMC
} 
elseif ($OS -Like "Windows Server 2012*"){
Import-Module ServerManager
Install-WindowsFeature GPMC
}

}

#Install XenDesktop 7.x Studio
Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x Studio"
Write-Host

Start-Process -Wait ".\x64\XenDesktop Setup\xendesktopserversetup.exe" -ArgumentList "/components DESKTOPSTUDIO /configure_firewall /quiet /noreboot /logpath $LogDir"

Pop-Location