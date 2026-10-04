# Install Armada to internal storage
> Scope: Armada Installer behaviour and recovery · Researched: 2026-10-03 · Confidence: high (docs)

Open **Desktop Mode → Armada Installer (System menu)** from the SD-booted system. Options: [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/install-to-internal-storage.md]
- **Install alongside Android** (fresh device): choose how much storage Android keeps; Armada takes the rest. **Factory-resets Android** (apps/data lost).
- **Reinstall / Switch to Armada** (ROCKNIX/Armada present): replaces the Linux install, **leaves Android untouched**.
- **Remove and restore Android**: erase Armada/ROCKNIX; disk returns to Android (factory reset on next Android boot).
Then power off and remove the SD card.

**Verify boot source:** hold **VOL-** at power-on → ABL; **Boot source = Internal** (select "Switch boot source", POWER toggles).
**Recovery:** interrupted install → rerun the installer from SD; won't boot → ABL → Boot source = **SDCard**; full Android userdata restore → [restore-android](restore-android.md).
History: internal installer first shipped in 20260621; reimplemented in 20260915 ([release-history](release-history.md)).

## Sources
- [S1] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/install-to-internal-storage.md
