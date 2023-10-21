Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL" -ComputerName "xa76-2k12r2-02.ocdevil.local" | Where-Object{$_.id -eq 8003} | ft message

$event = Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL" -ComputerName "xa76-2k12r2-02.ocdevil.local" | Where-Object {$_.id -eq 8004}
foreach ($_ in $event){
  $sid = $_.userid;
  $eventid = $_.id;
  $eventmsg = $_.message;
    if($sid -eq $null) { return; }
  $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid);
  $objUser = $objSID.Translate([System.Security.Principal.NTAccount]);

}