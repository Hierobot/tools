$ProxyIP = '10.50.0.33'
$Download = 'https://cdn.zabbix.com/zabbix/binaries/stable/6.4/6.4.19/zabbix_agent-6.4.19-windows-amd64-openssl.zip'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$webclient = new-object System.Net.WebClient
$webclient.DownloadFile($Download, "C:\windows\temp\zabbix.zip")
Expand-Archive -LiteralPath 'C:\windows\temp\zabbix.zip' -DestinationPath 'C:\zabbix'

$conffile = "C:\zabbix\conf\zabbix_agentd.conf"
$hostname=(hostname)
(Get-Content $conffile).replace("LogFile=c:\zabbix_agentd.log", "LogFile=c:\zabbix\zabbix_agentd.log") | Set-Content $conffile
(Get-Content $conffile).replace("Server=127.0.0.1", "Server=$proxyIP") | Set-Content $conffile
(Get-Content $conffile).replace("ServerActive=127.0.0.1", "ServerActive=$proxyIP") | Set-Content $conffile
(Get-Content $conffile).replace("Hostname=Windows host", "Hostname=$hostname") | Set-Content $conffile
(Get-Content $conffile).replace("# HostMetadata=", "HostMetadata=Windows") | Set-Content $conffile
set-itemproperty -path HKLM:\system\currentcontrolset\control\windows -name NoInteractiveServices -value 0
& "C:\zabbix\bin\zabbix_agentd.exe" -i -c C:\zabbix\conf\zabbix_agentd.conf
Start-Service "Zabbix Agent"
