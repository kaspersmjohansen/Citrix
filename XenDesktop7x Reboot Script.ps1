#---------------------------------------------------------------------
# Script: RebootXenApp7VDA.ps1
# Reboot Script for two groups of XenApp 7.x VDAs (for 24x7 environments)
# Creator: Wilco van Bragt
# Creation Date: 27-11-2014
#---------------------------------------------------------------------
# Version: 0.1
# By: Wilco van Bragt
# Date: 27-11-2014
# Changes: Initial Release
#---------------------------------------------------------------------
# Import Modules
#---------------------------------

add-pssnapin Citrix.* -erroraction silentlycontinue

# Define Infrastructure Dependent Variables
#---------------------------------
$DeliveryGroup="<<DELIVERYGROUPNAME>>"
$EnableMaintenanceTime=21600
$Tempdir="C:\temp"
$Logdir="C:\temp"
$EvenDays="Sunday","Tuesday","Thursday"
$OddDays="Monday","Wednesday","Friday"
$UserWarningMessagePart1="Please save your work and log-off. This machine will be restarted in"
$UserWarningMessagePart2="minutes."

# Define Script Variables
#---------------------------------
$exe="C:\Windows\System32\msg.exe"
$ScriptStart=Get-Date
$Date=Get-Date -format M.d.yyyy
$DayofWeek=(get-date).dayofweek
$Logfile=$Logdir+"\RebootLog"+$Date+".log"
$ServerstoReboot=$TempDir+"\ServerstoReboot.txt"

# Functions
#---------------------------------
Function LogWrite

{

   Param ([string]$logstring)

   Add-content $Logfile -value $logstring

}

# Start RebootScript

#---------------------------------

LogWrite "Script started at $ScriptStart"

# Determine based on the Day of the week even or odd servers are booted

#---------------------------------

If ($DayofWeek -eq "Saturday")

{LogWrite "Today is Saturday, no servers will be rebooted"

   $EndScriptDate=Get-Date

   LogWrite "Script ended on $EndScript"

   exit

}

If ($EvenDays -contains $DayofWeek)

{$Reboot="Even"

   LogWrite "Day of the week is $DayofWeek, even servers need to be rebooted"

   }

If ($OddDays -contains $DayofWeek)

   {$Reboot="Odd"

   LogWrite "Day of the week is $DayofWeek, odd servers need to be rebooted"

   }

  

# Catch the VDAs in the Delivery Group which are not in maintenance mode

#---------------------------------

LogWrite "Determine which VDAs in the Delivery Group which are not in maintenance and have the state registered"

Get-BrokerMachine -DesktopGroupName "$DeliveryGroup" | Where-Object {($_.InMaintenanceMode -ne "True") -And ($_.RegistrationState -eq "Registered")} | select MachineName | Add-Content $TempDir"\VDAs.txt"

if (!(test-path $TempDir"\VDAs.txt"))

                {LogWrite "No machines are found. Script will quit."

                $EndScriptDate=Get-Date

   LogWrite "Script ended on $EndScript"

                exit

                }

$VDAs=Get-Content $TempDir"\VDAs.txt"

LogWrite "The following servers are available in the Delivery Group: $VDAs"

LogWrite "Next step is to determine which servers will be rebooted this day"

#Trim the VDA Name and determine if the server should be rebooted

#---------------------------------

foreach ($line in $VDAs)

                { $DeviceName=$line.split('=')[1]

                    $DeviceName=$DeviceName.Trim("}")

                $DeviceLastNumber = [int]"$(($DeviceName)[-1])"

     If([bool]!($DeviceLastNumber%2))

       {$DeviceNumber="Even"}

     else

       {$DeviceNumber="Odd"}

     If ($Reboot -eq "Even" -And $DeviceNumber -eq "Even")

         {$DeviceName | Add-Content $ServerstoReboot

           LogWrite "$DeviceName is added to the list of servers to reboot"

         }                  

     If ($Reboot -eq "Odd" -And $DeviceNumber -eq "Odd")

         {$DeviceName | Add-Content $ServerstoReboot

           LogWrite "$DeviceName is added to the list of servers to reboot"

         }    

       $DeviceName=$null

   }

