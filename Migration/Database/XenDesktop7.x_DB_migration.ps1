<# 

This script migrates the XenDesktop 7.x database to another SQL server. 
The script is testet with SQL Express 2012 and SQL Server 2012 Enterprise and XenDesktop 7.6

Make sure the database/databases is/are backed up and migrated to the new SQL server
Run this query on the SQL Server: create login [domain\machine$] and set the needed permissions on the database

This script must be executed on a XenDesktop 7.x delivery controller

More information about database migration in XenDesktop 7.x can be found here:
http://support.citrix.com/article/CTX140319

IMPORTANT NOTE:
Set-AnalyticsDBConnection -DBConnection is for 7.6 and later. On versions older than 7.6 you will receive an error.

The $NewSQL variable must contain the computername of the new SQL server
The $SiteDBName variabel must contain the name of the Xenesktop 7.x Site database
The $MonitorDBName variabel must contain the name of the Xenesktop 7.x Monitor database
The $LogDBName variabel must contain the name of the Xenesktop 7.x Logging database

The database names can be found by running the commands:

Get-BrokerDBConnection  = Site database
Get-LogDBConnection     = Log Database
Get-MonitorDBConnection = Monitor Database

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 07-07-2015

#>

$NewSQL = "SQL01"
$SiteDBName = "CitrixTestSite"
$MonitorDBName = "CitrixTestSite"
$LoggingDBName = "CitrixTestSite"

# Do not edit below this line, unless you know what you are doing!
# ---------------------------------------------------------------#

# Configure ODBC connection strings
$SiteDBConnectionString = "Server=$NewSQL;Initial Catalog=$SiteDBName;Integrated Security=True"
$MonitorDBConnectionString = "Server=$NewSQL;Initial Catalog=$MonitorDBName;Integrated Security=True"
$LoggingDBConnectionString = "Server=$NewSQL;Initial Catalog=$LoggingDBName;Integrated Security=True"

Add-PSSnapin Citrix*

cls

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Disconnecting current site database..."
Write-Host


# Remove current DB connection
Set-ConfigDBConnection -DBConnection $null
Set-AcctDBConnection -DBConnection $null
Set-AnalyticsDBConnection -DBConnection $null
Set-HypDBConnection -DBConnection $null
Set-ProvDBConnection -DBConnection $null
Set-BrokerDBConnection -DBConnection $null
Set-EnvTestDBConnection -DBConnection $null
Set-SfDBConnection -DBConnection $null
Set-AdminDBConnection -DBConnection $null

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Connecting new site database to $NewSQL"
Write-Host



# Enable DB connections new SQL server
Set-AdminDBConnection -DBConnection $SiteDBConnectionString
Set-ConfigDBConnection -DBConnection $SiteDBConnectionString
Set-AcctDBConnection -DBConnection $SiteDBConnectionString
Set-AnalyticsDBConnection -DBConnection $SiteDBConnectionString
Set-HypDBConnection -DBConnection $SiteDBConnectionString
Set-ProvDBConnection -DBConnection $SiteDBConnectionString
Set-BrokerDBConnection -DBConnection $SiteDBConnectionString
Set-EnvTestDBConnection -DBConnection $SiteDBConnectionString
Set-SfDBConnection -DBConnection $SiteDBConnectionString

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Disconnecting Logging and Monitoring databases..."
Write-Host

# Disable DB connections
Set-LogSite -State Disabled

# Stop monitoring
Set-MonitorConfiguration -DataCollectionEnabled $False

# Remove current DB connection
Set-MonitorDBConnection -DataStore Monitor -DBConnection $null
Set-MonitorDBConnection -DBConnection $null
Set-LogDBConnection -DataStore Logging -DBConnection $null
Set-LogDBConnection -DBConnection $null

Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Connecting new Logging and Monitoring databases to $NewSQL"
Write-Host

# Enable Monitor and Logging DB Connections to new SQL Server
Set-LogDBConnection -DBConnection $SiteDBConnectionString

Start-Sleep -s 5

Set-LogDBConnection -DataStore Logging -DBConnection $LoggingDBConnectionString

Start-Sleep -s 5

Set-MonitorDBConnection -DBConnection $SiteDBConnectionString

Start-Sleep -s 5

Set-MonitorDBConnection -DataStore Monitor -DBConnection $MonitorDBConnectionString

# Enable Configuration Logging
Set-LogSite -State Enabled

#Enable Monitoring
Set-MonitorConfiguration -DataCollectionEnabled $true

# Test DB connections on new SQL server
Test-AdminDBConnection -DBConnection $SiteDBConnectionString
Test-ConfigDBConnection -DBConnection $SiteDBConnectionString
Test-AcctDBConnection -DBConnection $SiteDBConnectionString
Test-AnalyticsDBConnection -DBConnection $SiteDBConnectionString
Test-HypDBConnection -DBConnection $SiteDBConnectionString
Test-ProvDBConnection -DBConnection $SiteDBConnectionString
Test-BrokerDBConnection -DBConnection $SiteDBConnectionString
Test-EnvTestDBConnection -DBConnection $SiteDBConnectionString
Test-LogDBConnection -DBConnection $SiteDBConnectionString
Test-LogDBConnection -DataStore Logging -DBConnection $LoggingDBConnectionString
Test-MonitorDBConnection -DBConnection $SiteDBConnectionString
Test-MonitorDBConnection -DataStore Monitor -DBConnection $MonitorDBConnectionString
Test-SfDBConnection -DBConnection $SiteDBConnectionString