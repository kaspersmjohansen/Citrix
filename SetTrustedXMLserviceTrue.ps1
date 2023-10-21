Add-PSSnapin Citrix*
Set-BrokerSite -TrustRequestsSentToTheXmlServicePort $true

$TrustedXMLservice = (Get-BrokerSite).TrustRequestsSentToTheXmlServicePort
Write-Host "Trusted XML Service = $TrustedXMLservice"