# 02 - Algorithms and protocols

## Display sleep sync
Source: `tweaks/system/thor-display-sync.py`. Status: superseded per `docs/armada/dual-screen-dimming.md` line 20, still deployed by `--system` (see [05](05-device-constraints-decisions.md)).

**Input.** The debugfs DRM state file `/sys/kernel/debug/dri/0/state` (`STATE_FILE`, line 14). `get_crtc_states()` (lines 58-69) runs two regexes, `crtc\[\d+\]:\s*crtc-0.*?active=(\d+)` and the same for `crtc-1`, both with `re.DOTALL` (lines 19-20).

**Defaults.** A missing match or a read error returns `active=1` for both CRTCs (lines 65-69). A read error therefore reads as "awake".

**Loop.** Every 0.5 s (`time.sleep(0.5)`, line 114):

| Condition | Action |
|---|---|
| `top_active` changed to 0 | If `/run/user/1000/gamescope-1` exists: `gamescopectl drm_sleep_internal_screen 1` for instance `gamescope-1`. Then write `4` to `bl_power` (`set_secondary_backlight_power`) |
| `top_active` changed to 1 | Write `0` to `bl_power`. Then, if the socket exists, `gamescopectl drm_sleep_internal_screen 0` |
| `top_active == 0` and `bottom_active == 1` (no top change this tick) | Repeat the sleep actions. This branch runs on every tick while the mismatch persists |

Sleep order is gamescope first, then backlight. Wake order is backlight first, then gamescope.

**Command execution.** `gamescopectl` runs through `runuser -u armada -- env ...` with `HOME=/var/home/armada`, `XDG_RUNTIME_DIR=/run/user/1000` and `GAMESCOPE_WAYLAND_DISPLAY=<sock>`, with a 3 s timeout. Output is discarded (lines 23-45).

**Regex note.** `.*?` with `DOTALL` lets a `crtc-0` header match before its own `active=` field, so the captured value may belong to a later block if `crtc-0`'s block lacks one. **UNVERIFIED** against a real debugfs dump; the code assumes each block has an `active=` line.

## Stick LED state machine
Source: `tweaks/lighting/stick-led-color.py`. Copied unmodified from an Armada fork, comment header lines 2-7.

**Daemon loop** (`run_daemon`, line 614). Each iteration:
1. If `/run/armada/fake-suspend.active` exists (`SUSPEND_FLAG`, line 72): close the evdev and ambilight handles, set all LEDs to 0, reset phases, sleep `SUSPEND_POLL_INTERVAL` (0.5 s), continue.
2. Otherwise `load_state()` reads `/etc/armada/stick-led.conf`, so a `set-*` CLI call takes effect on the next tick.
3. `scale = screen_scale()` if `screen_link` is on, else 1.0.
4. Compute colour for the mode, write to LEDs.

**Tick periods** (from the module docstring, lines 47-49): `IDLE_INTERVAL = 5.0` s for `static` and battery modes; `BREATH_INTERVAL = 0.05` s for animated modes (`ANIMATED_MODES`, line 78).

**LED write.** `write_zone(side, zone, r, g, b)` (lines 501-510) writes `r`, `g`, `b` to `/sys/class/leds/<side>:<chan><zone>/brightness` for side in `l, r`, zone in `1..4`, with values clamped to 0-255 and rounded.

**Battery colour** (`battery_rgb`, lines 569-593):

| Battery state | RGB |
|---|---|
| `Charging` or `Full` | (0, 200, 0) |
| capacity >= 50 | (255 * (1 - t), 200, 0), t = (cap - 50) / 50 (green to yellow) |
| capacity < 50 | (255, 200 * t, 0), t = cap / 50 (yellow to red) |
| No battery found | (0, 80, 255) |

**Reactive mode** (`stick_reactive_rgb`, lines 274-281, deadzone line 271):
- Stick position `(x, y)` normalised to [-1, 1] from the device's `ABS` range (`ranges`, default -32768..32767).
- `magnitude = min(1, hypot(x, y))`. Below `REACTIVE_DEADZONE = 0.12`, output is black.
- `hue = (atan2(y, x) mod 2pi) / 2pi`; full-saturation HSV at value 1.
- `travel = (magnitude - 0.12) / 0.88`; `level = floor + (1 - floor) * travel`, where floor is `intensity` (default 0.15).
- Output = HSV RGB * 255 * level.
- Button flash: an `EV_KEY` press with value 1 sets `flash = 1.0`. `tick_decay` multiplies by `FLASH_DECAY = 0.72` per tick and clears below 0.02. Button codes map to names through `FLASH_BUTTON_CODES` (lines 145-162); unknown codes fall into `other`.

**Ambilight mode** (lines 298-332, sampler class from line 349):
- One long-lived `ffmpeg -f kmsgrab -device <card> -i - -r 2 ...` process at `AMBILIGHT_CAPTURE_FPS = 2`.
- Filter graph: `hwdownload,format=x2rgb10le,format=bgr0`, split into two strips. Left strip: `crop` width 100 px at x = 10 px. Right strip: width 100 px at x = `iw - 10 - 100`. Both: y = 40 % of height (`AMBILIGHT_TOP_EXCLUDE`), height = 55 % (100 - 40 - 5), with 5 % bottom excluded. Each strip `scale`d to 4x4, then `hstack`.
- Output frame: 8x4 pixels, BGRA, `AMBILIGHT_FRAME_SIZE = 128` bytes.
- Per-stick colour: average of the strip's pixels (`_average_region`). The colour moves toward the sample by `s = min(0.9, AMBILIGHT_SMOOTHING * speed)` per sample, with `AMBILIGHT_SMOOTHING = 0.35` (line 304) and the blend in `sample()` (line 431).
- Default colour when no sample: (0, 80, 255).
- DRM card: the first sorted `/dev/dri/card*` (`drm_card_path`, lines 314-319). The comments say the card is not reliably `card0`.

