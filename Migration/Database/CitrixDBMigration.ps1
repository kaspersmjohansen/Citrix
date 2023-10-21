#hvis det fejler nÃ¥r db sÃ¦ttes til null, sÃ¥ reset connection i regdatabase og genstart service
#Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\XDservices\xxx\DataStore\Connections
#Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\DesktopServer\DataStore\Connections\Controller#

# https://docs.citrix.com/en-us/advanced-concepts/implementation-guides/database-connection-strings#procedure

$pause = $true

Add-PSSnapin citrix*

$CurrentSQL = "SRVSQL01.johansen.local"
$NewSQL = "SRVSQL02.johansen.local"

$SiteDBName = "CitrixXDTESTSite"
$LogDBName = "CitrixXDTESTLogging"
$MonDBName = "CitrixXDTESTMonitoring"

Write-Host "Testing existing DB connections" -ForegroundColor Cyan
$ConnStr    = Get-ConfigDBConnection 
$ConnLogStr = Get-LogDBConnection -DataStore Logging
$ConnMonStr = Get-MonitorDBConnection -DataStore Monitor

$CurrentConnStr = Get-ConfigDBConnection

# Current SQL server conenction string
# $ConnStr    = "Server=$CurrentSQL;Initial Catalog=$SiteDBName;Integrated Security=True"
# $ConnLogStr = "Server=$CurrentSQL;Initial Catalog=$LogDBName;Integrated Security=True"
# $ConnMonStr = "Server=$CurrentSQL;Initial Catalog=$MonDBName;Integrated Security=True"

# New SQl Server conenction string
$ConnStr    = "Server=$NewSQL;Initial Catalog=$SiteDBName;Integrated Security=True"
$ConnLogStr = "Server=$NewSQL;Initial Catalog=$LogDBName;Integrated Security=True"
$ConnMonStr = "Server=$NewSQL;Initial Catalog=$MonDBName;Integrated Security=True"

# Test current DB connection string
Test-AdminDBConnection -DBConnection $CurrentConnStr
Test-ConfigDBConnection -DBConnection $CurrentConnStr
Test-AcctDBConnection -DBConnection $CurrentConnStr
Test-HypDBConnection -DBConnection $CurrentConnStr
Test-ProvDBConnection -DBConnection $CurrentConnStr
Test-BrokerDBConnection -DBConnection $CurrentConnStr
Test-EnvTestDBConnection -DBConnection $CurrentConnStr
Test-LogDBConnection -DBConnection $CurrentConnStr
Test-MonitorDBConnection -DBConnection $CurrentConnStr
Test-SfDBConnection -DBConnection $CurrentConnStr

# Stop Site logging
Write-Host "Stopping Logging" -ForegroundColor Cyan
if ($pause) { pause }
Set-LogSite -State "Disabled"
Set-MonitorConfiguration -DataCollectionEnabled $False

# Clear all current DB connections
Write-Host "Clearing all current DB Connections" -ForegroundColor Cyan
if ($pause) { pause }
Set-MonitorDBConnection -DataStore Monitor -DBConnection $null
Set-LogDBConnection -DataStore Logging -DBConnection $null

Set-ConfigDBConnection -DBConnection $null
Set-AcctDBConnection -DBConnection $null
Set-AnalyticsDBConnection -DBConnection $null
Set-HypDBConnection -DBConnection $null
Set-ProvDBConnection -DBConnection $null
Set-BrokerDBConnection -DBConnection $null
Set-EnvTestDBConnection -DBConnection $null
Set-TrustDBConnection -DBConnection  $null
Set-SfDBConnection -DBConnection $null
Set-AppLibDBConnection  -DBConnection $null
Set-OrchDBConnection  -DBConnection $null
Set-MonitorDBConnection -DBConnection $null
Set-LogDBConnection -DBConnection $null 
Set-AdminDBConnection -DBConnection $null -force


# Kør på alle
Write-Host "Configuring new DB Connections" -ForegroundColor Black -BackgroundColor Yellow
if ($pause) { pause }
Set-AdminDBConnection -DBConnection $ConnStr
Set-LogDBConnection -DBConnection  $ConnStr

Set-AnalyticsDBConnection -DBConnection $ConnStr
Set-ConfigDBConnection -DBConnection $ConnStr
Set-AcctDBConnection -DBConnection $ConnStr
Set-HypDBConnection -DBConnection $ConnStr
Set-ProvDBConnection -DBConnection $ConnStr
Set-BrokerDBConnection -DBConnection $ConnStr
Set-EnvTestDBConnection -DBConnection $ConnStr
Set-AppLibDBConnection  -DBConnection $ConnStr
Set-OrchDBConnection  -DBConnection $ConnStr
Set-MonitorDBConnection -DBConnection $ConnStr
Set-SfDBConnection -DBConnection $ConnStr

# write-host " Kør reset-monitordatastore og  reset-logdatastore på DDC2"
# pause
Reset-MonitorDataStore –DataStore Monitor 
Reset-LogDataStore -DataStore Logging

Set-MonitorDBConnection -DataStore Monitor -DBConnection $ConnMonStr
Set-LogDBConnection -DataStore Logging -DBConnection $ConnLogStr

Write-Host "Testing new DB Connections..." -ForegroundColor Cyan
Test-AdminDBConnection -DBConnection $ConnStr
Test-AnalyticsDBConnection -DBConnection $ConnStr
Test-ConfigDBConnection -DBConnection $ConnStr
Test-AcctDBConnection -DBConnection $ConnStr
Test-HypDBConnection -DBConnection $ConnStr
Test-ProvDBConnection -DBConnection $ConnStr
Test-BrokerDBConnection -DBConnection $ConnStr
Test-EnvTestDBConnection -DBConnection $ConnStr
Test-LogDBConnection -DBConnection $ConnStr
Test-MonitorDBConnection -DBConnection $ConnStr
Test-SfDBConnection -DBConnection $ConnStr

Write-Host "Enable Logging" -ForegroundColor Cyan
if ($pause) { pause }
Set-MonitorConfiguration -DataCollectionEnabled $true
Set-LogSite -State "Enabled"

#write-host "start DDC og  kør license upgrade / site upgrade. Bagefter  kan den næste være nødvendig"
#pause

Write-Host "Resetting Broker instancer.   Skal kÃ¸res pÃ¥ alle broker" -ForegroundColor Cyan
if ($pause) { pause }
Get-ConfigRegisteredServiceInstance -ServiceType "Broker" | Unregister-ConfigRegisteredServiceInstance
Get-BrokerServiceInstance | Register-ConfigServiceInstance

Write-Host "Restarting all Citrix Services.. bør ikke være nødvendig." -ForegroundColor Cyan
pause
if ($pause) { pause }
Get-Service Citrix* | Stop-Service -Force
Get-Service Citrix* | Start-Service
