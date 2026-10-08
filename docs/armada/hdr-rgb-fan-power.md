# HDR, RGB, Fan and Power Profiles (Armada OS)
> Scope: Armada's power daemon, fan handling, RGB tool and HDR on the Thor · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high where tagged. Removed from the earlier version: "hooks for the 80 % charge limit" in `armada-powerd` (none exist), "likely" RGB behaviour, and HDR "direct scanout" (only a branch name supports that).

## Power (`armada-powerd`)
- A Python D-Bus daemon on the system bus: name `org.armada.Power`, interface `org.armada.Power1`; it also implements Steam's `com.steampowered.SteamOSManager1.PerformanceProfile1`, `GpuPerformanceLevel1` and `CpuScaling1`, which is how the Steam UI controls it. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-powerd#L19-L24]
- Profiles are `eco`, `balanced`, `performance`; each profile in `/etc/armada/power-profiles.conf` sets a CPU governor, an optional CPU underclock and a fan curve. The GPU is driven through the `*.gpu` devfreq node. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-powerd#L28, #L347-L353, #L433-L437]
- `armada-power status` on the Thor (2026-10-03/04) showed `profile=Performance`, GPU pinned at 680 MHz. [observed: docs/hardware/device-observed.md]
- There is no charge-limit code in `armada-powerd`; the 80 % question is in `docs/armada/sleep-battery.md`.

## Fans
- Fan curves and sensors are handled in `armada-control`'s `fan_curves.py` / `fan_sensors.py`; `charging_pwm` sets a minimum PWM while external power is online, and `armada-powerd` applies it awake and asleep. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-powerd#L830-L861; refs/upstream/armada@574da80:decky/armada-control/py_modules/armada_control/fan_curves.py#L270-L276]
- Observed: fan RPM readable (about 2044 RPM at the time). [observed 2026-10-03/04: docs/hardware/device-observed.md]

## RGB
- `armada-rgb` (Rust, `packages/armada-rgb`) controls LEDs exposed as Linux multicolor or per-channel LEDs, loads a per-model profile from `/usr/share/armada-rgb/profiles.json`, and saves settings to `/etc/armada/rgb.json`. [src: refs/upstream/armada@574da80:packages/armada-rgb/README.md#L1-L25]
- For `AYN Thor` the profile is the multicolor backend with targets `rgb:l1..l4`, `rgb:r1..r4`. [src: refs/upstream/armada@574da80:packages/armada-rgb/profiles.json#L1-L30] On the Thor those are `leds_group_multicolor` groups of the raw `l:*`/`r:*` channels (HTR3212 chip). [observed 2026-10-07: docs/hardware/device-observed.md]
- `armada-rgb.service` was enabled but inactive and `rgb.json` had `"enabled": false` on 2026-10-07. [observed]

## HDR
- Release notes: experimental HDR from `20260806`/`20260817`; `20260907`: "Added HDR support for the AYN Thor" and a fix for dim SDR / clipped HDR highlights. [src: refs/_gh/releases/20260806.json; refs/_gh/releases/20260817.json; refs/_gh/releases/20260907.json]
- The Thor's device profile declares `ARMADA_HDR_NITS=650`. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor.conf#L16]
- The repo has a branch named `hdr-direct-scanout`, but nothing here shows what shipped from it. [src: refs/_gh/branches.json]

## Sources
- [S1] refs/upstream/armada@574da80 (armada-powerd, armada-control, armada-rgb, devices/ayn-thor.conf)
- [S2] refs/_gh/releases/*.json, refs/_gh/branches.json
- [S3] docs/hardware/device-observed.md
