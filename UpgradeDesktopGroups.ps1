Add-PSSnapin Citrix*

$DeliveryController = "srvxdc01.ocdevil.local"
$DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $DeliveryController | where {$_.MinimumFunctionalLevel -ne "LMAX"} | select Name,MinimumFunctionalLevel

foreach ($Group in $DesktopGroups){
Set-BrokerDesktopGroup -Name $Group.Name -MinimumFunctionalLevel LMAX

}