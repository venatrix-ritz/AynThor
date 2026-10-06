#!/usr/bin/env bash
# apply-all-tweaks.sh: Deploy curated AYN Thor tweaks & goodies to the device.
# Usage: ./apply-all-tweaks.sh [--all | --audio | --battery | --lighting | --system | --status] [HOST]
set -euo pipefail

THOR_HOST="${2:-armada@<thor-ip>}"
MODE="${1:---all}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Target host: ${THOR_HOST}"

deploy_audio() {
    echo "==> Installing PipeWire Speaker EQ Tuning..."
    ssh "${THOR_HOST}" "mkdir -p ~/.config/pipewire/pipewire.conf.d"
    scp "${SCRIPT_DIR}/audio/50-thor-speaker-eq.conf" "${THOR_HOST}:~/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf"
    ssh "${THOR_HOST}" "systemctl --user restart pipewire.service pipewire-pulse.service"
    echo "==> Speaker EQ installed and PipeWire reloaded."
}

deploy_battery() {
    echo "==> Installing Thor 80% Battery Charge Ceiling Protection..."
    scp "${SCRIPT_DIR}/battery/thor-charge-limit" "${THOR_HOST}:/tmp/thor-charge-limit"
    scp "${SCRIPT_DIR}/battery/thor-charge-limit.service" "${THOR_HOST}:/tmp/thor-charge-limit.service"
    ssh "${THOR_HOST}" "
        sudo mkdir -p /var/local/bin
        sudo mv /tmp/thor-charge-limit /var/local/bin/thor-charge-limit
        sudo chmod +x /var/local/bin/thor-charge-limit
        sudo mv /tmp/thor-charge-limit.service /etc/systemd/system/thor-charge-limit.service
        sudo systemctl daemon-reload
        sudo systemctl enable --now thor-charge-limit.service
    "
    echo "==> Battery charge limit service active."
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

deploy_system() {
    echo "==> Applying System Fixes & Display Geometry..."
    scp "${SCRIPT_DIR}/system/setup-device-fixes.sh" "${THOR_HOST}:/tmp/setup-device-fixes.sh"
    ssh "${THOR_HOST}" "bash /tmp/setup-device-fixes.sh; rm -f /tmp/setup-device-fixes.sh"
    echo "==> System fixes applied."
}

show_status() {
    echo "==> Checking device tweak status on ${THOR_HOST}..."
    ssh "${THOR_HOST}" "
        echo '--- Audio EQ ---'
        ls -l ~/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf 2>/dev/null || echo 'Not installed'
        echo '--- Battery Protection ---'
        systemctl is-active thor-charge-limit.service 2>/dev/null || echo 'Inactive/Not installed'
        echo '--- Stick Lighting ---'
        systemctl is-active armada-stick-led.service 2>/dev/null || echo 'Inactive/Not installed'
        echo '--- Failed Units ---'
        systemctl --failed --no-pager
    "
}

case "$MODE" in
    --audio)
        deploy_audio
        ;;
    --battery)
        deploy_battery
        ;;
    --lighting)
        deploy_lighting
        ;;
    --system)
        deploy_system
        ;;
    --status)
        show_status
        ;;
    --all)
        deploy_audio
        deploy_battery
        deploy_lighting
        deploy_system
        show_status
        ;;
    *)
        echo "Usage: $0 [--all | --audio | --battery | --lighting | --system | --status] [HOST]"
        exit 1
        ;;
esac
