# AYN Thor Global Device Tweaks, Fixes & Goodies (Armada OS)

Curated system enhancements for the **AYN Thor** running Armada OS. Most were taken from community repos and have not been verified on this Thor; the Thor was reset after the 2026-10-03/04 survey and has not been re-surveyed. See the provenance note at the bottom.

---

## 1. Speaker Acoustic Equalization (Audio Fix)
- **Path:** `tweaks/audio/50-thor-speaker-eq.conf`
- **Source:** adapted from AlsoAmphy's GraphicEQ string in RetroPup's JamesDSP preset (`AYN Thor Audio Fix.tar`, `ItsRetroPup/AYN-Thor-Tweaks`, no licence declared): same band centres, lighter gains, so not the original curve. See `CREDITS.md`.
- **Problem:** The Thor internal stereo speakers suffer from box resonance in the mid-range (600 Hz - 3.8 kHz) and harsh distortion from sub-bass overload (<80 Hz).
- **Solution:** A native PipeWire filter-chain virtual sink. It applies an 80 Hz high-pass and targeted cuts at 444 Hz (-5 dB), 700 Hz (-12 dB), 1.86 kHz (-15 dB), and 3.8 kHz (-16 dB) with a high-end lift (+3 dB at 11 kHz).
- **Behavior:** Operates at the PipeWire layer. Automatically disables when headphones are connected.

---

## 2. 80% Battery Charge Ceiling: now the Gleipnir plugin
Moved out of this folder on 2026-10-07. It is its own Decky plugin and repo, **Gleipnir** ([venatrix-ritz/Gleipnir](https://github.com/venatrix-ritz/Gleipnir), checked out at the git-ignored `plugins/gleipnir`), because it needs a root daemon, a UI and a safety test of its own.
- **Why a test comes first:** the firmware ignores the standard `charge_control_end_threshold` (reads back `0`), and AYN's Android 80 % node (`/sys/class/qcom-battery/limit_capacity_charge`) does not exist on Armada [observed 2026-10-07]. Armada's own kernel patch `0903` exposes the charge current limit as `constant_charge_current` (writing `0` is documented to stop charging while the charger powers the system), but nobody has shown the Thor's firmware obeys it. Gleipnir therefore stays watch-only until its built-in test (charging must stop while clamped *and* resume after release) passes on the running kernel. [src: refs/upstream/armada@574da80:packages/kernel/patches/0903-power-supply-qcom-battmgr-expose-the-charge-current-limit.patch]
- **Source:** adapted from MgeeeeK's `thor-charge-limit` (`MgeeeeK/thor-armada` commits `a70010a`, `7e17352`); see `CREDITS.md`.
- **Install:** `plugins/gleipnir/scripts/deploy.sh`, then Steam menu, Decky, Gleipnir, Install daemon, Run test.

---

## 3. Reactive Analog Stick RGB Lighting Engine
> **Conflicts with Armada's own RGB.** The Thor's LED chip is an HTR3212 (I2C `3-003c`), the chip this script targets. Armada's `armada-rgb` drives `rgb:l1..r4`, which are `leds_group_multicolor` groups of the same `l:*`/`r:*` channels (observed 2026-10-07), so the unit now carries `Conflicts=armada-rgb.service`. On the device `armada-rgb` is currently disabled in `rgb.json`; the clash starts when RGB is switched on in Armada Control. Not part of `--all`.
- **Path:** `tweaks/lighting/stick-led-color.py` & `armada-stick-led.service`
- **Source:** Ga1dz1 (`Ga1dz1/armada` commit `8eedf04`, branch `stick-rgb-lighting`) — written for the Retroid Pocket Mini V2, copied unmodified; not part of `--all` (see provenance note).
- **Hardware Node:** `/sys/class/leds/l:{r,g,b}{1-4}` and `/sys/class/leds/r:{r,g,b}{1-4}` (HTR3212 controller, 4 zones per stick ring).
- **Modes Supported:**
  - `battery`: Stick rings show battery level (Red < 20%, Yellow 20-60%, Green > 60%, pulsing while charging).
  - `reactive`: Deflection angle and throw distance control hue and brightness; button presses flash both rings.
  - `ambilight`: Samples screen edge colors off the DRM framebuffer (via `kmsgrab`) to dynamically match gameplay!
  - `rainbow` / `breathing` / `chase` / `static`: Highly configurable lighting animations.
  - `screen_link`: Scales stick brightness in sync with panel backlight.

---

## 4. System Sanitation & Desktop Dual-Screen Geometry
- **Path:** `tweaks/system/setup-device-fixes.sh`
- **Failed Unit Cleanup:** Masks `rpm-ostree-countme.timer` and its service. It was the only failed unit on the surveyed 20260926 install (`docs/hardware/device-observed.md`, observed 2026-10-03; the Thor has since been reset).
- **KWin layout check (read-only):** Warns if the saved `kwinoutputconfig.json` has the top panel (`DSI-2`) disabled or the bottom panel (`DSI-1`) ahead of it in priority. It never edits the file.

---

## Deployment

Deploy individually or all at once via `apply-all-tweaks.sh`:

```bash
# From Windows / Git Bash or WSL:
./tweaks/apply-all-tweaks.sh --all armada@<thor-ip>

# Or selectively:
./tweaks/apply-all-tweaks.sh --audio
./tweaks/apply-all-tweaks.sh --wowlan     # Wake-on-WLAN only
./tweaks/apply-all-tweaks.sh --lighting
./tweaks/apply-all-tweaks.sh --system
./tweaks/apply-all-tweaks.sh --status
```

---

## Provenance note (added 2026-10-07 by an audit)
- `lighting/stick-led-color.py` is byte-identical to `system_files/usr/libexec/armada/stick-led-color` on **Ga1dz1's** `stick-rgb-lighting` branch (Ga1dz1/armada, a Retroid Pocket Mini V2 fork; git blob `f5852c7`; Armada's LICENSE.md puts original Armada scripts under GPL-2.0-or-later). It was not written for the Thor; credit is now in the script header and in item 3 above. Armada upstream already ships `packages/armada-rgb` with a Thor profile; running both would contend for the same LEDs.
- Re-checked on the Thor 2026-10-07: the firmware 80 % threshold does not work, the current-limit route (above) is untested; WoWLAN is supported and enabled on `phy0`; the display-sync daemon runs but its effect was not tested. See `docs/reference/open-questions.md`.

## battery-monitor.py
Read-only logger for the battery and power state (`tweaks/battery-monitor.py`, run it on the Thor with `python3`). One JSON line per sample in `~/battery-logs/`: a full snapshot every 5 s (power supplies, hwmon, thermal, CPU, devfreq, backlight, USB-C, Wi-Fi, top processes, Gleipnir) and a 1 s battery-only line. It writes nothing to sysfs and is not part of `apply-all-tweaks.sh`.
