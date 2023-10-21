<#
***********************************************************************************************************************

Unattended installation of Windows Hotfixes

Expected folder structure:

.\Hotfixes\MS\Windows 7\x86 - Hotfixes for Windows 7 32-bit
.\Hotfixes\MS\Windows 7\x64 - Hotfixes for Windows 7 64-bit
.\Hotfixes\MS\Windows 8\x86 - Hotfixes for Windows 8 32-bit
.\Hotfixes\MS\Windows 8\x64 - Hotfixes for Windows 8 64-bit
.\Hotfixes\MS\Windows 10\x86 - Hotfixes for Windows 10 32-bit
.\Hotfixes\MS\Windows 10\x64 - Hotfixes for Windows 10 64-bit
.\Hotfixes\MS\Windows Server 2008 R2 - Hotfixes for Windows Server 2008 R2
.\Hotfixes\MS\Windows Server 2012 R2 - Hotfixes for Windows Server 2012 R2

Copy any Windows hotfixes to one or more of the folders, the script will automatically install any MSU files in here
 
Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 20-06-2015

***********************************************************************************************************************
#>
# Script wide variables
$LogDir = "$env:SystemRoot\Temp"
$InstallDir = (Get-Location).Path
$OS = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

Push-Location $InstallDir
cd..

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Installing hotfixes for $OS - $OSArchitecture"
Write-Host

# Install Windows 7 32-bit hotfixes
If (($OSArchitecture -eq "32-bit") -and ($OS -Like "Windows 7*")){
ls ".\Hotfixes\MS\Windows 7\x86\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows 7 64-bit hotfixes
If (($OSArchitecture -eq "64-bit") -and ($OS -Like "Windows 7*")){
ls ".\Hotfixes\MS\Windows 7\x86\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows 8 32-bit hotfixes
If (($OSArchitecture -eq "32-bit") -and ($OS -Like "Windows 8*")){
ls ".\Hotfixes\MS\Windows 8\x86\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows 8 64-bit hotfixes
If (($OSArchitecture -eq "64-bit") -and ($OS -Like "Windows 8*")){
ls ".\Hotfixes\MS\Windows 8\x64\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows 10 32-bit hotfixes
If (($OSArchitecture -eq "32-bit") -and ($OS -Like "Windows 10*")){
ls ".\Hotfixes\MS\Windows 10\x86\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows 10 64-bit hotfixes
If (($OSArchitecture -eq "64-bit") -and ($OS -Like "Windows 10*")){
ls ".\Hotfixes\MS\Windows 10\x64\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows Server 2008 R2 hotfixes
If ($OS -Like "Windows Server 2008 R2*"){
ls ".\Hotfixes\MS\Windows Server 2008 R2\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

# Install Windows Server 2012 R2 hotfixes
If ($OS -Like "Windows Server 2012 R2*"){
ls ".\Hotfixes\MS\Windows Server 2012 R2\*.msu" | %{start -wait $_ -argumentlist '/quiet /norestart'}
}

Pop-Location