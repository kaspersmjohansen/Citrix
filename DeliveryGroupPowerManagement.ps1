# Konfigurerer Power Management til at starte x antal maskiner baseret på nedenstående variabler
$PeakHours = 175
$OffHours = 50

Add-PSSnapin Citrix*
Set-BrokerPowerTimeScheme -DisplayName "Weekdays" -Name "VDI - Windows 7_Weekdays" -PoolSize ( 0..23 | %{ if ($_ -lt 6 -or $_ -gt 18) { $OffHours } else { $PeakHours } } )