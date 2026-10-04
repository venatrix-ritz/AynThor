# AYN Launcher and Technical Facts
> Scope: Stock firmware launcher details and Android system facts · Researched: 2026-10-04 · Confidence: high

## AYN Launcher
The stock Android firmware includes AYN's custom home screen replacement.
- **Top Screen**: Acts as the standard Android home screen with a console-like app grid.
- **Bottom Screen**: AYN includes a proprietary widget panel that displays system stats (Battery, CPU/GPU utilization, Fan Speed) and quick toggles (TDP profiles, brightness).
- **AYN Button**: A physical button mapped at the system level to summon the AYN quick-access menu overlay or swap applications between screens.
- **Replacement**: Because the AYN Launcher's bottom screen implementation is proprietary, users who switch to third-party launchers (like Nova Launcher or CocoonFE) often lose the stock bottom-screen widgets unless they use community tools like DualScreen-Launcher to spawn apps there.

## Thor Android Technical Facts
- **Display IDs**: Top Screen = Display 0, Bottom Screen = Display 1.
- **System Partitions**: As mapped in the partition-layout.md, Android relies on dynamic partitions inside super (sda14). 
- **Stock Firmware Versions**: The most recent known OTA update string is Thor_20251120_ota.zip. The device shipped with a .377 Wi-Fi build string indicating its compile timestamp and baseline hardware revision. 
- **Waydroid (guestos) in Armada**: When Armada boots the Android container, it mounts the Android ootfs from a loop device, effectively running a stripped-down Android 11/12 image (often LineageOS based) rather than the heavy stock AYN firmware, saving resources for emulation.
