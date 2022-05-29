#Requires -RunAsAdministrator
<#
****************************************************************************************************
Name:               
Author:             Kasper Johansen
Website:            https://virtualwarlock.net            

****************************************************************************************************
.SYNOPSIS
    This script creates a Citrix Virtual Apps and Desktops hosting connection. 

.DESCRIPTION
    This script has been tested with Microsoft System Center Virtual Machine Manager 2022 and
    Citrix Virtual Apps and Desktop 2203.
    
    The script must be executed on a working Citrix Delivery Controller and it is obviously required
    that you have the necessary permissions within the Citrix site, to be able to create and modify
    hosting connections. 
    You will of course also have to have a username with the required hypervisor permissions, 
    to be able to communicate correctly with the hypervisor management feature.

.VARIABLE HostConnectionName
    The name of the hosting connection as seen in Citrix Studio

.VARIABLE HostConnectionType
    The type of hosting connection. Valid values are SCVMM, XenServer and Vcenter

    SCVMM = Microsoft System Center Virtual Machine Manager which is used in a Hyper-V based setup
    XenServer = Used in a Citrix Hypervisor/Citrix XenServer based setup
    Vcenter = Used in a VMware vSphere based setup

.VARIABLE HostConnectionAddress
    The hypervisor management feature hostname or URL. 
    
    SCVMM = Configure the hostname of the Virtual Machine Manager host
    XenServer = Configure the URL to the Citrix Hypervisor host
    Vcenter = Configure the URL to the VMware Vcenter host

.VARIABLE HostConnectionUserName
    The hypervisor management feature username 

.VARIABLE HostConnectionPassword
    The hypervisor management feature password 

****************************************************************************************************
#>

# Citrix hosting connection variables
$HostConnectionName = ""
$HostConnectionType = ""
$HostConnectionAddress = ""
$HostConnectionUserName = ""
$HostConnectionPassword = ""

# Add the Citrix hosting admin snap-in
Add-PSSnapin Citrix.Host.Admin.V2

# Imports the Host service Powershell snap-in
Set-HypAdminConnection

# Configures the hypervisor connection configuration
New-Item -ConnectionType $HostConnectionType -HypervisorAddress @($HostConnectionAddress) -Path @("XDHyp:\Connections\$HostConnectionName") -Persist -Password $HostConnectionPassword -UserName $HostConnectionUserName

# Configures the hypervisor hosting connection
$HostConnectionGuid = (Get-ChildItem "XDHyp:\Connections" | where {$_.PSChildName -eq "$HostConnectionName"}).HypervisorConnectionUid
New-BrokerHypervisorConnection -HypHypervisorConnectionUid $HostConnectionGuid

# Configures the hypervisor hosting connection storage and network settings
$HostConnectionHypervisorHost = (Get-ChildItem -Path "XDHyp:\Connections\$HostConnectionName" | where {$_.ObjectType -eq "Host"}).FullName
$HostConnectionStoragePath = (Get-ChildItem -Path "XDHyp:\Connections\$HostConnectionName\$HostConnectionHypervisorHost" | where {$_.ObjectType -eq "Storage"}).FullName
$HostConnectionNetwork = (Get-ChildItem -Path "XDHyp:\Connections\$HostConnectionName\$HostConnectionHypervisorHost" | where {$_.ObjectType -eq "Network"}).FullName
New-Item -HypervisorConnectionName $HostConnectionName -NetworkPath @("XDHyp:\Connections\$HostConnectionName\$HostConnectionHypervisorHost\$HostConnectionNetwork") -Path @("XDHyp:\HostingUnits\$HostConnectionName Resources") -RootPath "XDHyp:\Connections\$HostConnectionName\$HostConnectionHypervisorHost" -StoragePath @("XDHyp:\Connections\$HostConnectionName\$HostConnectionHypervisorHost\$HostConnectionStoragePath")

# Executes a test of the added hypervisor hosting connection
$HostConnectionTest = New-EnvTestDiscoveryTargetDefinition -TargetIdType "HypervisorConnection" -TestSuiteId "HypervisorConnection" -TargetId $(Get-BrokerHypervisorConnection).HypHypervisorConnectionUid
Start-EnvTestTask -InputObject @($HostConnectionTest)