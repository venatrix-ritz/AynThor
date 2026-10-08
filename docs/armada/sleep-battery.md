# Sleep and Battery Management (Armada OS)
> Scope: suspend modes, the fan while charging, and charge limiting on the Thor · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high where tagged; the unsourced parts of the earlier version were removed

## Suspend modes
- Armada offers two sleep modes in its control tool: `fake` (always available) and `s2idle` (only if the kernel advertises it in `/sys/power/mem_sleep`). Choosing `s2idle` writes it to `mem_sleep`. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-control#L185-L187, #L418-L425]
- The mode is stored as `suspend_mode=` in `/etc/armada/sleep.conf` and read back by `device-env`. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/device-env#L55-L56]
- On the Thor Max surveyed 2026-10-03 the config read `suspend_mode=s2idle`. [observed 2026-10-03: docs/hardware/device-observed.md] On build `20261006.9c7dd3e` `/etc/armada/sleep.conf` does not exist (`/etc/armada` holds `abl.conf`, `controller.conf`, `desktop-session`, `game-tweaks.json`, `power-profiles.conf`, `rgb.json`, `bottom-screen-brightness`, `sleep-debug-hook`). [observed 2026-10-07]
- Release `20260926` notes: lower sleep power use on SM8550/SM8650/SM8750 (most devices about 50 % less battery drain), faster Wi-Fi reconnect after wake, power-profile defaults changed, and optional sleep logs under `Documents/sleep-logs`. [src: refs/_gh/releases/20260926.json]
- A system-sleep hook gates the power key's wake source for a suspend started by a lid-close event. [src: refs/upstream/armada@574da80:system_files/usr/lib/systemd/system-sleep/50-armada-powerbutton-suspend#L1-L2]
- The user session holds a blocking inhibitor from `armada-powerbuttond` for `handle-power-key:handle-suspend-key:handle-lid-switch`, reason "Steam Game Mode handles power events". [observed 2026-10-07]

## Fan while charging
`armada-powerd` keeps a `charging_pwm` floor: while external power is online the fan target is raised to at least that value, both awake and suspended, and the value is also written to the fan hwmon's `pwm1_sleep_charging` so the kernel side can use it during sleep. The floor defaults to 0 and is editable in Armada Control. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-powerd#L830-L861; refs/upstream/armada@574da80:decky/armada-control/py_modules/armada_control/fan_curves.py#L270-L276]

## Charge limit (80 %)
- **Firmware threshold: does not work.** On Armada `20261006.9c7dd3e` (kernel 7.2.6) `charge_control_end_threshold` is `0` and a write of 80 reads back `0`. [observed 2026-10-07: docs/hardware/device-observed.md] Armada carries patches that expose more of the battery manager: charge unit and `CHARGE_NOW` (upstream submissions `0901`, `0902`), and an Armada-authored `0903` that exposes the firmware's charge-current limit as the standard `constant_charge_current` attribute, where writing `0` stops charging while the charger keeps powering the system. [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L389-L398; refs/upstream/armada@574da80:packages/kernel/patches/0903-power-supply-qcom-battmgr-expose-the-charge-current-limit.patch#L1-L8]
- The Thor shows `constant_charge_current` = `9000000` µA at 73 % charge and `4680000` at 96 % (unplugged, discharging), with `constant_charge_current_max` = `9000000`: the firmware changes the value itself. [observed 2026-10-07] So an 80 % cap through that attribute should be possible on stock Armada; whether it really stops charging at 80 % has **not been tested** on this Thor.
- The MgeeeeK/thor-armada fork exposes a charge-current limit under the name `charge_control_limit` and drives it from its own `thor-charge-limit` script (whether that is the same firmware control as patch 0903 was not compared). [src: refs/upstream/armada@7e17352:system_files/usr/libexec/armada/thor-charge-limit] This repo's `tweaks/battery/thor-charge-limit` adapts that script and clamps through whichever node exists. [src: tweaks/README.md]

## Sources
- [S1] refs/upstream/armada@574da80 (paths above), refs/upstream/armada@7e17352 (fork)
- [S2] refs/_gh/releases/20260926.json
- [S3] docs/hardware/device-observed.md (device surveys 2026-10-03/04 and 2026-10-07)
