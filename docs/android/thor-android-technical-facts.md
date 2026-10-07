# AYN Launcher and Android Technical Facts
> Scope: what is actually sourced about the stock Android side of the Thor · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: medium. The earlier version of this page described the stock launcher's bottom-screen widgets, display IDs and an "Android 11/12 Waydroid container" without sources; those parts were removed or corrected.

## AYN button and the stock launcher
- Community launchers cannot read the AYN button: Loki (Thor-Launcher) says the button's firmware "does not send anything an app can read", so it uses stick clicks instead. [src: refs/thor-android/Thor-Launcher@dcd74fa:README.md#L121]
- Thor Wayfinder can take over the AYN button for its quick panel, otherwise it opens "AYN's drawer", so a stock drawer exists. [src: refs/thor-android/thor-wayfinder@305d3ad:README.md#L116]
- What the stock launcher shows on each screen (widgets, stats, TDP toggles) is `[UNVERIFIED]`: no source in `refs/` documents it. Another doc here names `com.ayn…` as the bottom-screen home claimant, also without a source. [src: docs/android/dual-screen-on-android.md#L137]

## Displays on stock Android
- LineageOS's Thor device tree defines three display-layout states over two physical display addresses (`4630946441858561667`, default, and `4630946482288158084`): state 0 both on (second follows the first), state 1 first only, state 2 second only. [src: refs/thor-android/android_device_ayn_odin2thor@cc40a46:configs/display/display_layout_configuration.xml#L7-L33]
- The earlier "Top = Display 0, Bottom = Display 1" statement has no source and is dropped.

## Firmware
- A full stock ROM named `Thor_20251120_ota.zip` is shared through the XDA rooting thread (post #5); the root-guide repo records its SHA-256 (`5a18a649…e73a06`). [src: refs/thor-android/ayn-thor-root-guide@8eed02f:README.md#L18; refs/thor-android/ayn-thor-root-guide@8eed02f:data/Thor_20251120_ota.zip.sha256sum]
- The community Wi-Fi recovery tool is validated only on build `Thor_V1.0.0.377_20260206_165408_user` (the ".377" build). [src: refs/thor-android/AYN-Thor-WiFi-Recovery@2144afb:app/src/main/res/values/strings.xml#L23] That build is dated after the November 2025 ROM, so "the newest OTA is Thor_20251120" is not supported.

## Partitions
Android uses dynamic partitions inside `super` (`sda14`, 5.3 GiB). [observed 2026-10-07: docs/boot-kernel/partition-layout.md]

## Armada's "guestos" is not a Waydroid container
The earlier text claimed Armada boots a stripped Android 11/12 image from a loop device. On the Thor the loop mounts are an erofs image `guestos-android.erofs` (14.9 MiB) at `/usr/share/guestos/android` plus two FEX x86 RootFS squashfs images; what the erofs contains was not inspected. [observed 2026-10-07: docs/boot-kernel/partition-layout.md]; the FEX overlay wiring is in [src: refs/upstream/armada@574da80:build_files/30-install-steam-session.sh#L86-L95].

## Sources
- [S1] refs/thor-android/Thor-Launcher, thor-wayfinder, ayn-thor-root-guide, AYN-Thor-WiFi-Recovery, android_device_ayn_odin2thor (SHAs in `refs/MANIFEST.md`)
- [S2] refs/upstream/armada@574da80:build_files/30-install-steam-session.sh
- [S3] On-device `lsblk` / `mount`, 2026-10-07
