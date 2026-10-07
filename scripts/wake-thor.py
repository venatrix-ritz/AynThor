#!/usr/bin/env python3
"""
Send a Wake-on-LAN (WoWLAN) magic packet to the AYN Thor Max.
Target MAC and LAN broadcast address come from THOR_MAC / THOR_BROADCAST (environment) or from the
git-ignored local/thor.env at the repo root (template: scripts/thor.env.example). Port 9.
"""

import os
import socket
import sys
from pathlib import Path

PORT = 9


def _load_local_env():
    path = Path(__file__).resolve().parent.parent / "local" / "thor.env"
    values = {}
    if path.is_file():
        for line in path.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, val = line.split("=", 1)
                values[key.strip()] = val.strip()
    return values


def _setting(name):
    return os.environ.get(name) or _load_local_env().get(name)


def wake_thor(mac, ip, port=PORT):
    clean_mac = mac.replace(":", "").replace("-", "")
    if len(clean_mac) != 12:
        raise ValueError(f"Invalid MAC address format: {mac}")

    payload = bytes.fromhex("FF" * 6 + clean_mac * 16)
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.sendto(payload, (ip, port))
        # Send twice for reliability over Wi-Fi
        sock.sendto(payload, (ip, port))

    print(f"[wake-thor] Magic packet broadcast to {mac} via {ip}:{port}")


if __name__ == "__main__":
    mac = sys.argv[1] if len(sys.argv) > 1 else _setting("THOR_MAC")
    broadcast = _setting("THOR_BROADCAST")
    if not mac or not broadcast:
        sys.exit("Set THOR_MAC and THOR_BROADCAST (env or local/thor.env, see scripts/thor.env.example)")
    wake_thor(mac, broadcast)
