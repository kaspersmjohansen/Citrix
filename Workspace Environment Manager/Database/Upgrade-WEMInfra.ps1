$DBName = "CitrixWEM"
$SQLServerName = "srvsql01.johansen.local"
$LicServerName = "srvfil01.johansen.local"
$Domain = "johansen"
$ServiceAccount = "svc-ctx"
$ServiceAccountPwd = "Password1"

$passwd = ConvertTo-SecureString $ServiceAccountPwd -AsPlainText -Force;
$cred = New-Object System.Management.Automation.PSCredential("$Domain\$ServiceAccount", $passwd);

Import-Module WemDatabaseConfiguration
Update-WemDatabase -DatabaseServerInstance "$SQLServerName" -DatabaseName $DBName

Set-WemInfrastructureServiceConfiguration -InfrastructureServer $env:COMPUTERNAME -InfrastructureServiceAccountCredential $cred -DatabaseServerInstance "$SQLServerName" -DatabaseName $DBName -EnableScheduledMaintenance Enable -StatisticsRetentionPeriod "365" -SystemMonitoringRetentionPeriod "90" -AgentRegistrationsRetentionPeriod "1" -DatabaseMaintenanceExecutionTime "02:00" -GlobalLicenseServerOverride Enable -LicenseServerName "$LicServerName" -LicenseServerPort "27000"