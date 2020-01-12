#Requires -Version 3.0
#Requires -RunAsAdministrator
<#
*********************************************************************************************************************
Name:               Import-PVSvDiskVHD
Author:             Kasper Johansen
Company:            edgemo
Contact:            kjo@edgemo.com
Last modified by:   Kasper Johansen
Last modified Date: 14-10-2019
Version             2.5

.SYNOPSIS
    Imports one or more VHD(S) to the Provisioning Services vDisk store.

.DESCRIPTION
    This script imports VHD(S) to the Provisioning Services vDisk store. 
    
    The script must be executed on a working PVS server!!
    The script is NOT supported on Windows Server 2012/2012 R2 
    Certain parts of the script will fail on 2012/2012R2 due to missing PowerShell commands
    
    You must specify the $BuildDir which is the directory where the script
    should look for VHDX files.

    .PARAMETER BuildDir
    Specifies the directory where the script should look for VHDX files. Any and all
    VHDX files in this directory, will be imported and configured. The directory specied
    should be the a local directory on the Provisionin Services server.
    
    .PARAMETER vDiskWriteCacheType
    Specifies the vDisk write cache type. If not specified, the default value is 9
    Acceptable values are:
    Private image
    0=Private
    Other values are standard image 
    1=Cache on Server, 
    3=Cache in Device RAM, 
    4=Cache on Device Hard Disk, 
    6=Device RAM Disk, 
    7=Cache on Server, Persistent, 
    9=Cache in Device RAM with Overflow on Hard Disk.

    .PARAMETER vDiskWriteCacheSize
    Specifies the vDisk write cache size in MB (megabytes). If not specified, the default value is 2048

    .PARAMETER vDiskLicenseMode
    Specifies the vDisk licensing mode. If not specified, the default value is 2
    Acceptable values are:
    1=MAK
    2=KMS

    .PARAMETER Site
    Specifies the name of the Provisioning Services site. If not specified, the Provisioning Services server
    is queried for the site name.

    .PARAMETER Store
    Specifies the Provisioning Services vDisk store the VHD(S) should be imported to. If not specified,
    the Provisioning Services server is queried for the store name and the first store in the list is selected.

    .PARAMETER StorePath
    Specifies the Provisioning Services vDisk store path

    .PARAMETER Defrag
    Runs disk optimization (Defrag) on the VHD before importing it to the vDisk store and before eventual
    replication,

    .PARAMETER Replicate
    Copies the VHD/VHDX + PVP to all additional PVS servers in the site.

    .PARAMETER LogDir
    Specifies the directory to store the transcription logfile. If not specified, the default 
    $env:SystemRoot\Temp directory is selected.
    
.EXAMPLES
    Import a new VHDX to the Provisioning Service vDisk store:

        Import-PVSvDiskVHD -BuildDir "D:\Builds"

    Import a new VHDX to the Provisioning Service vDisk store and configure the vDisk write cache mode
    to "cache on device harddisk":

        Import-PVSvDiskVHD -BuildDir "D:\Builds" -vDiskWriteCacheType "4"

    Import a new VHDX to the Provisioning Service vDisk store and configure the vDisk write cache mode
    to "cache on device harddisk" and the licensing mode to MAK:

        Import-PVSvDiskVHD -BuildDir "D:\Builds" -vDiskWriteCacheType "4" -vDiskLicenseMode "1"


*********************************************************************************************************************
#>

# Function parameters
Param(
    [Parameter(Mandatory = $true)]
    [string]$BuildDir,
    [ValidateSet("0","1","3","4","6","7","9")]
    [string]$vDiskWriteCacheType = "9",
    [string]$vDiskWriteCacheSize = "2048",
    [ValidateSet("1","2")]
    [string]$vDiskLicenseMode = "2",
    [string]$Site, 
    [string]$Store,
    [switch]$Defrag,
    [switch]$Replicate,
    [string]$LogDir = "$env:SystemRoot\Temp"
    )

function Defrag-VHD
    {
    param(
         $BuildDir,
         $vhd
         )
            # Mount VHD
            Write-Host "Mounting $vhd" -Verbose
            Write-Host
            Mount-DiskImage -ImagePath "$BuildDir\$vhd" -Verbose

                # Get mounted VHD
                $MountedVHD = Get-Disk | where {$_.Location -eq "$BuildDir\$vhd"}
            
                    # If mounted disk is offline, bring it online
                    If ($MountedVHD.OperationalStatus -eq "Offline")
                    {
                        Set-Disk -Number $MountedVHD.Number -IsOffline $false -Verbose
                    }
            
                        # Get Volume ObjectID from mounted VHD
                        $VolumeObjID = ($MountedVHD | Get-Partition | where {$_.Type -ne "System" -and $_.Type -ne "Reserved"} | Get-Volume).ObjectId
                        
                            # Optimize Volume
                            Write-Host "Defragmenting $vhd"
                            Write-Host
                            Optimize-Volume -ObjectId $VolumeObjID -Defrag
                        
                                # Unmount VHD
                                Write-Host "Unmounting $vhd" -Verbose
                                Write-Host
                                Dismount-DiskImage -ImagePath "$BuildDir\$vhd"             
     }

