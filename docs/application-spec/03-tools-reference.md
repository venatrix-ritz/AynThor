# 03 - Tools reference

Every command, flag and default below is copied from the file named in its heading. "Device" means the Thor over SSH; "workstation" means the Windows machine with Git Bash and PowerShell.

## Index
| Tool | Where it runs | Section |
|---|---|---|
| `tweaks/apply-all-tweaks.sh` | Workstation | [below](#apply-all-tweakssh) |
| `tweaks/cleanup-device.sh` | Workstation (drives the device) | [below](#cleanup-devicesh) |
| `tweaks/lighting/stick-led-color.py` | Device | [below](#stick-led-colorpy) |
| `tweaks/system/thor-display-sync.py` | Device (daemon, no arguments) | [below](#thor-display-syncpy) |
| `tweaks/system/thor-wowlan` | Device (oneshot, no arguments) | [below](#thor-wowlan) |
| `tweaks/system/setup-device-fixes.sh` | Device | [below](#setup-device-fixessh) |
| `tweaks/battery-monitor.py` | Device | [below](#battery-monitorpy) |
| `tweaks/profile-bench.py` | Device | [below](#profile-benchpy) |
| `tweaks/system-bench.py` | Device, root | [below](#system-benchpy) |
| `tweaks/game-profiles/build_game_tweaks.py` | Workstation | [below](#build_game_tweakspy) |
| `scripts/wake-thor.py`, `scripts/wake-thor.ps1` | Workstation | [below](#wake-thor) |
| `scripts/clone-refs.ps1` | Workstation | [below](#clone-refsps1) |
| `scripts/fetch-gh-meta.ps1` | Workstation | [below](#fetch-gh-metaps1) |

---

## apply-all-tweaks.sh
Usage (from the script header): `./apply-all-tweaks.sh [--all | --audio | --lighting | --system | --wowlan | --status] [HOST]`

| Mode | Effect | Exit codes |
|---|---|---|
| `--audio` | Copies `audio/50-thor-speaker-eq.conf` to `~/.config/pipewire/pipewire.conf.d/` on the device and restarts `pipewire.service` and `pipewire-pulse.service` (user units) | 0 on success; `set -e` aborts otherwise |
| `--lighting` | Installs `/var/local/bin/stick-led-color` and `armada-stick-led.service` into `/etc/systemd/system`, then `enable --now` | as above |
| `--system` | Runs `setup-device-fixes.sh` on the device, installs `thor-display-sync` and `thor-wowlan` units, `90-wowlan.conf` into `/etc/NetworkManager/conf.d/`, enables `thor-wowlan` and `thor-display-sync` | as above |
| `--wowlan` | Installs `thor-wowlan` and `90-wowlan.conf` only | as above |
| `--status` | Prints `is-active` for Gleipnir, `armada-stick-led`, `thor-display-sync`, `thor-wowlan`; last `thor-wowlan` journal line; failed units | 0 |
| `--all` (default when no flag) | `--audio`, then `--system` (with the Gleipnir note), then `--status`. Skips `--lighting` | as above |
| `--battery` | Prints a message pointing to Gleipnir | 1 |
| anything else | Usage line | 1 |

Host resolution: `arg 2` > `$THOR_HOST` > `THOR_HOST=` line in `local/thor.env`. Exit 2 if none is set, or if `ssh -o BatchMode=yes -o ConnectTimeout=8 HOST true` fails (not checked for `-h`).

Note: `--system` installs `thor-display-sync`, which `docs/armada/dual-screen-dimming.md` calls superseded. See [05](05-requirements-testing-limitations.md).

## cleanup-device.sh
Usage (from the script header): `./cleanup-device.sh [--apply] [--keep-stick-led] [--purge-build] [--drop-sudo] [HOST]`

| Flag | Effect |
|---|---|
| (none) | Dry run: every change prints as `[dry-run] ...` |
| `--apply` | Execute the changes |
| `--keep-stick-led` | Leave `armada-stick-led` installed |
| `--purge-build` | Also delete `~/build` and the `localhost/artemis-builder` podman image |
| `--drop-sudo` | Also delete `/etc/sudoers.d/91-claude-full` (run last) |
| `-h`, `--help` | Print the header |

Steps run on the device, in order: (1) remove `thor-charge-limit` unit and binary; (2) remove `armada-stick-led` unit and `/var/local/bin/stick-led-color` unless kept; (3) de-duplicate `~/.ssh/authorized_keys`; (4) optional build purge; (5) `systemctl daemon-reload`; (6) report only `/etc/NetworkManager/ignore-sleep` state, never changes it. Exit 1 if the device has no passwordless sudo; exit 2 if the host is unreachable.

## stick-led-color.py
Installed as `/var/local/bin/stick-led-color`. Entry: `main(argv)` at `tweaks/lighting/stick-led-color.py:699`.

| Command | Argument rules | Effect | Exit |
|---|---|---|---|
| `get` (default) | none | Prints `mode=`, `color=`, `screen_link=`, each `<param>_<mode>=`, each `flash_<button>=` | 0 |
| `set <RRGGBB>` | 6 hex digits | Sets static colour, applies it (scaled by backlight if screen_link on), saves mode `static` | 0; 1 if apply fails; 2 usage |
| `set-mode <mode>` | one of the modes below | Saves the mode and applies it | 0 / 1 / 2 |
| `set-screen-link <on\|off>` | | Saves and applies | 0 / 1 / 2 |
| `set-param <speed\|intensity\|size> <mode> <value>` | mode must apply to the param (see table) | Clamps value and saves | 0 / 2 |
| `set-flash-color <button> <RRGGBB>` | button in `FLASH_BUTTONS` | Saves flash colour | 0 / 2 |
| `apply` | | Re-applies the saved state once | 0 / 1 |
| `daemon` | | Runs forever (used by the unit) | 0 |

**Modes** (`MODES`, line 77): `static`, `breathing`, `battery`, `battery-breathing`, `rainbow`, `chase`, `alternating`, `reactive`, `multidot`, `ambilight`. `battery-breathing` shares the `breathing` tunables.

**Tunables** (`PARAM_SPECS`, lines 92-96):

| Param | Range | Default | Modes it applies to |
|---|---|---|---|
| `speed` | 0.25-3.0 | 1.0 | breathing, chase, rainbow, alternating, multidot, ambilight |
| `intensity` | 0.0-0.5 | 0.15 | breathing, alternating, chase, multidot, reactive |
| `size` | 1-3 | 2 | chase, multidot |

`clamp_param` clamps to the range but does not round `size` (stored as a float) - **UNVERIFIED** whether the animation code expects an integer.

**Flash button names** (`FLASH_BUTTONS`, from `FLASH_BUTTON_CODES` lines 145-162): `south east north west l1 r1 l3 r3 l4 r4 start select dpad_up dpad_down dpad_left dpad_right other`.

## thor-display-sync.py
Daemon, no arguments. Installed as `/var/local/bin/thor-display-sync` by `--system`. Details in [design 02](../design-spec/02-algorithms-protocols.md#display-sleep-sync). Loop period 0.5 s (`main()`, line 114).

## thor-wowlan
Oneshot, no arguments. Environment `THOR_WAIT_S` (default 60) bounds the wait for a Wi-Fi phy.

| Exit | Meaning |
|---|---|
| 0 | `iw phy <phy> wowlan show` reads back `magic packet` |
| 1 | Transient: no phy appeared, enable failed, or readback mismatch |
| 78 | Unsupported: `iw` missing, or phy does not advertise WoWLAN; the unit does not retry (`RestartPreventExitStatus=78`) |

Logs to the journal with tag `thor-wowlan`.

## setup-device-fixes.sh
Run on the device by `--system` (as `bash /tmp/setup-device-fixes.sh`). No arguments. Steps: masks `rpm-ostree-countme.timer` and `.service` with `sudo systemctl mask --now`; checks (never edits) `~/.config/kwinoutputconfig.json` for DSI-2 enabled and DSI-1 not ahead of it; checks zram swap and prints swappiness. Always `exit 0`; read the warning count.

## battery-monitor.py
Usage: `battery-monitor.py [--interval SEC] [--fast SEC] [--out FILE]`

| Flag | Default | Effect |
|---|---|---|
| `--interval` | 5 | Period of `"k":"full"` snapshots |
| `--fast` | 1 | Period of `"k":"fast"` lines (0 disables) |
| `--out` | `~/battery-logs/battery-<YYYYmmdd-HHMMSS>.jsonl` | Output file, opened in append mode |

Stop with Ctrl-C or SIGTERM. Writes nothing to sysfs (docstring, lines 1-15). Fast-line fields: `FAST_ATTRS` at lines 29-30.

## profile-bench.py
Usage: `profile-bench.py [--profiles eco,balanced,performance] [--duration 240] [--out FILE]`. Default out `~/profile-bench-<timestamp>.jsonl`. Uses `armada-power status` and `armada-power profile NAME`. Restores the starting profile in a `finally` block. Aborts a profile if a CPU zone reaches 95 C or the battery reaches 45 C (`ABORT_CPU_C`, `ABORT_BATT_C`). Starts each profile after cooling to 52 C, waiting at most 300 s (`COOL_TARGET_C`, `COOL_MAX_S`). Samples every 10 s.

## system-bench.py
Usage: `sudo python3 system-bench.py [--seconds 8] [--disk sda] [--wifi wlp1s0] [--skip-wifi]`. Prints `memory:` (copy throughput, one thread and four processes, 256 MiB buffers), `storage <scheduler> <result>` per I/O scheduler (O_DIRECT sequential and random reads of the raw disk), and `wifi:` latency with power save on and off unless `--skip-wifi`. The docstring says it restores the scheduler and Wi-Fi power save; the restore code was **not traced** in this spec (**UNVERIFIED**).

## build_game_tweaks.py
Usage: `build_game_tweaks.py [OUT.json]` (default `game-tweaks.json` beside the script). Writes JSON with 2-space indent and LF endings and prints the game count. Tier tables and their basis are in `tweaks/game-profiles/README.md`. Current output: 64 games (`"fexProfile"` appears 64 times in `game-tweaks.json`).

## wake-thor
- `scripts/wake-thor.py [MAC]`: MAC from argument, else `THOR_MAC`; broadcast from `THOR_BROADCAST`. Both come from the environment or `local/thor.env`. Sends the magic packet twice to UDP port 9.
- `scripts/wake-thor.ps1 [-MacAddress] [-BroadcastIp] [-Port 9]`: same lookup order; sends twice with 100 ms between.

Both exit non-zero when MAC or broadcast is missing (`sys.exit` in the Python script; `Write-Error` plus `exit 1` in PowerShell).

## clone-refs.ps1
Usage: `.\scripts\clone-refs.ps1` or `.\scripts\clone-refs.ps1 -UseLock`. Sets `GIT_TERMINAL_PROMPT=0`. Clones each target into `refs/<dir>` in full, shallow (depth 1) or sparse mode; with `-UseLock`, checks out SHAs from `scripts/refs.lock.json`. The target list is the `$targets` array in the script. Shallow clone size cap: `$maxShallowMB = 300`.

## fetch-gh-meta.ps1
No arguments. Requires `gh` authenticated. Writes `refs/_gh/releases-list.json`, `refs/_gh/releases/<tag>.json`, `issues.json` (up to 2000 issues), `prs.json` (up to 2000), `tags.json`, `branches.json`, `contributors.json`, `repo.json` for `armada-os/armada`.
