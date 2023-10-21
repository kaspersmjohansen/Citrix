Add-PSSnapin Citrix.*

$XenappServers = Get-BrokerMachine | Where-Object -FilterScript {$_.SummaryState -NE "Unregistered"}| Sort-Object DNSName

Foreach ($XenappServer in $XenappServers){
 Write-Host "Updating $($XenappServer.dnsname)"
 Invoke-Command -ComputerName $($XenappServer.DNSName) -ScriptBlock { gpupdate /force } -AsJob | Out-Null
}
