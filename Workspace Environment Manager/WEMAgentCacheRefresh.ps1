$LogPath = "D:\"
$LogFile = "WEMagentrefresh.log"
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
                Start-Process -Wait "AgentCacheUtility.exe" -ArgumentList "-refreshcache"
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

            # Start Citrix WEM Agent Host Service and Netlogon service
            Start-Service -Name "Citrix WEM Agent Host Service"
            Start-Service -Name "Netlogon"

                # Refresh/recreate to Citrix WEM Agent Cache
                Push-Location "${env:ProgramFiles(x86)}\Citrix\Workspace Environment Management Agent"
                Start-Process -Wait "AgentCacheUtility.exe" -ArgumentList "-refreshcache"
                Pop-Location
         }    
}
else
    {
        Write-Output "Citrix WEM Agent is not installed" -Verbose
    }