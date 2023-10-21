Add-PSSnapin Citrix*

$DeliveryController = "srvxdc01.ocdevil.local"
$DesktopGroups = Get-BrokerCatalog -AdminAddress $DeliveryController | where {$_.MinimumFunctionalLevel -ne "LMAX"} | select Name,MinimumFunctionalLevel

foreach ($Group in $DesktopGroups){
Set-BrokerCatalog -Name $Group.Name -MinimumFunctionalLevel LMAX

}