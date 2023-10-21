# Disable NETBIOS over TCP/IP
Try {
    Get-CimInstance win32_networkadapterconfiguration -Filter "servicename = 'netvsc'" | Invoke-CimMethod -MethodName settcpipnetbios -Arguments @{TcpipNetbiosOptions = 2}
    Write-Host "NetBios is Disabled over TCP/IP"
    Write-Host "Script Check passed"
}
Catch {
    Write-Host "Script Check Failed"
    Exit 1001 
}

# Configure <generatePublisherEvidence enabled=”false” in Aspnet.config files
Try {
    $FilePathx64 = "C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Aspnet.config"
    $FilePathx86 = "C:\Windows\Microsoft.NET\Framework\v2.0.50727\Aspnet.config"

    Copy-Item -Path $FilePathx64 -Destination "$FilePathx64.old"
    Copy-Item -Path $FilePathx86 -Destination "$FilePathx86.old"

    $TextToAdd = "`n        <generatePublisherEvidence enabled=`”false`” />"
    
    $Contentx64 = Get-Content $FilePathx64
    $Contentx86 = Get-Content $FilePathx86
    $Contentx64[$LineNumber+2] += $TextToAdd
    $Contentx86[$LineNumber+2] += $TextToAdd
    
    $Contentx64 | Set-Content $FilePathx64
    $Contentx86 | Set-Content $FilePathx86

    Write-Host "<generatePublisherEvidence enabled=`”false`” is configured successfully"
}
Catch{
    Write-Host "Unable to configure <generatePublisherEvidence enabled=`”false`”"
    Exit 1001
}

# Disable the "check for server certificate revocation" and "Check for publisher’s certifcate revocation" in Internet Explorer
Try {
    Set-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "CertificateRevocation" -Value "0" -Force
    Set-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name "State" -Value "146944" -Force
    Write-Host "check for server certificate revocation and Check for publisher’s certifcate revocation in Internet Explorer are disabled"
}
Catch{
    Write-Host "check for server certificate revocation and Check for publisher’s certifcate revocation in Internet Explorer are NOT disabled"
    Exit 1001
}

# Disable pooledsockets in StoreFront store(s), WorkSpace Control - Disable logoff disconnect and WorkSpace Control - Disable autoconnect
Try{
    $StorePath = "$env:SystemDrive\inetpub\wwwroot\Citrix"
    $StoreName = "Store"
    $StoreWeb = $StoreName + "Web"
    
    Copy-Item -Path "$StorePath\$StoreName\web.config" -Destination "$StorePath\$StoreName\web.config.old"
    Copy-Item -Path "$StorePath\$StoreWeb\web.config" -Destination "$StorePath\$StoreWeb\web.config.old"

    $Content = Get-Content "$StorePath\$StoreName\web.config"
    $Content.Replace('pooledSockets="off"','pooledSockets="on"') | Set-Content "$StorePath\$StoreName\web.config"

    $ContentWeb = Get-Content "$StorePath\$StoreWeb\web.config"
    $ContentWeb.Replace('"logoffAction="disconnect"','"logoffAction="none"') | Set-Content "$StorePath\$StoreWeb\web.config"
    $ContentWeb.Replace('"autoReconnectAtLogon="true"','autoReconnectAtLogon="false"') | Set-Content "$StorePath\$StoreWeb\web.config"

    Write-Host "Pooledsockets=on configured"
    Write-Host "WorkSpace Control - Disable logoff disconnect configured"
    Write-Host "WorkSpace Control - Disable autoconnect configured"
}
Catch{
    Write-Host "Pooledsockets could not be configured"
    Write-Host "WorkSpace Control - Disable logoff could not be configured"
    Write-Host "WorkSpace Control - Disable autoconnect could not be configured"
    Exit 1001
}