############################################################################
#
# NAME: XD7Import.ps1
#
# AUTHOR: Peter Juncker, Atea A/S
# DATE  : 27-11-2013
# DATA  : 17-12-2013
#
# COMMENT: Script til oprettelse af XD7 applikationer fra en export fil generet af XD7Export.ps1
#	   Husk at Vælg DesktopGroupName !! (Delivery Group)
#
# Version 2.10
############################################################################
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$AppListpath = $scriptPath + "\APPList.csv"
$IconListpath = $scriptPath + "\IkonList.csv"
$UserMappath = $scriptPath + "\usermap.csv"
#$DesktopGroupName="Produktion"


#Clear Screen
cls
Write-Host -BackgroundColor Green -ForegroundColor Black "XD7Import - XenDesktop7 Import Utility by Atea" 
Write-Host
$DesktopGroupName = Read-Host 'Select the Delivery Group to be imported into ?'
Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Importing all application - wait" 
Write-Host

#henter DesktopGroup
$DesktopGroup=Get-BrokerDesktopGroup | Where-Object {$_.Name -eq $DesktopGroupName}
IF ($DesktopGroup.UID) 
	{
	Write-Host -BackgroundColor Green -ForegroundColor Black "DesktopGroup UID= "  $DesktopGroup.UID
	}
	else
	{
	Write-Host -BackgroundColor Green -ForegroundColor Black "ERROR - DesktopGroupName (Delivery Group) '" $DesktopGroupName "' not found"
	exit
	}

import-csv -path $AppListpath|ForEach-Object {
	$AppApplicationType=$_.ApplicationType
	$AppAssociatedDesktopGroupPriorities=$_.AssociatedDesktopGroupPriorities
	$AppAssociatedDesktopGroupUids=$_.AssociatedDesktopGroupUids
	$AppAssociatedUserFullName=$_.AssociatedUserFullNames
	$AppAssociatedUserNames=$_.AssociatedUserNames
	$AppAssociatedUserUPNs=$_.AssociatedUserUPNs
	$AppBrowserName=$_.BrowserName
	$AppClientFolder=$_.ClientFolder
	$AppCommandLineArguments=$_.CommandLineArguments
	$AppCommandLineExecutable=$_.CommandLineExecutable
	$AppCpuPriorityLevel=$_.CpuPriorityLevel
	$AppDescription=$_.Description
	$AppEnabled=$_.Enabled -as [bool]
	$AppIconFromClient=$_.IconFromClient -as [bool]
	$AppIconUid=$_.IconUid
	$AppMetadataKeys=$_.MetadataKeys
	$AppMetadataMap=$_.MetadataMap
	$AppName=$_.Name
	$AppPublishedName=$_.PublishedName
	$AppSecureCmdLineArgumentsEnabled=$_.SecureCmdLineArgumentsEnabled -as [bool]
	$AppShortcutAddedToDesktop=$_.ShortcutAddedToDesktop -as [bool]
	$AppShortcutAddedToStartMenu=$_.ShortcutAddedToStartMenu -as [bool]
	$AppStartMenuFolder=$_.StartMenuFolder
	$AppUUID=$_.UUID
	$AppUid=$_.Uid
	$AppUserFilterEnabled=$_.UserFilterEnabled -as [bool]
	$AppVisible=$_.Visible -as [bool]
	$AppWaitForPrinterCreation=$_.WaitForPrinterCreation -as [bool]
	$AppWorkingDirectory=$_.WorkingDirectory



Write-Host -BackgroundColor Green -ForegroundColor Black "-Start----------------------------------"
Write-Host -BackgroundColor Green -ForegroundColor Black "Applications Name= " $AppName
Write-Host -BackgroundColor Green -ForegroundColor Black "Description= " $AppDescription

#Henter ICON Data
$Icondata=import-csv -path $IconListpath| Where-Object {$_.UID -eq $AppIconUid}
#Write-Host -BackgroundColor Green -ForegroundColor Black "EncodedIconData " $Icondata.EncodedIconData
#Write-Host -BackgroundColor Green -ForegroundColor Black "IMPORTET ICON UID " $Icondata.Uid

#Henter UserAccess
$UserName=import-csv -path $UserMappath| Where-Object {$_.UID -eq $AppUid} #| ForEach-Object {
Write-Host -BackgroundColor Green -ForegroundColor Black "Getting Username(s) " $UserName.Username

#Opretter Ikon
$NewIconID=New-BrokerIcon  -EncodedIconData $Icondata.EncodedIconData
#Write-Host -BackgroundColor Green -ForegroundColor Black "NEW UID " $NewIconID.UID

#Opretter Applikation
#Write-Host -BackgroundColor Green -ForegroundColor Black "AppShortcutAddedToDesktop= "  $AppShortcutAddedToDesktop
IF (Get-BrokerApplication | Where { $_.Name -eq $AppName }) 
	{
	Write-Host -BackgroundColor Yellow -ForegroundColor Black "Application allready exist !"
	}
	ELSE
	{
	Write-Host -BackgroundColor Green -ForegroundColor Black "Creating Application - GO FOR IT BILBO !!"
	New-BrokerApplication  -ApplicationType $AppApplicationType -ClientFolder $AppClientFolder -CommandLineArguments $AppCommandLineArguments -CommandLineExecutable $AppCommandLineExecutable -CpuPriorityLevel $AppCpuPriorityLevel -Description $AppDescription -DesktopGroup $DesktopGroup.UID -Enabled $AppEnabled -IconUid $NewIconID.UID  -Name $AppName -Priority 0 -PublishedName $AppPublishedName -SecureCmdLineArgumentsEnabled $AppSecureCmdLineArgumentsEnabled -StartMenuFolder $AppStartMenuFolder -ShortcutAddedToDesktop $AppShortcutAddedToDesktop -ShortcutAddedToStartMenu $AppShortcutAddedToStartMenu -UserFilterEnabled $False -Visible $AppVisible -WaitForPrinterCreation $AppWaitForPrinterCreation
	
	$NewAPPUUID=Get-BrokerApplication $AppName
	Write-Host -BackgroundColor Green -ForegroundColor Black "NewAPPUUID= "  $NewAPPUUID.UID
	Write-Host -BackgroundColor Green -ForegroundColor Black "AppUserFilterEnabled= "  $AppUserFilterEnabled
	if ($AppUserFilterEnabled -eq $True)
		{
		#Write-Host -BackgroundColor Green -ForegroundColor Black "True !"
		Set-BrokerApplication  -InputObject $NewAPPUUID -UserFilterEnabled $True -WorkingDirectory $AppWorkingDirectory
		Add-BrokerApplication   -DesktopGroup $DesktopGroup.UID -InputObject $NewAPPUUID   -Priority 0
		
		$UserName | ForEach-Object {
		Write-Host -BackgroundColor Green -ForegroundColor Black "Adding Username " $_.Username 
		Add-BrokerUser  -Application $NewAPPUUID  -Name $_.Username
		}
		}
		else
		{
		#Write-Host -BackgroundColor Green -ForegroundColor Black "False !"
		Set-BrokerApplication  -InputObject $NewAPPUUID -UserFilterEnabled $False -WorkingDirectory $AppWorkingDirectory
		Add-BrokerApplication   -DesktopGroup $DesktopGroup.UID -InputObject $NewAPPUUID   -Priority 0
		}
	}

}

