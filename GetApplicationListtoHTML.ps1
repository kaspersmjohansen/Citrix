Add-PSSnapin Citrix*
$Apps = Get-BrokerApplication | Select-Object Name, PublishedName, AssociatedUserNames, ApplicationType, Enabled
$Apps | %{$_.AssociatedUserNames = [string]$_.AssociatedUserNames}
$Apps | ConvertTo-Html  | Out-File C:\ApplicationList.html