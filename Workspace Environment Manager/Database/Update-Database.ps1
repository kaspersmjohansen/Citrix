$DBName = "CitrixWEMTEST"
$SQLServerName = "srvsql01.johansen.local"
Import-Module WemDatabaseConfiguration
Update-WemDatabase -DatabaseServerInstance "$SQLServerName" -DatabaseName $DBName