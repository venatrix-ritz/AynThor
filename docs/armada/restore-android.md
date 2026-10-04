# Uninstall Armada / restore Android
> Scope: ABL-based removal and boot-mode switch · Researched: 2026-10-03 · Confidence: high

**Uninstall:** power off; hold **VOL-** while powering on → ABL; select **UNINSTALL CFW** (POWER) → choose **UNINSTALL CFW & EXPAND USERDATA** → POWER. [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md]
**Switch back to Android, keep Armada:** ABL → **Switch boot mode** → POWER until Boot mode reads **Android**. [src: same]
Armada Installer also offers **Remove and restore Android** ([install-internal](install-internal.md)).

## Restoring Stock ABL and Bootloader Lock State
The Thor is shipped with an unlocked bootloader by default to permit custom OS installations. Restoring the stock ABL requires the original `abl_a.img` and `abl_b.img` files created during the install (`backup_abl.sh`). These can be restored via the `restore_abl.sh` script on the Android side, or manually flashed via `fastboot flash abl_a <file>` / `fastboot flash abl_b <file>`. Without these backups, users must request a factory image from AYN support. Re-locking the bootloader is generally unnecessary and not officially supported without a full factory image.
## Sources
- [S1] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/uninstalling-and-restoring-android.md, install-to-internal-storage.md
