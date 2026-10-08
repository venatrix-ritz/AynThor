# The ROCKNIX Relationship
> Scope: how Armada relates to ROCKNIX · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high where tagged. Fixed: the dts file name, and the unsourced description of ROCKNIX's rootfs.

Armada says its device support was adapted from ROCKNIX: kernel patches, input mappings, audio profiles, firmware layout and the bootloader. [src: refs/upstream/armada@574da80:LICENSE.md#L24-L26] Armada's credits page lists ROCKNIX first for "bootloader, device support, input mappings, audio profiles, and more". [src: refs/upstream/armadaos.dev@26dcfc3:docs/project/credits.md#L1-L3]

## The ABL (Android bootloader replacement)
- Armada ships ROCKNIX's ABL (`From ROCKNIX (https://github.com/ROCKNIX/abl), GPL-2.0`) as per-SoC signed ELFs plus backup/flash script templates; the Thor uses the `SM8550` one. [src: refs/upstream/armada@574da80:abl/README#L1-L1; refs/upstream/armada@574da80:abl/README#L5-L22]
- Install flow: copy the `rocknix_abl` folder to Android storage, back up the current ABL with `backup_abl.sh`, flash with `flash_abl.sh`, reboot holding VOL- to enter the ABL menu. [src: refs/upstream/armada@574da80:abl/README#L3-L26]
- In the menu (VOL-/+ to move, POWER to select) you set the device model, toggle the boot mode to Linux and choose Start. Most devices enter the menu with VOL-; the AYANEO Pocket DMG uses its `...` button. [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/flashing-to-an-sd-card.md#L54-L67]
- The menu also has "Switch boot mode" (back to Android) and "UNINSTALL CFW & EXPAND USERDATA". [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md#L9-L25]
- On the surveyed Thor the ABL version is 1.1.8 in both `abl_a` and `abl_b` (the stock Android bootloader slots the ABL replaces). [observed 2026-10-03: docs/hardware/device-observed.md; partition names: observed 2026-10-07, docs/boot-kernel/partition-layout.md]

## Device trees
Armada's Thor dts (`qcs8550-ayn-thor.dts`, plus the shared `qcs8550-ayn-common.dtsi`) is byte-identical to ROCKNIX's base copy, which carries the header "BSD-3-Clause, Copyright (c) 2025, Teguh Sobirin"; Armada layers its own `.dts.patch` on top. [src: docs/boot-kernel/devicetree-thor.md#L4-L8; refs/upstream/rocknix@9f8c79dc12:projects/ROCKNIX/devices/SM8550/linux/dts/qcom/qcs8550-ayn-thor.dts#L1-L3] The kernel patch index shows 143 `source:` entries pointing at `ROCKNIX/distribution`. [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md] See `docs/boot-kernel/mainline-linux-status.md`.

## Differences
- ROCKNIX describes itself as "an immutable Linux distribution for handheld gaming devices" developed by a community of enthusiasts. [src: refs/upstream/rocknix@9f8c79dc12:README.md#L5] (The earlier text called its rootfs "older, more traditional"; ROCKNIX's own README says immutable, so that wording is dropped.)
- Armada is a Fedora bootc image that mimics the SteamOS experience and updates through bootc/ostree; the Thor surveyed 2026-10-07 reports image `ghcr.io/armada-os/armada:testing`. [src: refs/upstream/armada@574da80:LICENSE.md#L20-L22; observed 2026-10-07: `bootc status`]
- Thorch, the Arch-based project, builds on the same ROCKNIX ABL layout; see `docs/comparison/thorch-and-related.md`.

## Sources
- [S1] refs/upstream/armada@574da80:abl/README, LICENSE.md
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/, docs/project/credits.md
- [S3] refs/upstream/rocknix@9f8c79dc12 (README.md, qcs8550-ayn-thor.dts)
