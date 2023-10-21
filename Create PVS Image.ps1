<#
  ****************************************************************************************************************

  Unattended convert of PVS vDisk using Citrix XenConvert
  P2PVS is used to convert the image to vDisk P2PVS MUST exist, otherwise the script will fail. 
  P2PVS is installed with the Citrix Provisioning Services Device Target Software.

  The script is tested on Windows 7/2008 R2 and Windows 8.1/2012 R2.

  Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
  Date: 22-02-2015

  ****************************************************************************************************************
#>
# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Running Provisioning Services Device Optimizations"
Write-Host

# Compile .NET Framework assemblies
If ((($OSArchitecture -eq "64-bit") -and (Test-Path -Path "$env:SystemRoot\Microsoft.Net\Framework\v4.0.30319\ngen.exe") -and (Test-Path -Path "$env:SystemRoot\Microsoft.Net\Framework64\v4.0.30319\ngen.exe"))){
Start-Process -Wait "$env:SystemRoot\Microsoft.Net\Framework\v4.0.30319\ngen.exe" -WindowStyle Minimized -ArgumentList "executequeueditems" | Out-Null
Start-Process -Wait "$env:SystemRoot\Microsoft.Net\Framework64\v4.0.30319\ngen.exe" -WindowStyle Minimized -ArgumentList "executequeueditems" | Out-Null
}

elseif (($OSArchitecture -eq "32-bit") -and (Test-Path -Path "$env:SystemRoot\Microsoft.Net\Framework\v4.0.30319\ngen.exe")){
Start-Process -Wait "$env:SystemRoot\Microsoft.Net\Framework\v4.0.30319\ngen.exe" -WindowStyle Minimized -ArgumentList "executequeueditems" | Out-Null
}

# Disable Scheduled Tasks
If (($OS -Like "Windows Server 2012*") -or ($OS -Like "Windows 8*")){
Disable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "RegIdleBackup" -TaskPath "\Microsoft\Windows\Registry" -ErrorAction SilentlyContinue | Out-Null
}
elseif ($OS -Like "Windows 8*"){
Disable-ScheduledTask -TaskName "Windows Defender Cache Maintenance" -TaskPath "\Microsoft\Windows\Windows Defender" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Windows Defender Cleanup" -TaskPath "\Microsoft\Windows\Windows Defender" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Windows Defender Scheduled Scan" -TaskPath "\Microsoft\Windows\Windows Defender" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Windows Defender Verification" -TaskPath "\Microsoft\Windows\Windows Defender" -ErrorAction SilentlyContinue | Out-Null
}
elseif (($OS -Like "Windows 7*") -or ($OS -Like "Windows Server 2008 R2*")){
schtasks /change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable -ErrorAction SilentlyContinue | Out-Null
schtasks /change /TN "\Microsoft\Windows\Registry\RegIdleBackup" /Disable -ErrorAction SilentlyContinue | Out-Null
schtasks /change /TN "\Microsoft\Windows Defender\MP Scheduled Scan" /Disable -ErrorAction SilentlyContinue | Out-Null
}

# Disable Windows Defender services
If ($OS -Like "Windows 7*"){
Stop-Service windefend -ErrorAction SilentlyContinue | Out-Null
Set-Service windefend -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
}

# Stop and disable Windows Update
Stop-Service wuauserv -ErrorAction SilentlyContinue | Out-Null
Set-Service wuauserv -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name NoAutoUpdate -Value 1 -PropertyType DWORD -Force | Out-Null

# Disable Indexing Service
Stop-Service WSearch -ErrorAction SilentlyContinue | Out-Null
Set-Service WSearch -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null

# Disable Superfetch
If (($OS -Like "Windows 7*") -or ($OS -Like "Windows 8*")){
Stop-Service SysMain -ErrorAction SilentlyContinue | Out-Null
Set-Service SysMain -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
}

# Disable Offline Files
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" -Name Enabled -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable DefragBootOptimizationFunction
New-Item -Path "HKLM:\SOFTWARE\Microsoft" -Name Dfrg -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Dfrg" -Name BootOptimizeFunction -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" -Name Enable -Value N -Force | Out-Null

# Disable Background Layout Service
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name OptimalLayout -ErrorAction SilentlyContinue | Out-Null 
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout" -Name EnableAutoLayout -Value 1 -PropertyType DWORD -Force | Out-Null

# Disable Last Access Time Stamp
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name NtfsDisableLastAccessUpdate -Value 1 | Out-Null

# Disable CrashDump
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name CrashDumpEnabled -Value 0 | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name LogEvent -Value 0 | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name SendAlert -Value 0 | Out-Null

