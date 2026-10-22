# 06 - Glossary

| Term | Meaning |
|---|---|
| AYN Thor | Dual-screen Snapdragon 8 Gen 2 handheld; the device all tweaks target |
| Armada OS | SteamOS-like ARM64 Linux image that runs on the Thor (`armada-os/armada`) |
| Armada Control | Armada's own control UI; the RGB page is the place `armada-rgb` is switched on (`tweaks/README.md`, section 3) |
| `armada-power` | Armada's CLI for power profiles, used by `profile-bench.py` |
| `armada-rgb` | Armada's RGB service for the Thor; conflicts with the stick LED daemon |
| bootc / OSTree | Image-based OS layers; `/etc` drift is checked with `ostree admin config-diff` (`docs/hardware/device-observed.md`) |
| `/var/local/bin` | Where the tweaks install their binaries on the device |
| DSI-1 / DSI-2 | Kernel connector names of the bottom and top panels (`tweaks/system/setup-device-fixes.sh`, `kwinoutputconfig.json` check) |
| CRTC | Display controller output; `crtc-0` is the top panel and `crtc-1` the bottom in the sync daemon |
| gamescope / `gamescopectl` | Armada's compositor; `gamescopectl` sends `drm_sleep_internal_screen` to one instance |
| `bl_power` | Backlight power state file; `0` on, `4` off |
| Fake suspend | Armada's software sleep; stick LED daemon checks `/run/armada/fake-suspend.active` |
| s2idle | Suspend-to-idle used by the Thor's kernel (`docs/hardware/device-observed.md`) |
| WoWLAN | Wake on Wireless LAN; here, the magic-packet wake of the Wi-Fi chip |
| Magic packet | Broadcast frame of 6 bytes `FF` followed by the target MAC repeated 16 times (102 bytes) |
| HTR3212 | 12-channel LED driver chip that drives the stick rings |
| evdev | Linux input event device; the stick LED daemon reads the gamepad through it |
| kmsgrab | ffmpeg capture of the DRM framebuffer, used for ambilight |
| PipeWire filter-chain | Audio graph module used for the speaker EQ |
| Decky | Decky Loader, the plugin host that Ratatoskr and Gleipnir install into (`CLAUDE.md`, "The two Decky plugins") |
| Ratatoskr | Bottom-screen trackpad and keyboard plugin (formerly Touch Master); separate repo |
| Gleipnir | 80 % battery ceiling plugin; separate repo, watch-only until its on-device test passes |
| Junction | Windows directory link used for `plugins/ratatoskr` and `plugins/gleipnir` |
| `refs/` | Gitignored upstream clones used as citation sources |
| Claim tag | `[src: ...]`, `[UNVERIFIED — ...]`, `[CONFLICT: ...]` or `[observed]` in docs (`docs/reference/CONVENTIONS.md`) |
| Lock file | `scripts/refs.lock.json`, the pinned SHAs for `refs/` |
| Dry run | Default mode of `cleanup-device.sh`; prints actions without changing the device |
