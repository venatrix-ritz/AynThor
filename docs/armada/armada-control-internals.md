# Armada Control Internals
> Scope: how the Decky plugin `armada-control` is built and what it can do · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high, read from `decky/armada-control` at `574da80`. Fixed: the earlier text said RGB goes through a "universal LED driver" and controller switching "likely" uses InputPlumber; the code shows `armada-rgb` and a `controller-type` helper.

## Architecture
- **Frontend:** TypeScript built with Rollup against `@decky/api` 1.1.3 and `@decky/ui` 4.11.6; the build output goes to `/packages/decky-dist` and is copied into the image. [src: refs/upstream/armada@574da80:decky/armada-control/package.json#L9-L16; refs/upstream/armada@574da80:build_files/45-install-decky-plugins.sh#L16]
- **Backend:** Python `main.py` with a `Plugin` class; every RPC wraps its blocking work in `asyncio.to_thread(...)` "so a slow call can't stall Decky's asyncio loop". [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L34-L38]
- **Privilege split:** the plugin does not touch root-owned state itself; `privileged.call()` sends a JSON line over the Unix socket `/run/armada/control.sock` to the root helper `armada-control` (30 s timeout). [src: refs/upstream/armada@574da80:decky/armada-control/py_modules/armada_control/privileged.py#L1-L19]
- Modules under `py_modules/armada_control/`: `calibration`, `config`, `controller`, `fan_curves`, `fan_sensors`, `power`, `privileged`, `proc`, `rgb`, `steam`, `system`, `tweaks`. [src: refs/upstream/armada@574da80:decky/armada-control/py_modules/armada_control/]

## RPC surface (from `main.py`)
- **Config and games:** `get_config`, `get_installed_games`, `get_compat_mapped_appids`, `get_compat_applied` / `save_compat_applied`, `save_power_config`, `save_tweaks`. [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L36-L58]
- **System toggles:** `set_ssh_enabled`, `set_mtp_enabled`, `set_abl_auto_enabled`, `set_desktop_mode`, `set_sleep_mode`, `get/set_sleep_logs_enabled`, `reapply_perf`, `restart_game_mode`. [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L59-L94]
- **Bottom screen:** `get_bottom_screen_active`, `set_bottom_screen_enabled`, `set_bottom_screen_brightness`. [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L68-L76]
- **Controller:** `set_controller_type` (types: `deck-uhid` "Steam Deck", `xbox-series`, `xb360`, `ds5`, applied through `/usr/libexec/armada/controller-type`); calibration: `get_controller_state`, `begin/end_calibration_session`, `save_calibration`, `reset_calibration`. [src: refs/upstream/armada@574da80:decky/armada-control/py_modules/armada_control/controller.py#L1-L11; refs/upstream/armada@574da80:decky/armada-control/main.py#L95-L118]
- **RGB:** `get_rgb`, `set_rgb(enabled, color, saturation, brightness)`; the root helper runs `/usr/bin/armada-rgb`. [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L98-L103; refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-control#L24, #L504-L532]
- **Fans:** `get_fans_state`, `save_fan_curves`, `set_charging_fan_pwm`, `get_current_temp`. [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L119-L131]

The Thor surveyed 2026-10-03 had `/etc/armada/controller.conf` with `controller_type=xb360`; the file was still present on 2026-10-07. [observed 2026-10-03: docs/hardware/device-observed.md]

## Sources
- [S1] refs/upstream/armada@574da80:decky/armada-control/ and system_files/usr/libexec/armada/armada-control
- [S2] refs/upstream/armada@574da80:build_files/45-install-decky-plugins.sh
