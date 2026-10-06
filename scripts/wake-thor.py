#!/usr/bin/env python3
"""
Send a Wake-on-LAN (WoWLAN) magic packet to AYN Thor Max.
Target MAC: <thor-wifi-mac>
Subnet Broadcast: <lan-broadcast> (port 9)
"""

import socket
import sys

THOR_MAC = "<thor-wifi-mac>"
BROADCAST_IP = "<lan-broadcast>"
PORT = 9


def wake_thor(mac=THOR_MAC, ip=BROADCAST_IP, port=PORT):
    clean_mac = mac.replace(":", "").replace("-", "")
    if len(clean_mac) != 12:
        raise ValueError(f"Invalid MAC address format: {mac}")

    payload = bytes.fromhex("FF" * 6 + clean_mac * 16)
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.sendto(payload, (ip, port))
        # Send twice for reliability over Wi-Fi
        sock.sendto(payload, (ip, port))

    print(f"[wake-thor] Magic packet successfully broadcast to {mac} via {ip}:{port}")


if __name__ == "__main__":
    mac = sys.argv[1] if len(sys.argv) > 1 else THOR_MAC
    wake_thor(mac)
