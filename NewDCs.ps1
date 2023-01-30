Write-Host "Welcome to Mishky's networking setup script for new Windows servers"
Write-Host "Please enter the below info for IPv4 to set a static IP and the right DNS"
Write-Host "FYSA Mishky also disables IPv6 & NetBIOS, because the network isn't using them"
$IP = read-host "Please enter the server's IP address"
$Gateway = read-host "Please enter the gateway IP address"
$ServerName = read-host "Please enter the server's name"
#Disable IPv6
Disable-NetAdapterBinding -InterfaceAlias "Ethernet0" -ComponentID ms_tcpip6
#Disable NetBIOS
$regkey = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
Get-ChildItem $regkey |foreach { Set-ItemProperty -Path "$regkey\$($_.pschildname)" -Name NetbiosOptions -Value 2 -Verbose}
#Set IPv4 address, gateway, & DNS servers
New-NetIPAddress -InterfaceAlias "Ethernet0" -AddressFamily IPv4 -IPAddress $IP -PrefixLength 24 -DefaultGateway $Gateway
Set-DNSClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("192.168.0.101", "192.168.0.102", "192.168.0.104", "<ISP DNS I>", "<ISP DNS II>")
#Rename the server
Rename-Computer -NewName $ServerName -LocalCredential Administrator -PassThru -restart -force
