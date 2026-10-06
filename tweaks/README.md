# AYN Thor Global Device Tweaks, Fixes & Goodies (Armada OS)

Curated, hardware-verified system enhancements and goodies for the **AYN Thor** running Armada OS.

---

## 1. Speaker Acoustic Equalization (Audio Fix)
- **Path:** `tweaks/audio/50-thor-speaker-eq.conf`
- **Source:** RetroPup & AlsoAmphy acoustic measurement profile (`AYN Thor Audio Fix.tar` from `ItsRetroPup/AYN-Thor-Tweaks`).
- **Problem:** The Thor internal stereo speakers suffer from box resonance in the mid-range (600 Hz - 3.8 kHz) and harsh distortion from sub-bass overload (<80 Hz).
- **Solution:** A native PipeWire filter-chain virtual sink. It applies an 80 Hz high-pass and targeted cuts at 444 Hz (-5 dB), 700 Hz (-12 dB), 1.86 kHz (-15 dB), and 3.8 kHz (-16 dB) with a high-end lift (+3 dB at 11 kHz).
- **Behavior:** Operates at the PipeWire layer. Automatically disables when headphones are connected.

---

## 2. 80% Battery Charge Ceiling Protection
- **Path:** `tweaks/battery/thor-charge-limit` & `thor-charge-limit.service`
- **Source:** MgeeeeK (`MgeeeeK/thor-armada` commits `a70010a` and `7e17352`).
- **Hardware Node:** `/sys/class/power_supply/battery/charge_control_end_threshold` and `charge_control_limit`.
- **Problem:** Continuous 100% trickle charging at elevated handheld operating temperatures (45-55°C) causes rapid battery degradation. Stock Armada OS does not expose a battery charge cap out-of-the-box (`charge_control_end_threshold = 0`).
- **Solution:** Daemon sets `charge_control_end_threshold = 80` in the PMIC and clamps charge current to 1000 µA once capacity hits 80%, releasing only when dropped below 77% or unplugged.

---

## 3. Reactive Analog Stick RGB Lighting Engine
- **Path:** `tweaks/lighting/stick-led-color.py` & `armada-stick-led.service`
- **Source:** Ga1dz1 (`Ga1dz1/armada` commit `8eedf04`).
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
- **Failed Unit Cleanup:** Masks `rpm-ostree-countme.timer`, eliminating the sole persistent failed systemd unit on Armada OS boots.
- **KWin Output Pinning:** Verifies `kwinoutputconfig.json` retains `DSI-2` (top panel) as primary output `0,0` and `DSI-1` (bottom panel) as secondary output `490,800`.

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
