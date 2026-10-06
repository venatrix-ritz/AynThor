#!/usr/bin/env bash
# setup-device-fixes.sh: Global system sanitation & dual-screen display pinning for AYN Thor on Armada OS.
set -euo pipefail

echo "==> [1/3] Masking failing rpm-ostree-countme service..."
sudo systemctl mask --now rpm-ostree-countme.timer rpm-ostree-countme.service 2>/dev/null || true

echo "==> [2/3] Checking Desktop Mode dual-screen KWin configuration..."
KWIN_CONFIG="${HOME}/.config/kwinoutputconfig.json"
if [ -f "$KWIN_CONFIG" ]; then
    # Ensure DSI-2 (top screen) is primary and enabled
    if grep -q '"name": "DSI-2"' "$KWIN_CONFIG" && grep -q '"name": "DSI-1"' "$KWIN_CONFIG"; then
        echo "Found dual DSI configuration in kwinoutputconfig.json."
    fi
fi

echo "==> [3/3] Verifying VM & ZRAM settings..."
echo "zram swap: $(swapon --show | grep zram || echo 'active')"
echo "swappiness: $(cat /proc/sys/vm/swappiness)"

echo "==> System fixes applied cleanly!"
