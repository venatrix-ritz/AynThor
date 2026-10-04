# Armada OS — overview
> Scope: what Armada is, feature set, how the pieces fit, per the project's own docs · Researched: 2026-10-03 · Confidence: high

## Summary
- Armada is "SteamOS-like Linux for ARM handhelds": ARM64 Steam, FEX x86 translation, CachyOS Proton 11, KDE Plasma desktop, over-the-air updates, handheld power/fan controls. Built on **Fedora bootc**, device support derived from **ROCKNIX**. [src: refs/upstream/armadaos.dev@26dcfc3:docs/index.md]
- Credits: ROCKNIX (bootloader, device support, input mappings, audio profiles); Bazzite / Universal Blue (bootc image build structure, image-template, Steam/Gamescope session patterns); Fedora + bootc (base image/tooling). [src: refs/upstream/armadaos.dev@26dcfc3:docs/project/credits.md]
- License: GPL-2.0-or-later for Armada's code; bundled components keep upstream licenses. [src: https://github.com/armada-os/armada README via WebFetch — secondary]
- Status: "early preview"; OTA updates "new and still being validated"; native sleep "work-in-progress". [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/updating.md] [src: refs/upstream/armadaos.dev@26dcfc3:docs/using-armada/sleep-shutdown-and-battery.md]

## Feature list (as advertised)
| Feature | Doc statement | Thor? |
|---|---|---|
| Game Mode / Desktop | Boots to Game Mode; KDE desktop or Plasma Mobile on demand | yes |
| Performance | CPU/GPU clocks, core pinning, fan curves (Armada Control) | yes |
| Sleep/resume | S2idle "native" sleep (WIP); fake sleep selectable | yes |
| Devices | ">25 handhelds from AYN, Retroid, AYANEO" | Thor = Tested |
| **Dual screen** | "Use both screens in desktop mode, or run Plasma Mobile and dual screen emulators in Game Mode" | **Thor + Pocket DS** |
| HDR | supported games, "growing range of devices" | Thor per release notes ([release-history](release-history.md)) |
| External monitor | USB-C | [UNVERIFIED for Thor] |
| Armada Store | Decky plugin: emulators, apps, plugins | yes |
| Android apps | preinstalled Waydroid | yes |
| Dual boot | SD card, or internal alongside Android | yes |
| Updates | via Steam; rollback | yes |

[src: refs/upstream/armadaos.dev@26dcfc3:docs/index.md]

Normal play: install from Steam; FEX + Proton preconfigured; tuning in **Armada Control**. [src: refs/upstream/armadaos.dev@26dcfc3:docs/using-armada/index.md]

Related: [install-sd](install-sd.md) · [install-internal](install-internal.md) · [restore-android](restore-android.md) · [updating-ota](updating-ota.md) · [armada-control](armada-control.md) · [armada-store](armada-store.md) · [desktop-mode](desktop-mode.md) · [known-issues](known-issues.md) · [faq](faq.md) · [devices-ayn](devices-ayn.md)

## Sources
- [S1] refs/upstream/armadaos.dev@26dcfc3:docs/index.md, project/credits.md, using-armada/*.md (armada-os/armadaos.dev clone, taken 2026-10-02)