**Screen link** (`screen_scale`, lines 485-498). Brightness divided by max brightness of the first sorted `/sys/class/backlight/*` entry. Scales the final colour.

## WoWLAN magic packet
Sources: `scripts/wake-thor.py` (`wake_thor`), `scripts/wake-thor.ps1`, `tweaks/system/thor-wowlan`.

**Packet** (102 bytes): 6 bytes of `0xFF`, followed by the 6-byte target MAC repeated 16 times. The MAC is stripped of `:` and `-`; anything other than 12 hex digits is rejected (`wake_thor` raises `ValueError`).

**Transport.** UDP datagram to the broadcast address on port 9. Python sets `SO_BROADCAST`. The packet is sent twice in a row (Python) or twice with 100 ms between (PowerShell).

**Device side** (`thor-wowlan`):
1. Wait up to `THOR_WAIT_S` (default 60) seconds for a phy. The phy is found by parsing `iw dev` (`phy#N` then `Interface`).
2. `iw phy <phy> info` must mention `wowlan`, else exit 78.
3. `iw phy <phy> wowlan enable magic-packet`.
4. Read back `iw phy <phy> wowlan show` and require the text `magic packet`.

The NetworkManager profile `90-wowlan.conf` sets `wifi.wake-on-wlan=0x8` for `type:wifi`. The 0x8 value is the magic-packet flag in NetworkManager's enum; **UNVERIFIED** in the repo (no source is cited).

## Speaker EQ
Source: `tweaks/audio/50-thor-speaker-eq.conf`. A PipeWire `libpipewire-module-filter-chain` with five chained biquads and a high-pass.

| Node | Label | Freq (Hz) | Q | Gain (dB) |
|---|---|---|---|---|
| `eq_band_70` | `bq_highpass` | 80 | 0.707 | (none) |
| `eq_band_444` | `bq_peaking` | 444 | 1.2 | -5.0 |
| `eq_band_700` | `bq_peaking` | 700 | 1.0 | -12.0 |
| `eq_band_1860` | `bq_peaking` | 1860 | 1.0 | -15.0 |
| `eq_band_3800` | `bq_peaking` | 3800 | 1.2 | -16.0 |
| `eq_band_11k` | `bq_peaking` | 11000 | 0.7 | +3.0 |

Links run in series from `eq_band_70:Out` to `eq_band_11k:In`. The graph is declared stereo with `audio.channels = 2` and `audio.position = [ FL FR ]`. The file has no comment explaining the stereo routing, and it declares no explicit `In`/`Out` port nodes. (A mono-collapse rule appears in a hub note, not in this file.)

**Not in the file:** the README says the EQ "automatically disables when headphones are connected" (`tweaks/README.md` section 1). No logic for that exists in the repo (**UNVERIFIED**, probably not implemented here).

## Per-game caps
Source: `tweaks/game-profiles/build_game_tweaks.py`, output `game-tweaks.json`.

| Tier | Count | Fields |
|---|---|---|
| Heavy | 13 | `fexProfile: default`, `cores: big`, `DXVK_FRAME_RATE` and `VKD3D_FRAME_RATE` = 40 |
| Medium | 17 | `fexProfile: default`, `cores: big`, both = 60 |
| Light | 34 | `fexProfile: default` only |

Counts checked against `game-tweaks.json`: 64 `fexProfile` entries, 30 `cores: big`, 13 entries at 40, 17 at 60. The tier choice is judgement (`tweaks/game-profiles/README.md`). The frame caps only affect DXVK and VKD3D (Proton) titles, per that README.

## Battery and power logging
Source: `tweaks/battery-monitor.py`.

| Record | Period | Content |
|---|---|---|
| `"k":"full"` | 5 s | Every attribute of every `/sys/class/power_supply/*`, hwmon readings, thermal zones, CPU frequency and utilisation (delta of `/proc/stat` idle over total), devfreq, backlights, lit LEDs, Type-C ports, Wi-Fi counters, memory, suspend counters, top 6 processes, Gleipnir unit state |
| `"k":"fast"` | 1 s | `capacity`, `status`, `charge_type`, `current_now`, `voltage_now`, `power_now`, `temp`, `constant_charge_current`, `charge_now`, time estimates, USB online and current |

## Profile and system benchmarks
- `profile-bench.py`: for each profile, `armada-power profile NAME`, wait until the hottest CPU thermal zone (zone names starting `cpu`, `hottest(zones(), "cpu")`) is at or below 52 C (max 300 s), then run 8 workers hashing 64 KB blocks with SHA-256 for the duration (default 240 s). Sample every 10 s. Power in W = `voltage_now * current_now / 1e12` (microvolts times microamps). Stops on CPU >= 95 C or battery >= 45 C. Restores the original profile in `finally`.
- `system-bench.py`: memory copy with 256 MiB buffers (1 thread, then 4 processes); sequential reads of 1 MiB with `O_DIRECT` at a random offset in the first 200 GiB of the disk, for each I/O scheduler; Wi-Fi latency test with power save on and off. Restore behaviour **UNVERIFIED** (not traced).
