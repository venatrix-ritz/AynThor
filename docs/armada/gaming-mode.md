# Gaming Mode and Desktop Mode (Armada OS)
> Scope: Game Mode (Gamescope + Steam UI), the bottom screen, and Desktop Mode on the Thor · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: high where tagged. Fixed: the earlier text had the screens' connector names swapped (the top screen is `DSI-2`, the bottom `DSI-1`).

## Screens
For the Thor, Armada's device profile sets the **primary (top) connector `DSI-2`** with backlight `ae96000.dsi.0` and the **secondary (bottom) connector `DSI-1`** with backlight `ae94000.dsi.0`; Gamescope drives only the top panel, the desktop session uses both; panel orientation is `right`; HDR peak is declared as 650 nits. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor.conf#L5-L17]

## Gaming Mode
- Game Mode is a Gamescope session running Steam; the user unit on the surveyed Thor is `gamescope-session-plus@steam.service`. [observed 2026-10-07: docs/hardware/device-observed.md]
- **Bottom screen:** a second Gamescope runs as a DRM-lease client of the main one (`--drm-lease-client <socket> --drm-lease-yield --expose-wayland --force-windows-fullscreen`), rotated with `--force-orientation` from the device profile, and refuses to start if the device has no secondary display or touchscreen. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/bottom-gamescope#L8-L32] On the Thor this was confirmed in the process list on 2026-10-03/04 (see `docs/armada/dual-screen.md`).
- Community launchers such as Barry Launcher use the same lease mechanism; see `docs/armada/community-guides.md`.
- Decky Loader and Armada's two plugins (`armada-control`, `armada-store`) are baked into the image; see `docs/armada/decky-plugins-and-branches.md`.

## Desktop Mode
- Reached from the Steam power menu. [src: refs/upstream/armadaos.dev@26dcfc3:docs/using-armada/desktop-mode.md]
- The surveyed Thor's saved KWin layout had both panels enabled in Desktop Mode (`DSI-2` priority 1 at 0,0 and `DSI-1` priority 2 at 418,720) and `/etc/armada/desktop-session` = `desktop`. [observed 2026-10-07: docs/hardware/device-observed.md]
- A desktop entry `armada-return-to-gamemode` runs `steamos-session-select gamescope`. [src: refs/upstream/armada@574da80:system_files/usr/share/applications/armada-return-to-gamemode.desktop#L6]
- Emulators and apps are installed as Flatpaks under `/var/lib/flatpak/app/...`. [src: refs/upstream/armadaos.dev@26dcfc3:docs/emulation/emulators/retroarch.md#L38] That `/usr` is read-only and non-persistent across updates (a bootc/ostree image) is the design as the docs describe Armada, but no source line in `refs/` says so directly: `[UNVERIFIED]`.

## Sources
- [S1] refs/upstream/armada@574da80 (ayn-thor.conf, bottom-gamescope, return-to-gamemode)
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/using-armada/desktop-mode.md
- [S3] docs/hardware/device-observed.md
