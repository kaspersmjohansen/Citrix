<#
This script creates a backup of a database on an SQL server using SQL Server Command Line tool
The script must be executed on the SQL server which contains the database you wish to backup

The variable $SQLDatabaseBackupDir must contain the directory name where the database should backup up
The variable $SQLInstanceName must contain the SQL instance name, if an instance is configured, otherwise leave it blank
The variable $SQLDatabaseName must containt the name of the database you wish to backup

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 26-06-2015
#>

# SQL variables
$SQLDatabaseBackupDir = "C:\Database Backup"
$SQLInstanceName = ""
$SQLDatabaseName = "CitrixTest_Site","CitrixTest_Monitor","CitrixTest_Logging"

# Do not edit below this line, unless you know what you are doing!
# ---------------------------------------------------------------#

foreach ($db in $SQLDatabaseName){
If (!([string]::IsNullOrWhiteSpace($SQLInstanceName))){
$Argumentlist = "-S $env:COMPUTERNAME\$SQLInstanceName -E -Q `"BACKUP DATABASE $db TO DISK = N'$SQLDatabaseBackupDir\$db.bak' WITH NOFORMAT, NOINIT, NAME = N'Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10`""
}
else{
$Argumentlist = "-S $env:COMPUTERNAME -E -Q `"BACKUP DATABASE $db TO DISK = N'$SQLDatabaseBackupDir\$db.bak' WITH NOFORMAT, NOINIT, NAME = N'Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10`""
}

If (!(Test-Path -Path $SQLDatabaseBackupDir)){
New-Item -Path $SQLDatabaseBackupDir -ItemType Directory
Start-Process -Wait sqlcmd.exe -ArgumentList $Argumentlist
}
else{
Start-Process -Wait sqlcmd.exe -ArgumentList $Argumentlist
}
}