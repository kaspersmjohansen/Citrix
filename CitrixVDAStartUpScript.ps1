$LogPath = "D:\"
$LogFile = "StartupScript.log"
$LogPS = $LogPath + $LogFile

# Start PowerShell transscript log
Start-Transcript -Path $LogPS

# Force Citrix WEM Agent cache refresh
# Verifying that Citrix WEM Agent is installed
If (Test-Path -Path "${env:ProgramFiles(x86)}\Norskale\Norskale Agent Host\AgentCacheUtility.exe")
{
    Write-Output "Citrix WEM Agent is installed" -Verbose

        # Check if the Norskale Agent Host Service is running
        If ((Get-Service -Name "Norskale Agent Host Service").Status -eq "Running")
        {
            # If running, stop it and delete the Citrix WEM Agent cache SDF files
            # It is sometimes necesarry to delete the SDF files, usually when the Citrix WEM Agent has been upgraded
            Stop-Service -Name "Norskale Agent Host Service" -Force -Verbose
            Remove-Item -Path "C:\Program Files (x86)\Norskale\Norskale Agent Host\Local Databases\*.sdf" -Verbose

            # Start Norskale Agent Host Service and Netlogon service
            Start-Service -Name "Norskale Agent Host Service"
            Start-Service -Name "Netlogon"

                # Refresh/recreate to Citrix WEM Agent Cache
                Push-Location "${env:ProgramFiles(x86)}\Norskale\Norskale Agent Host"
                Start-Process -Wait "AgentCacheUtility.exe" -ArgumentList "-refreshcache" -RedirectStandardOutput "$LogPath\CitrixWEMAgent.log"
                Pop-Location
        }
}

If (Test-Path -Path "${env:ProgramFiles(x86)}\Citrix\Workspace Environment Management Agent\AgentCacheUtility.exe")
{
        If ((Get-Service -Name "Citrix WEM Agent Host Service").Status -eq "Running")
        {
            # If running, stop it and delete the Citrix WEM Agent cache SDF files
            # It is sometimes necesarry to delete the SDF files, usually when the Citrix WEM Agent has been upgraded
            Stop-Service -Name "Citrix WEM Agent Host Service" -Force -Verbose
            Remove-Item -Path "${env:ProgramFiles(x86)}\Citrix\Workspace Environment Management Agent\Local Databases\*.sdf" -Verbose

            # Start Norskale Agent Host Service and Netlogon service
            Start-Service -Name "Citrix WEM Agent Host Service"
            Start-Service -Name "Netlogon"

                # Refresh/recreate to Citrix WEM Agent Cache
                Push-Location "${env:ProgramFiles(x86)}\Citrix\Workspace Environment Management Agent"
                Start-Process -Wait "AgentCacheUtility.exe" -ArgumentList "-refreshcache" -RedirectStandardOutput "$LogPath\CitrixWEMAgent.log"
                Pop-Location
         }    
}
else
    {
        Write-Output "Citrix WEM Agent is not installed" -Verbose
    }

# In modern versions of Windows, the Citrix PVS BDM disk is sometimes assigned a driveletter.
# The drive letter is removed as the user may be able to access it via File Explorer.
# Check for BNDevice.exe
If (Test-Path -Path "C:\Program Files\Citrix\Provisioning Services\BNDevice.exe")
{
    Write-Output "BNDevice.exe exists - This is probably a PVS Target Device" -Verbose
   
        # Check to verify the PVS Target Device is in Standard/Shared Mode
        If (Select-String -Path "$env:SystemDrive\Personality.ini" -pattern "`_DiskMode`=S")
        {
            Write-Output "PVS Target Device is in Standard/Shared Mode" -Verbose
                
                # Remove any assigned drive letter on Citrix PVS BDM volume
                If (Get-Volume | where {$_.FileSystemLabel -eq "Citrix Boot"})
                {
                    $CitrixBootDisk = Get-Volume | where {$_.FileSystemLabel -eq "Citrix Boot"}
                    $BootDiskDriveLtr = $CitrixBootDisk.Driveletter+":"
                    $CitrixBootDisk | Get-Partition | Remove-PartitionAccessPath -AccessPath $BootDiskDriveLtr -Verbose
                }
                else
                    {
                        Write-Output "No Citrix BDM volume found" -Verbose
                    }
        }
        else
            {
                Write-Output "PVS Target Device is not in Standard/Shared Mode" -Verbose
            }
}

Stop-Transcript