if (!(test-path $ServerstoReboot))

                {LogWrite "No machines are added to list to reboot. Script will quit."

                $EndScriptDate=Get-Date

   LogWrite "Script ended on $EndScript"

                exit

                }             

               

#Set Maintenance Mode for servers who will reboot

#---------------------------------

$RebootServers=Get-Content $ServerstoReboot

foreach ($line in $RebootServers)

     {$DeviceName=$line

     Set-BrokerMachineMaintenanceMode -InputObject $DeviceName -MaintenanceMode $True

     LogWrite "$DeviceName is set in maintenance mode"

     $DeviceName=$null

     }

     LogWrite   "All machines are set in Maintenance. Script will wait for $EnableMaintenanceTime seconds to continue."

     start-sleep -s $EnableMaintenanceTime

#Send Messages to possible active users

#---------------------------------

foreach ($line in $RebootServers)

       {$DeviceName=$line

       $DeviceName=$DeviceName.split('\')[1]

       & $exe * /Server:$DeviceName /time:120 $UserWarningMessagePart1 "60" $UserWarningMessagePart2

       LogWrite "Warning message 60 minutes is send to possible active users on machine $DeviceName"

         }

start-sleep 1800

foreach ($line in $RebootServers)

       {$DeviceName=$line

       $DeviceName=$DeviceName.split('\')[1]

       & $exe * /Server:$DeviceName /time:120 $UserWarningMessagePart1 "30" $UserWarningMessagePart2

       LogWrite "Warning message 30 minutes is send to possible active users on machine $DeviceName"

       }

start-sleep 1200

foreach ($line in $RebootServers)

       {$DeviceName=$line

       $DeviceName=$DeviceName.split('\')[1]

       & $exe * /Server:$DeviceName /time:120 $UserWarningMessagePart1 "10" $UserWarningMessagePart2

       LogWrite "Warning message 10 minutes is send to possible active users on machine $DeviceName"

       }

start-sleep 300

foreach ($line in $RebootServers)

       {$DeviceName=$line

       $DeviceName=$DeviceName.split('\')[1]

       & $exe * /Server:$DeviceName /time:120 $UserWarningMessagePart1 "5" $UserWarningMessagePart2

       LogWrite "Warning message 5 minutes is send to possible active users on machine $DeviceName"

       }

start-sleep 300

#Execute Reboot and check if servers are back on-line

#---------------------------------

LogWrite "Actual reboot process will start now"

foreach ($line in $RebootServers)

       {$CTXDeviceName=$line

         $DeviceName=$line

         $DeviceName=$DeviceName.split('\')[1]

         LogWrite "Restart command is send to machine $DeviceName"

         Restart-Computer -Computername $DeviceName -Force -Wait -For PowerShell

         LogWrite "Start-up process of $DeviceName is being checked."

         $count=$null

         Do

           {   start-Sleep 30

                 $ServerStatus=Get-BrokerMachine -MachineName $CTXDeviceName

               $count=$count+1

           }

         Until (($ServerStatus.RegistrationState -eq "Registered") -or ($count -eq "4"))

          

         IF ($ServerStatus.RegistrationState -eq "Registered")

         {LogWrite "Machine $CTXDeviceName has successfully registered. MaintenanceMode will be turned off."

                               Set-BrokerMachineMaintenanceMode -InputObject $CTXDeviceName -MaintenanceMode $False

                               }

         ELSE

         {LogWrite "Machine $CTXDeviceName is not successfully registered. Please check this machine."}

         }

#Clean-up temporary files         

#---------------------------------

Remove-Item $ServerstoReboot

Remove-Item   $TempDir"\VDAs.txt"  

                              

$EndScriptDate=Get-Date

LogWrite "Script finished at $EndScriptDate"
