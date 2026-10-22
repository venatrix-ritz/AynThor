# 04 - Interfaces and error handling

## Device interfaces

| Interface | Path or command | Used by | Direction | Notes |
|---|---|---|---|---|
| DRM state (debugfs) | `/sys/kernel/debug/dri/0/state` | display sync | read | Needs debugfs and root |
| Bottom backlight power | `/sys/class/backlight/ae94000.dsi.0/bl_power` | display sync | write `0` or `4` | Only written if the file exists |
| Backlights | `/sys/class/backlight/*/brightness`, `max_brightness` | LED screen link, battery monitor | read | First sorted entry for screen link |
| Stick LEDs | `/sys/class/leds/{l,r}:{r,g,b}{1-4}/brightness` | LED daemon | write 0-255 | Heroic HTR3212 channels |
| Gamepad input | `/dev/input/eventN` whose `device/name` is `AYN Odin2 Gamepad` or `Retroid Pocket Gamepad` | LED reactive mode | read, non-exclusive | `EVIOCGABS` for ranges |
| DRM card | `/dev/dri/card*` (first sorted) | ambilight via ffmpeg `kmsgrab` | read (via ffmpeg) | |
| Battery | `/sys/class/power_supply/battery/*`, `qcom-battmgr-usb/*` | LED battery mode, battery monitor, profile bench | read | |
| Charge current limit | `constant_charge_current` (in the fast log fields) | battery monitor | read | Written by the Gleipnir plugin (separate repo, not read here); this repo's code only reads it |
| Fan | `/sys/class/hwmon/hwmon*/fan1_input` where `name` is `pwmfan` | profile bench | read | |
| GPU clock | `/sys/class/devfreq/3d00000.gpu/cur_freq` | profile bench | read | |
| I/O scheduler | `/sys/block/sda/queue/scheduler` | system bench | read and temporary write | Restore **UNVERIFIED** |
| Suspend counters | `/sys/power/suspend_stats/*` | battery monitor | read | |
| Fake-suspend flag | `/run/armada/fake-suspend.active` | LED daemon | exists check | Written by Armada |
| Stick LED config | `/etc/armada/stick-led.conf` | LED CLI and daemon | read and atomic write (tmp then replace) | `key=value` |
| Gamescope socket | `/run/user/1000/gamescope-1` and `gamescopectl` | display sync | command | Via `runuser -u armada` |
| Wi-Fi | `iw dev`, `iw phy <phy> info`, `iw phy <phy> wowlan enable|show`, `iw dev <if> link` | WoWLAN, battery monitor | command | |
| Power profile | `armada-power status`, `armada-power profile NAME` | profile bench | command | |
| Journal | `logger -t thor-wowlan`, `journalctl -t thor-wowlan` | WoWLAN | write and read | |
| PipeWire | `systemctl --user restart pipewire.service pipewire-pulse.service` | audio deploy | command | |

## Workstation to device

| Mechanism | Used by | Notes |
|---|---|---|
| `ssh -o BatchMode=yes -o ConnectTimeout=8` | Orchestrator reachability check, cleanup | No password prompt; key auth only |
| `scp` into `/tmp` then `sudo mv` | Orchestrator | Files pass through `/tmp` before the privileged move |
| `ssh HOST bash -s` with a heredoc | cleanup-device.sh | Remote script is fixed text with `APPLY`, `KEEP_LED`, `PURGE`, `DROP_SUDO` passed as environment |
| `ssh HOST "..."` with multi-line commands | Orchestrator | Commands run as the device user, `sudo` for system paths |

## Exit codes

| Program | 0 | 1 | 2 | Other |
|---|---|---|---|---|
| `apply-all-tweaks.sh` | Success | `--battery`, unknown mode | No host, or unreachable | `set -euo pipefail` aborts with the failing command's code |
| `cleanup-device.sh` | Success or dry run | Device has no passwordless sudo, or unknown flag | No host, or unreachable | Remote errors propagate |
| `stick-led-color.py` | Success | Apply failed (`set`, `set-mode`, `set-screen-link`, `apply`) | Usage or invalid value | `daemon` runs `while True` and does not return (`run_daemon`, line 614) |
| `thor-wowlan` | Enabled and read back | Transient (no phy, enable failed, readback mismatch) | - | 78 = unsupported; `RestartPreventExitStatus=78` |
| `setup-device-fixes.sh` | Always 0 | - | - | Read the warning count in its output |
| `wake-thor.py` | Success | - | - | `sys.exit` with a message when env is missing; invalid MAC raises `ValueError` |
| `wake-thor.ps1` | Success | `exit 1` on missing values or bad MAC | - | |

## Failure handling by component

| Component | Failure | Behaviour |
|---|---|---|
| Orchestrator | Missing host | Exit 2 with a message naming the three sources |
| Orchestrator | Unreachable device | Exit 2 before any copy |
| Orchestrator | Remote command fails | `set -e` on the remote `bash` and local `set -euo pipefail` abort the mode |
| Cleanup | No passwordless sudo | Exit 1 before any change |
| Cleanup | Dry run | Every change prints `[dry-run]`; `run` evaluates only with `APPLY=1` |
| Display sync | Read or regex failure | Returns `(1, 1)`: treats both panels as awake; the loop continues |
| Display sync | `gamescopectl` fails or times out | Output discarded; `check=False`; timeout 3 s; loop continues |
| Display sync | Any exception in a loop tick | Written to stderr, next tick after 0.5 s |
| Display sync | Socket missing | Gamescope call skipped; backlight still written |
| Display sync | `bl_power` write fails | Written to stderr; continues |
| Stick LEDs | `/sys/class/leds` write fails | `write_zone` returns False; other channels still attempted |
| Stick LEDs | No gamepad device | `ensure_open` returns False; reactive falls back to no input |
| Stick LEDs | ffmpeg missing or DRM card missing | `ensure_open` returns False; ambilight shows the default colour |
| Stick LEDs | Config file missing or bad | Defaults used; invalid lines ignored |
| Stick LEDs | Unit crash | `Restart=on-failure`, `RestartSec=2` |
| WoWLAN | No phy in 60 s | Exit 1; unit retries after 15 s (`RestartSec=15`) |
| WoWLAN | Driver lacks WoWLAN | Exit 78; unit does not retry |
| Setup script | `rpm-ostree-countme` already masked | Warning count incremented; exit still 0 |
| Setup script | `python3` missing for the KWin check | Warning; exit still 0 |
| Profile bench | CPU or battery over limit | Run aborted; original profile restored |
| Profile bench | Any exit | `finally` restores the original profile |
| Battery monitor | Missing sysfs file | `rd()` returns None; field is null |
| Battery monitor | SIGINT or SIGTERM | Stop flag set; loop exits and file is closed |
| Wake (PowerShell) | Bad MAC | `Write-Error` and exit 1 |
