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

## 2. 80% Battery Charge Ceiling Protection
> **Partly working, untested end to end (observed 2026-10-07, Armada `20261006.9c7dd3e`, kernel 7.2.6).** The firmware threshold path does not work: `charge_control_end_threshold` accepts a write but reads back `0`, and the old script logged `set to 80 (readback=0)` while reporting success. Armada's own kernel does carry an Armada-authored patch (`0903`) that exposes the battery manager's charge-current limit as the standard `constant_charge_current` attribute (writing `0` stops charging while the charger keeps powering the system), and the Thor has that attribute (`9000000` at 73 % charge, `4680000` at 96 %, `constant_charge_current_max` `9000000`: the firmware changes it itself, so the script remembers the value it found and restores exactly that rather than forcing the maximum). The script now clamps through it (`charge_control_limit` on the MgeeeeK fork). Not yet tried on the real battery. `--battery` only checks that a limit node exists and installs nothing otherwise; `--all` skips it. [src: refs/upstream/armada@574da80:packages/kernel/patches/0903-power-supply-qcom-battmgr-expose-the-charge-current-limit.patch]
- **Path:** `tweaks/battery/thor-charge-limit` & `thor-charge-limit.service`
- **Source:** MgeeeeK (`MgeeeeK/thor-armada` commits `a70010a` and `7e17352`).
- **Hardware Node:** `/sys/class/power_supply/battery/charge_control_end_threshold` and `charge_control_limit`.
- **Problem:** Continuous 100% trickle charging at elevated handheld operating temperatures (45-55°C) causes rapid battery degradation. Stock Armada OS does not expose a battery charge cap out-of-the-box (`charge_control_end_threshold = 0`).
- **Behavior:** Writes `charge_control_end_threshold = 80` and treats it as applied only if it reads back 80; if the kernel also exposes `charge_control_limit` it clamps charge current to 1000 µA at 80% (release below 78% or when unplugged). Exits 78 (service shown as failed, no retry) if the firmware rejects the threshold and no clamp node exists. **Not verified that charging really stops at 80%.**

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
./tweaks/apply-all-tweaks.sh --battery
./tweaks/apply-all-tweaks.sh --lighting
./tweaks/apply-all-tweaks.sh --system
./tweaks/apply-all-tweaks.sh --status
```

---

## Provenance note (added 2026-10-07 by an audit)
- `lighting/stick-led-color.py` is byte-identical to `system_files/usr/libexec/armada/stick-led-color` on **Ga1dz1's** `stick-rgb-lighting` branch (Ga1dz1/armada, a Retroid Pocket Mini V2 fork; git blob `f5852c7`; Armada's LICENSE.md puts original Armada scripts under GPL-2.0-or-later). It was not written for the Thor; credit is now in the script header and in item 3 above. Armada upstream already ships `packages/armada-rgb` with a Thor profile; running both would contend for the same LEDs.
- Re-checked on the Thor 2026-10-07: the firmware 80 % threshold does not work, the current-limit route (above) is untested; WoWLAN is supported and enabled on `phy0`; the display-sync daemon runs but its effect was not tested. See `docs/reference/open-questions.md`.
