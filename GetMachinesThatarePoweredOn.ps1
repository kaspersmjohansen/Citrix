$MachineName =""

Add-PSSnapin Citrix*
Get-BrokerMachine -PowerState On | where {$_.MachineName -match "$MachineName*"} | ft MachineName