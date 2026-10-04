# Dual-screen implementation (AYN Thor)
> Scope: how Armada drives the Thor's two panels, from the source at `574da80` · Researched: 2026-10-03 · Confidence: high for what the scripts/units do; behaviour on hardware not observed [UNVERIFIED on-device]

Paths below are relative to `refs/upstream/armada@574da80:system_files/usr/` unless noted.

## Summary
- The Thor is described in one device-conf file: **top panel = DSI-2** (backlight `ae96000.dsi.0`, touch `top_touchscreen`) is primary; **bottom panel = DSI-1** (backlight `ae94000.dsi.0`, touch `bottom_touchscreen`) is secondary; panel orientation `right`; virtual keyboard pinned to DSI-1; HDR nits 650. The conf comment says Gamescope drives only the top panel and the desktop session uses both. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor.conf#L1-L17]
- Thor Lite's conf puts the virtual keyboard on **DSI-2** instead (the two models' panel wiring differs). [src: refs/upstream/armada@574da80:tests/thor-virtual-keyboard-test.sh#L16-L17]
- Dual-screen capability is **config-driven**: any device that sets `ARMADA_SECONDARY_CONNECTOR` + `ARMADA_SECONDARY_TOUCHSCREEN` gets it (Armada Control checks exactly those two keys; `bottom-gamescope` fails with "device has no secondary display" if unset). [src: refs/upstream/armada@574da80:decky/armada-control/py_modules/armada_control/config.py#L47] [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/bottom-gamescope#L14-L16]

## Desktop mode: both screens
1. `desktop-bootstrap` first re-enables the secondary touchscreen (Game Mode inhibits it — "the desktop is the only session that lights up the secondary panel"). [src: system_files/usr/libexec/armada/desktop-bootstrap#L28-L32]
2. It waits for `kscreen-doctor` (5 tries × 2 s), sets rotation and scale on the primary connector once (marker files under `~/.config/armada` prevent re-running), then — if a secondary connector exists — runs `setup-dual-screen`. [src: system_files/usr/libexec/armada/desktop-bootstrap#L47-L75]
3. `setup-dual-screen` (Python) places the secondary output **below the primary, centered**, makes the primary the priority-1 output, and pins each touchscreen to its own output (matching by input-device name/vendor/product via `/sys/class/input`) so taps land on the screen touched. [src: system_files/usr/libexec/armada/setup-dual-screen#L1-L8]

## Game Mode: bottom screen via DRM lease
- `armada-bottom-gamescope.service` (user unit) is `Wants`-ed by the Steam gamescope session drop-in; its `ExecCondition` runs `bottom-gamescope --supported`, so non-dual devices skip it silently. [src: system_files/usr/lib/systemd/user/armada-bottom-gamescope.service#L7-L8] [src: system_files/usr/lib/systemd/user/gamescope-session-plus@steam.service.d/30-armada-gamescope.conf#L2]
- `bottom-gamescope` launches a second **gamescope** with `--backend drm --drm-lease-client $GAMESCOPE_LEASE_SOCK(/tmp/gamescope-lease.sock) --drm-lease-yield --expose-wayland --force-windows-fullscreen --xwayland-count 1 --default-touch-mode 4 --force-orientation $ARMADA_PANEL_ORIENTATION --force-composition-rotation`, running `bottom-gamescope-ready`. It aborts if the lease socket is missing ("DRM lease socket is unavailable"). [src: system_files/usr/libexec/armada/bottom-gamescope#L18-L31]
  - Reading: the main gamescope owns the top panel and *leases* the bottom connector to the second gamescope over a socket; "yield" lets the lease be handed back [UNVERIFIED — inferred from flag names; gamescope source not read].
- `armada-bottom-screen.service` is `PartOf/Wants/After` the bottom-gamescope unit (the thing that runs on the bottom screen). [src: system_files/usr/lib/systemd/user/armada-bottom-screen.service#L3-L5] `bottom-screen-session` exports `XDG_CONFIG_DIRS` pointing at `~/.config/plasma-mobile` before starting the session. [src: system_files/usr/libexec/armada/bottom-screen-session#L32]
- Release 20260907 describes the result: Plasma Mobile on the bottom screen launched from Armada Control, persistent brightness, and DRM-leasing builds of melonDS/Azahar in the Store; 20260926 fixed "bottom screen Gamescope startup during display handoff". [src: refs/_gh/releases/20260907.json] [src: refs/_gh/releases/20260926.json]

## Plasma Mobile session
`armada-plasma-mobile.desktop` → `start-plasma-mobile` (sets `DESKTOP_SESSION=plasma-mobile`, `exec startplasmamobile`); Armada packages its own `plasma-mobile` RPM built from Fedora SRPM `plasma-mobile-6.7.4-1.fc44` with a patch sourced from an invent.kde.org commit. `armada-control` maps `"mobile"` ↔ that session file; `steam-default-session` can choose it as the default. [src: system_files/usr/share/wayland-sessions/armada-plasma-mobile.desktop#L4] [src: system_files/usr/libexec/armada/start-plasma-mobile#L11-L22] [src: refs/upstream/armada@574da80:packages/plasma-mobile/BASE.env#L1] [src: refs/upstream/armada@574da80:packages/plasma-mobile/PATCHES.md#L8] [src: system_files/usr/libexec/armada/armada-control#L43] [src: system_files/usr/libexec/armada/steam-default-session#L11]

## Related
- Virtual keyboard test and Thor conf consistency: `tests/thor-virtual-keyboard-test.sh`.
- Open dual-screen issues/PRs (brightness, Armada Trackpad, nested gaming, HDR): [thor-issues-and-prs](thor-issues-and-prs.md), [thor-changelog](thor-changelog.md).
- Kernel side (two DSI panels in the devicetree): [devicetree-thor](../boot-kernel/devicetree-thor.md).

## Sources
- [S1] refs/upstream/armada@574da80 (files cited inline), refs/_gh/releases/20260907.json, 20260926.json
