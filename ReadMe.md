# HttpDiag.ps1

``` powershell
NAME
    C:\HttpDiag.ps1

SYNOPSIS


SYNTAX
    C:\HttpDiag.ps1 [-LogDir <String>] [<CommonParameters>]

    C:\HttpDiag.ps1 [-StartTrace] [-LogDir <String>] [<CommonParameters>]

    C:\HttpDiag.ps1 [-StopTrace] [-LogDir <String>] [<CommonParameters>]

    C:\HttpDiag.ps1 [-InteractiveTrace] [-LogDir <String>] [<CommonParameters>]


DESCRIPTION
    A diagnostic script for the http.sys Windows component


RELATED LINKS

REMARKS
    To see the examples, type: "Get-Help C:\HttpDiag.ps1 -Examples"
    For more information, type: "Get-Help C:\HttpDiag.ps1 -Detailed"
    For technical information, type: "Get-Help C:\HttpDiag.ps1 -Full"
```

## Example

```
HttpDiag vers: 1.0

Service Information:

Name                : Http
DisplayName         : HTTP Service
Status              : Running
DependentServices   : {WMPNetworkSvc, WinRM, Wecsvc, WebManagement…}
ServicesDependedOn  : {MsQuic}
CanPauseAndContinue : False
CanShutdown         : False
CanStop             : True
ServiceType         : KernelDriver



Component Versions:

FileName                             ProductVersion FileVersion
--------                             -------------- -----------
C:\Windows\System32\httpapi.dll      10.0.22000.1   10.0.22000.1 (WinBuild.160101.0800)
C:\Windows\System32\drivers\http.sys 10.0.22000.1   10.0.22000.1 (WinBuild.160101.0800)


Configured Request Queues:

Processes       Active NumProcesses NumUrls RegisteredUrls
---------       ------ ------------ ------- --------------
svchost(19812)    True 1            2       {HTTP://+:5985/WSMAN/, HTTP://+:47001/WSMAN/}
svchost(8296)     True 1            1       {HTTP://*:5357/EF13F6F4-ED14-4343-A1B7-81F961318396/}
spoolsv(5472)     True 1            1       {HTTP://*:5357/6EC4A674-E954-41AA-9257-051FF202A4F8/}
spoolsv(5472)     True 1            1       {HTTP://*:5357/D049CB4D-948C-4410-B7BA-C12952CA7216/}
svchost(5148)     True 1            1       {HTTP://*:5357/B9F9F89E-410B-4C66-9D78-81A6920C7EAE/}


Reserved Urls

User                  Url
----                  ---
BUILTIN\Users         http://*:5357/
\Everyone             http://+:80/Temporary_Listen_Addresses/
BUILTIN\Users         https://*:5358/
SERVICE\SstpSvc       https://+:443/sra_{BA195980-CD49-458b-9E23-C84EE0ADCD75}/
SERVICE\WinRM         https://+:5986/wsman/
SERVICE\WinRM         http://+:47001/wsman/
SERVICE\WinRM         http://+:5985/wsman/
Users                 http://+:10247/apps/
SERVICE               http://*:2869/
Users                 http://+:10246/MDEServer/
SERVICE\WMPNetworkSvc https://+:10245/WMPNSSv4/
SERVICE\WMPNetworkSvc http://+:10243/WMPNSSv4/
SERVICE               http://+:80/0131501b-d67f-491b-9a40-c4bf27bcb4d4/
SERVICE               https://+:443/C574AC30-5794-4AEE-B1BB-6651C5315029/
SERVICE               http://+:80/116B50EB-ECE2-41ac-8429-9F9E963361B7/
BUILTIN\Users         http://+:8299/
BUILTIN\Users         http://+:15500/v1/
NORTHAMERICA\wiaftrin http://+:15099/
Unknown               https://+:6516/
SERVICE\TermService   https://+:3392/rdp/
SERVICE\TermService   http://+:3387/rdp/


Registry Information:

    Hive: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services

Name                           Property
----                           --------
HTTP                           DependOnService : {MsQuic}
                               Description     : @%SystemRoot%\system32\drivers\http.sys,-2
                               DisplayName     : @%SystemRoot%\system32\drivers\http.sys,-1
                               ErrorControl    : 1
                               ImagePath       : system32\drivers\HTTP.sys
                               Start           : 3
                               Type            : 1

    Hive: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\HTTP

Name                           Property
----                           --------
Parameters
```
