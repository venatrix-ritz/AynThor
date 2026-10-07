# Desktop Mode & The Dual Desktop Variants (KDE Plasma Desktop vs. Plasma Mobile)
> Scope: Desktop architecture, session switching, configuration isolation, and dual-screen display management in Armada OS · Researched: 2026-10-05 · Confidence: high (verified against `session-control`, `start-plasma-mobile`, `plasma-config-lib`, and `setup-dual-screen` in `refs/upstream/armada@574da80`)

## 1. Overview of the Two Desktop Environments
Armada OS packages two distinct Wayland desktop environments for handheld use:
1. **KDE Plasma Desktop (`armada-plasma.desktop`)**:
   * Traditional full-featured desktop environment powered by `startplasma-wayland`.
   * Intended for docked use with keyboard/mouse or precision trackpad control.
   * Standard KDE panel, window manager decorations, floating multi-window management, and multi-monitor layout.
2. **KDE Plasma Mobile (`armada-plasma-mobile.desktop`)**:
   * Touch-first mobile shell powered by `startplasmamobile` (`DESKTOP_SESSION=plasma-mobile`).
   * Packaged as a custom RPM (`plasma-mobile-6.7.4-1.fc44.armada`) patched with upstream KDE shell fixes.
   * Optimized for handheld touchscreen use: full-screen app drawer, swipe-down mobile quick settings, navigation gestures, and touch-friendly task switcher.

---

## 2. Session Switching & SDDM Autologin
Switching between Gaming Mode and Desktop Mode is managed by `/usr/libexec/armada/session-control`:
- When triggered via the Steam Power Menu ("Switch to Desktop"), `session-control switch-desktop` checks `/var/home/armada/.config/steamos-manager/state.toml`:
  - If `desktop_session = "armada-plasma-mobile.desktop"`, it selects Plasma Mobile.
  - Otherwise, it selects standard `armada-plasma.desktop`.
- It writes the selected session to the SDDM autologin override file:
  ```ini
  # /etc/sddm.conf.d/zz-holo-autologin.conf
  [Autologin]
  Session=armada-plasma.desktop  # (or armada-plasma-mobile.desktop / gamescope-session-steam.desktop)
  ```
- It purges `zz-steamos-autologin.conf`, resets failed systemd state for SDDM, and executes `systemctl --no-block restart sddm.service`.
- When switching back from Desktop Mode to Game Mode, `session-control switch-gamemode` calls `logout_plasma` (sending `org.kde.Shutdown.logout` via QDBus to gracefully shut down the Wayland session) before restarting SDDM.

---

## 3. Configuration Isolation (`plasma-config-lib`)
Because both desktop variants share the user's home directory (`~/.config`), they would normally collide on KDE's central `plasmashellrc`.
Armada solves this via `/usr/lib/armada/plasma-config-lib`:
- Before starting either session, `armada_plasma_activate_config <mode>` (`desktop` or `mobile`) is invoked.
- It dynamically manages two separate configuration targets:
  - `~/.config/plasmashellrc.desktop`
  - `~/.config/plasmashellrc.mobile`
- It creates an atomic symlink `~/.config/plasmashellrc -> plasmashellrc.<mode>`, guaranteeing that widget layouts, panels, and drawer settings from Plasma Mobile never overwrite or corrupt the standard desktop layout.

---

## 4. Dual-Screen Management in Desktop Mode
On the AYN Thor, Desktop Mode lights up **both AMOLED screens simultaneously**:
1. **Bootstrap Initialization (`desktop-bootstrap`)**:
   - Re-enables the bottom touchscreen (`bottom_touchscreen`), which is inhibited during single-screen Game Mode.
   - Waits for `kscreen-doctor` to become available on Wayland (up to 5 retries).
   - If marker files `desktop-rotation.done` and `desktop-scale.done` are absent, it applies rotation and scaling.
2. **Output Placement & Input Mapping (`setup-dual-screen`)**:
   - Queries KWin via `kscreen-doctor` to map `DSI-2` (top 1080×1920 120Hz) and `DSI-1` (bottom 1080×1240 60Hz).
   - Places `DSI-1` (bottom) directly below `DSI-2` (top), centered on the X-axis:
     - Top display: Priority 1, position `(0, 0)`, scale 1.5.
     - Bottom display: Priority 2, position `(418, 720)`, scale 2.8.
   - Binds each physical touchscreen to its corresponding display output using `/sys/class/input` sysfs matching, ensuring touch inputs on the bottom screen register at bottom coordinates and top touches register at top coordinates.

---

## 5. Game Mode Bottom Screen (Companion Mobile Session)
When the Thor is in Game Mode (primary Gamescope session holding `DSI-2`), the bottom screen can be driven independently:
- `armada-bottom-gamescope.service` leases `DSI-1` from the primary Gamescope via `/tmp/gamescope-lease.sock`.
- `armada-bottom-screen.service` launches `/usr/bin/armada-run-bottom -- /usr/libexec/armada/bottom-screen-session`.
- This runs an isolated instance of `plasmashell -p org.kde.plasma.mobileshell` directly inside the bottom leased Gamescope window, giving the user access to mobile widgets, app drawer, and media controls while gaming on the top display.

---

## Sources
- [S1] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/session-control`
- [S2] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/start-plasma-mobile`
- [S3] `refs/upstream/armada@574da80:system_files/usr/lib/armada/plasma-config-lib`
- [S4] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/desktop-bootstrap`
- [S5] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/setup-dual-screen`
- [S6] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/bottom-screen-session`
- [S7] `refs/upstream/armada@574da80:packages/plasma-mobile/BASE.env`