# Reduce Event Log File Size to 64 kB
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Application" -Name MaxSize -Value 65536 | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security" -Name MaxSize -Value 65536 | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\System" -Name MaxSize -Value 65536 | Out-Null

# Reduce Internet Explorer Temporary File Cache
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\System" -Name MaxSize -Value 65536 | Out-Null

New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
New-Item -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name Cache -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache" -Name Content -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 5.0 -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0" -Name Cache -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache" -Name Content -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content" -Name CacheLimit -Value 1024 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Content" -Name CacheLimit -Value 1024 -PropertyType DWORD -Force | Out-Null
Remove-PSDrive -Name HKU | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" -Name Paths -Value 4 -PropertyType DWORD -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" -Name path1 -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" -Name path2 -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" -Name path3 -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" -Name path4 -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path1" -Name CacheLimit -Value 256 | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path2" -Name CacheLimit -Value 256 | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path3" -Name CacheLimit -Value 256 | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path4" -Name CacheLimit -Value 256 | Out-Null

# Disable Clear Page File at Shutdown
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name ClearPageFileAtShutdown -Value 0 | Out-Null

# Disable Machine Account Password Changes
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name DisablePasswordChange -Value 1 | Out-Null

# Disable hibernate 
Start-Process -Wait "powercfg.exe" -ArgumentList "-h off" | Out-Null

# Set Write Cache disk timeout
# http://support.citrix.com/article/CTX139478
If ($OS -Like "Windows Server 2012*"){
Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Set Write Cache disk timeout"
Write-Host

New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BNIStack" -Name Parameters
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BNIStack\parameters" -Name WcHDInitRetryNumber -Value 200
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BNIStack\parameters" -Name WcHDInitRetryIntervalMs -Value 500
}

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Flushing DNS cache"
Write-Host

ipconfig /flushdns | Out-Null

# Preparing PVS image - Applicable in XenApp 6.5 only
If (Test-Path -Path "C:\Program Files (x86)\Citrix\XenApp\ServerConfig"){

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Preparing OS for PVS capture - XenApp Only!"
Write-Host

Push-Location "C:\Program Files (x86)\Citrix\XenApp\ServerConfig"
Start-Process -Wait "XenAppConfigConsole.exe" -ArgumentList "/ExecutionMode:ImagePrep /RemoveCurrentServer:True /PrepMsmq:True" | Out-Null
Pop-Location
}

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Disabling auto admin logon"
Write-Host

# Disable AutoAdminLogon
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "0" -Type "Dword" | Out-Null

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Cleaning out MDT links"
Write-Host

# Remove MDT LiteTouch.lnk to prevent MDT startup
If (Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\LiteTouch.lnk"){ 
Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\LiteTouch.lnk" -Force | Out-Null
}

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Change power plan to High Performance"
Write-Host

# Set Power Plan to High Performance
Start-Process -Wait "powercfg.exe" -Argumentlist "/setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
Start-Process -Wait "powercfg.exe" -Argumentlist "/change disk-timeout-ac 0"
Start-Process -Wait "powercfg.exe" -Argumentlist  "/change disk-timeout-dc 0"

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Clearing Windows Event Logs"
Write-Host

# Clear Event Logs
Clear-EventLog -LogName "Application" | Out-Null
Clear-EventLog -LogName "Security" | Out-Null
Clear-EventLog -LogName "System" | Out-Null
Clear-EventLog -LogName "Setup" -ErrorAction SilentlyContinue | Out-Null

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Activate Windows"
Write-Host

# Activate Windows
Push-Location "$env:windir\System32"
cscript .\SlMgr.vbs /ato
Pop-Location

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Activate Office"
Write-Host

# Activate Office
Push-Location "$env:ProgramFiles\Microsoft Office\Office15"
cscript .\ospp.vbs /act
Pop-Location

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Rearm Windows"
Write-Host

# Rearm Windows
Push-Location "$env:windir\System32"
cscript .\SlMgr.vbs /rearm
Pop-Location

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Rearm Office"
Write-Host

# Rearm Office
Push-Location "${env:ProgramFiles(x86)}\Common Files\microsoft shared\OfficeSoftwareProtectionPlatform"
.\OSPPREARM.EXE
Pop-Location

Push-Location "$env:ProgramFiles\Common Files\microsoft shared\OfficeSoftwareProtectionPlatform"
.\OSPPREARM.EXE
Pop-Location

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Converting server to PVS vDisk"
Write-Host

# Running P2PVS
Push-Location "$env:ProgramFiles\Citrix\Provisioning Services"
Start-Process -Wait "P2PVS.EXE" -ArgumentList "P2PVS $env:SystemDrive /L /AutoFit"
Pop-Location

# Shutdown Computer
Stop-Computer -Force