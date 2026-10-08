#!/usr/bin/env bash
# apply-all-tweaks.sh: Deploy curated AYN Thor tweaks & goodies to the device.
# Usage: ./apply-all-tweaks.sh [--all | --audio | --lighting | --system | --wowlan | --status] [HOST]
set -euo pipefail

# Host comes from arg 2, $THOR_HOST, or the git-ignored local/thor.env (template: scripts/thor.env.example).
_ENV_FILE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)/local/thor.env"
if [ -z "${THOR_HOST:-}" ] && [ -f "$_ENV_FILE" ]; then THOR_HOST="$(sed -n 's/^THOR_HOST=//p' "$_ENV_FILE" | head -1)"; fi
THOR_HOST="${2:-${THOR_HOST:-}}"
[ -n "$THOR_HOST" ] || { echo "ERROR: no Thor host. Pass it as arg 2, set THOR_HOST, or fill local/thor.env (see scripts/thor.env.example)." >&2; exit 2; }
MODE="${1:---all}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Target host: ${THOR_HOST}"
if [ "$MODE" != "-h" ] && ! ssh -o BatchMode=yes -o ConnectTimeout=8 "${THOR_HOST}" true 2>/dev/null; then
    echo "ERROR: cannot reach ${THOR_HOST} with key auth (new address after a reset? key not re-authorized?)." >&2
    exit 2
fi

deploy_audio() {
    echo "==> Installing PipeWire Speaker EQ Tuning..."
    ssh "${THOR_HOST}" "mkdir -p ~/.config/pipewire/pipewire.conf.d"
    scp "${SCRIPT_DIR}/audio/50-thor-speaker-eq.conf" "${THOR_HOST}:~/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf"
    ssh "${THOR_HOST}" "systemctl --user restart pipewire.service pipewire-pulse.service"
    echo "==> Speaker EQ installed and PipeWire reloaded."
}
deploy_lighting() {
    echo "==> Installing Reactive Stick RGB LED Controller..."
    scp "${SCRIPT_DIR}/lighting/stick-led-color.py" "${THOR_HOST}:/tmp/stick-led-color"
    scp "${SCRIPT_DIR}/lighting/armada-stick-led.service" "${THOR_HOST}:/tmp/armada-stick-led.service"
    ssh "${THOR_HOST}" "
        sudo mkdir -p /var/local/bin
        sudo mv /tmp/stick-led-color /var/local/bin/stick-led-color
        sudo chmod +x /var/local/bin/stick-led-color
        sudo mv /tmp/armada-stick-led.service /etc/systemd/system/armada-stick-led.service
        sudo systemctl daemon-reload
        sudo systemctl enable --now armada-stick-led.service
    "
    echo "==> Stick RGB LED controller active."
}

deploy_wowlan() {
    echo "==> Installing Wake-on-WLAN only (no display sync, no countme mask)..."
    scp "${SCRIPT_DIR}/system/thor-wowlan" "${THOR_HOST}:/tmp/thor-wowlan"
    scp "${SCRIPT_DIR}/system/thor-wowlan.service" "${THOR_HOST}:/tmp/thor-wowlan.service"
    scp "${SCRIPT_DIR}/system/90-wowlan.conf" "${THOR_HOST}:/tmp/90-wowlan.conf"
    ssh "${THOR_HOST}" "
        sudo mkdir -p /var/local/bin
        sudo mv /tmp/thor-wowlan /var/local/bin/thor-wowlan
        sudo chmod +x /var/local/bin/thor-wowlan
        sudo mv /tmp/thor-wowlan.service /etc/systemd/system/thor-wowlan.service
        sudo mv /tmp/90-wowlan.conf /etc/NetworkManager/conf.d/90-wowlan.conf
        sudo systemctl daemon-reload
        sudo systemctl enable --now thor-wowlan.service
        sudo systemctl reload NetworkManager
        journalctl -t thor-wowlan -n 1 --no-pager || true
    "
    echo "==> Wake-on-WLAN installed."
}

