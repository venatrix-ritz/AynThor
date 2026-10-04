# Stock Android vs. Armada OS on the AYN Thor
> Scope: practical and architectural comparison between factory Android 13 and Armada OS for AYN Thor owners · Researched: 2026-10-04 · Confidence: high (grounded in device observation, upstream source, and community tooling)

## Comparison Matrix

| Domain | Stock Android 13 | Armada OS (Linux) |
|---|---|---|
| **OS Architecture** | Android 13 (AOSP with AYN OEM layer) | Fedora 44 bootc (`ghcr.io/armada-os/armada:beta`), OSTree deployment |
| **Kernel** | Downstream Qualcomm Android BSP kernel | Linux **7.2.6** aarch64 (ROCKNIX lineage + Armada patches) |
| **Primary Interface** | AYN Launcher, touch home, or community launchers (Loki, Cocoon) | SteamOS Game Mode (`gamescope-session-steam`) / KDE Plasma Desktop |
| **PC / Steam Gaming** | Experimental via Winlator / Mobox (high overhead, low compatibility) | **Native ARM64 Steam client**, FEX-Emu x86/x86_64 JIT, CachyOS Proton 11 |
| **Retro & Console Emulation** | Native Android APKs (Citra, melonDS, NetherSX2, Dolphin, Drastic) | Flatpaks, native Linux emulators, or Proton/Windows emulator builds |
| **Dual-Screen Handling** | Native `DisplayManager` multi-display; apps move via Wayfinder / auto-dim | Top screen direct KMS; bottom screen via DRM-lease gamescope or KWin desktop |
| **Input Subsystem** | Android input framework (AYN controller mapping) | `CONFIG_JOYSTICK_RSINPUT=m` + InputPlumber (virtual Xbox 360 / DualSense) |
| **Audio Pipeline** | Qualcomm vendor Audio HAL + stock tuning | ALSA/PipeWire HiFi sink; needs JamesDSP flatpak (`thor-armada-audio-fix`) for tuning |
| **Power Management** | Deep SoC sleep (`suspend-to-RAM`), fine-tuned Qualcomm thermal throttling | `s2idle` suspend; manual/performance governor profiles (higher baseline drain) |
| **System Mutability** | Read-only partitions; rooted via "Run script as root" in settings | Read-only container root; user-space tools in `~/.local/` / user Flatpaks / Decky |
| **Storage Footprint** | Occupies stock Android partitions (`super`, `metadata`, `userdata`) | Coexists on UFS: shrinks `userdata` to 50 GB, takes 890 GB for `ARMADA_ROOT` |
| **Dual-Boot Flow** | Boot default or selected in ABL | Selected in ROCKNIX ABL menu (hold VOL- at boot: Android / Linux) |

[src: docs/hardware/device-observed.md] [src: docs/android/community-tools.md] [src: docs/armada/overview.md] [src: docs/armada/dual-screen.md]

---

## Detailed Trade-offs

### 1. Gaming Capabilities & Target Libraries
- **Choose Android if:**
  Your primary focus is mobile gaming (Genshin Impact, Zenless Zone Zero, Call of Duty: Warzone), Google Play Store apps, and turnkey retro emulation (especially Android-optimized DS/3DS/PS2 emulators). Android's touch-first input and immediate app wake-up excel for quick casual sessions.
- **Choose Armada if:**
  You bought the Thor primarily as a miniature Steam Deck. Armada brings a full Steam Deck UI, cloud saves, achievements, and legitimate compatibility with hundreds of PC Steam titles running through FEX-Emu and Proton 11. It also provides a full Linux workstation environment in Desktop Mode.

### 2. Dual-Screen Experience
- **Android:**
  Android natively exposes both displays as standard system displays. Community apps like **Thor-Wayfinder** allow hotkey app swapping between screens (hold Back), per-game dual-screen shortcuts, and touch controls on the secondary display. Emulators like DraStic and Citra MMJ naturally span across both screens.
- **Armada OS:**
  In Game Mode, gamescope focuses solely on the top 120Hz display by default. Dual-screen gaming is experimental (introduced in release `20260907`), leveraging a secondary gamescope instance attached via a DRM lease socket. In Desktop Mode, both screens function seamlessly as an extended desktop with touch support, though window positioning must be managed by the compositor.

### 3. Battery Life, Sleep, and Thermals
- **Android:**
  Benefits from Qualcomm's production power management. Standby battery loss overnight is typically under 2–4%, and deep sleep reliably shuts down unused display and SoC rails.
- **Armada OS:**
  Uses `s2idle` suspend. While release `20260926` improved sleep drain by 50%, Linux standby still consumes significantly more battery than Android. On the "Performance" governor profile, the GPU is pinned at 680 MHz, pushing idle temperatures to ~48–53 °C and load temperatures over 73 °C.

### 4. System Maintenance & Customization
- **Android:**
  Can be rooted with Magisk without unlocking the bootloader via the stock firmware's hidden debug menu (`Settings → Thor settings → Run script as root`).
- **Armada OS:**
  Employs an immutable Fedora bootc container root (`/usr` is read-only). System updates occur atomically over the air (OTA) via Steam's settings menu or `bootc update`. System packages cannot be permanently installed via standard `dnf` or `bootc usroverlay` (which vanishes on reboot). Users extend the system via Decky plugins, user-level Flatpaks, or unpacking standalone binaries into `~/.local/opt/` with environment wrappers.

---

## Sources
- [S1] `docs/hardware/device-observed.md` (live device survey on Armada 20260926 / kernel 7.2.6)
- [S2] `docs/android/community-tools.md` and `docs/android/bootloader-root.md`
- [S3] `docs/armada/{overview.md, dual-screen.md, release-history.md, install-internal.md}`
- [S4] `refs/upstream/armada@574da80` (device confs and service units)
