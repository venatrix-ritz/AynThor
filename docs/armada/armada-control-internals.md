# Armada Control Internals
> Scope: Architecture of the Decky plugin rmada-control · Researched: 2026-10-03 · Confidence: high

rmada-control is the central Decky Loader plugin providing hardware configuration for Armada OS. It bridges the Steam UI to the underlying hardware and OS services.

## Architecture
- **Frontend**: React/TypeScript (built via Node during the image container build, placed in /packages/decky-dist).
- **Backend**: Python (runs within the Decky Loader Python environment). The main entry point main.py defines a Plugin class that exposes RPC endpoints via syncio.

## Features / Submodules
1. **Calibration**: Endpoints to start/stop controller calibration, read controller state, and save parameters.
2. **Controller (set_controller_type)**: Switches emulation modes (likely via InputPlumber interaction).
3. **Power**: Manages power profiles, translating UI choices into kernel sysfs limits.
4. **RGB**: Interfaces with the universal LED driver for the joysticks/shell LEDs.
5. **System & Display**:
   - ottom_screen_active, set_bottom_screen_brightness, set_bottom_screen_enabled: Manages dual-screen topology.
   - set_mtp_enabled, set_ssh_enabled: Toggles systemd services.
   - set_sleep_mode: Toggles sleep behaviors (e.g., s2idle vs deep).
6. **Fan Curves**: get_state, save_all, and save_charging_pwm. Interacts with fan sensors to allow custom thermal profiles, including setting minimum fan speeds while charging.
7. **Steam Integration**: compat_mapped_appids and installed_games to manage game-specific compatibility tools and tweaks.

## Concurrency
Blocking calls (like reading/writing sysfs or parsing Steam library states) are wrapped in syncio.to_thread() to prevent stalling Decky's main asyncio loop.
