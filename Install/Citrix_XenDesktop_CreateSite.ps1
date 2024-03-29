<# 
************************************************************************************************************************************
This script configures and creates a new XenDesktop 7.x site and creates site hosting connections and resources

This script is created using these sites as references:
archy.net - Citrix XenDesktop 7 – Create Persistent Hypervisor Connection and Hosting Unit, Unattended - http://bit.ly/1a5UJuX
archy.net - Citrix XenDesktop 7 – Unattended from scratch - http://bit.ly/1d05oXG
Sepago - How-to create XenDesktop 7 database(s) unattended using PowerShell - http://bit.ly/10oRiMQ
Citrix Blogs - XenDesktop 7 Site Creation via PowerShell - http://bit.ly/1hksQ3S

Thx to Stephane Thirion @ archy.net , Thomas Fuhrmann @ The Citrix Blogs and Timm Brochhaus @ sepago

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 07-07-2015

*******************************************************************************************************************************************************

$DatabaseServer = "SQL server computername"
$DatabaseName_Site = "XenDesktop 7 Site DB name"
$DatabaseName_Logging = "XenDesktop 7 Configurationn Logging DB name"
$DatabaseName_Monitor = "XenDesktop 7 Monitoring (Director) DB name"

$DatabaseUser = "domain\user" !Database user must be sysadmin on DB server!
$DatabasePassword = "password"


$XD7Site = "XenDesktop 7 site name"
$DeliveryControllerName = Delivery Controller hostname - If the script is executed remotely, you need to define this variable, otherwise leave it blank
$FullAdminGroup = "domain\group" or "domain\user" The AD group og AD user that is to have full administrator rights in the site

$LicenseServer = "Citrix license server hostname"
$LicenseServer_LicensingModel = "Concurrent" or "UserDevice" Specifies the license type
$LicenseServer_ProductCode = "XDT" or "MPS" XDT = XenDeskstop MPS = XenApp Specifies the license product
$LicenseServer_ProductEdition = "PLT" or "ENT" or "STD" PLT = Platinum ENT = Enterprise STD = Standard

$HypervisorAddress = "http://yourXenServerAddress" use an IP or FQDN with http or https if you use vCenter, don't forget to add /sdk 
$ConnectionType = "XenServer" for XenServer value = XenServer or VMware = VCenter or Hyper-V = SCVMM
$HypervisorConnectionName = "WhateverTheNameYouWantToUse"

$HypervisorUser = Username to connect to the hypervisor
$HypervisorPassword = "password"

$NetworkName = "Host Network resource" The network name you want VDAs to connect to in the hypervisor
$StorageName = "Host Storage resource" The storage resource name you want the VDAs to be stored on in the hypervisor

$PersonalvDiskStoragePath = "Host Storage resources for pvDisk" The storage resource name you want the pvDisks to be stored on in the hypervisor
$StorageNetworkResourceName = "WhateverTheNameYouWantToUse" A logical/administrative name for the Storage and Network resource

*******************************************************************************************************************************************************
#>

# XenDesktop 7.x SQL Parameters
$DatabaseServer = "SQL01"
$DatabaseName_Site = "CitrixTest_Site"
$DatabaseName_Logging = "CitrixTest_Logging"
$DatabaseName_Monitor = "CitrixTest_Monitor"

$DatabaseUser = "ocdevil\svc_ctx"
$DatabasePassword = "Password1"

# Create XenDesktop 7.x Site and Hosting Parameters
$XD7Site = "CitrixTest"
$DeliveryControllerName = ""
$FullAdminGroup = "ocdevil\domain admins"

$LicenseServer = "SRVFIL01.ocdevil.local"
$LicenseServerPort = "27000"
$LicenseServer_LicensingModel = "Concurrent"
$LicenseServer_ProductCode = "XDT"
$LicenseServer_ProductEdition = "PLT"

$HypervisorAddress = "http://xen01.ocdevil.local"
$ConnectionType = "XenServer"
$HypervisorConnectionName = "xen01"

$HypervisorUser = "root"
$HypervisorPassword = "Passw0rd"

$NetworkName = "LAN"
$StorageName = "Test Storage 2"

$PersonalvDiskStoragePath = "$StoragePath"
$StorageNetworkResourceName = "Resource"

