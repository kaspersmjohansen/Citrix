# *********************************************************************************************
#
# Unattended installation of Citrix XenDesktop 7.x Director and prerequisites
# The script assumes that the XenDesktop 7.x source files are copied to a subfolder called XenDesktop
# 
# Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
# date: 27-03-2014
#
#*********************************************************************************************

# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing Windows Roles and Features Prerequisites"
Write-Host

# Install IIS Roles and Windows Remote Assistance based on OS
# Windows Server 2008 R2 and Windows Server 2012/2012 R2 is supported
if ($OS -Like "Windows Server 2008 R2*"){
Import-Module ServerManager
Add-WindowsFeature Remote-Assistance,NET-Framework-Core,NET-Framework,Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Static-Content,Web-Http-Redirect,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Http-Tracing,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-App-Dev,Web-ASP,Web-CGI,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Scripting,Web-WMI,Web-Scripting-Tools,Web-Mgmt-Service,WAS,WAS-Process-Model,WAS-Config-APIs,NET-Win-CFAC,NET-HTTP-Activation,WAS-NET-Environment -logpath "$LogDir\WindowsRoles.txt"
} elseif (($OS -Like "Windows Server 2012*") -or ($OS -Like "Windows Server 2012 R2*")){
Import-Module ServerManager
Install-WindowsFeature Remote-Assistance,Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Static-Content,Web-Http-Redirect,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Http-Tracing,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-App-Dev,Web-Net-Ext45,Web-ASP,Web-Asp-Net45,Web-CGI,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Scripting,Web-WMI,Web-Scripting-Tools,Web-Mgmt-Service,NET-WCF-HTTP-Activation45,WAS,WAS-Process-Model,WAS-Config-APIs -logpath "$LogDir\WindowsRoles.txt" 
            
# Install .NET Framework 3.5
# Change registry to enable .NET Framework 3.5 files are retrieved directly from Windows Update and not local WSUS
# New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies -Name Servicing |Out-Null
# New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Servicing" -Name LocalSourcePath -Value "" -PropertyType ExpandString -Force |Out-Null
# New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Servicing" -Name RepairContentServerSource -Value "2" -PropertyType Dword -Force |Out-Null
# DISM /Online /Enable-Feature /FeatureName:NetFx3 /All | Out-File "$LogDir\NETFramework35.txt"
#Delete registry changes
# Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Servicing |Out-Null
}

Push-Location $InstallDir
cd..

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing XenDesktop 7.x Director"
Write-Host

# Install XenDesktop 7.x Director
Start-Process -Wait ".\x64\XenDesktop Setup\xendesktopserversetup.exe" -ArgumentList "/components DESKTOPDIRECTOR /configure_firewall /quiet /noreboot /logpath $LogDir"

Pop-Location

# Configure default domain in Director login page
$text = 'TextBox ID="Domain"'
$replacetext1 = 'TextBox ID="Domain" Text="'
$replacetext2 = $env:userdnsdomain
$replacetext3 = '" readonly="true"'
$replacetext = $replacetext1 + $replacetext2 + $replacetext3

$pathToFile = "C:\inetpub\wwwroot\Director"

Rename-Item $pathToFile\logon.aspx $pathToFile\logon.aspx.org
Get-Content $pathToFile\logon.aspx.org | % {$_ -replace $text, $replacetext} | set-content $pathToFile\logon.aspx