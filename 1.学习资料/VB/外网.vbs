strIP = "177.17.18.202"
strMask = "255.255.0.0"
strGW = "177.17.18.1"
strDNS1 = "202.97.224.68"      
strDNS2 = "202.97.224.69"

'==================以下代码一般不需要修改=====================

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colNetAdapters = objWMIService.ExecQuery _
("Select * from Win32_NetworkAdapterConfiguration where IPEnabled=TRUE")
strIPAddress = Array(strIP)
strSubnetMask = Array(strMask)
strGateway = Array(strGW)
strGatewayMetric = Array(1)
For Each objNetAdapter in colNetAdapters
 errEnable = objNetAdapter.EnableStatic(strIPAddress, strSubnetMask)
 errGateways = objNetAdapter.SetGateways(strGateway, strGatewaymetric)
     arrDNSServers = Array(strDNS1,strDNS2)
    errDNS = objNetAdapter.SetDNSServerSearchOrder(arrDNSServers)
If errEnable = 0 Then
WScript.Echo "IP地址已更改。"
Else
WScript.Echo "更改IP地址失败。"
End If
Next
