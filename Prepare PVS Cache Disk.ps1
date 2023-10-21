<#
  ****************************************************************************************************************

  Preparation of Citrix PVS Cache Disk
  The script prepares the PVS Cache Disk for Event Viewer redirection, EdgeSight agent data redirection
  and Printer Spooler redirection

  You MUST set the $CacheDrvLtr variable, with the drive letter containing the PVS Cache
  The script creates a Microsoft folder for the Event Viewer logs and a Citrix folder for the Edgesight agent data
  
  Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
  Date: 24-07-2014

  ****************************************************************************************************************
#>

# Prepare PVS Cache Disk
$CacheDrvLtr = "D:"
$EvntLogDestFolder = "$CacheDrvLtr\Microsoft\Event Viewer"
$PrinterSpoolerFolder = "$CacheDrvLtr\Microsoft\spool\PRINTERS"

# Check if PVS Cache disk exist
If (Test-Path -Path "$CacheDrvLtr\"){

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Preparing PVS Cache Disk"
Write-Host

# Create destination folder for Event Viewer Logs
If (!(Test-Path -Path "$EvntLogDestFolder")){
New-Item -ItemType Directory "$EvntLogDestFolder"

# Change Event Viewer Log file path in Application, System and Security logs
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\Application" -Name "Flags" -Value "1" -PropertyType "Dword" -Force | Out-Null -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\Application" -Name "File" -Value "$EvntLogDestFolder\Application.evtx" -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue

New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\Security" -Name "Flags" -Value "1" -PropertyType "Dword" -Force | Out-Null -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\Security" -Name "File" -Value "$EvntLogDestFolder\Security.evtx" -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue

New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\System" -Name "Flags" -Value "1" -PropertyType "Dword" -Force | Out-Null -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\System" -Name "File" -Value "$EvntLogDestFolder\System.evtx" -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
}

# Create destination folder for Printer Spooler
If (!(Test-Path -Path "$PrinterSpoolerFolder")){
New-Item -ItemType Directory "$PrinterSpoolerFolder"
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers" -Name "DefaultSpoolDirectory" -Value "$PrinterSpoolerFolder" -Force | Out-Null -ErrorAction SilentlyContinue
}

else {

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "$CacheDrvLtr does not exist or vDisk is not in Shared Mode!"
Write-Host

}
}