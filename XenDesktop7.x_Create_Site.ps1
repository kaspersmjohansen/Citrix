# ************************************************************************************************************************************
# This script configures and creates a new XenDesktop 7 site and creates site hosting connections
#
# This script is created using these sites as references:
# archy.net - Citrix XenDesktop 7 – Create Persistent Hypervisor Connection and Hosting Unit, Unattended - http://bit.ly/1a5UJuX
# archy.net - Citrix XenDesktop 7 – Unattended from scratch - http://bit.ly/1d05oXG
# Sepago - How-to create XenDesktop 7 database(s) unattended using PowerShell - http://bit.ly/10oRiMQ
# Citrix Blogs - XenDesktop 7 Site Creation via PowerShell - http://bit.ly/1hksQ3S
#
# Thx to Stephane Thirion @ archy.net , Thomas Fuhrmann @ The Citrix Blogs and Timm Brochhaus @ sepago
#
# Modified by: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
# Modifications:
# 
# 30-11-2013:
# Implemented an IF statement to configure storage and network settings if using MCS
# If MCS is NOT used, the storage and network configuration will not be made
#
# Make changes in the top of the file to reflect your installation, explanation of the needed parameters below
#
# ************************************************************************************************************************************
# $DatabaseServer = "SQL server computername"
# $DatabaseName_Site = "XenDesktop 7 Site DB name"
# $DatabaseName_Logging = "XenDesktop 7 Configurationn Logging DB name"
# $DatabaseName_Monitor = "XenDesktop 7 Monitoring (Director) DB name"
# $XD7Site = "XenDesktop 7 site name"
# $FullAdminGroup = "domain\group" or "domain\user" The AD group og AD user that is to have full administrator rights in the site 
# $LicenseServer = "Citrix license server computername"
# $LicenseServer_LicensingModel = "Concurrent" or "UserDevice" Specifies the license type
# $LicenseServer_ProductCode = "XDT" og "MPS" Use MPS only if you are using XenDesktop 7 App Edition
# $LicenseServer_ProductEdition = "PLT" or "ENT" or "STD" PLT = Platinum ENT = Enterprise STD = Standard
# $DatabaseUser = "domain\user" !Database user must be sysadmin on DB server!
# $DatabasePassword = "password"
#
# $HypervisorAddress = "http://yourXenServerAddress" use an IP or FQDN with http or https if you use vCenter, don't forget to add /sdk 
# $ConnectionType = "XenServer" for XenServer value = XenServer , vmware = VCenter , Hyper-V = SCVMM
# $HypervisorConnectionName = "WhateverTheNameYouWantToUse"
# $Networkpath = "Host Networkname You Want To Use" Just copy and past from XenCenter
# $StoragePath = "Name of the Storage you want to use"  Just copy and past from XenCenter
# $PersonalvDiskStoragePath = "Name of the Storage you want to use for pvDisk"  Just copy and past from XenCenter
# $StorageNetworkResourceName = "WhateverTheNameYouWantToUse"
# $MCS = "Yes" If you plan on using MCS you must set this this value to "Yes" otherwise the hosting configuration will not be complete 
# ************************************************************************************************************************************

# *******************************************
# Create XenDesktop 7 Site Parameters
# *******************************************
$DatabaseServer = "DBSERVER"
$DatabaseName_Site = "XD71DS_Site"
$DatabaseName_Logging = "XD71DS_Logging"
$DatabaseName_Monitor = "XD71DS_Monitor"
$XD7Site = "XD71SITE"

$FullAdminGroup = "domain\group"

$LicenseServer = "LICSERVER"
$LicenseServer_LicensingModel = "Concurrent"
$LicenseServer_ProductCode = "XDT"
$LicenseServer_ProductEdition = "PLT"

$DatabaseUser = "domain\user"
$DatabasePassword = "password"

# *******************************************
# Create XenDesktop 7 Site Hosting Parameters
# *******************************************
$HypervisorAddress = "http://"
$ConnectionType = "XenServer"
$HypervisorConnectionName = "XenServer"

$HypervisorUser = "user"
$HypervisorPassword = "password"

$MCS ="No"
$Networkpath = "LAN"
$StoragePath = "Storage"
$PersonalvDiskStoragePath = "Storage"
$StorageNetworkResourceName = "StorageNetworkResourceXD7"

# ***************************************************************
# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!
# ***************************************************************


# *******************************************
# Create XenDesktop 7 Site
# *******************************************
$DatabasePassword = $DatabasePassword | ConvertTo-SecureString -asPlainText -Force
$Database_CredObject = New-Object System.Management.Automation.PSCredential($DatabaseUser,$DatabasePassword)

