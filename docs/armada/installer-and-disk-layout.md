# Installer and Disk Layout (Armada OS)
> Scope: the internal installer's partition plan, read from its source · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high, from `armada-installer` at `574da80`. Corrected: Android's size is chosen by the user (8 GiB minimum), not "defaulted to 50 GB", and the old text overstated the userdata "secure wipe".

## What the installer is
`armada-installer` is a Python script (`system_files/usr/libexec/armada/armada-installer`, 840 lines) with `detect` and `install` commands, a console path and a GTK path; `--device` defaults to `$ARMADA_INTERNAL_DEVICE`. It refuses to run on the boot disk and takes an exclusive lock. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L805-L815; refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L646-L650]

## Fresh install (no Armada partitions yet)
1. It reads the GPT with `sfdisk --json`, requires a GPT with 512- or 4096-byte sectors and exactly one `userdata` partition; anything after `userdata` is the "tail". [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L126-L128, #L161-L166]
2. Constants: ESP 512 MiB, boot 1 GiB, root minimum 32 GiB, Android minimum 8 GiB, plus 64 MiB reserve. The largest Android size offered is the space left after those. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L25-L28, #L175-L180]
3. The new Android (`userdata`) size is **chosen by the user**: `--userdata-gib` (required for an unattended run), an interactive prompt, or a slider in the GUI. There is no default of 50 GB in the code. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L652-L660, #L695-L699] (The Thor surveyed has `userdata` at 50.0 GiB, i.e. that was the size chosen at install. [observed 2026-10-07: docs/boot-kernel/partition-layout.md])
4. It shrinks `userdata` in the table and appends three partitions, preferring the next three numbers: `ARMADA` (EFI type, 512 MiB), `ARMADA_BOOT` (Linux, 1 GiB), `ARMADA_ROOT` (Linux, the rest). [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L233-L242]
5. Filesystems: `mkfs.btrfs -L root` with subvolumes `root`, `var`, `home`; `mkfs.vfat -F 16 -n ARMADA` for the ESP; `mkfs.ext4 -L boot` for the boot partition; an ostree sysroot is initialised on the root. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L533-L544]
6. Android data is destroyed by zeroing only the **first 8 MiB** of the shrunk `userdata` (`dd … bs=1M count=8`), not by a full secure wipe; the confirmation text says "All Android user data will be erased". [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L523-L525, #L248-L249]

## Re-install ("replace" mode)
If partitions already exist after `userdata`, the plan is `replace`: it erases all partitions after `userdata`, recreates the three Armada partitions and installs the running image; `userdata` and earlier partitions are untouched (no zeroing step in this mode). `--userdata-gib` is rejected in this mode. [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L216-L220, #L245-L247, #L523]

## Removal
The installer's epilog says "To uninstall, select UNINSTALL CFW in ABL." [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer#L806] Armada's docs: ABL menu → UNINSTALL CFW → "UNINSTALL CFW & EXPAND USERDATA". [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md#L9-L13] Whether the ABL also triggers an Android factory reset is not stated in these sources.

## Resulting layout on the Thor
See `docs/boot-kernel/partition-layout.md` (sda18–sda20, observed).

## Sources
- [S1] refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-installer
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md
