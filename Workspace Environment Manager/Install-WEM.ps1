#Requires -RunAsAdministrator
<#
*************************************************************************************************************************************
Name:               Install-WEM
Author:             Kasper Johansen
Company:            edgemo
Contact:            kjo@edgemo.com
Last modified by:   Kasper Johansen
Last modified Date: 01-04-2019


*************************************************************************************************************************************

.SYNOPSIS
    Install Citrix WEM, infrastructure service, console, agent and agent prerequisites.

.DESCRIPTION
    Install Citrix WEM, infrastructure service, console, agent and agent prerequisites.

.PARAMETER Infrastructure
    Installs the Citrix WEM Infrastructure Service

.PARAMETER Console
    Installs the Citrix WEM Console

.PARAMETER Agent
    Installs the Citrix WEM Agent

.PARAMETER AgentPrereqs
    Installs the Citrix WEM Agent Prerequisites

.PARAMETER LogDir
    Configures a directory for the PowerShell transscription log files. The default folder for the log files is C:\Windows\temp

.EXAMPLES
    Install Citrix WEM Infrastructure Services:
            Install-WEM -Infrastructure

    Install Citrix WEM Console:
            Install-WEM -Console

    Install Citrix WEM Agent:
            Install-WEM -Agent

    Install Citrix WEM Agent Prerequisites:
            Install-WEM -AgentPrereqs

    Install Citrix WEM Agent with alternate log directory:
            Install-WEM -Agent -LogDir C:\LogFiles

#************************************************************************************************************************************
#>

# Script parameters
Param(
    [switch]$Infrastructure,
    [switch]$Console,
    [switch]$Agent,
    [switch]$AgentPrereqs,
    [string]$LogDir = "$env:SystemRoot\Temp"
    )

function Install-WEM ($Infrastructure,$Console,$Agent,$AgentPrereqs,$LogDir)
    {
    $AgentInstaller = "Citrix Workspace Environment Management Agent Setup.exe"
    $ConsoleInstaller = "Citrix Workspace Environment Management Console Setup.exe"
    $InfraStrcuteInstaller = "Citrix Workspace Environment Management Infrastructure Services Setup.exe"
    # Get OS variable
    $OS = (Get-WmiObject Win32_OperatingSystem).Caption

    # Get script execution directory
    $InstallDir = (Get-Location).Path
    Push-Location $InstallDir
    cd..
        
        If ($Infrastructure)
        {
        # Start time measuring and transcripting
        $LogPS = $LogDir + "\Install-WEM_Infra.log"
        $startDTM = (Get-Date)
        Start-Transcript $LogPS

            # Install Citrix WEM Infrastructure Services
            Write-Output "Installing Citrix WEM Infrstructure Services" -Verbose
            Start-Process -Wait ".\$InfraStrcuteInstaller" -ArgumentList "/s /v/qn" -PassThru

        $EndDTM = (Get-Date)
        Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
        Stop-Transcript
        }

            If ($Console)
            {
            # Start time measuring and transcripting
            $LogPS = $LogDir + "\Install-WEM_Console.log"
            $startDTM = (Get-Date)
            Start-Transcript $LogPS

                # Install Citrix WEM Infrastructure Services
                Write-Output "Installing Citrix WEM Console" -Verbose
                Start-Process -Wait ".\$ConsoleInstaller" -ArgumentList "/s /v/qn" -PassThru

            $EndDTM = (Get-Date)
            Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
            Stop-Transcript
            }

                If ($Agent)
                {
                # Start time measuring and transcripting
                $LogPS = $LogDir + "\Install-WEM_Agent.log"
                $startDTM = (Get-Date)
                Start-Transcript $LogPS

                    # Install Citrix WEM Infrastructure Services
                    Write-Output "Installing Citrix WEM Agent" -Verbose

                    # Set Citrix WEM Agent install switches
                    $InstallSwitches = "/quiet Cloud=0"

                        # Install Citrix WEM Agent
                        Start-Process -Wait ".\$AgentInstaller" -ArgumentList $InstallSwitches -PassThru

                        # Stop Citrix WEM User Logon Service
                        Stop-Service -Name WemLogonSvc -Force
                        Set-Service -Name WemLogonSvc -StartupType Disabled
                    <#
                    # Determine if device is a PVS Target Device
                    $CacheDrvLtr = (Get-WMIObject Win32_Volume | Where-Object {$_.Label -eq 'PVS Cache' -or $_.Label -eq "WCDisk"}).DriveLetter
                    $WEMCache = $CacheDrvLtr + "\Citrix\WEMAgentCache"
                    $PVSInstallSwitches = "/S `/v`"AgentCacheAlternateLocation=\`"$WEMCache\`" /qn"""

                            # Test to see if PVS Cache Disk is present and create folder for WEM Cache
                            If ($CacheDrvLtr)
                            {
                                If (!(Test-Path -Path $WEMCache))
                                {
                                New-Item -Path $WEMCache -ItemType Directory
                                }
                                    # Install Citrix WEM Agent on PVS Target Device
                                    Start-Process -Wait ".\$AgentInstaller" -ArgumentList $PVSInstallSwitches -PassThru
                                }
                            else
                            {
                                    # Install Citrix WEM Agent on non-PVS Target Device
                                    Start-Process -Wait ".\$AgentInstaller" -ArgumentList $InstallSwitches -PassThru
                            }
                    #>

                $EndDTM = (Get-Date)
                Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
                Stop-Transcript
                }

                    If ($AgentPrereqs)
                    {
                    # Start time measuring and transcripting
                    $LogPS = $LogDir + "\Install-WEM_Agentprereqs.log"
                    $startDTM = (Get-Date)
                    Start-Transcript $LogPS

                        # Install Citrix WEM Agent Prerequisites
                        Write-Output "Installing Citrix WEM Agent Prerequisites" -Verbose
                        Start-Process -Wait ".\Agent Prerequisites\SSCERuntime_x64-ENU.msi" -ArgumentList "/qb- /norestart" -PassThru
                        Start-Process -Wait ".\Agent Prerequisites\SSCERuntime_x86-ENU.msi" -ArgumentList "/qb- /norestart" -PassThru
                        Start-Process -Wait ".\Agent Prerequisites\SSCEServerTools-ENU.msi" -ArgumentList "/qb- /norestart" -PassThru

                    $EndDTM = (Get-Date)
                    Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
                    Stop-Transcript
                    }


    }

Install-WEM $Infrastructure $Console $Agent $AgentPrereqs $LogDir