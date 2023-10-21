# Compile .NET Assemblies
# Full path to the ngen.exe files
$NGENx86 = $env:SystemRoot + "\Microsoft.Net\Framework\v4.0.30319\ngen.exe"
$NGENx64 = $env:SystemRoot + "\Microsoft.Net\Framework64\v4.0.30319\ngen.exe"

# ngen.exe command line arguments
$Arguments = "executequeueditems /silent"

Write-Output "Optimizaing .NET Framework"
Start-Process -Wait $NGENx86 -WindowStyle Minimized -ArgumentList $Arguments
Start-Process -Wait $NGENx64 -WindowStyle Minimized -ArgumentList $Arguments

# Disable IPv6
Write-Output "Disabling IPv6"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TcpIp6\Parameters" -Name "DisabledComponents" -Value "255" -Type DWORD | Out-Null

# Do not start Server Manager at logon
# Write-Output "Do not start Server Manager at logon"
# New-ItemProperty -Path "HKCU:\Software\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Value "1" -PropertyType DWORD | Out-Null

# Reset WSUS Settings
If (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")
{
Write-Output "Reset WSUS Configuration"
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Recurse
}

# Disable Windows Update
Write-Output "Disabling Windows Update"
    If (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"))
    {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsUpdate" | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "AU" | Out-Null
    }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value "1" -Type DWORD

# Disable Windows Defender
Write-Output "Disable Windows Defender"
Set-MpPreference -DisableRealtimeMonitoring $true

# Flush DNS Cache
Write-Host Flushing DNS Cache. -ForegroundColor Green
ipconfig /flushdns

# Clear ARP Cache
Write-Host Clearing ARP Cache. -ForegroundColor Green
netsh interface ip delete arpcache

# Clear Windows Event Viewer
Write-Host Deleting all possible Event Log entries. -ForegroundColor Green
wevtutil.exe el | foreach-object {wevtutil.exe cl "$_"} 2>&1 | Out-Null

# Clear Recycle Bin
Write-Host Clearing out the Recycle Bin -ForegroundColor Green
Get-ChildItem "C:\`$Recycle.bin\" -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue