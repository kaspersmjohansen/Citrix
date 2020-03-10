#Requires -Version 3.0
<#
*********************************************************************************************************************************
Name:               Migrate-XAapps
Author:             Kasper Johansen
Last modified by:   Kasper Johansen
Last modified Date: 16-11-2019
Version             1.0

.SYNOPSIS
    Migrates Admin Folders between Citrix Virtual Apps and Desktops sites.

.DESCRIPTION
    This script migrates any Admin Folders between Citrix Virtual Apps and Desktops sites.

    The script can both import and export Admin Folders from a Citrix Virtual Apps and Desktops site.
    
    The script has been testet with:
    Citrix Virtual Apps and Desktops 1909
    Citrix Viertual Apps and Desktop Services (Citrix Cloud)

    !! If migrating to Citrix Cloud, you must have the Citrix Remote PowerShell SDK Installed !! 
    More info here: https://docs.citrix.com/en-us/citrix-virtual-apps-desktops-service/sdk-api.html

    All information about an Admin Folder is exported to a CSV file

    The name of the CSV file is hardcoded, but the path to the CSV file is customizable.
    The specific CSV produced when exporting is:
    
    AppsAdminFolders.csv

    Which is a CSV file containing all information about Admin Folder

    This CSV file is needed for a successfull import!

    .PARAMETER CSVInput
    Specifies the path to the CSV file. If not specified, the default path, 
    which is the directory from where the script is executed, is selected. 
    This parameter can only be used with the -Import switch.

    .PARAMETER CSVOutput
    Specifies the path to where the CSV files are to be exported. If not specified, the default path, 
    which is the directory from where the script is executed, is selected. 
    This parameter can only be used with the -Export switch.

    .SWITCH Import
    Enables the import of published applications to a Citrix Virtual Apps and Desktop Site

    .SWITCH Export
    Enables the Export of published applications from a Citrix Virtual Apps and Desktop Site

    .PARAMETER LogDir
    Specifies the directory to store the transcription logfile. If not specified, the default path, 
    which is the directory from where the script is executed, is selected.
    
.EXAMPLES
    
    Export Admin Folders with custom CSV output path:

        Migrate-CVADAdminFolders -Export -CSVOutput C:\CSVOutput

    Import Admin Folders from custom CSV path:

        Migrate-CVADAdminFolders -Import -CSVInput C:\CSVOutput

    Export Admin Folders using default values:

        Migrate-CVADAdminFolders -Export

    Import Admin Folders using default values
        
        Migrate-CVADAdminFolders -Import

*********************************************************************************************************************************
#>

# Function parameters
Param(
    [Parameter(ParameterSetName = "Import")]
    [string]$CSVInput = (Split-Path -parent $MyInvocation.MyCommand.Definition),
    [Parameter(ParameterSetName = "Export")]
    [string]$CSVOutput = (Split-Path -parent $MyInvocation.MyCommand.Definition),
    [Parameter(ParameterSetName = "Import", Mandatory)]
    [switch]$Import,
    [Parameter(ParameterSetName = "Export", Mandatory)]
    [switch]$Export,
    [string]$DeliveryController = $env:COMPUTERNAME,
    [string]$LogDir = (Split-Path -parent $MyInvocation.MyCommand.Definition)
    )

function Export-AppsAdminsFolders ($CSVOutput,$LogDir,$Export)
    {
        # Start time measuring and transcription
        $LogPS = $LogDir + "\Export-CVADAdminFolders.log"
        $startDTM = (Get-Date)
        Start-Transcript $LogPS | Out-Null

        # CSV path variables
        $AppsAdminFoldersCSV = $CSVOutput + "\AppsAdminFolders.csv"

        # Export Admin Folders information
        Write-Host "Exporting Admin Folders" -Verbose
        If (Test-Path -Path $AppsAdminFoldersCSV)
        {
            Remove-Item -Path $AppsAdminFoldersCSV
        }
                Get-BrokerAdminFolder | Export-Csv $AppsAdminFoldersCSV -Encoding "UTF8" -NoTypeInformation -Verbose

        # End time measuring and transcription
        $EndDTM = (Get-Date)
        Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
        Stop-Transcript | Out-Null
                   
    }

function Import-AppsAdminsFolders ($CSVOutput,$LogDir,$Export)
    {
        # Start time measuring and transcription
        $LogPS = $LogDir + "\Import-CVADAdminFolders.log"
        $startDTM = (Get-Date)
        Start-Transcript $LogPS | Out-Null

        # CSV path variables
        $AppsAdminFoldersCSV = $CSVInput + "\AppsAdminFolders.csv"

        # Import Admin Folders information
        Import-Csv .\AppsAdminFolders.csv|ForEach-Object {
                    
            [string]$FolderName = $_.FolderName
            [string]$Name = $_.Name
	        [int]$ParentAdminFolderUid = $_.ParentAdminFolderUid
	        [int]$Uid=$_.Uid
            
            # Import Admin Folders. 
            # Skip UID 0, if exist, this is always the default root folder UID.
            If ($Uid -ne "0")
            {
                Write-Host "Creating Admin folder: $FolderName"
                # If ParentFolder UID is 0
                If ($ParentAdminFolderUid -eq "0")
                {
                    New-BrokerAdminFolder -FolderName $FolderName -ParentFolder $ParentAdminFolderUid
                }
                else
                    {
                        $ParentAdminFolder = $Name -replace "\\$FolderName\\",""
                        New-BrokerAdminFolder -FolderName $FolderName -ParentFolder $ParentAdminFolder    
                    }
            }
        }
        # End time measuring and transcription
        $EndDTM = (Get-Date)
        Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
        Stop-Transcript | Out-Null
    }
    
function Migrate-CVADAdminFolders ($CSVInput,$CSVOutput,$LogDir,$Import,$Export)
    {
        If ($Export)
        {
            Export-AppsAdminsFolders -CSVOutput $CSVOutput -LogDir $LogDir
        }
            If ($Import)
            {
                Import-AppsAdminsFolders -CSVInput $CSVInput -LogDir $LogDir
            }
    }

Migrate-CVADAdminFolders $CSVInput $CSVOutput $LogDir $Import $Export