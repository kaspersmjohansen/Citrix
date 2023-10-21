Add-PSSnapin Citrix*

$AppName = "NIS Lovguide"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "http://nis/"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "Brugerdata"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "https://hjbd01.hjoerring.local/RDWeb/Pages/en-US/default.aspx"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "DUBU"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "https://www.dubu.dk/logon/"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "Hjørring Centralkøkken BMS"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "http://10.12.18.18"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "KMD Care"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "http://kmdcare"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "ØS-Indsigt"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "http://osi-drift/os2000"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "Silkeborgdata"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "http://www.sd.dk"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "SocialTilsyn Nord"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "https://social.tilsyn.dk/"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir

$AppName = "Xenta555"

$AppCLIExec = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$AppCLIArgs = "https://10.54.0.100/www/index/Slogin.html?URL=/www/index/indexTree.html"
$AppWorkDir = "C:\Program Files (x86)\Internet Explorer"

$AppDesktopGrp = "XenApp - 2012 R2"
$AppIconUID = "27"

# IconUID "39" = Explorer
# IconUID "27" = IE icon
# IconUID "26" = Default Citrix Icon
# IconUID "24" = RDP icon

New-BrokerApplication -ApplicationType HostedOnDesktop -Name $AppName -CommandLineExecutable $AppCLIExec -CommandLineArguments $AppCLIArgs -DesktopGroup $AppDesktopGrp -IconUID $AppIconUID
Set-BrokerApplication -Name $AppName -WorkingDirectory $AppWorkDir