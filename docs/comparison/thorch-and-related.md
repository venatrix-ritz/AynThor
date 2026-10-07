# Thorch and Related Linux Distributions
> Scope: other Thor-compatible Linux OSes · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: high for Thorch (read from its repo at `82e7472`)

## Thorch (Thor + Arch Linux ARM)
Thorch is an experimental, unofficial Arch Linux ARM image for the AYN Thor, built on public ROCKNIX work. It is not affiliated with ROCKNIX, AYN, Valve, KDE or others. [src: refs/thor-linux/thorch@82e7472:README.md#L3-L6; refs/thor-linux/thorch@82e7472:NOTICE.md#L1-L4]
- **What it adds on top of ROCKNIX:** an Arch root filesystem, a ROCKNIX-derived Thor kernel with a BinderFS/Waydroid config fragment, its own initramfs repacked into the ROCKNIX-compatible boot image, local Arch packages and KDE defaults. [src: refs/thor-linux/thorch@82e7472:README.md#L11-L13]
- **Image and boot:** first target is a bootable SD image (internal install is "the intended performance path", SD stays the recovery path); a ROCKNIX-ABL-compatible FAT boot partition with a top-level Android boot image `/KERNEL`; roots are ext4 or compressed Btrfs. [src: refs/thor-linux/thorch@82e7472:README.md#L17-L19, #L37-L43]
- **Desktop:** Plasma Desktop (Wayland) is the default session while touch is being worked on; Plasma Mobile is optional. [src: refs/thor-linux/thorch@82e7472:README.md#L28-L30]
- **First boot:** `thorch-firstboot` starts a fullscreen QML onboarding flow on first login. [src: refs/thor-linux/thorch@82e7472:README.md#L247; refs/thor-linux/thorch@82e7472:docs/build.md#L250]
- **Internal install:** `thorch-install-internal`; the `--create-from-userdata` mode shrinks Android `userdata` by deleting and recreating it smaller, which wipes the Android instance. It never flashes or replaces ABL. [src: refs/thor-linux/thorch@82e7472:README.md#L86-L90; refs/thor-linux/thorch@82e7472:docs/internal-install.md#L9, #L40]
- **Shared base with Armada:** both rely on the ROCKNIX ABL boot layout and the fake-Android-boot-image `/KERNEL` approach. [src: refs/thor-linux/thorch@82e7472:README.md#L37-L41; docs/boot-kernel/boot-chain.md]
- **Licence:** a custom "Thorch source license" file; see `CREDITS.md`. [src: refs/thor-linux/thorch@82e7472:LICENSE#L1]

## ROCKNIX
ROCKNIX is the upstream of both: Thorch says the SM8550 and Thor enablement lives there and it "would not boot on Thor without ROCKNIX". [src: refs/thor-linux/thorch@82e7472:README.md#L51-L53] Armada's docs credit ROCKNIX for bootloader, device support, input mappings and audio profiles. [src: refs/upstream/armadaos.dev@26dcfc3:docs/project/credits.md#L1-L3] See `docs/boot-kernel/rocknix-relationship.md`.

## Sources
- [S1] refs/thor-linux/thorch@82e7472 (README.md, NOTICE.md, LICENSE, docs/build.md, docs/internal-install.md)
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/project/credits.md
