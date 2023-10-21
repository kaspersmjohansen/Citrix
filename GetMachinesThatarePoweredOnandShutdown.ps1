$MachineName ="HJA-VDI"

Add-PSSnapin Citrix*
$VDA = Get-BrokerMachine -PowerState On | where {$_.MachineName -match "$MachineName*"}

ForEach ($Machine in $VDA.MachineName){
New-BrokerHostingPowerAction -MachineName $Machine -Action Shutdown
}