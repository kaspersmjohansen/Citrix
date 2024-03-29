<# 
*************************************************************************************************************************************************

Unattended installation of Citrix XenDesktop 7.x Controller, Director, Studio and VDA Hotfixes

Expected folder structure:

.\Hotfixes\Citrix\Controller - Hotfixes for Controller
.\Hotfixes\Citrix\Director - Hotfixes for Director
.\Hotfixes\Citrix\Studio - Hotfixes for Studio
 
.\Hotfixes\Citrix\VDA\DesktopOS\x64 - Hotfixes for VDAs for 64-bit desktop OS (Windows 7, Windows 8.1)
.\Hotfixes\Citrix\VDA\DesktopOS\x86 - Hotfixes VDAs for 32-bit desktop OS (Windows 7, Windows 8.1)
.\Hotfixes\Citrix\VDA\ServerOS - Hotfixes for VDAs for server OS (Windows Server 2008 R2, Windows Server 2012 R2)

Copy hotfixes for the installed roles to the folders specified above, the script will automatically install any MSP or MSI files in these folders

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 14-01-2015

*************************************************************************************************************************************************
#>
# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

Push-Location $InstallDir
cd..

clear

# Install Citrix Delivery Controller hotfixes
If (Get-ItemProperty -Path "HKLM:SOFTWARE\Citrix\Broker\Service" -Name InstallLocation -ErrorAction SilentlyContinue){

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Citrix XenDesktop Delivery Controller Hotfixes"
Write-Host

ls ".\Hotfixes\Citrix\Controller\*.msi" | %{start -wait $_ -argumentlist '/qb- /norestart'}
ls ".\Hotfixes\Citrix\Controller\*.msp" | %{start -wait $_ -argumentlist '/qb- /norestart'}
}
else{
Write-Host
Write-Host -BackgroundColor Red -ForegroundColor Black "Citrix XenDesktop Delivery Controller NOT found"
Write-Host
}

# Install Citrix Director hotfixes
If (Get-ItemProperty -Path "HKLM:SOFTWARE\Wow6432Node\Citrix\DesktopDirector" -Name URL -ErrorAction SilentlyContinue){

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Citrix XenDesktop Director Hotfixes"
Write-Host

ls ".\Hotfixes\Citrix\Director\*.msi" | %{start -wait $_ -argumentlist '/qb- /norestart'}
ls ".\Hotfixes\Citrix\Director\*.msp" | %{start -wait $_ -argumentlist '/qb- /norestart'}
}
else{
Write-Host
Write-Host -BackgroundColor Red -ForegroundColor Black "Citrix XenDesktop Director NOT found"
Write-Host
}

# Install Citrix Studio hotfixes
If (Get-ItemProperty -Path "HKLM:SOFTWARE\Citrix\DesktopStudio" -Name InstallLocation -ErrorAction SilentlyContinue){

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Citrix XenDesktop Studio Hotfixes"
Write-Host

ls ".\Hotfixes\Citrix\Studio\*.msi" | %{start -wait $_ -argumentlist '/qb- /norestart'}
ls ".\Hotfixes\Citrix\Studio\*.msp" | %{start -wait $_ -argumentlist '/qb- /norestart'}
}
else{
Write-Host
Write-Host -BackgroundColor Red -ForegroundColor Black "Citrix XenDesktop Studio NOT found"
Write-Host
}

# Install VDA Hotfixes
If (Get-ItemProperty -Path "HKLM:SOFTWARE\Citrix\VirtualDesktopAgent" -Name ProductInstalled -ErrorAction SilentlyContinue){

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Citrix XenDesktop VDA Hotfixes"
Write-Host
Write-Host
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Operating System - $OSArchitecture $OS"
Write-Host

# Install Citrix XenDesktop VDA server OS hotfixes
If ($OS -Like "Windows Server 2012*" -or $OS -Like "Windows Server 2008 R2*"){
ls ".\Hotfixes\Citrix\VDA\ServerOS\*.msi" | %{start -wait $_ -argumentlist '/qb- /norestart'}
ls ".\Hotfixes\Citrix\VDA\ServerOS\*.msp" | %{start -wait $_ -argumentlist '/qb- /norestart'}
}

# Install Citrix XenDesktop VDA desktop OS hotfixes
If ($OS -Like "Windows 7*" -or $OS -Like "Windows 8*" -or $OS -Like "Windows 10*"){
# Install hotfixes for 64-bit OS
If ($OSArchitecture -eq "64-bit"){
ls ".\Hotfixes\Citrix\VDA\DesktopOS\x64\*.msi" | %{start -wait $_ -argumentlist '/qb- /norestart'}
ls ".\Hotfixes\Citrix\VDA\DesktopOS\x64\*.msp" | %{start -wait $_ -argumentlist '/qb- /norestart'}
}
# Install hotfixes for 32-bit OS
If ($OSArchitecture -eq "32-bit"){
ls ".\Hotfixes\Citrix\VDA\DesktopOS\x86\*.msi" | %{start -wait $_ -argumentlist '/qb- /norestart'}
ls ".\Hotfixes\Citrix\VDA\DesktopOS\x86\*.msp" | %{start -wait $_ -argumentlist '/qb- /norestart'}
}
}
}
else{
Write-Host
Write-Host -BackgroundColor Red -ForegroundColor Black "Citrix XenDesktop VDA NOT found"
Write-Host
}
Pop-Location