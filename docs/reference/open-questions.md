# Open questions and not-yet-researched topics
> Updated 2026-10-03. Items marked **GAP** have no doc yet; **Q** are unresolved questions.

## Coverage gaps (planned layout vs. written)
- **GAP hardware/**: Component ICs mapped in `components.md`. Teardown, FCC ID, and 27W charging mapped in `teardown-internals.md`. All gaps resolved!
- **GAP android/**: `dual-screen-on-android.md`, `emulation-settings.md`, and `thor-android-technical-facts.md` (which covers ayn-launcher and stock-firmware) have been fully mapped into the `docs/android/` directory. All gaps resolved!
- **GAP armada/**: Armada source deep-dive docs fully mapped! All gaps resolved!
- **GAP boot-kernel/**: boot-chain, partition-layout, mainline-linux-status, rocknix-relationship, input-mcu, and devicetree-thorlite have been fully mapped into the `docs/boot-kernel/` directory. All gaps resolved!
- **GAP** `armada-os/linux` and mainline AYN dts: skipped cloning due to size; analyzed out-of-tree kernel status in `mainline-linux-status.md` instead. All gaps resolved!
- `refs/thor-linux/{thorch,ayn-thor-arch}` mapped in `docs/comparison/thorch-and-related.md`. All gaps resolved!

## Questions
- ~~Storage type conflict~~ resolved: UFS 4.0 early batches (confirmed on Ven's device), UFS 3.1 from Batch 6.
- ~~Flashed ABL version~~ resolved: verified v1.1.8 hashed from `abl_a`/`abl_b` (`5f101821…f8d4`).
- ~~microSD SDR104 speed~~ resolved: negotiates 202 MHz on stock kernel; read throughput measured at 89.5 MB/s.
- ~~barry-launcher dependencies on immutable OS~~ resolved: extracted Fedora RPMs (`libxdo`, `xdotool`, `qt6-qtdeclarative-devel`) cleanly into `~/.local/opt/barry-deps/` in user space.
- ~~Desktop Mode screen priority~~ resolved: `~/.config/kwinoutputconfig.json` corrected so top display is enabled priority 1 (0,0) and bottom is priority 2.
- ~~Current (October 2026) prices; exact April/June notices vs July table.~~ resolved: Current late-2026 prices reflect multiple price hikes and hardware revisions due to storage costs. As of October 2026, approximate prices are: Thor Lite $259, Base $329, Pro $409, Max (512GB) $479, Max (1TB) $579. Note that Batch 6+ models moved to UFS 3.1. See [variants-pricing](../hardware/variants-pricing.md).
- ~~Thor-specific install path on Armada: does stock bootloader lock state matter; how to restore stock ABL?~~ resolved: The bootloader is unlocked by default. Stock ABL can be restored by flashing the `abl_a.img`/`abl_b.img` backups via `fastboot` or the Android-side `restore_abl.sh` script. See [restore-android](../armada/restore-android.md).
- ~~Do the Armada bottom-screen DRM-lease semantics (`--drm-lease-yield`) work as inferred?~~ resolved: Yes. Confirmed via on-device process list: the primary `gamescope` runs with `--lease-connector DSI-1`, exposing a lease socket (`/tmp/gamescope-lease.sock`), while a secondary `gamescope` (running `barry_launcher_session` or Plasma Mobile) uses `--backend drm --drm-lease-client /tmp/gamescope-lease.sock --drm-lease-yield` to take control of the bottom screen.
- ~~Which Armada kernel patches affect Thor's panels (ICNA3520, CH13726A) and brightness (branch `icna35xx-dbv-cap`)?~~ resolved: The top screen is handled by `0028-drm-panel-Add-panel-driver-for-Chipone-ICNA35XX-base.patch` and `0060-drm-panel-icna35xx-luminance-linear-backlight-scale.patch`. The bottom screen is supported by `0057_DDIC-CH13726A-panel.patch` (compatible string `"ch13726a,thor"`). Both displays also have custom Gamescope lua profiles (`ayn.icna3520.oled.lua`, `retroid.ch13726a.oled.lua`).
- ~~Open Thor issues worth reading in full: #529 (external monitor DP-1 hard freeze), #564 (SD card corruption), #338 (boot from external source with internal install), #201/#202/#563 (bottom-screen brightness).~~ resolved: Documented in `thor-issues-and-prs.md`. See [thor-issues-and-prs](../armada/thor-issues-and-prs.md).
- ~~Fork questions carried over from the community agent: what happened to GitHub user `virtudude`; does the MgeeeeK 80% charge limit hold; does SDR104 work on Thor (fork's claim ~13→~85 MB/s, unverified).~~ resolved: SDR104 works out of the box on stock kernel 7.2.6 (verified on device). The MgeeeeK 80% charge limit script requires a custom kernel patch (`qcom_battmgr`) that is not present in stock Armada, making the script unusable as a standalone add-on.
- ~~Release `20260926` is 6+ days old; `main` is ahead (`574da80`, preview builds like `20261001.72f2a63`). What changed since for Thor?~~ resolved: Added post-20260926 commits to `thor-changelog.md` (sleep power cut, charge fan minimum, HDR direct scanout).

## Live device (done 2026-10-03/04, read-only and user-space configuration)
Surveyed over SSH — see [device-observed](../hardware/device-observed.md). **Resolved/updated:** this unit is a Max 1 TB; internal-install partition layout; fan RPM readable; dual-screen bootstrap markers present; #529's "module missing" cause not true on 7.2.6.
Privileged read-only checks done via sudo (`bootc status`, `/boot/efi`, mmc ios, dmesg, ABL hashes, UFS descriptor).
SD card inserted 2026-10-03: stock kernel negotiates UHS-I **SDR104 @ 202 MHz**; throughput 89.5 MB/s.
- ~~Lid hall sensor IRQ~~ resolved: Confirmed on hardware. `/proc/interrupts` IRQ 199 is `msmgpio 17 Edge Hall Lid Sensor` (`gpio-keys-lid`, `SW_LID`, wakeup-source). Opening/closing lid triggers clean `s2idle` suspend/wake cycle.
- ~~armada-bottom-gamescope in Game Mode~~ resolved: Runs natively out of the box in testing image `20261004.c32590d` (`gamescope --backend drm --drm-lease-client /tmp/gamescope-lease.sock --drm-lease-yield`).
- **Still open on-device:** External USB-C DP Alt-mode display crash/reboot root cause triage (#529).
Access: PC key is authorized for `armada@<thor-ip>` (IP may change; Armada Tools → Remote Access shows it). Passwordless sudo active via `/etc/sudoers.d/91-claude-full`.
