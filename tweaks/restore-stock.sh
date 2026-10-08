#!/usr/bin/env bash
# restore-stock.sh: put the Thor's Armada settings back to the image defaults and remove our add-ons.
# RUN THIS ON THE THOR (it needs sudo, which asks for the armada password):
#     scp tweaks/restore-stock.sh "$THOR_HOST":/tmp/ && ssh -t "$THOR_HOST" 'bash /tmp/restore-stock.sh'            # dry run
#     ssh -t "$THOR_HOST" 'bash /tmp/restore-stock.sh --apply'                                                       # do it
# Dry run by default: prints what it would do. Nothing is deleted: every config file and leftover folder is MOVED into
# ~/stock-reset-backup-<timestamp>/ so it can be put back. A CHANGED/KEPT report is printed and saved next to it.
#
# Flags: --apply   execute      --leftovers   ALSO move the game-save folders in step 7 (they are real saves: Steam Auto-Cloud files, Unity and Godot saves)
#
# Always kept: SSH (sshd + authorized_keys), Steam (login, library, settings), Decky and its plugins, Ratatoskr (Touch Master),
# Artemis, Flatpaks, Heroic, KDE/Plasma user settings, Wi-Fi connections, the ABL auto-update flag, Armada's own sudoers.
set -uo pipefail

APPLY=0; LEFTOVERS=0
for a in "$@"; do
    case "$a" in
        --apply) APPLY=1 ;;
        --leftovers) LEFTOVERS=1 ;;
        -h|--help) sed -n 2,12p "$0"; exit 0 ;;
        *) echo "unknown option $a" >&2; exit 1 ;;
    esac
done

TS=$(date +%Y%m%d-%H%M%S)
BK="$HOME/stock-reset-backup-$TS"
REPORT="$BK/report.txt"
CHANGED=(); KEPT=(); NOTES=()

run() { if [ "$APPLY" = 1 ]; then echo "+ $*"; eval "$*"; else echo "[dry-run] $*"; fi; }
changed() { CHANGED+=("$1"); }
kept() { KEPT+=("$1"); }

