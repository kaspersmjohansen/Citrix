$DBName = "CITRIXWEM"
$SQLServerName = "sql-p-citrixwem"
$SQLDBFolder = "E:\Data\"
$SQLCredentials = 
$Domain = "laksen04"
$AdminGroup = "Citrix Farm Admin"
$ServiceAccount = "svc-ctx-wem"
$vuempassword = "SjGHjGXGJ7Z7r6d2"
$vuemsecurepasswd = ConvertTo-SecureString $vuempassword -AsPlainText -Force


New-WemDatabase -DatabaseServerInstance "$SQLServerName" -DatabaseName $DBname -DataFilePath($SQLDBFolder+$DBname+"_Data.mdf") -LogFilePath($SQLDBFolder+$DBname+"_Log.ldf") -DefaultAdministratorsGroup "$domain\$AdminGroup" -WindowsAccount "$domain\$ServiceAccount" -PSDebugMode Enable -VuemUserSqlPassword $vuemsecurepasswd