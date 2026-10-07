# Uninstall Armada / restore Android
> Scope: ABL-based removal and boot-mode switch · Researched: 2026-10-03 · Confidence: high

**Uninstall:** power off; hold **VOL-** while powering on → ABL; select **UNINSTALL CFW** (POWER) → choose **UNINSTALL CFW & EXPAND USERDATA** → POWER. [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md]
**Switch back to Android, keep Armada:** ABL → **Switch boot mode** → POWER until Boot mode reads **Android**. [src: same]
Armada Installer also offers **Remove and restore Android** ([install-internal](install-internal.md)).

## Restoring Stock ABL and Bootloader Lock State
Restoring the stock ABL requires the original `abl_a.img` and `abl_b.img` written by `backup_abl.sh` during the install. Armada's `abl/` folder ships a **`restore_backup_abl.sh.template`** for this (the script name `restore_abl.sh` that an earlier revision of this page used does not exist in the repo). [src: refs/upstream/armada@574da80:abl/restore_backup_abl.sh.template] Manual `fastboot flash abl_a/abl_b` of those images and a stock-ROM recovery route (`Thor_20251120_ota.zip` per the XDA thread) are described in [bootloader-root](../android/bootloader-root.md) [community source]. **Removed unsourced claims** from an earlier revision: that the Thor "ships with an unlocked bootloader by default" (the community guide says to *check* the state and that unlocking wipes the device) and that re-locking is "not officially supported" — neither is backed by a source. [UNVERIFIED]
## Sources
- [S1] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md, install-to-internal-storage.md
