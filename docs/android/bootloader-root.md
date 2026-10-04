# Thor stock Android: bootloader, root, recovery
> Scope: bootloader unlock + Magisk root + brick-recovery as documented by one community guide · Researched: 2026-10-03 · Confidence: medium — single community source (written "against a real device", every command run per the author), not independently reproduced

Source repo: `refs/thor-android/ayn-thor-root-guide@8eed02f` (`ayn-thor-root-guide.md`), which cites the XDA thread "Ayn thor rooting guide" (https://xdaforums.com/t/ayn-thor-rooting-guide.4767974/).

## Facts
- Thor has a built-in **root script runner**: *Settings → Thor settings → Run script as root*. `adb root` does **not** work (production build: "adbd cannot run as root in production builds"). [src: refs/thor-android/ayn-thor-root-guide@8eed02f:ayn-thor-root-guide.md §2]
  - This is the same mechanism Armada's install flow needs to run `backup_abl.sh` / `flash_abl.sh` — see [install-sd](../armada/install-sd.md). The Armada docs only say "Run script as Root / Root Script" without the Thor menu path; the path here comes from this single guide [UNVERIFIED on my device].
- Bootloader state is shown after `adb reboot bootloader` (or power off + bootloader key): `DEVICE STATE - unlocked | locked`. Unlock = Developer options → OEM unlocking, then `fastboot flashing unlock` (fallback `fastboot oem unlock`); **unlocking factory-resets the device**. Unlocked boots show a warning screen and can trip strict integrity checks.
- Rooting touches only `init_boot`: dump `init_boot_a/b` with the root script runner (`dd` from `/dev/block/bootdevice/by-name/`), patch with Magisk, `fastboot flash init_boot`. Revert = flash the stock dump back. Slots normally identical (differ right after an OTA); active slot via `getprop ro.boot.slot_suffix`.
- OTAs will likely replace `init_boot` and remove root (re-patch after updating). Play Integrity Fix module reportedly works for root detection.
- **Stock ROM for recovery:** `Thor_20251120_ota.zip` (1.8 GB, build 2025-11-20) is attached to post #5 of the XDA thread; the AYN Discord link is reported dead (2026-07-19). Flashing may need `payload.bin` extraction (`payload-dumper-go`) and per-image `fastboot flash`.
- Relevance to Armada: the ROCKNIX ABL flash replaces a bootloader stage and takes `abl_a/abl_b` backups first; whether the stock Android bootloader state (locked/unlocked) matters for Armada is **not stated** in the Armada docs [UNVERIFIED]. Armada issue #48 reports `fastboot devices` returning empty despite correct enumeration (closed the same day; its body/resolution not read, relation to the Thor not established). [src: refs/_gh/issues.json#48]

## Sources
- [S1] refs/thor-android/ayn-thor-root-guide@8eed02f:ayn-thor-root-guide.md, README.md
- [S2] refs/_gh/issues.json (#48)
