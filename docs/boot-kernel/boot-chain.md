# Boot Chain (Armada on Thor)
> Scope: from the bootloader to user space on an internal Armada install · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high for the `/KERNEL` mechanism (read from the regeneration script); the early Qualcomm stages are named from partitions only. The earlier text also said the ABL "looks for a file named KERNEL on the ARMADA EFI partition" and that the DTB is chosen "based on the device model set in the ABL menu"; the script's comments support both in spirit and are quoted below.

## 1. Early stages (what the disk shows)
`sdb` holds `xbl_a`, `xbl_config_a`, `multiimgqti_a`, `multiimgoem_a`, `apdp`; `sdc` holds the `_b` set; `sde` holds the A/B firmware images and `abl_a`/`abl_b`, `boot_a/b`, `vendor_boot_a/b`. [observed 2026-10-07: docs/boot-kernel/partition-layout.md] The roles of the first stages (PBL, XBL) are generic Qualcomm background and are not documented in `refs/`: `[UNVERIFIED]`.

## 2. The ABL (ROCKNIX's replacement)
Armada ships ROCKNIX's ABL for the Thor's SoC (SM8550); you enter its menu with VOL- to set the device model and the boot mode (Linux or Android). [src: refs/upstream/armada@574da80:abl/README#L1-L10, #L26-L31; refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/flashing-to-an-sd-card.md#L54-L67] The Thor's ABL measured v1.1.8 in both slots. [observed 2026-10-03: docs/hardware/device-observed.md] See `docs/boot-kernel/rocknix-relationship.md`.

## 3. `/KERNEL`: an Android boot image on the FAT ESP
- Armada's ostree setup has no bootloader of its own (`bootloader=none`), so a service rebuilds `/KERNEL` on the ESP (`/boot/efi`) for the next-boot deployment: the script is `armada-bootimg-update`, run by `armada-bootimg-sync.service` before reboot and again after a staged deployment finalizes (`armada-bootimg-finalize` as an `ExecStop` of `ostree-finalize-staged`). [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-bootimg-update#L1-L3; refs/upstream/armada@574da80:system_files/usr/lib/systemd/system/armada-bootimg-sync.service#L1-L9; refs/upstream/armada@574da80:system_files/usr/lib/systemd/system/ostree-finalize-staged.service.d/10-armada-bootimg.conf#L1-L7]
- Steps: pick the highest-version Boot Loader Spec entry as the next-boot deployment, read its `linux`, `initrd` and `ostree=` karg; `gzip -c` the kernel; append every DTB named in the deployment's `usr/lib/armada/supported-dtbs`; then `mkbootimg.py` with header-v0 geometry (`--base 0x10000000 --pagesize 2048 --kernel_offset 0x8000 …`). The script's comment: "ROCKNIX ABL expects gzip(Image) with all supported DTBs appended; its model picker chooses among them at boot." [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-bootimg-update#L141-L150; refs/upstream/armada@574da80:system_files/usr/lib/armada/bootimg-args#L3]
- The command line is capped at 512 bytes with `ostree=` first, so a truncated header loses tuning arguments rather than the root pointer. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/bootimg-args#L5-L12]
- A known-good spare `KERNEL.BAK` (with `.armada-bootimg*.id` stamps) is kept so a corrupt `/KERNEL` can be fixed from any PC that reads the card; the file name is plain 8.3 because a long name would also generate a short alias next to `KERNEL`, "the one name the ABL looks up". [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-bootimg-update#L13-L16, #L43-L50] The Thor had `KERNEL`, `KERNEL.BAK` and the stamps on `/boot/efi`. [observed 2026-10-03: docs/hardware/device-observed.md]
- If `/boot/efi` is not mounted the script refuses to write `/KERNEL`. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-bootimg-update#L36-L41]

## 4. Ostree and bootc
The kernel boots with the `ostree=` argument from the BLS entry, mounts the btrfs `ARMADA_ROOT` (`sda20`: subvolumes `root`, `var`, `home`) and enters the ostree deployment. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L533-L538; observed 2026-10-07: docs/boot-kernel/partition-layout.md]

## Sources
- [S1] refs/upstream/armada@574da80 (abl/README, armada-bootimg-update, bootimg-args, units)
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/flashing-to-an-sd-card.md
- [S3] docs/hardware/device-observed.md, docs/boot-kernel/partition-layout.md
