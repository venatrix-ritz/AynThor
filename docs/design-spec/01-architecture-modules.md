# 01 - Architecture and modules

## Layout

| Module | Files | Role | Runs on |
|---|---|---|---|
| Orchestrator | `tweaks/apply-all-tweaks.sh` | Copies files with `scp`, runs install commands with `ssh`, reports status | Workstation |
| Cleanup | `tweaks/cleanup-device.sh` | One SSH session runs a remote bash script that removes stale units and binaries; dry run unless `--apply` | Workstation, acts on device |
| Audio | `tweaks/audio/50-thor-speaker-eq.conf` | PipeWire filter-chain virtual sink | Device (user session) |
| Display sleep sync | `tweaks/system/thor-display-sync.py`, `.service` | Poll DRM state, sleep the bottom panel with the top | Device (system daemon) |
| Wake-on-WLAN | `tweaks/system/thor-wowlan`, `.service`, `90-wowlan.conf` | Enable magic-packet wake on the Wi-Fi phy; NetworkManager profile | Device (oneshot) |
| Device fixes | `tweaks/system/setup-device-fixes.sh` | Mask a failing timer; check KWin layout and zram; never edits layout | Device (run by orchestrator) |
| Stick LEDs | `tweaks/lighting/stick-led-color.py`, `armada-stick-led.service` | Mode state machine, evdev reader, ambilight sampler, sysfs writer | Device (system daemon plus CLI) |
| Game profiles | `tweaks/game-profiles/build_game_tweaks.py`, `game-tweaks.json` | Generate per-AppID JSON for Armada's launcher | Workstation (generator); file copied by hand |
| Telemetry | `tweaks/battery-monitor.py` | JSON-lines logger of power, thermal, CPU, GPU, Wi-Fi state | Device |
| Benchmarks | `tweaks/profile-bench.py`, `tweaks/system-bench.py` | CPU load per power profile; memory, storage and Wi-Fi latency | Device |
| Wake | `scripts/wake-thor.py`, `scripts/wake-thor.ps1` | Magic packet over UDP broadcast | Workstation |
| Reference refresh | `scripts/clone-refs.ps1`, `scripts/fetch-gh-meta.ps1`, `scripts/refs.lock.json` | Rebuild `refs/`, export GitHub metadata | Workstation |
| Knowledge base | `docs/` | Sourced research with claim tags | Read only |

## Deploy topology

- The repo is the source of truth. Files are copied to the device with `scp`, usually into `/tmp`, then moved into `/var/local/bin`, `/etc/systemd/system`, `/etc/NetworkManager/conf.d` or the user's `~/.config` (`apply-all-tweaks.sh`, `deploy_*` functions).
- The reason for `/var/local/bin` is not written in the repo. The hub note says `/usr` is read-only on Armada (OSTree); **UNVERIFIED** in this read.
- Systemd units are enabled with `enable --now`. `thor-wowlan` and the stick LED daemon use `Restart=on-failure`; `thor-display-sync` uses `Restart=always` (`RestartSec=3`).
- There is no installer, package or versioned release. The device's state is checked with `--status`, which reports unit state and not file contents (`show_status()`).
- The Gleipnir and Ratatoskr plugins are separate repos, reached through junctions in `plugins/`. Their deploy scripts are outside this repo (`tweaks/apply-all-tweaks.sh` `--battery` message; `tweaks/README.md` section 2).

## Module dependencies

| Module | Depends on (device) | Depends on (workstation) |
|---|---|---|
| Stick LEDs | `/sys/class/leds`, `/sys/class/power_supply`, `/sys/class/backlight`, `/dev/input` (evdev), `/dev/dri`, `ffmpeg` (ambilight only), `/run/armada/fake-suspend.active` | none |
| Display sync | `/sys/kernel/debug/dri/0/state`, `/sys/class/backlight/ae94000.dsi.0/bl_power`, `runuser`, `/usr/bin/gamescopectl`, `/run/user/1000/gamescope-1` | none |
| WoWLAN | `iw`, NetworkManager, the Wi-Fi phy | none |
| Audio | PipeWire (`pipewire.service`, `pipewire-pulse.service` user units) | none |
| Battery monitor | `/sys/class/power_supply`, `/proc/stat`, `/proc/net/dev`, `iw`, `systemctl`, `journalctl`, `ps` | none |
| Orchestrator | `ssh`, `scp` | `local/thor.env` |
| Game profiles | Steam AppIDs (from the builder's tier tables) | Python 3 |
