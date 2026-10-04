# HDR, RGB, Fan, and Power Profiles (Armada OS)
> Scope: System daemons and kernel interaction for power and thermal management · Researched: 2026-10-03 · Confidence: high

Armada provides deep integration with Steam's native UI by translating standard `SteamOSManager1` DBus calls into Qualcomm-specific kernel interactions.

## Power Management (`armada-powerd`)
The `armada-powerd` service (`/usr/libexec/armada/armada-powerd`) is a Python DBus daemon that exposes `com.steampowered.SteamOSManager1.PerformanceProfile1`.
- It maps Steam's TDP and performance profiles to three modes: `eco`, `balanced`, and `performance`.
- It implements `armada_perf` scaling, modifying Linux CPU scaling governors (`sysfs`), GPU clock speeds, and thermal trip points.
- **Sleep & Battery**: Supports `s2idle` for deep power cut during sleep. Charging profiles integrate with kernel Battery Manager (`battmgr`), and there are hooks to allow `armada-control` to set battery limits (like the 80% charge limit patch).

## Thermal and Fan Management
The device relies on a custom fan curve mapping:
- Managed via `armada-control`'s `fan_curves.py` and `fan_sensors.py`.
- **Charging PWM**: A specific feature allows setting a minimum fan speed while the device is charging (`save_charging_pwm`) to prevent thermal runaway when the battery gets hot under charge.
- Reads `sysfs` thermal zones for SoC and Battery to dynamically adjust PWM output.

## HDR & Display
- **Direct Scanout**: Recent Armada updates added support for HDR direct scanout on the SM8550. This allows Gamescope to bypass composition and directly present HDR content to the primary OLED panel (Chipone ICNA3520), minimizing latency and saving power.

## RGB Controls
- **Universal LED Driver**: The joysticks and shell LEDs are controlled via the `armada_control.rgb` backend. It likely writes to the `leds` subsystem in `sysfs` to map user-selected colors from the Decky plugin to the hardware LED controllers.