# Copy a root-owned file into the backup, then remove it with sudo.
stash_root_file() {  # path
    local f=$1
    [ -e "$f" ] || { echo "   (absent) $f"; return 1; }
    run "mkdir -p '$BK/root$(dirname "$f")' && sudo cp -a '$f' '$BK/root$f' && sudo chown -R '$USER' '$BK/root' && sudo rm -f '$f'"
    return 0
}
# Move a user file/folder into the backup.
stash_user() {  # path
    local f=$1
    [ -e "$f" ] || { echo "   (absent) $f"; return 1; }
    run "mkdir -p '$BK/home$(dirname "${f#$HOME}")' && mv '$f' '$BK/home${f#$HOME}'"
    return 0
}

echo "==> Stock reset on $(hostname) as $USER; mode: $([ $APPLY = 1 ] && echo APPLY || echo 'dry run (add --apply to execute)')"
if [ "$APPLY" = 1 ]; then
    mkdir -p "$BK"
    sudo -v || { echo "sudo needs the armada password; aborting."; exit 1; }
fi

echo "-- 1. Armada settings: delete the /etc/armada overrides (factory values live in /usr/share/armada)"
for f in power-profiles.conf game-tweaks.json controller.conf rgb.json bottom-screen-brightness desktop-session; do
    if stash_root_file "/etc/armada/$f"; then changed "/etc/armada/$f removed (back to factory/default)"; fi
done
kept "/etc/armada/abl.conf (bootloader auto-update flag), /etc/armada/sleep-debug-hook (Armada's own)"
run "sudo systemctl restart armada-powerd.service 2>/dev/null || true"

echo "-- 2. Add-on: thor-wowlan (Wake-on-WLAN) and its NetworkManager conf"
if [ -e /etc/systemd/system/thor-wowlan.service ] || [ -e /etc/NetworkManager/conf.d/90-wowlan.conf ]; then
    run "sudo systemctl disable --now thor-wowlan.service 2>/dev/null || true"
    stash_root_file /etc/systemd/system/thor-wowlan.service >/dev/null
    stash_root_file /etc/NetworkManager/conf.d/90-wowlan.conf >/dev/null
    phy=$(iw dev 2>/dev/null | awk '/^phy#/{p=substr($1,5)} /Interface/{print "phy" p; exit}')
    [ -n "${phy:-}" ] && run "sudo iw phy $phy wowlan disable 2>/dev/null || true"
    run "sudo systemctl reload NetworkManager 2>/dev/null || true"
    changed "thor-wowlan.service + 90-wowlan.conf removed; Wake-on-WLAN disabled"
else echo "   already gone"; fi

echo "-- 3. Add-on: thor-display-sync"
if [ -e /etc/systemd/system/thor-display-sync.service ] || [ -e /var/local/bin/thor-display-sync ]; then
    run "sudo systemctl disable --now thor-display-sync.service 2>/dev/null || true"
    stash_root_file /etc/systemd/system/thor-display-sync.service >/dev/null
    stash_root_file /var/local/bin/thor-display-sync >/dev/null
    changed "thor-display-sync.service + /var/local/bin/thor-display-sync removed"
else echo "   already gone"; fi

echo "-- 4. Add-on: PipeWire speaker EQ (audio goes back to the raw speaker/headphone sinks)"
if stash_user "$HOME/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf"; then
    run "systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true"
    changed "~/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf removed"
fi

echo "-- 5. Add-on: rpm-ostree-countme mask (stock state = not masked; the weekly job fails on its own)"
st=$(systemctl is-enabled rpm-ostree-countme.timer 2>&1 || true)
if [[ "$st" == *masked* ]]; then
    run "sudo systemctl unmask rpm-ostree-countme.timer rpm-ostree-countme.service"
    changed "rpm-ostree-countme unmasked"
fi

echo "-- 6. NetworkManager ignore-sleep flag (Armada Control's sleep setting removes it; the image ships it)"
if [ ! -e /etc/NetworkManager/ignore-sleep ] && [ -e /usr/etc/NetworkManager/ignore-sleep ]; then
    run "sudo cp -a /usr/etc/NetworkManager/ignore-sleep /etc/NetworkManager/ignore-sleep"
    changed "/etc/NetworkManager/ignore-sleep restored from the image"
fi

run "sudo systemctl daemon-reload"
[ -d /var/local/bin ] && [ -z "$(ls -A /var/local/bin 2>/dev/null)" ] && NOTES+=("/var/local/bin is empty (left in place)")

if [ "$LEFTOVERS" = 1 ]; then
    echo "-- 7. Game-save folders (--leftovers): moved to the backup, not deleted. These hold real saves; Steam Auto-Cloud may restore them. Contents first:"
    for d in "$HOME/.local/share/8bitskull_skull_horde" "$HOME/.local/share/FasterThanLight" "$HOME/.local/share/godot" \
             "$HOME/.local/share/dV" "$HOME/.local/share/Trash" "$HOME/.config/unity3d"; do
        if [ -e "$d" ]; then
            printf '   %s  (%s)\n' "$d" "$(du -sh "$d" 2>/dev/null | cut -f1)"
            find "$d" -maxdepth 2 -mindepth 1 2>/dev/null | head -6 | sed 's/^/      /'
            if stash_user "$d"; then changed "$d moved to backup (may hold game saves/settings)"; fi
        fi
    done
else
    echo "-- 7. Game-save folders left alone (add --leftovers to move them: 8bitskull_skull_horde, FasterThanLight, godot, dV, Trash, unity3d)"
fi

kept "SSH: sshd enabled, ~/.ssh/authorized_keys"
kept "Steam: login, library, settings, saves (~/.local/share/Steam, ~/.steam)"
kept "Decky Loader, armada-control, armada-store and their settings (~/homebrew)"
kept "Ratatoskr (Touch Master): plugin, ~/.config/systemd/user/touch-master.service, ~/.config/thor-input, ~/.local/share/thor-input"
kept "Artemis: ~/.local/share/artemis, ~/.config/Artemis Desktop Project, its Steam shortcut"
kept "Flatpaks (WebCord, AudioTube, PlasmaTube) and Heroic config"
kept "KDE/Plasma/kwin user settings in ~/.config; Wi-Fi connections; Armada's own sudoers (armada-user)"

echo
echo "================ REPORT ================"
{
    echo "Stock reset $TS ($([ $APPLY = 1 ] && echo applied || echo 'dry run'))"
    echo "CHANGED:"; for c in "${CHANGED[@]:-}"; do [ -n "$c" ] && echo "  - $c"; done
    echo "KEPT:";    for k in "${KEPT[@]:-}"; do [ -n "$k" ] && echo "  - $k"; done
    [ "${#NOTES[@]}" -gt 0 ] && { echo "NOTES:"; for n in "${NOTES[@]}"; do echo "  - $n"; done; }
    echo "Backup: $BK   (delete it with rm -rf when you are sure)"
    echo "Reboot afterwards so the controller type, RGB and power profile reload their defaults."
} | tee "$([ "$APPLY" = 1 ] && echo "$REPORT" || echo /dev/null)"