Import-Module Citrix.XenDesktop.Admin  
Add-PSSnapin Citrix.*

# Create Databases
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XD7Site -DataStore Site -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Site -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XD7Site -DataStore Logging -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Logging -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XD7Site -DataStore Monitor -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Monitor -DatabaseCredentials $Database_CredObject 

# Create Site 
New-XDSite -DatabaseServer $DatabaseServer -LoggingDatabaseName $DatabaseName_Logging -MonitorDatabaseName $DatabaseName_Monitor -SiteDatabaseName $DatabaseName_Site -SiteName $XD7Site -AdminAddress $env:COMPUTERNAME

# ConfigureLicensing and confirm the certificate hash
Set-XDLicensing -AdminAddress $env:COMPUTERNAME -LicenseServerAddress $LicenseServer -LicenseServerPort 27000
Set-ConfigSite  -AdminAddress $env:COMPUTERNAME -LicensingModel $LicenseServer_LicensingModel -ProductCode $LicenseServer_ProductCode -ProductEdition $LicenseServer_ProductEdition
Set-ConfigSiteMetadata -AdminAddress $env:COMPUTERNAME -Name 'CertificateHash' -Value $(Get-LicCertificate -AdminAddress "https://$LicenseServer").CertHash

# Add admin group to full admins
New-AdminAdministrator -AdminAddress $env:COMPUTERNAME -Name $FullAdminGroup
Add-AdminRight -AdminAddress $env:COMPUTERNAME -Administrator $FullAdminGroup -Role 'Full Administrator' -All

# *******************************************
# Create XenDesktop 7 Site Hosting
# *******************************************
# Create Hosting Connection 
Get-ConfigServiceStatus  -AdminAddress $env:COMPUTERNAME
 
Get-LogSite  -AdminAddress $env:COMPUTERNAME
 
New-Item  -AdminAddress $env:COMPUTERNAME -ConnectionType $ConnectionType -HypervisorAddress @($HypervisorAddress) -Path xdhyp:\connections\$HypervisorConnectionName -Scope @() -Password $HypervisorPassword -UserName $HypervisorUser
 
# Update Hosting Connection 
Get-ConfigServiceStatus  -AdminAddress $env:COMPUTERNAME
 
Get-LogSite  -AdminAddress $env:COMPUTERNAME
 
Set-Item  -AdminAddress $env:COMPUTERNAME -PassThru -Path xdhyp:\connections\$HypervisorConnectionName -Password $HypervisorPassword -UserName $HypervisorUser
 
# Create Hosting Resources and Persist Hosting Connection
Get-ConfigServiceStatus  -AdminAddress $env:COMPUTERNAME
 
Get-LogSite  -AdminAddress $env:COMPUTERNAME
 
Get-Item  -AdminAddress $env:COMPUTERNAME -Path xdhyp:\connections\$HypervisorConnectionName
 
Remove-Item  -AdminAddress $env:COMPUTERNAME -Path xdhyp:\connections\$HypervisorConnectionName
 
New-Item  -AdminAddress $env:COMPUTERNAME -ConnectionType $ConnectionType -HypervisorAddress @($HypervisorAddress) -Path xdhyp:\connections\$HypervisorConnectionName -Persist -Scope @() -Password $HypervisorPassword -UserName $HypervisorUser
 
$HypervisorConnectionUid = (Get-Item  -AdminAddress $env:COMPUTERNAME -Path xdhyp:\connections\$HypervisorConnectionName).HypervisorConnectionUid.ToString()
 
New-BrokerHypervisorConnection  -AdminAddress $env:COMPUTERNAME -HypHypervisorConnectionUid $HypervisorConnectionUid

# Create Hosting Network and Hosting Storage Connection
# Runs if $MCS is configured to "Yes"
If ($MSC -eq "Yes"){
New-Item  -AdminAddress $env:COMPUTERNAME -HypervisorConnectionName $HypervisorConnectionName -NetworkPath xdhyp:\connections\$HypervisorConnectionName\$NetworkPath.network -Path xdhyp:\hostingunits\$StorageNetworkResourceName -PersonalvDiskStoragePath xdhyp:\connections\$HypervisorConnectionName\$PersonalvDiskStoragePath.storage -RootPath xdhyp:\connections\$HypervisorConnectionName -StoragePath xdhyp:\connections\$HypervisorConnectionName\$StoragePath.storage
}