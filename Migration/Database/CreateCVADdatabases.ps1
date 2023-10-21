Add-PSSnapin Citrix*
Import-Module Citrix.XenDesktop.Admin
$SQLServerName = "srvsql01.johansen.local"

$SiteName = "CVADTEST"
$SiteDBName = "$SiteName-Site"
$MonDBName = "$SiteName-Monitoring"
$LogDBName = "$SiteName-Logging"

# Site DB
New-XDDatabase -SiteName $SiteName -DataStore Site -DatabaseServer $SQLServerName -DatabaseName $SiteDBName

# Monitoring DB
New-XDDatabase -SiteName $SiteName -DataStore Monitor -DatabaseServer $SQLServerName -DatabaseName $MonDBName

# Logging DB
New-XDDatabase -SiteName $SiteName -DataStore Logging -DatabaseServer $SQLServerName -DatabaseName $LogDBName

Add-PSSnapin Citrix.Broker.Admin.V2
$csSite = "Server=$SQLServerName;Initial Catalog=$SiteDBName;Integrated Security=True"
$csLogging = "Server=$SQLServerName;Initial Catalog=$LogDBName;Integrated Security=True"
$csMonitoring = "Server=$SQLServerName;Initial Catalog=$MonDBName;Integrated Security=True"

Test-AcctDBConnection -DBConnection $csSite
Test-AdminDBConnection -DBConnection $csSite
Test-LogDBConnection -DBConnection $csSite
Test-LogDBConnection -DataStore Logging -DBConnection $csLogging
Test-MonitorDBConnection -DBConnection $csSite
Test-MonitorDBConnection -Datastore Monitor -DBConnection $csMonitoring
Test-AnalyticsDBConnection -DBConnection $csSite
Test-AppLibDBConnection -DBConnection $csSite
Test-BrokerDBConnection -DBConnection $csSite
Test-ConfigDBConnection -DBConnection $csSite
Test-EnvTestDBConnection -DBConnection $csSite
Test-HypDBConnection -DBConnection $csSite
Test-OrchDBConnection -DBConnection $csSite
Test-ProvDBConnection -DBConnection $csSite
Test-SfDBConnection -DBConnection $csSite
Test-TrustDBConnection -DBConnection $csSite

Set-AdminDBConnection -DBConnection $csSite
Set-AcctDBConnection -DBConnection $csSite

Set-LogDBConnection -DBConnection $csSite
Set-LogDBConnection -DataStore Logging -DBConnection $csLogging

Set-MonitorDBConnection -DBConnection $csSite
Set-MonitorDBConnection -DataStore Monitor -DBConnection $csMonitoring 

Set-AnalyticsDBConnection -DBConnection $csSite
Set-AppLibDBConnection -DBConnection $csSite
Set-BrokerDBConnection -DBConnection $csSite
Set-ConfigDBConnection -DBConnection $csSite
Set-EnvTestDBConnection -DBConnection $csSite
Set-HypDBConnection -DBConnection $csSite


Set-OrchDBConnection –DBConnection $csSite
Set-ProvDBConnection -DBConnection $csSite
Set-SfDBConnection -DBConnection $csSite
Set-TrustDBConnection –DBConnection $csSite






Set-AdminDBConnection -DBConnection $csSite
Set-ConfigDBConnection -DBConnection $csSite
Set-AcctDBConnection -DBConnection $csSite
Set-AnalyticsDBConnection -DBConnection $csSite # 7.6 and newer
Set-HypDBConnection -DBConnection $csSite 
Set-ProvDBConnection -DBConnection $csSite
Set-AppLibDBConnection –DBConnection $csSite # 7.8 and newer
Set-OrchDBConnection –DBConnection $csSite # 7.11 and newer
Set-TrustDBConnection –DBConnection $csSite # 7.11 and newer
Set-BrokerDBConnection -DBConnection $csSite
Set-EnvTestDBConnection -DBConnection $csSite
Set-SfDBConnection -DBConnection $csSite
Set-LogDBConnection -DBConnection $csSite
Set-LogDBConnection -DataStore Logging -DBConnection $null
Set-LogDBConnection -DBConnection $null
Set-LogDBConnection -DBConnection $csSite
Set-LogDBConnection -DataStore Logging -DBConnection $csLogging
Set-MonitorDBConnection -DBConnection $csSite
Set-MonitorDBConnection -DataStore Monitor -DBConnection $null
Set-MonitorDBConnection -DBConnection $null
Set-MonitorDBConnection -DBConnection $csSite
Set-MonitorDBConnection -DataStore Monitor -DBConnection $csMonitoring
Set-LogSite -State Enabled