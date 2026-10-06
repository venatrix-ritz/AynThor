<#
.SYNOPSIS
    Broadcasts a Wake-on-LAN (WoWLAN) magic packet to AYN Thor Max.
.DESCRIPTION
    Sends standard magic packet payload (6x 0xFF followed by 16x target MAC)
    over UDP broadcast port 9 to wake AYN Thor Max over Wi-Fi.
#>

param(
    [string]$MacAddress = "<thor-wifi-mac>",
    [string]$BroadcastIp = "<lan-broadcast>",
    [int]$Port = 9
)

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
