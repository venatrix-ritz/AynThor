# 04 - Configuration

## Workstation

### Local env file: `local/thor.env` (git-ignored)
Template: `scripts/thor.env.example`. Real values never go in tracked files (`CLAUDE.md`, "Device access").

| Key | Meaning | Used by |
|---|---|---|
| `THOR_HOST` | `armada@<host>` target for SSH and SCP | `apply-all-tweaks.sh`, `cleanup-device.sh` |
| `THOR_MAC` | Wi-Fi MAC of the Thor | `scripts/wake-thor.py`, `scripts/wake-thor.ps1` |
| `THOR_BROADCAST` | LAN broadcast address for the magic packet | same |

Lookup order (all scripts): environment variable first, then `local/thor.env`. `apply-all-tweaks.sh` and `cleanup-device.sh` read only `THOR_HOST` from the file, with `sed -n 's/^THOR_HOST=//p'`.

### Environment variables
| Variable | Read by | Default | Purpose |
|---|---|---|---|
| `THOR_HOST` | `apply-all-tweaks.sh`, `cleanup-device.sh` | none | Host if no argument is given |
| `THOR_MAC`, `THOR_BROADCAST` | `wake-thor.py`, `wake-thor.ps1` | from `local/thor.env` | Magic packet target |
| `GIT_TERMINAL_PROMPT` | `scripts/clone-refs.ps1` (set to 0 inside the script) | | Stops git prompting |
| `THOR_WAIT_S` | `thor-wowlan` on the device | 60 | Seconds to wait for a Wi-Fi phy |

### Lock and manifest files
| File | Written by | Read by |
|---|---|---|
| `scripts/refs.lock.json` | `clone-refs.ps1` (pins SHA per target) | `clone-refs.ps1 -UseLock` |
| `refs/MANIFEST.md` (gitignored) | `clone-refs.ps1` | Citations in `docs/` (per `docs/reference/CONVENTIONS.md`) |
| `refs/_gh/*.json` (gitignored) | `fetch-gh-meta.ps1` | Citations in `docs/` |

### Line endings
`.gitattributes` pins `tweaks/**`, `*.sh`, `*.service`, `*.py`, `*.json`, `*.desktop`, `*.js`, and `plugins/**` to `eol=lf`. `scripts/wake-thor.py` is also pinned. Reason given in the file: files that run on the Thor must stay LF. `CLAUDE.md` adds that the workstation has `core.autocrlf=true`.

## Device (paths the tweaks write)

| Path | Written by | Format / contents |
|---|---|---|
| `/var/local/bin/stick-led-color` | `--lighting` | Python 3 script |
| `/var/local/bin/thor-display-sync` | `--system` | Python 3 daemon |
| `/var/local/bin/thor-wowlan` | `--wowlan`, `--system` | bash |
| `/etc/systemd/system/armada-stick-led.service` | `--lighting` | systemd unit, `Conflicts=armada-rgb.service` |
| `/etc/systemd/system/thor-display-sync.service` | `--system` | systemd unit |
| `/etc/systemd/system/thor-wowlan.service` | `--wowlan`, `--system` | systemd unit (oneshot) |
| `/etc/NetworkManager/conf.d/90-wowlan.conf` | `--wowlan`, `--system` | `[connection-wifi-wowlan]`, `match-device=type:wifi`, `wifi.wake-on-wlan=0x8` |
| `~/.config/pipewire/pipewire.conf.d/50-thor-speaker-eq.conf` | `--audio` | PipeWire filter-chain module |
| `/etc/armada/stick-led.conf` | `stick-led-color` (save_state) | `key=value` lines: `mode`, `color`, `screen_link` (`1`/`0`), `<param>_<mode>`, `flash_<button>` |
| `/etc/armada/game-tweaks.json` | Manual copy, not a script | JSON, see below |
| `~/battery-logs/*.jsonl` | `battery-monitor.py` | JSON lines (`"k":"full"` or `"k":"fast"`) |
| `~/profile-bench-*.jsonl` | `profile-bench.py` | JSON lines (`begin`, sample, `start`, `end`) |
| `~/.config/kwinoutputconfig.json` | Armada (read only here) | Checked by `setup-device-fixes.sh`, never written |

### Stick LED config (`/etc/armada/stick-led.conf`)
Written by `save_state` in `tweaks/lighting/stick-led-color.py`. Defaults when the file is missing: `mode=static`, `color=0050FF`, `screen_link=0`, `DEFAULT_COLOR`/`DEFAULT_MODE`/`DEFAULT_SCREEN_LINK` (lines 74-76). Values that fail validation are ignored on load (`load_state`).

### game-tweaks.json schema
Top-level `games` object keyed by Steam AppID (string). Per game, fields used in this repo: `fexProfile` (always `default`), `cores` (`big` for 30 entries), `env` with `DXVK_FRAME_RATE` and `VKD3D_FRAME_RATE` (40 for 13 entries, 60 for 17). The schema is read from Armada's code, not from this repo (`tweaks/game-profiles/README.md`, "What is and is not backed by a source"). Other schema fields listed in that README (`nice`, `scheduler`, `wineTopology`, `thunks`, `global`) are not used by the builder.

### Speaker EQ (`tweaks/audio/50-thor-speaker-eq.conf`)
Module `libpipewire-module-filter-chain`, `flags = [ ifexists nofail ]`, node description `AYN Thor Tuned Speakers`, capture sink `effect_input.thor_speaker_eq` (Audio/Sink), playback `effect_output.thor_speaker_eq`. Band list in [design 02](../design-spec/02-algorithms-protocols.md#speaker-eq).

### Display sync constants (`tweaks/system/thor-display-sync.py`)
Hard-coded: debugfs state path, `ae94000.dsi.0` backlight, `/run/user/1000/gamescope-1` socket, `/usr/bin/gamescopectl`, and an environment for `runuser -u armada` with `HOME=/var/home/armada`. Changing the device user requires editing the script.

## Changing a value
| To change | Edit | Redeploy |
|---|---|---|
| Speaker EQ bands | `tweaks/audio/50-thor-speaker-eq.conf` | `apply-all-tweaks.sh --audio` |
| Stick LED defaults or modes | `tweaks/lighting/stick-led-color.py` | `--lighting` |
| Per-game caps | `tweaks/game-profiles/build_game_tweaks.py` then regenerate | Manual copy (see [02 W7](02-users-workflows.md#w7---choose-per-game-profiles)) |
| Thor address | `local/thor.env` | none |