deploy_system() {
    echo "==> Applying System Fixes, WoWLAN & Display Sleep Sync..."
    scp "${SCRIPT_DIR}/system/setup-device-fixes.sh" "${THOR_HOST}:/tmp/setup-device-fixes.sh"
    scp "${SCRIPT_DIR}/system/thor-wowlan" "${THOR_HOST}:/tmp/thor-wowlan"
    scp "${SCRIPT_DIR}/system/thor-wowlan.service" "${THOR_HOST}:/tmp/thor-wowlan.service"
    scp "${SCRIPT_DIR}/system/90-wowlan.conf" "${THOR_HOST}:/tmp/90-wowlan.conf"
    scp "${SCRIPT_DIR}/system/thor-display-sync.py" "${THOR_HOST}:/tmp/thor-display-sync"
    scp "${SCRIPT_DIR}/system/thor-display-sync.service" "${THOR_HOST}:/tmp/thor-display-sync.service"
    ssh "${THOR_HOST}" "
        bash /tmp/setup-device-fixes.sh
        rm -f /tmp/setup-device-fixes.sh
        sudo mkdir -p /var/local/bin
        sudo mv /tmp/thor-display-sync /var/local/bin/thor-display-sync
        sudo chmod +x /var/local/bin/thor-display-sync
        sudo mv /tmp/thor-wowlan /var/local/bin/thor-wowlan
        sudo chmod +x /var/local/bin/thor-wowlan
        sudo mv /tmp/thor-wowlan.service /etc/systemd/system/thor-wowlan.service
        sudo mv /tmp/thor-display-sync.service /etc/systemd/system/thor-display-sync.service
        sudo mv /tmp/90-wowlan.conf /etc/NetworkManager/conf.d/90-wowlan.conf
        sudo systemctl daemon-reload
        sudo systemctl enable --now thor-wowlan.service
        sudo systemctl enable --now thor-display-sync.service
        sudo systemctl reload NetworkManager
    "
    echo "==> System fixes, WoWLAN and display sync applied."
}

show_status() {
    echo "==> Checking device tweak status on ${THOR_HOST}..."
    ssh "${THOR_HOST}" "
        echo '--- Audio EQ ---'
        ls -l ~/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf 2>/dev/null || echo 'Not installed'
        echo '--- Gleipnir (battery ceiling plugin) ---'
        systemctl is-active gleipnir.service 2>/dev/null || echo 'Inactive/Not installed'; sudo -n /var/local/bin/gleipnir --status 2>/dev/null | head -4 || true
        echo '--- Stick Lighting ---'
        systemctl is-active armada-stick-led.service 2>/dev/null || echo 'Inactive/Not installed'
        echo '--- Display Sleep Sync ---'
        systemctl is-active thor-display-sync.service 2>/dev/null || echo 'Inactive/Not installed'
        echo '--- Wake-on-WLAN ---'
        systemctl is-active thor-wowlan.service 2>/dev/null || echo 'Inactive/Not installed'; journalctl -t thor-wowlan -n 1 --no-pager 2>/dev/null || true
        echo '--- Failed Units ---'
        systemctl --failed --no-pager
    "
}

case "$MODE" in
    --audio)
        deploy_audio
        ;;
    --battery)
        echo "The 80% battery ceiling is now Gleipnir, its own Decky plugin (repo venatrix-ritz/Gleipnir, checked out at plugins/gleipnir). Install it with: plugins/gleipnir/scripts/deploy.sh" >&2
        exit 1
        ;;
    --lighting)
        deploy_lighting
        ;;
    --system)
        deploy_system
        ;;
    --wowlan)
        deploy_wowlan
        ;;
    --status)
        show_status
        ;;
    --all)
        deploy_audio
        echo "==> NOTE: the 80% battery ceiling is not part of --all. It is the Gleipnir plugin (plugins/gleipnir/scripts/deploy.sh); it stays watch-only until its on-device test passes."
        deploy_system
        echo "==> NOTE: --all skips the stick-RGB daemon: Armada already ships armada-rgb (Armada Control > RGB) for the Thor and two writers would fight over the LEDs. Use --lighting explicitly if you want it."
        show_status
        ;;
    *)
        echo "Usage: $0 [--all | --audio | --lighting | --system | --wowlan | --status] [HOST]"
        exit 1
        ;;
esac
