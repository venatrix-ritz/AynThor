#!/usr/bin/env bash
# cleanup-device.sh: remove what earlier agent sessions left on the Thor that is dead or conflicting.
# Dry run by default: prints what it would do. Nothing changes without --apply.
# Usage: ./cleanup-device.sh [--apply] [--keep-stick-led] [--purge-build] [--drop-sudo] [HOST]
#   --keep-stick-led  leave armada-stick-led alone (default: remove it; Armada ships armada-rgb for the Thor)
#   --purge-build     also delete ~/build (Artemis source) and the localhost/artemis-builder podman image
#   --drop-sudo       also delete /etc/sudoers.d/91-claude-full (passwordless sudo for armada). Do this last.
# Why each step exists: docs/hardware/device-observed.md ("Re-survey 2026-10-07").
set -euo pipefail

APPLY=0; KEEP_LED=0; PURGE=0; DROP_SUDO=0; ARG_HOST=""
for a in "$@"; do
    case "$a" in
        --apply) APPLY=1 ;;
        --keep-stick-led) KEEP_LED=1 ;;
        --purge-build) PURGE=1 ;;
        --drop-sudo) DROP_SUDO=1 ;;
        -h|--help) sed -n 2,10p "$0"; exit 0 ;;
        -*) echo "unknown option $a" >&2; exit 1 ;;
        *) ARG_HOST="$a" ;;
    esac
done

_ENV_FILE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)/local/thor.env"
if [ -z "${THOR_HOST:-}" ] && [ -f "$_ENV_FILE" ]; then THOR_HOST="$(sed -n 's/^THOR_HOST=//p' "$_ENV_FILE" | head -1)"; fi
THOR_HOST="${ARG_HOST:-${THOR_HOST:-}}"
[ -n "$THOR_HOST" ] || { echo "ERROR: no Thor host (arg, THOR_HOST, or local/thor.env)." >&2; exit 2; }
ssh -o BatchMode=yes -o ConnectTimeout=8 "$THOR_HOST" true 2>/dev/null || { echo "ERROR: cannot reach ${THOR_HOST} with key auth." >&2; exit 2; }

echo "==> Target: ${THOR_HOST}  mode: $([ $APPLY = 1 ] && echo APPLY || echo 'dry run (add --apply to execute)')"
ssh "$THOR_HOST" env APPLY=$APPLY KEEP_LED=$KEEP_LED PURGE=$PURGE DROP_SUDO=$DROP_SUDO bash -s <<'REMOTE'
set -u
run() { if [ "$APPLY" = 1 ]; then echo "+ $*"; eval "$*"; else echo "[dry-run] $*"; fi; }
sudo -n true 2>/dev/null || { echo "ERROR: passwordless sudo is not available on the Thor."; exit 1; }

echo "-- 1. thor-charge-limit (deployed old version only checks charge_control_limit, which this kernel lacks, so it does nothing; the 80% cap is now the Gleipnir plugin, see plugins/gleipnir)"
if [ -e /etc/systemd/system/thor-charge-limit.service ] || [ -e /var/local/bin/thor-charge-limit ]; then
    run "sudo systemctl disable --now thor-charge-limit.service 2>/dev/null || true"
    run "sudo rm -f /etc/systemd/system/thor-charge-limit.service /var/local/bin/thor-charge-limit"
else echo "   already gone"; fi

echo "-- 2. armada-stick-led: shares the HTR3212 channels with armada-rgb"
if [ "$KEEP_LED" = 1 ]; then echo "   kept (--keep-stick-led); redeploy with tweaks/apply-all-tweaks.sh --lighting to get Conflicts=armada-rgb.service"
elif [ -e /etc/systemd/system/armada-stick-led.service ] || [ -e /var/local/bin/stick-led-color ]; then
    run "sudo systemctl disable --now armada-stick-led.service 2>/dev/null || true"
    run "sudo rm -f /etc/systemd/system/armada-stick-led.service /var/local/bin/stick-led-color"
else echo "   already gone"; fi

echo "-- 3. duplicate lines in ~/.ssh/authorized_keys"
total=$(wc -l < ~/.ssh/authorized_keys); uniq_n=$(awk '!s[$0]++' ~/.ssh/authorized_keys | wc -l)
if [ "$total" != "$uniq_n" ]; then
    run "awk '!s[\$0]++' ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.new && cat ~/.ssh/authorized_keys.new > ~/.ssh/authorized_keys && rm -f ~/.ssh/authorized_keys.new"
else echo "   no duplicates ($total lines)"; fi

if [ "$PURGE" = 1 ]; then
    echo "-- 4. build leftovers (--purge-build)"
    [ -d ~/build ] && run "rm -rf ~/build" || echo "   ~/build already gone"
    podman image exists localhost/artemis-builder 2>/dev/null && run "podman rmi localhost/artemis-builder" || echo "   artemis-builder image already gone"
fi

run "sudo systemctl daemon-reload"

echo "-- 5. NOT touched, check yourself: /etc/NetworkManager/ignore-sleep (Armada's Wi-Fi-across-fake-suspend flag)"
if [ -e /etc/NetworkManager/ignore-sleep ]; then echo "   present"; elif [ -e /usr/etc/NetworkManager/ignore-sleep ]; then echo "   MISSING in /etc (image ships it). Restore only if the Armada Control setting should be on: sudo cp /usr/etc/NetworkManager/ignore-sleep /etc/NetworkManager/"; fi

if [ "$DROP_SUDO" = 1 ]; then
    echo "-- 6. passwordless sudo (--drop-sudo, last step)"
    run "sudo rm -f /etc/sudoers.d/91-claude-full"
else echo "-- 6. /etc/sudoers.d/91-claude-full kept (add --drop-sudo when device work is finished)"; fi
REMOTE
echo "==> Done. Redeploy the corrected units with: tweaks/apply-all-tweaks.sh --system"
