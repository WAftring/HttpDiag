<#
    .DESCRIPTION
    A diagnostic script for the http.sys Windows component
    .PARAMETER StartTrace
    Starts a http.sys ETW tracing session
    .PARAMETER StopTrace
    Stops a http.sys ETW tracing session
    .PARAMETER InteractiveTrace
    Starts an interactive http.sys ETW tracing session
#>

[CmdletBinding(DefaultParameterSetName = "General")]
param(
    [Parameter(ParameterSetName = "Start")]
    [switch]$StartTrace,
    [Parameter(ParameterSetName = "Stop")]
    [switch]$StopTrace,
    [Parameter(ParameterSetName = "Interactive")]
    [switch]$InteractiveTrace,
    [string]$LogDir = "C:\HttpDiag"
)

#region GLOBALS

$Script:LogPath = $LogDir
$Script:Version = "1.0"
$Script:EventLogs = @(
    "Microsoft-Windows-HttpService/Log!HttpService.evtx"
    "Microsoft-Windows-HttpService/Trace!HttpService-Trace.evtx"
    "Microsoft-Windows-CAPI2/Operational!CAPI2.evtx"
)

#endregion


# This is just a wrapper function
function Get-HttpConfig {
    # Component information
    Write-Host "Service Information:"
    Get-Service Http | Format-List | Out-String | Write-Host

    Write-Host "Component Versions:"
    (Get-Item "C:\Windows\System32\httpapi.dll", "C:\Windows\System32\drivers\http.sys").VersionInfo | Select-Object -Property FileName, ProductVersion, FileVersion | Out-String | Write-Host

    Get-HttpRequestQueues
    Get-HttpReservedUrls
}
function Get-HttpRequestQueues {
    Write-Debug "Enter Get-HttpConfig"
    $HttpConfigList = [System.Collections.ArrayList]::New()

    $RawRequestQueues = Invoke-Expression -Command 'netsh http show servicestate view="req"'
    $RequestQueueLines = $RawRequestQueues | Select-String "^Request queue name"

    $RequestQueueLines | ForEach-Object {
        $offset = 2
        $HttpObj = [PSCustomObject]@{
            Processes      = $null
            Active         = $false
            NumProcesses   = 0
            NumUrls        = 0
            RegisteredUrls = $null
        }

        $LineNumber = $_.LineNumber - 1
        $HttpObj.Active = $RawRequestQueues[$LineNumber + $offset].Trim() -eq "State: Active"
        $offset += 3
        $HttpObj.NumProcesses = $RawRequestQueues[$LineNumber + $offset].Trim().Split(" ")[-1]
        $offset += 2
        $Processes = ""
        for ($i = 0; $i -lt $HttpObj.NumProcesses; $i++) {
            $ID = $RawRequestQueues[$LineNumber + $offset + $i].Trim().Split(" ")[1].Replace(",", "")
            $Proc = Get-Process -Id $ID
            $Processes += ("$($Proc.Name)($($Proc.Id)) ")
        }

        $HttpObj.Processes = $Processes
        $offset += $i + 9
        $HttpObj.NumUrls = $RawRequestQueues[$LineNumber + $offset].Trim().Split(" ")[-1]
        $offset += 2
        $HttpObj.RegisteredUrls = [System.Collections.ArrayList]::New()
        for ($j = 0; $j -lt $HttpObj.NumUrls; $j++) {
            # Silencing the add result
            [void]$HttpObj.RegisteredUrls.Add($RawRequestQueues[$LineNumber + $offset + $j].Trim())
        }

        # Silencing the Add result
        [void]$HttpConfigList.Add($HttpObj)
    }

    Write-Host "Configured Request Queues:"
    $HttpConfigList | Sort-Object -Property NumUrls, NumProcesses -Descending | Format-Table -AutoSize -Wrap | Out-String | Write-Host
    Write-Debug "Exit Get-HttpConfig"
}

