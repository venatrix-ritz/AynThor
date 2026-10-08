# Dual-screen dimming and sleep (why only the top screen dims)
> Scope: what dims and sleeps each Thor panel, and how Ratatoskr mirrors the dim · Researched: 2026-10-07 · Confidence: medium (source + journal evidence; the mirror itself is untested on the device)

## Summary
- **Steam dims only the top panel.** Armada deliberately steers every Steam backlight write to the primary panel (`ae96000.dsi.0` on the Thor), so the bottom panel (`ae94000.dsi.0`) never follows. [src: refs/upstream/armada@574da80:system_files/usr/bin/steamos-polkit-helpers/steamos-priv-write#L75-L98] [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor.conf#L9-L12]
- **The dim delay is a Steam setting**, read here from `~/.local/share/Steam/config/config.vdf`: `IdleBacklightDimBatterySeconds` = 300 and `IdleBacklightDimACSeconds` = 0 (never) on the surveyed Thor. [observed 2026-10-07]
- **What Steam's dim looks like** (journal tag `armada-steamos-priv-write`, which logs each write): a burst of about 265 writes ramping the 0-255 value from 254 down to 7, starting **exactly 300 s** after the previous wake (15:50:55 then 15:55:55; 15:59:08 then 16:04:08), and a jump back to about 255 on the next input. [observed 2026-10-07]
- **Sleep is separate and already covers both screens by design:** Armada's fake-suspend sends `drm_sleep_internal_screen` to every gamescope instance in the session (the top one and the bottom lease client), and falls back to `bl_power` on every backlight. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/fake-suspend#L42-L68] Not confirmed by a test on the Thor. [UNVERIFIED]
- **Neither backlight is user-writable on stock Armada** (`-rw-r--r-- root root`); the udev ACL helper withholds the grant on multi-panel devices so Steam keeps going through the steering helper. [observed 2026-10-07] [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/backlight-acl#L2-L13] Anything that sets the bottom backlight from the user session therefore needs root: Ratatoskr falls back to `sudo -n tee <file>`, and ships an optional narrow sudoers fragment for exactly the two backlight files.

## Details
**Mirror design (Ratatoskr, opt-in `mirror_dim`).** It cannot ask Steam when it dims, and a user-writable backlight would make Steam write the wrong panel, so it reproduces the timer instead:
1. Read the delay for the current power source from `config.vdf` (battery vs charging/full; 0 = never), re-read every 10 s.
2. Track idle time from input on every readable input device (buttons, sticks past 25 % deflection, triggers, hat, mouse, the top touchscreen), plus the grabbed bottom touchscreen, which the app reports itself.
3. After the delay, fade the bottom panel to `mirror_dim_floor_percent` (default 3 %); on the next input restore the level it had. It never writes Armada's saved bottom-screen level, backs off for a minute if the backlight is not writable, and logs `DBG-610` lines, including every time the **top** backlight really drops, so the timer can be compared with Steam.
4. Why 3 %: Steam's observed dim floor was 7/255, about 2.7 %.

**What is not known.** Whether the idle tracker sees the same activity Steam does (Steam's own idle source is not in any clone); whether the dim ramp length or floor changes with other settings; the mirror has not been run on the device. Compare the `DBG-610` log lines against the top panel on a battery run before trusting the timing.

**Superseded:** `tweaks/system/thor-display-sync` (a polling daemon that copied the top panel's DRM active state to the bottom one) addressed sleep rather than dim, and its effect was never tested. Stock fake-suspend already sleeps every gamescope instance, so it is not part of the re-apply set.

## Sources
- [S1] refs/upstream/armada@574da80: `steamos-priv-write` backlight steering (`steamos-priv-write`), `backlight-acl`, `devices/ayn-thor.conf`, `fake-suspend`
- [S2] Journal of `armada-steamos-priv-write` and `~/.local/share/Steam/config/config.vdf` on the Thor, read over SSH 2026-10-07 (read-only)
- [S3] Gamescope patches `0015` (blank a leased connector on release) and `0023` (power down an idle lease companion) in refs/upstream/armada@574da80:packages/gamescope/patches/
