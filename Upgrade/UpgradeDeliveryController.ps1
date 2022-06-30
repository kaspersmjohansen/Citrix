$Path = "\\johansen.local\public\Work\Software\Citrix"
$Product = "Citrix Virtual Apps and Desktops"
$Version = "2206"

$CVAD = $Path+"\"+$Product+" "+$Version
$ISO = (Get-ChildItem -Path "$CVAD\*" -Include *.iso).Name

Mount-DiskImage -ImagePath "$CVAD\$ISO"

$InstallerSwitches = "/components CONTROLLER,DESKTOPDIRECTOR /ignore_hw_check_failure /noreboot /passive"

$Volume = Get-Volume | where {$_.FileSystem -like "UDF" -and $_.FileSystemLabel -like "CVAD*"}
$DrvLtr = $Volume.Driveletter+":"
Start-Process -FilePath "$DrvLtr\x64\XenDesktop Setup\XenDesktopServerSetup.exe" -ArgumentList $InstallerSwitches -Wait
Dismount-DiskImage -ImagePath "$CVAD\$ISO"