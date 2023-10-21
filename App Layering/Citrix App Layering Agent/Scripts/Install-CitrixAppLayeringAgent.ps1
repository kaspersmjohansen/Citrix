#Requires -RunAsAdministrator
<#
*************************************************************************************************************************************
Name:               Install-CitrixAppLayeringAgent
Author:             Kasper Johansen
Company:            Atea Denmark
Contact:            kasper.johansen@atea.dk
Last modified by:   Kasper Johansen
Last modified Date: 10-03-2018


*************************************************************************************************************************************

.SYNOPSIS
    Install Citrix App Layering Agent.

.DESCRIPTION
    Installs and configures the Citrix App Layering Agent. If an older version is found, this is uninstalled, before a newer version is installed.
    The PVS Console Powershell add-in is registered if found.

.PARAMETER ELMaddress
    Configures the Enterprise Layer Manager (ELM) hostname or IP address.

.PARAMETER ELMuser
    Configures the username used to connect to the ELM

.PARAMETER ELMuserPwd
    Configures the password for the username used to connect to the ELM

.PARAMETER Transforms
    Specify another transforms file. Default is "CitrixAppLayeringAgentSkipELMRegistration.mst"

.PARAMETER LogDir
    Configures a directory for the PowerShell transcription log files. The default folder for the log files is C:\Windows\temp

.EXAMPLES
    Install Citrix App Layering Agent:
            Install-CitrixAppLayeringAgent -ELMaddress elm01.test.local -ELMuser user01 -ELMuserPwd P@ssw0rd

    Install Citrix App Layering Agent with alternate log directory:
            Install-WEM -Agent -LogDir C:\LogFiles

#************************************************************************************************************************************
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]$ELMadddress,
    [Parameter(Mandatory = $true)]
    [string]$ELMuser,
    [Parameter(Mandatory = $true)]
    [string]$ELMuserPwd,
    [string]$Transforms = "CitrixAppLayeringAgentSkipELMRegistration.mst",
    [string]$LogDir = "$env:SystemRoot\Temp" 
    )

function Install-CitrixAppLayeringAgent ($ELMaddress,$ELMuser,$ELMuserPwd,$Transforms,$LogDir)
    {
        # Installer executable file names
        $AgentInstaller = "Citrix App Layering Agent.msi"
        
            # Install switches
            $Switches = "/qn ALLUSERS=1 REBOOT=ReallySuppress PORT=8016 SKIP_ELM_REGISTRATION=1 TRANSFORMS=`"$Transforms`""
            
                # Get script execution directory
                $InstallDir = (Get-Location).Path
                Push-Location $InstallDir
                cd..
                cls
        
        # Start time measuring and transcription
        $LogPS = $LogDir + "\Install-CitrixAppLayeringAgent.log"
        $startDTM = (Get-Date)
        Start-Transcript $LogPS

            # Check if Citrix App Layering Agent is installed, if installed, then uninstall the old version.
            If (Test-Path -Path "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{886FB0B5-5F09-4FCD-B329-B16AC8BA9E3D}")
            {
                Write-Output "Citrix App Layering Agent found"
                Write-Output "Uninstalling - Please Wait..."
                Start-Process -Wait msiexec.exe -ArgumentList "/X{886FB0B5-5F09-4FCD-B329-B16AC8BA9E3D} /qb" -PassThru

                    Write-Output ""
                    Write-Output "Waiting for Windows installer to calm down"
                    Start-Sleep -Seconds 10
                        
                        Write-Output ""
                        Write-Output "Installing Citrix App Layering Agent - Please Wait..."
                        Start-Process -Wait $AgentInstaller -ArgumentList "$Switches" -PassThru
            }
            else
            {
                            Write-Output "Installing Citrix App Layering Agent - Please Wait..."
                            Start-Process -Wait $AgentInstaller -ArgumentList "$Switches" -PassThru
            }
                                # Configure the Citrix App Layering Agent - Connect to the ELM
                                Write-Output "COnfiguring Citrix App Layering Agent"
                                Push-Location "${env:ProgramFiles(x86)}\Citrix\Agent"
                                Start-Process -Wait ".\Citrix.AppLayering.Agent.Service.exe" -ArgumentList "registerwithelm /elmaddress:`"$ELMadddress`" /user:`"$ELMuser`" /password:`"$ELMuserPwd`" /errorfile:`”$LogDir\ELMRegistrationErrorLog.log`” /ignorecerterrors:true" -PassThru
                                Pop-Location

                                    # Register PVS Console Powershell add-in if exist
                                    If (Test-Path -Path "$env:ProgramFiles\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll")
                                    {
                                        Write-Output "Registering Citrix PVS Console Snapin"
                                        Start-Process -Wait "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\installutil.exe" -ArgumentList "/AssemblyName $env:ProgramFiles\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll" -PassThru
                                    }
        
        $EndDTM = (Get-Date)
        Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
        Stop-Transcript
    }

Install-CitrixAppLayeringAgent $ELMaddress $ELMuser $ELMuserPwd $Transforms $LogDir