<#
.SYNOPSIS
    Broadcasts a Wake-on-LAN (WoWLAN) magic packet to AYN Thor Max.
.DESCRIPTION
    Sends standard magic packet payload (6x 0xFF followed by 16x target MAC)
    over UDP broadcast port 9 to wake AYN Thor Max over Wi-Fi.
#>

param(
    [string]$MacAddress = "",
    [string]$BroadcastIp = "",
    [int]$Port = 9
)

# MAC and broadcast come from -MacAddress/-BroadcastIp, THOR_MAC/THOR_BROADCAST, or the git-ignored
# local/thor.env at the repo root (template: scripts/thor.env.example).
$envFile = Join-Path (Split-Path $PSScriptRoot -Parent) "local\thor.env"
$local = @{}
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object {
        $k, $v = $_ -split '=', 2; $local[$k.Trim()] = $v.Trim()
    }
}
if (-not $MacAddress)  { $MacAddress  = if ($env:THOR_MAC) { $env:THOR_MAC } else { $local['THOR_MAC'] } }
if (-not $BroadcastIp) { $BroadcastIp = if ($env:THOR_BROADCAST) { $env:THOR_BROADCAST } else { $local['THOR_BROADCAST'] } }
if (-not $MacAddress -or -not $BroadcastIp) {
    Write-Error "Set THOR_MAC and THOR_BROADCAST (env or local/thor.env, see scripts/thor.env.example)"
    exit 1
}

$cleanMac = $MacAddress -replace "[:-]", ""
if ($cleanMac.Length -ne 12) {
    Write-Error "Invalid MAC address: $MacAddress"
    exit 1
}

$macBytes = for ($i = 0; $i -lt 12; $i += 2) {
    [Convert]::ToByte($cleanMac.Substring($i, 2), 16)
}

$packet = [byte[]]::new(102)
for ($i = 0; $i -lt 6; $i++) {
    $packet[$i] = 0xFF
}
for ($i = 0; $i -lt 16; $i++) {
    [Array]::Copy($macBytes, 0, $packet, 6 + ($i * 6), 6)
}

$client = [System.Net.Sockets.UdpClient]::new()
$client.EnableBroadcast = $true
$endpoint = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Parse($BroadcastIp), $Port)

try {
    $client.Send($packet, $packet.Length, $endpoint) | Out-Null
    Start-Sleep -Milliseconds 100
    $client.Send($packet, $packet.Length, $endpoint) | Out-Null
    Write-Host "[wake-thor] Magic packet successfully broadcast to $MacAddress via ${BroadcastIp}:${Port}" -ForegroundColor Green
} finally {
    $client.Close()
    $client.Dispose()
}