# Do not edit below this line, unless you know what you are doing!
# ---------------------------------------------------------------#

cls

# Verify that  Citrix XenDesktop Admin module is available
If (!(Get-Module -ListAvailable -Name "Citrix.XenDesktop.Admin")){
Write-Host
Write-Host -BackgroundColor Red  -ForegroundColor Black "The Citrix XenDesktop Admin PowerShell module is not found on this computer.."
Write-Host -BackgroundColor Red  -ForegroundColor Black "Please install Citrix XenDesktop Studio"
Write-Host
Break
}

Write-Host
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Creating and Configuring your new XenDesktop 7.x setup"
Write-Host

# Import modules and snapins
Import-Module Citrix.XenDesktop.Admin  
Add-PSSnapin Citrix.*

# Set $DeliveryControllerName variable to $env:COMPUTERNAME if not defined
If ([string]::IsNullOrWhiteSpace($DeliveryControllerName)){
$DeliveryControllerName = $env:COMPUTERNAME
}

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Creating the new databases..."
Write-Host

# Create XenDesktop 7.x Site
$DatabasePassword = $DatabasePassword | ConvertTo-SecureString -asPlainText -Force
$Database_CredObject = New-Object System.Management.Automation.PSCredential($DatabaseUser,$DatabasePassword)

# Create Databases
New-XDDatabase -AdminAddress $DeliveryControllerName -SiteName $XD7Site -DataStore Site -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Site -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $DeliveryControllerName -SiteName $XD7Site -DataStore Logging -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Logging -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $DeliveryControllerName -SiteName $XD7Site -DataStore Monitor -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Monitor -DatabaseCredentials $Database_CredObject 

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Creating the new site..."
Write-Host

# Create Site 
New-XDSite -DatabaseServer $DatabaseServer -LoggingDatabaseName $DatabaseName_Logging -MonitorDatabaseName $DatabaseName_Monitor -SiteDatabaseName $DatabaseName_Site -SiteName $XD7Site -AdminAddress $DeliveryControllerName

# ConfigureLicensing and confirm the certificate hash
Set-XDLicensing -AdminAddress $DeliveryControllerName -LicenseServerAddress $LicenseServer -LicenseServerPort $LicenseServerPort
Set-ConfigSite  -AdminAddress $DeliveryControllerName -LicensingModel $LicenseServer_LicensingModel -ProductCode $LicenseServer_ProductCode -ProductEdition $LicenseServer_ProductEdition
Set-ConfigSiteMetadata -AdminAddress $DeliveryControllerName -Name 'CertificateHash' -Value $(Get-LicCertificate -AdminAddress "https://$LicenseServer").CertHash

# Add admin group to full admins
New-AdminAdministrator -AdminAddress $DeliveryControllerName -Name $FullAdminGroup
Add-AdminRight -AdminAddress $DeliveryControllerName -Administrator $FullAdminGroup -Role 'Full Administrator' -All

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Creating the site hosting connections and resources..."
Write-Host

# Create XenDesktop 7.x Site Hosting Connections and Resources
New-Item  -AdminAddress $DeliveryControllerName -ConnectionType $ConnectionType -HypervisorAddress @($HypervisorAddress) -Path xdhyp:\connections\$HypervisorConnectionName -Persist -Scope @() -Password $HypervisorPassword -UserName $HypervisorUser
$HypervisorConnectionUid = (Get-Item  -AdminAddress $DeliveryControllerName -Path xdhyp:\connections\$HypervisorConnectionName).HypervisorConnectionUid.ToString()
New-BrokerHypervisorConnection  -AdminAddress $DeliveryControllerName -HypHypervisorConnectionUid $HypervisorConnectionUid
New-Item  -HypervisorConnectionName "$HypervisorConnectionName" -NetworkPath @("XDHyp:\Connections\$HypervisorConnectionName\$NetworkName.network") -Path @("XDHyp:\HostingUnits\$StorageNetworkResourceName") -PersonalvDiskStoragePath @("XDHyp:\Connections\$HypervisorConnectionName\$StorageName.storage") -RootPath "XDHyp:\Connections\$HypervisorConnectionName" -StoragePath @("XDHyp:\Connections\$HypervisorConnectionName\$StorageName.storage")