# Installer and Disk Layout (Armada OS)
> Scope: The internal installation mechanism and disk layout strategy · Researched: 2026-10-03 · Confidence: high

Armada is installed via the `armada-installer` Python script. When running from a live USB (or SD card), the installer interrogates the primary UFS storage (`sda`) and calculates a partition plan.

## Partitioning Strategy
The installer targets `sda`, the primary LUN, which houses Android's `userdata` partition.
1. **Locate Userdata:** The installer finds the `userdata` partition (typically `sda17`).
2. **Calculate Free Space:** The maximum size for Android is calculated based on the block device capacity minus required Linux partitions (`ESP`, `BOOT`, `ROOT`).
3. **Shrink and Wipe Userdata:** On a fresh internal installation, the installer shrinks the size of `userdata` in the partition table (defaulting to 50 GB) and securely wipes its header. **This wipes all Android data on the device.**
4. **Append Linux Partitions:** Three partitions are created in the remaining space:
   - `ARMADA` (512 MB): EFI System Partition (`mkfs.vfat`)
   - `ARMADA_BOOT` (1 GB): Linux boot partition (`mkfs.ext4`)
   - `ARMADA_ROOT` (remainder of disk): Ostree BTRFS root (`mkfs.btrfs -L root`)

## Replacement (Re-install)
If Armada partitions already exist (e.g. `ARMADA`, `ARMADA_BOOT`, `ARMADA_ROOT`), the installer enters "replace" mode. It will wipe these three partitions and reinstall the running image onto them, while leaving the `userdata` partition untouched (preserving Android data across an Armada reinstall).

## Removal
As documented in `restore-android.md`, removing the CFW requires booting into the ABL menu and selecting "UNINSTALL CFW & EXPAND USERDATA". This tells the ABL to delete the Linux partitions, expand the `userdata` partition back to its original size, and trigger an Android factory reset.