function Import-PVSvDiskVHD ($BuildDir,$vDiskWriteCacheType,$vDiskWriteCacheSize,$vDiskLicenseMode,$Site,$Store,$Defrag,$Replicate,$LogDir)
    {
    # Start time measuring and transcription
    $LogPS = $LogDir + "\Import-PVSvDiskVHD.log"
    $startDTM = (Get-Date)
    Start-Transcript $LogPS

        # Import PVS PowerShell module
        Write-Host "Importing Provisioning Services PowerShell module" -Verbose
        Import-Module “C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll” -ErrorAction Stop

            # Verify that the specified $BuildDir exists
            If (!(Test-Path -Path $BuildDir))
            {
                Write-Host "The specified directory does not exist!"
                Write-Host
                                
                $EndDTM = (Get-Date)
                Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
                Stop-Transcript
                Break
            }
                # Get VHDs in $BuildDir
                Write-Host
                Write-Host "VHDs in $BuildDir" -Verbose
                Write-Host

                $VHDs = Get-ChildItem -Path $BuildDir -Recurse -Include "*.VHD","*.VHDX" 
                If (($VHDs | Measure-Object).Count -eq "0")
                {
                    Write-Host "$BuildDir does not contain any VHD or VHDX files, aborting script!"
                    Write-Host
                    
                    $EndDTM = (Get-Date)
                    Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
                    Stop-Transcript
                    Break
                }
                else
                {
                    # List VHD/VHDX
                    $VHDName = $VHDs.Name
                    Write-Host "$VHDName" -ForegroundColor Green
                }
                        # Get Provisioning Services site name, if not specified
                        If ([String]::IsNullOrWhiteSpace($Site))
                        {
                            [string]$Site = (Get-PvsSite).SiteName
                        }
                        Write-Host "PVS Site:$Site" -ForegroundColor Green
                        Write-Host

                            # Get the Provisioning Services store name, if not specified
                            If ([String]::IsNullOrWhiteSpace($Store))
                            {
                               [string]$Store = (Get-PvsStore).StoreName
                            }
                            Write-Host "PVS Store:$Store" -ForegroundColor Green
                            Write-Host

                                # Get the path to specified vDisk store
                                [string]$StorePath = (Get-PvsStore | where {$_.Name -eq $Store}).Path

                                    # Move and import VHD(S) 
                                    ForEach ($vhd in $VHDs.Name)
                                    {
                                        If ($Defrag)
                                        {
                                            Defrag-VHD -BuildDir $BuildDir -vhd $vhd
                                        }

                                        # Move VHD(S) to $StorePath.
                                        Write-Host "Moving $vhd to $StorePath - Please wait..." -Verbose
                                        Write-Host

                                            Move-Item -Path "$BuildDir\$vhd" -Destination $StorePath -Verbose
                                            $vhd = $vhd -replace ".vhdx",""

                                                # Import VHD(S) to vDisk $Store
                                                Write-Host "Importing and configuring $vhd in Provisioning Services $Store" -Verbose
                                                Write-Host

                                                New-PvsDiskLocator -Name $vhd -StoreName $Store -SiteName $Site -RebalanceEnabled -SubnetAffinity 1 -VHDX -NewDiskWriteCacheType $vDiskWriteCacheType
                                                Set-PvsDisk -Name $vhd -StoreName $Store -SiteName $Site -WriteCacheSize $vDiskWriteCacheSize -LicenseMode $vDiskLicenseMode
                                    
                                        If ($Replicate)
                                        {
                                            # Get $Storepath driveletter and store folder
                                            $StoreDriveLtr = $StorePath.Substring(0,1)
                                            $StoreFolder = $StorePath.Substring(3)
                                            $PVSServersinSite = (Get-PvsServer -SiteId ((Get-PvsSite -Name $Site).SiteId) | where {$_.Name -ne $env:COMPUTERNAME}).ServerFqdn
                                            ForEach ($PVSserver in $PVSServersinSite)
                                            {
                                                Write-Host "Copying $vhd.pvp to $PVSserver" -Verbose
                                                Write-Host

                                                Copy-Item -Path "$StorePath\$vhd.pvp" -Destination "\\$PVSserver\$StoreDriveLtr$\$StoreFolder" -Verbose

                                                Write-Host "Copying $vhd.vhdx to $PVSserver" -Verbose
                                                Write-Host

                                                Copy-Item -Path "$StorePath\$vhd.vhdx" -Destination "\\$PVSserver\$StoreDriveLtr$\$StoreFolder" -Verbose
                                            }
                                        }
                                    }

        # End time measuring and transcription
        $EndDTM = (Get-Date)
        Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
        Stop-Transcript
    }

Import-PVSvDiskVHD $BuildDir $vDiskWriteCacheType $vDiskWriteCacheSize $vDiskLicenseMode $Site $Store $Defrag $Replicate $LogDir