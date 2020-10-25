# Function parameters
Param(
     [string]$Site,
     [string]$Collection,
     [string]$Store,
     [string]$vDisk         
     )

function Assign-PVSvDisk
    {
        # Import PVS PowerShell module
        Import-Module “C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll” -ErrorAction Stop

            # Get target device information in the specified collection
            $TargetDevices = Get-PvsDeviceInfo -CollectionName $Collection -SiteName $Site

                # Get vDisk ID
                $vDiskID = Get-PvsDiskInfo -Name $vDisk -SiteName $Site -StoreName $Store | Select-Object DiskLocatorId -ExpandProperty DiskLocatorId
         
                    # Configure the specified vDisk on target devices in the specified collection
                    ForEach ($Target in $TargetDevices)
                    {
                        # Set target name and current vDisk variables
                        $TargetName = $target.devicename 
                        $CurrentvDisk = $target.DiskLocatorName -replace "[$Store\\]" , ""

                        # Remove current vDisk and assign new vDisk to target device
                        If ($CurrentvDisk -ne $vDisk)
                        {
                            # Remove current vDisk on target device
                            Remove-PvsDiskLocatorFromDevice -DeviceName $TargetName -DiskLocatorName $CurrentvDisk -SiteName $Site -StoreName $Store

                                # Assign new vDisk to target device
                                Add-PvsDiskLocatorToDevice -DeviceID $Target.deviceID -DiskLocatorId $vDiskID
                                Write-Host "Configuring $vDisk on $TargetName" -ForegroundColor Cyan
                        }
                        else
                        {
                            Write-Host "$CurrentvDisk is already configured on $TargetName" -ForegroundColor Green
                        }
                    }
    }

Assign-PVSvDisk $Site $Collection $Store $vDisk