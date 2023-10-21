# **********************************************************************************************
#
# Unattended installation of Citrix XenDesktop 7.x VDA
# The script assumes the XenDesktop 7.x source files are copied to a subfolder called XenDesktop
# 
# Please fill in the relevant values in the $ComponentsServerOS and/or $ComponentsDesktopOS, XDCControllers and $Arguments variables
#
# For more information about which values are acceptable, please visit the Citrix eDocs:
# http://support.citrix.com/proddocs/topic/xenapp-xendesktop-76/xad-install-command.html
# 
# Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
# Date: 27-03-2014
#
#***********************************************************************************************

# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

$ComponentsServerOS = "VDA"
$ComponentsDesktopOS = "VDA"
$XDCControllers = ""

$Arguments = "/Controllers `"$XDCControllers`" /QUIET /ENABLE_HDX_PORTS /ENABLE_REAL_TIME_TRANSPORT /ENABLE_REMOTE_ASSISTANCE /MASTERIMAGE /OPTIMIZE /NOREBOOT /logpath $LogDir"

Push-Location $InstallDir
cd..

clear

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x VDA"
Write-Host
Write-Host
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Operating System - $OSArchitecture $OS"
Write-Host

# Install XenDesktop 7.x Server OS VDA - 64-bit
If (($OSArchitecture -eq "64-bit") -and ($OS -Like "Windows Server 2012*" -or $OS -Like "Windows Server 2012*" -or $OS -Like "Windows Server 2008 R2*")){
Start-Process -Wait ".\x64\XenDesktop Setup\VDAServerSetup_7.6.300.exe" -ArgumentList "/COMPONENTS $ComponentsServerOS $Arguments"
}

# Install XenDesktop 7.x Desktop OS VDA - 64-bit
If (($OSArchitecture -eq "64-bit") -and ($OS -Like "Windows 7*" -or $OS -Like "Windows 8*" -or $OS -Like "Windows 10*")){
Start-Process -Wait ".\x64\XenDesktop Setup\VDAWorkstationSetup_7.6.300.exe" -ArgumentList "/COMPONENTS $ComponentsDesktopOS $Arguments"
}

# Install XenDesktop 7.x Desktop OS VDA - 32-bit
If (($OSArchitecture -eq "32-bit") -and ($OS -Like "Windows 7*" -or $OS -Like "Windows 8*" -or $OS -Like "Windows 10*")){
Start-Process -Wait ".\x86\XenDesktop Setup\VDAWorkstationSetup_7.6.300.exe" -ArgumentList "/COMPONENTS $ComponentsDesktopOS $Arguments"
}

Pop-Location