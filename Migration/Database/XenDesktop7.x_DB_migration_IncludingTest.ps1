<# 

This script migrates the XenDesktop 7.x database to another SQL server. 
The script is testet with SQL Express 2012, SQL Sever 2012, SQL Server 2014 and XenDesktop 7.6

Make sure the database/databases is/are backed up and migrated to the new SQL server

More information about database migration in XenDesktop 7.x can be found here:
http://support.citrix.com/article/CTX140319

This script must be executed on a XenDesktop 7.x delivery controller

IMPORTANT NOTE:
Set-AnalyticsDBConnection -DBConnection is for 7.6 and later. On versions older than 7.6 you will receive an error during script execution.

The $NewSQL variable must contain the computername of the new SQL server
The $SiteDBName variabel must contain the name of the Xenesktop 7.x Site database
The $MonitorDBName variabel must contain the name of the Xenesktop 7.x Monitor database
The $LogDBName variabel must contain the name of the Xenesktop 7.x Logging database

The database names can be found by running the commands:

Get-BrokerDBConnection  = Site database
Get-LogDBConnection     = Log Database
Get-MonitorDBConnection = Monitor Database

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 21-06-2015

#>

$NewSQL = ""
$SiteDBName = "Citrix_Site"
$MonitorDBName = "Citrix_Monitor"
$LoggingDBName = "Citrix_Logging"

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