<#
This script restores a database on an SQL server using SQL Server Command Line tool
The script must be executed on the SQL server where you wish to restore the database

The variable $SQLDatabaseBackupDir must contain the directory name where the database should backup up
The variable $SQLInstanceName must contain the SQL instance name, if an instance is configured, otherwise leave it blank
The variable $SQLDatabaseName must containt the name/names of the database you wish to backup. Multiple names

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 26-06-2015
#>

# Variables
$SQLDatabaseBackupDir = "C:\Database Backup"
$SQLInstanceName = ""
$SQLDatabaseName = "CitrixTest_Site","CitrixTest_Monitor","CitrixTest_Logging"

$XDChostname = "XDC-TEST"

# Do not edit below this line, unless you know what you are doing!
# ---------------------------------------------------------------#

$GetDB = Get-ChildItem -Path $SQLDatabaseBackupDir

foreach ($db in $GetDB.BaseName){
Write-Host "$db"
}

foreach ($db in $GetDB.BaseName){
If (!([string]::IsNullOrWhiteSpace($SQLInstanceName))){
$Argumentlist = "-S $env:COMPUTERNAME\$SQLInstanceName -E -Q `"RESTORE DATABASE $db FROM DISK = '$SQLDatabaseBackupDir\$db.bak'`""
}
else{
$Argumentlist = "-S $env:COMPUTERNAME -E -Q `"RESTORE DATABASE $db FROM DISK = '$SQLDatabaseBackupDir\$db.bak'`""
}
Start-Process -Wait sqlcmd.exe -ArgumentList $Argumentlist
}
Start-Process -Wait sqlcmd.exe -ArgumentList "[$env:USERDOMAIN\$XDChostname] from windows"