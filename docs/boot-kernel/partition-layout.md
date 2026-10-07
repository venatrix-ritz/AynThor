# Partition Layout (UFS on AYN Thor 1TB)

> **Re-verified 2026-10-07 against the device** (`lsblk`, `sudo sgdisk -p /dev/sda`, `mount`; Thor Max 1 TB, Armada `testing` `20261006.9c7dd3e`, internal install). Everything marked `[observed 2026-10-07]` was read from the device. Sizes are binary units as printed by `lsblk`/`sgdisk` (GiB/MiB). Statements without a tag (what the installer does, what a partition is for) are not backed by a citation. The loop-device section was wrong before and is corrected below.

> Scope: Block device layout on an internal Armada OS installation · Researched: 2026-10-03, re-checked 2026-10-07 · Confidence: high for names/sizes, unverified for purposes

The AYN Thor exposes its UFS storage as six LUNs, `sda` through `sdf`. [observed 2026-10-07]

## UFS LUN Breakdown

### LUN 0 (`sda`) - System and User Data (949.2 GiB, model SKhynix HN8T374ZJKX141, 4096-byte sectors) [observed 2026-10-07]
The primary storage LUN. A GPT with 20 partitions. The installer shrinks Android `userdata` and appends the Linux partitions at the end (installer behaviour not re-checked; the resulting layout below was observed).
- `sda1` - `sda12`: `nvdata1`, `nvdata2`, `reserve1`, `reserve2`, `persist` (32 MiB ext4), `qpdata1`, `qpdata2`, `frp`, `keystore`, `ssd`, `rawdump` (2 GiB), `misc`. [observed 2026-10-07]
- `sda13`: `metadata` (64 MiB, f2fs). [observed 2026-10-07]
- `sda14`: `super` (5.3 GiB), the Android dynamic-partition container (system, vendor). [observed 2026-10-07: size and name; contents not inspected]
- `sda15`, `sda16`: `vbmeta_system_a` / `vbmeta_system_b` (64 KiB each). [observed 2026-10-07]
- `sda17`: `userdata` (50.0 GiB; no filesystem reported by `lsblk`, not mounted). [observed 2026-10-07]
- `sda18`: `ARMADA` (512 MiB, vfat, type EF00), mounted at `/boot/efi`. [observed 2026-10-07]
- `sda19`: `ARMADA_BOOT` (1 GiB, ext4, label `boot`), mounted at `/boot`. [observed 2026-10-07]
- `sda20`: `ARMADA_ROOT` (890.3 GiB, btrfs, label `root`), mounted at `/sysroot`, `/var`, `/var/home` and `/etc` (ostree deployment). [observed 2026-10-07]

### LUN 1 & 2 (`sdb`, `sdc`) - Early boot stages (20 MiB each) [observed 2026-10-07]
`sdb` holds the `_a` set and `sdc` the `_b` set: `xbl_a`/`xbl_b` (3.5 MiB), `xbl_config_*`, `multiimgqti_*`, `multiimgoem_*`, and `apdp`/`apdpb`.

### LUN 3 (`sdd`) - Config tables (32 MiB) [observed 2026-10-07]
`ALIGN_TO_128K_1`, `cdt`, `ddr`. (What `cdt`/`ddr` contain was not inspected; earlier text called them "memory timings".)

### LUN 4 (`sde`) - Firmware and boot images (4 GiB, 80 partitions) [observed 2026-10-07]
A/B pairs for the Qualcomm firmware and the Android boot chain:
- `modem_a/b` (320 MiB), `bluetooth_a/b`, `dsp_a/b` (64 MiB), `tz_a/b`, `hyp_a/b`, `uefi_a/b` (5 MiB), `vm-bootsys_a/b`, `aop_*`, `cpucp_*`, `devcfg_*`, `keymaster_*`, `qupfw_*`, `shrm_*` and others.
- `abl_a` / `abl_b` (1 MiB each). The Armada installer replaces these with the ROCKNIX ABL (see `docs/boot-kernel/boot-chain.md`; this doc does not re-prove that).
- `boot_a/b` (96 MiB), `dtbo_a/b` (24 MiB), `vendor_boot_a/b` (96 MiB), `init_boot_a/b` (8 MiB), `recovery_a/b` (100 MiB), `vbmeta_a/b` (64 KiB).
- Unpaired: `logdump` (512 MiB), `splash` (32 MiB), `imagefv_a/b`, `vm-persist` (120 MiB), `uefivarstore`, `qmcs`, `loader_a/b` and various small ones.

### LUN 5 (`sdf`) - Modem storage (32 MiB) [observed 2026-10-07]
`ALIGN_TO_128K_2`, `modemst1`, `modemst2`, `fsg`, `fsc`.

## Loop devices (corrected 2026-10-07)
The earlier version described a Waydroid Android container and listed `loop0`/`loop1` with sizes that do not match. The device shows three read-only loop mounts (identify them by mount point; the loop numbers differ from the earlier text): [observed 2026-10-07]

| Mount point | Image | Type | Size |
|---|---|---|---|
| `/usr/share/guestos/android` | `/usr/share/armada/lepton/guestos-android.erofs` | erofs | 14.9 MiB |
| `/run/armada/guestos/rootfs` | `/usr/share/fex-emu/RootFS/ArchLinux.sqsh` | squashfs | 1.3 GiB |
| `/run/armada/guestos/mesa` | `/usr/share/fex-emu/RootFS/ArmadaMesa.sqsh` | squashfs | 19.3 MiB |

`rootfs` and `mesa` are overlaid read-only at `/usr/share/guestos/fex-mesa`, which Armada's build script points FEX's `RootFS` at for the x86 Proton chain, and `armada-guestos.service` fills it at boot. [src: refs/upstream/armada@574da80:build_files/30-install-steam-session.sh#L86-L95] [observed 2026-10-07: the overlay mount]. What `guestos-android.erofs` is used for was not checked; it is not evidence of Waydroid.

## Sources
- [S1] On-device read-only commands, 2026-10-07: `lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINTS`, `sudo sgdisk -p /dev/sda`, `parted unit B print`, `mount | grep -E "guestos|loop"`.
- [S2] refs/upstream/armada@574da80:build_files/30-install-steam-session.sh#L86-L95 (FEX guestos RootFS overlay).
