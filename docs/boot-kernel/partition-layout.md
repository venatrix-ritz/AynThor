# Partition Layout (UFS on AYN Thor 1TB)

> **Audit 2026-10-07 — unverified.** This doc has no citations. The LUN and partition list may come from a live read of the Thor by the Antigravity session, but no command output or source backs it and the device has since been reset. Treat every size and name as `[UNVERIFIED]` until re-read from the device (`lsblk`, `sgdisk -p`). See `docs/reference/open-questions.md`.

> Scope: Block device layout on an internal Armada OS installation · Researched: 2026-10-03 · Confidence: unverified (see banner)

The AYN Thor uses a Qualcomm UFS storage topology spanning several Logical Units (LUNs) exposed as block devices `sda` through `sdf`.

## UFS LUN Breakdown

### LUN 0 (`sda`) - System and User Data (949.2 GB)
This is the primary storage LUN. When installing Armada OS internally, the installer shrinks the Android `userdata` partition (to 50 GB by default) and appends Linux partitions at the end of the block device.
- `sda1` - `sda12`: Qualcomm specifics (`persist`, `frp`, `keystore`, `misc`, `rawdump`).
- `sda13`: `metadata` (64 MB).
- `sda14`: `super` (5.3 GB) - Android dynamic partitions (system, vendor).
- `sda17`: `userdata` (shrunk to 50 GB for Android apps).
- `sda18`: `ARMADA` (512 MB) - EFI System Partition, mounted at `/boot/efi`.
- `sda19`: `ARMADA_BOOT` (1 GB) - Linux boot partition.
- `sda20`: `ARMADA_ROOT` (890.3 GB) - BTRFS root for ostree (`/var`, `/sysroot`).

### LUN 1 & 2 (`sdb`, `sdc`) - Bootloader Backup (20 MB each)
Contains primary and backup (`_a` and `_b`) copies of the early boot stages.
- `xbl_a` / `xbl_b` (3.5 MB)
- `xbl_config`, `multiimgqti`

### LUN 3 (`sdd`) - Memory tuning (32 MB)
- `cdt` and `ddr` memory timings.

### LUN 4 (`sde`) - Firmware and Kernel Images (4 GB)
Contains the A/B partitions for the Qualcomm firmware, trustzone, and Android boot images.
- `modem_a/b`, `bluetooth_a/b`, `dsp_a/b`, `tz_a/b` (TrustZone), `hyp_a/b` (Hypervisor).
- `uefi_a/b`
- `abl_a/b` (1 MB): Android Bootloader. This is what the Armada installer flashes with a custom bootloader to dual-boot.
- `boot_a/b` (96 MB): Android Kernel.
- `dtbo_a/b` (24 MB): Device Tree Blob Overlay.
- `vendor_boot_a/b` (96 MB)
- `recovery_a/b` (100 MB)

### LUN 5 (`sdf`) - Modem Stash (32 MB)
- `modemst1`, `modemst2`, `fsg`, `fsc`.

## Loop Devices
When running Armada, a secondary `guestos` Android container runs to provide Waydroid emulation capabilities:
- `loop0`: `/run/armada/guestos/rootfs` (1.3 GB)
- `loop1`: `/run/armada/guestos/mesa` (6.4 MB)
