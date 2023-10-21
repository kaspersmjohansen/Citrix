#Requires -RunAsAdministrator
<#
*************************************************************************************************************************************
Name:               Install-CitrixReceiver
Author:             Kasper Johansen
Company:            edgemo
Contact:            kjo@edgemo.com
Last modified by:   Kasper Johansen
Last modified Date: 17-10-2018


*************************************************************************************************************************************

.SYNOPSIS
    Install Citrix Receiver on target device.

.DESCRIPTION
    Install Citrix  Receiver with or without single sign-on

.PARAMETER SFURL
    URL to the StoreFront server og StoreFront LB adresse - eg. https://storefront.test.local

.PARAMETER StoreName
    Name of the StoreFront store to be configured

.PARAMETER ReceiverSwitches
    The CLI switches to be used when installing Citrix Receiver. The default is /silent and /noreboot

.PARAMETER SSO
    Configures the CLI switches to enable single sign-on

.PARAMETER DISABLEFTU
    Suppresses the FTU "Add Store" popup box on Citrix Receiver startup

.PARAMETER NoStore
    Install Citrix Receiver with no store configuration.

.PARAMETER ReceiverExecutable
    Filename of the Citrix Receiver setup fil

.EXAMPLES
    Install Citrix Receiver with configured StoreFront Store, single sign-on enabled and FTU disabled:

        Install-CitrixReceiver -SFURL https://storefront.test.local -SSO -DisableFTU

#************************************************************************************************************************************
#>

# Script parameters
Param(
    [Parameter(ParameterSetName = "Store")]
    [string]$SFURL,
    [Parameter(ParameterSetName = "Store")]
    [string]$StoreName = "Store",
    [string]$ReceiverSwitches = "/silent /noreboot",
    [switch]$SSO = "/includeSSON ENABLE_SSON=YES",
    [switch]$DisableFTU,
    [Parameter(ParameterSetName = "NoStore")]
    [switch]$NoStore,
    [string]$ReceiverExecutable = "CitrixReceiver.exe"
    )

function Install-CitrixReceiver ($SFURL, $StoreName, $ReceiverSwitches, $SSO, $DisableFTU, $NoStore, $ReceiverExecutable)
    {
    # Get OS and OS bitness variables
    $OS = (Get-WmiObject Win32_OperatingSystem).Caption
    $OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

        # Get script dir
        $ScriptDir = (Get-Location).Path
        If ($NoStore)
        {
        # Install Citrix Receiver
        Write-Output "Installing Citrix Receiver..." -Verbose
        Push-Location $ScriptDir

        Start-Process -Wait $ReceiverExecutable -ArgumentList "$ReceiverSwitches" -PassThru
        }
        else
        {
            If ($SSO)
            {
                # Set Single Sign-on install switch
                $ReceiverSwitches = $ReceiverSwitches+$SSO    
            }
                    # Install Citrix Receiver
                    Write-Output "Installing Citrix Receiver..." -Verbose
                    Push-Location $ScriptDir

                    Start-Process -Wait $ReceiverExecutable -ArgumentList "$ReceiverSwitches STORE0=`"$StoreName;$SFURL/Citrix/$StoreName/discovery;on;App Store`"" -PassThru
                    
                        If ($DisableFTU)
                        {
                        Write-Output "Disable Citrix Receiver FTU..." -Verbose

                            # Disable FTU "Add Store" popup
                            If ($OSArchitecture -eq "64-bit")
                            {
                                New-Item -Path "HKLM:SOFTWARE\Wow6432Node\Policies" -Name Citrix -Force | Out-Null
                                New-ItemProperty -Path "HKLM:SOFTWARE\Wow6432Node\Policies\Citrix" -Name EnableX1FTU -Value 0 | Out-Null
                                New-ItemProperty -Path "HKLM:SOFTWARE\Wow6432Node\Citrix\Dazzle" -Name AllowAddStore -Value N -Force | Out-Null
                            }
                                If ($OSArchitecture -eq "32-bit")
                                {
                                    New-ItemProperty -Path "HKLM:SOFTWARE\Policies\Citrix" -Name EnableX1FTU -Value 0 | Out-Null
                                    New-ItemProperty -Path "HKLM:SOFTWARE\Citrix\Dazzle" -Name AllowAddStore -Value N -Force | Out-Null
                                }
                        }
        }
    }

Install-CitrixReceiver $SFURL $StoreName $ReceiverSwitches $SSO $DisableFTU $NoStore $ReceiverExecutable