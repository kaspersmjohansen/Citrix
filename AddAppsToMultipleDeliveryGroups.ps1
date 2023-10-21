$XDCController = "srvxdc01.ocdevil.local"
$DeliveryGroup = "XenApp 76 - 2012 R2 - MCS"

Add-PSSnapin Citrix*
$GetApps = Get-BrokerApplication -AdminAddress $XDCController

ForEach ($App in $GetApps.ApplicationName){
Add-BrokerApplication -Name "$app" -DesktopGroup "$DeliveryGroup"
}