function Get-HttpReservedUrls {
    Write-Debug "Enter Get-HttpReservedUrls"
    $ReservedUrlsList = [System.Collections.ArrayList]::New()
    $RawReservedUrls = Invoke-Expression -Command "netsh http show urlacl"
    $ReservedUrls = $RawReservedUrls | Select-String "Reserved URL"
    $ReservedUrls | ForEach-Object {
        $UrlObj = [PSCustomObject]@{
            User = "Unknown"
            Url  = ""
        }
        $LineNumber = $_.LineNumber - 1

        $UrlObj.Url = $RawReservedUrls[$LineNumber].Trim().Split(" ")[-1]
        if ($RawReservedUrls[$LineNumber + 1] -like "*User*") {
            $UrlObj.User = $RawReservedUrls[$LineNumber + 1].Trim().Split(" ")[-1]
        }
        [void]$ReservedUrlsList.Add($UrlObj)
    }
    Write-Host "Reserved Urls"
    $ReservedUrlsList | Format-Table -AutoSize -Wrap | Out-String | Write-Host
    Write-Debug "Exit Get-HttpReservedUrls"
}

function Invoke-HttpTrace {
    param(
        [switch]$Start,
        [switch]$Stop
    )
    Write-Debug "Enter Invoke-HttpTrace Start: $Start Stop: $Stop"
    $Pktmon = Get-Command pktmon -ErrorAction SilentlyContinue
    if ($Start) {
        Invoke-Expression -Command "netsh trace start capture=yes scenario=InternetServer_dbg maxsize=4096 persistent=yes report=disable tracefile=$Script:LogPath\HttpTrace.etl"
        if ($Pktmon -ne $null) {
            Invoke-Expression -Command "pktmon start --capture -f $Script:LogPath\Pktmon.etl -s 4096"
        }
        Enable-HttpLogs
    }
    elseif ($Stop) {
        Invoke-Expression -Command "netsh trace stop"
        if ($Pktmon -ne $null) {
            Invoke-Expression -Command "pktmon stop"
            Invoke-Expression -Command "pktmon list -a > $Script:LogPath\Pktmon-list.txt"
            Get-HttpTraceData
        }
    }
    Write-Debug "Exit Invoke-HttpTrace"
}

function Enable-HttpLogs {
    Write-Debug "Enter Enable-HttpLogs"
    foreach ($EventLog in $Script:EventLogs) {
        $Params = $EventLog.Split("!")
        $LogName = $Params[0]
        Invoke-Expression -Command "wevtutil sl `"$LogName`" /enabled:true /quiet:true"
    }
    Write-Debug "Exit Enable-HttpLogs"
}
function Get-HttpTraceData {
    Write-Debug "Enter Get-HttpTraceData"
    Invoke-Expression -Command "ipconfig /all > $Script:LogPath\ipconfig.txt"
    Invoke-Expression -Command "systeminfo > $Script:LogPath\systeminfo.txt"
    foreach ($EventLog in $Script:EventLogs) {
        $Params = $EventLog.Split("!")
        $LogName = $Params[0]
        $OutFile = $Params[1]
        Invoke-Expression -Command "wevtutil epl `"$LogName`" `"$OutFile`""
    }
    Write-Debug "Exit Get-HttpTraceData"
}

#region main

if (-not (Test-Path $Script:LogPath)) {
    New-Item $Script:LogPath -ItemType Directory | Out-Null
}

if ($StartTrace -or $InteractiveTrace -or $StopTrace) { Start-Transcript -Path "$Script:LogPath\Transcript.log" | Out-Null }

Write-Host "HttpDiag vers: $Script:Version`n"

if ($StartTrace -or $InteractiveTrace) { Invoke-HttpTrace -Start }
if ($InteractiveTrace) {
    Read-Host -Prompt "Press enter to stop the capture"
}
if ($StopTrace) { Invoke-HttpTrace -Stop }

Get-HttpConfig

if ($StartTrace -or $InteractiveTrace -or $Stop) { Stop-Transcript | Out-Null }

#endregion