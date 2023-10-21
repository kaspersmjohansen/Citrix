############################################################################
#
# NAME: XD7Export.ps1
#
# AUTHOR: Peter Juncker, Atea A/S
# DATE  : 27-11-2013
# DATA  : 17-12-2013
#
# COMMENT: Script til eksport af XD7 applikationer, som kan importeres med XD7Import.ps1
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
Write-Host -BackgroundColor Green -ForegroundColor Black "XD7Export - XenDesktop7 Export Utility by Atea" 
Write-Host
$DesktopGroupName = Read-Host 'Write Delivery Group to be exporteds ?'
Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Exporting all application - wait" 
Write-Host

#Henter DesktopGroup
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

#Henter Ikoner
get-brokericon | export-csv $IconListpath -encoding "UTF8"

#Henter Applikations Liste
get-brokerapplication -DesktopGroupUid $DesktopGroup.UID | export-csv $AppListpath -encoding "UTF8"

#Henter User Mapping
If (Test-Path $UserMappath) {Remove-Item $UserMappath}
Add-Content $UserMappath "UID,Username" -encoding "UTF8"
Get-BrokerApplication -DesktopGroupUid $DesktopGroup.UID | ForEach-Object {
	$Temp=$_.uid -as [string]

	get-brokeruser -ApplicationUid $_.uid | ForEach-Object {
		Write-Host -BackgroundColor Green -ForegroundColor Black "UID=" $Temp " User=" $_.Name
		$temp1=$_.Name -as [string]
		Add-Content $UserMappath "$temp,$temp1" -encoding "UTF8"
	}	
}