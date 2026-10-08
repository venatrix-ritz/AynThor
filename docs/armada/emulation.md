# Emulation on Armada OS
> Scope: x86 translation (FEX) and Android app support on the Thor · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: high where tagged. Corrected: "guestos" is the FEX x86 rootfs, not an Android container; performance claims removed (no benchmark source).

## FEX-Emu (x86 and x86-64 on ARM64)
- Armada ships FEX and a pinned x86 RootFS: `ArchLinux.sqsh` is downloaded at image build time from `rootfs.fex-emu.gg` (SHA-256 checked) and `ArmadaMesa.sqsh` (x86 Mesa) is built from `packages/mesa-x86`. [src: refs/upstream/armada@574da80:build_files/30-install-steam-session.sh#L77-L83; refs/upstream/armada@574da80:build_files/40-vendor-system-files.sh#L13-L14]
- `armada-guestos.service` mounts both images read-only as loop devices (`/run/armada/guestos/rootfs` and `/run/armada/guestos/mesa`) and overlays them at `/usr/share/guestos/fex-mesa`, the path Steam's FEX compat tool hardcodes for the x86 Proton chain. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-guestos-mount#L1-L40] This matches the live mounts on the Thor. [observed 2026-10-07: docs/boot-kernel/partition-layout.md]
- FEX itself is packaged under `packages/fex` (upstream project: [FEX-Emu/FEX](https://github.com/FEX-Emu/FEX), MIT). [src: refs/upstream/fex-emu@f11c8c7:README.md]

## Android apps (Waydroid)
- Armada installs `waydroid` in the image, ships Mesa/Android vendor drivers under `/usr/share/armada/waydroid`, a keylayout for the Thor's gamepad (`Vendor_2020_Product_3001.kl`), and `armada-waydroid-input.service` to share InputPlumber controllers with Waydroid; `waydroid-container.service` is **disabled** by default. [src: refs/upstream/armada@574da80:build_files/10-base-packages.sh#L133; refs/upstream/armada@574da80:build_files/40-vendor-system-files.sh#L11, #L106, #L121; refs/upstream/armada@574da80:system_files/usr/lib/systemd/system/armada-waydroid-input.service#L2]
- The earlier text said `loop0`/`loop1` hold the Android rootfs and Mesa; that was wrong. The loop mounts are the FEX images above plus a separate `guestos-android.erofs` (14.9 MiB) whose purpose was not found in Armada's source. [observed 2026-10-07: docs/boot-kernel/partition-layout.md]
- Whether Android apps appear inside the Steam UI is not shown by any source here: `[UNVERIFIED]`.

## Emulators
Native emulators come from the Armada Store as Flatpaks (RetroArch, Dolphin, melonDS, PPSSPP, Flycast and others) with documented app paths under `/var/lib/flatpak/app/`. [src: refs/upstream/armadaos.dev@26dcfc3:docs/emulation/emulators.md#L9-L18; refs/upstream/armada@574da80:decky/armada-store/catalog.json#L1-L22] For the dual-screen DRM-lease melonDS/Azahar builds see `docs/armada/armada-store.md`.

## Sources
- [S1] refs/upstream/armada@574da80 (build_files/, system_files/usr/libexec/armada/armada-guestos-mount, decky/armada-store/catalog.json)
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/emulation/
- [S3] refs/upstream/fex-emu@f11c8c7
