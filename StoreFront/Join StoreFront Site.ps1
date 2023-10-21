# Script wide variables
$ScriptDir = (Get-Location).Path
$OS = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# Primary Storefront server hostname
$PrimSFHostName = "sftest01.ocdevil.local"
$ClusterJoinPassPath = "c$\_Atea\StoreFront"

# Certificate information
$PFXCertName = "storefront.ocdevil.local.pfx"
$PFXCertpwd = "Passw0rd"
$PFXCertSubject = "CN=storefront.ocdevil.local"

# ***************************************************************************
# Do not change anything below this line, unless you know what you are doing!
#
# ***************************************************************************

# Install IIS Roles and Features - Windows Server 2008 R2 and Windows Server 2012/2012 R2 are supported
if ($OS -Like "Windows Server 2008 R2*"){
Import-Module ServerManager
Add-WindowsFeature NET-Framework-Core,NET-Framework,Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Static-Content,Web-Http-Redirect,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Http-Tracing,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-App-Dev,Web-ASP,Web-CGI,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Scripting,Web-WMI,Web-Scripting-Tools,Web-Mgmt-Service,WAS,WAS-Process-Model,WAS-Config-APIs,NET-Win-CFAC,NET-HTTP-Activation,WAS-NET-Environment -logpath "$LogDir\WindowsRoles.txt"
}
elseif ($OS -Like "Windows Server 2012*"){
Import-Module ServerManager
Install-WindowsFeature Web-Server,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Static-Content,Web-Http-Redirect,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Http-Tracing,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Basic-Auth,Web-Windows-Auth,Web-App-Dev,Web-Net-Ext45,Web-ASP,Web-Asp-Net45,Web-AppInit,Web-CGI,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Scripting,Web-WMI,Web-Scripting-Tools,Web-Mgmt-Service,NET-WCF-HTTP-Activation45,WAS,WAS-Process-Model,WAS-Config-APIs -logpath "$LogDir\WindowsRoles.txt" 
}

#Import certificate and bind it to IIS HTTPS listener
Push-Location $ScriptDir

certutil -f -importpfx -p $PFXCertpwd ".\Certificate\$PFXCertName"

Pop-Location

Import-Module WebAdministration

Push-Location "IIS:\SslBindings"

$CertDir = dir Cert:\LocalMachine\My | Where-Object {$_.Subject -like "$PFXCertSubject*"}
$CertThumbprint=$CertDir.Thumbprint.ToString()

New-webBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
Get-Item Cert:\LocalMachine\MY\$CertThumbprint | new-item 0.0.0.0!443

Pop-Location

#Install StoreFront
Push-Location $ScriptDir

Start-Process -Wait ".\CitrixStoreFront-x64" -ArgumentList "-silent"

Pop-Location

#Import SF modules
Push-Location "C:\Program Files\Citrix\Receiver StoreFront\Scripts"

.\ImportModules.ps1

Pop-Location

#Retrieve the authorization code to join a StoreFront Cluster.
If (Test-Path "\\$PrimSFHostName\$ClusterJoinPassPath\ClusterPasscode\PassCode.txt"){
$authorizerPasscode,$remainingLines = Get-Content "\\$PrimSFHostName\$ClusterJoinPassPath\ClusterPasscode\PassCode.txt"
Write-Host "PassCode : $authorizerPasscode"

Start-DSXdServerGroupJoinService
Start-DSXdServerGroupMemberJoin -authorizerHostName $PrimSFHostName -authorizerPasscode $authorizerPasscode
 
# Later (wait at least 5min...)
Write-host "Joining StoreFront Site - Please wait..."
Start-Sleep -s 300
 
#stop the ClusterJoinService
$s = New-PSSession -ComputerName $PrimSFHostName
Invoke-Command -Session $s {cd "C:\Program Files\Citrix\Receiver StoreFront\Scripts\"}
Invoke-Command -Session $s {.\ImportModules.ps1}
Invoke-Command -Session $s {Stop-DSXdServerGroupJoinService}
Stop-DSXdServerGroupJoinService

# Propagate changes in server group
Invoke-Command -Session $s {Start-DSClusterConfigurationUpdate}

Write-host "Junction done"
}
Else{
 Write-host "No PassCode file in destination"
}

# Enable Windows Firewall rule to enable admin shares
Import-Module NetSecurity
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"