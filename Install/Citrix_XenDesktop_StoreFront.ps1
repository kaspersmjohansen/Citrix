# *********************************************************************************************
#
# Unattended installation of Citrix XenDesktop 7.x StoreFront
# The script assumes the XenDesktop 7.x source files are copied to a subfolder called XenDesktop
# 
# Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
# Date: 27-03-2014
#
#*********************************************************************************************

# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Windows Roles and Features Prerequisites"
Write-Host

# Install IIS Roles and Features - Windows Server 2008 R2 and Windows Server 2012/2012 R2 are supported
if ($OS -Like "Windows Server 2008 R2*"){
Import-Module ServerManager
Add-WindowsFeature NET-Framework-Core,NET-Framework,Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Static-Content,Web-Http-Redirect,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Http-Tracing,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-App-Dev,Web-ASP,Web-CGI,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Scripting,Web-WMI,Web-Scripting-Tools,Web-Mgmt-Service,WAS,WAS-Process-Model,WAS-Config-APIs,NET-Win-CFAC,NET-HTTP-Activation,WAS-NET-Environment -logpath "$LogDir\WindowsRoles.txt"
}
elseif (($OS -Like "Windows Server 2012*") -or ($OS -Like "Windows Server 2012 R2*")){
Import-Module ServerManager
Install-WindowsFeature Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Static-Content,Web-Http-Redirect,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Http-Tracing,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-App-Dev,Web-Net-Ext45,Web-ASP,Web-Asp-Net45,Web-AppInit,Web-CGI,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Scripting,Web-WMI,Web-Scripting-Tools,Web-Mgmt-Service,NET-WCF-HTTP-Activation45,WAS,WAS-Process-Model,WAS-Config-APIs -logpath "$LogDir\WindowsRoles.txt" 
}

Push-Location $InstallDir
cd..

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Citrix XenDesktop 7.x StoreFront"
Write-Host

# Install XenDesktop 7.x StoreFront
Start-Process -Wait ".\x64\XenDesktop Setup\xendesktopserversetup.exe" -ArgumentList "/components StoreFront /configure_firewall /quiet /noreboot /logpath $LogDir"

Pop-Location