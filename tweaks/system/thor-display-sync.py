#!/usr/bin/env python3
"""
Thor Dual-Screen Display Sleep & Idle Sync Daemon
Monitors the primary display's DRM CRTC state (crtc-0 / DSI-2) and synchronizes
display sleep, idle blanking, and resume to the secondary display (crtc-1 / DSI-1).
"""

import os
import re
import subprocess
import sys
import time

STATE_FILE = "/sys/kernel/debug/dri/0/state"
BL_POWER_FILE = "/sys/class/backlight/ae94000.dsi.0/bl_power"
GAMESCOPE_SOCK = "/run/user/1000/gamescope-1"
GAMESCOPECTL = "/usr/bin/gamescopectl"

CRTC0_PATTERN = re.compile(r"crtc\[\d+\]:\s*crtc-0.*?active=(\d+)", re.DOTALL)
CRTC1_PATTERN = re.compile(r"crtc\[\d+\]:\s*crtc-1.*?active=(\d+)", re.DOTALL)


def run_gamescope_ctl(sock_name, command, val):
    """Run a gamescopectl command against a specific Gamescope instance."""
    env_vars = {
        "HOME": "/var/home/armada",
        "XDG_RUNTIME_DIR": "/run/user/1000",
        "GAMESCOPE_WAYLAND_DISPLAY": sock_name,
        "PATH": "/usr/bin:/usr/local/bin:/bin",
    }
    cmd = ["/usr/bin/runuser", "-u", "armada", "--", "env"]
    for k, v in env_vars.items():
        cmd.append(f"{k}={v}")
    cmd.extend([GAMESCOPECTL, command, str(val)])

    try:
        subprocess.run(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=3,
            check=False,
        )
    except Exception as e:
        sys.stderr.write(f"gamescopectl error: {e}\n")


def set_secondary_backlight_power(power):
    """Set secondary backlight bl_power (0 = unblank/on, 4 = powerdown/off)."""
    try:
        if os.path.exists(BL_POWER_FILE):
            with open(BL_POWER_FILE, "w") as f:
                f.write(f"{power}\n")
    except Exception as e:
        sys.stderr.write(f"bl_power error: {e}\n")


def get_crtc_states():
    """Read DRM CRTC active states from debugfs."""
    try:
        with open(STATE_FILE, "r") as f:
            text = f.read()
        m0 = CRTC0_PATTERN.search(text)
        m1 = CRTC1_PATTERN.search(text)
        active0 = int(m0.group(1)) if m0 else 1
        active1 = int(m1.group(1)) if m1 else 1
        return active0, active1
    except Exception:
        return 1, 1


def main():
    print("[thor-display-sync] Starting Thor Dual-Screen Display Sleep Sync Daemon...")
    sys.stdout.flush()

    # Initial state
    last_top_active = None

    while True:
        try:
            top_active, bottom_active = get_crtc_states()

            if last_top_active is None:
                last_top_active = top_active

            # State change detection
            if top_active != last_top_active:
                if top_active == 0:
                    print("[thor-display-sync] Top screen entered display sleep/blank. Sleeping bottom display.")
                    sys.stdout.flush()
                    if os.path.exists(GAMESCOPE_SOCK):
                        run_gamescope_ctl("gamescope-1", "drm_sleep_internal_screen", 1)
                    set_secondary_backlight_power(4)
                else:
                    print("[thor-display-sync] Top screen woke up. Resuming bottom display.")
                    sys.stdout.flush()
                    set_secondary_backlight_power(0)
                    if os.path.exists(GAMESCOPE_SOCK):
                        run_gamescope_ctl("gamescope-1", "drm_sleep_internal_screen", 0)

                last_top_active = top_active

            # Desync check: if top screen is asleep but bottom screen somehow remained/became awake
            elif top_active == 0 and bottom_active == 1:
                print("[thor-display-sync] Correcting desync: Top screen asleep but bottom screen awake.")
                sys.stdout.flush()
                if os.path.exists(GAMESCOPE_SOCK):
                    run_gamescope_ctl("gamescope-1", "drm_sleep_internal_screen", 1)
                set_secondary_backlight_power(4)

        except Exception as e:
            sys.stderr.write(f"[thor-display-sync] Loop exception: {e}\n")

        time.sleep(0.5)


if __name__ == "__main__":
    main()
