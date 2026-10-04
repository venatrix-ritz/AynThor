# Install Armada to an SD card
> Scope: documented SD install flow (ABL flash + SD image), Thor notes · Researched: 2026-10-03 · Confidence: high for steps; Thor specifics marked

## Steps (paraphrased) [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/flashing-to-an-sd-card.md]
1. Download latest `armada-YYYYMMDD.img.gz` from the Downloads page (generated from GitHub releases). [src: refs/upstream/armadaos.dev@26dcfc3:docs/downloads/index.md]
2. Flash to a **64 GB+** SD card, A2 recommended (Etcher, Raspberry Pi Imager, Win32 Disk Imager, or `dd`).
3. **Flash the ROCKNIX ABL** (replaces Android's bootloader stage):
   - Boot Android with the SD inserted; copy `rocknix_abl` from the card to internal-storage root.
   - Use your SoC subfolder — Thor = **SM8550** (`rocknix_abl/SM8550`). Wrong-SoC ABL "can brick the device".
   - Run scripts via Android's vendor root-script tool ("Run script as Root"/"Root Script"; Retroid path: Handheld Settings > Advanced). On the Thor the menu is reported as *Settings → Thor settings → Run script as root* by a community guide (single source; [bootloader-root](../android/bootloader-root.md)) — the Armada docs do not give a Thor-specific path [UNVERIFIED on device].
   - Run `backup_abl.sh`; copy `abl_a.img` + `abl_b.img` to a PC; then run `flash_abl.sh`.
4. Power off; boot holding the bootloader key (**VOL-** for most devices) → ABL menu (VOL-/+ navigate, POWER select): set **device model**, **boot mode = Linux**, **Start**.
5. First boot: after the intro animation the screen may stay black up to ~60 s (expected on SD boot), then Steam first-run (language, timezone, Wi-Fi), Steam restarts, another ~60 s black possible.

## Preview images
Preview = a build per commit to `main`; latest five at https://downloads.armadaos.dev/preview. Switch Beta↔Preview via OS Update Channel (may need Developer Mode + "Show Advanced Update Channels"). [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/preview-images.md]

## Notes
The first release's README said volume-up for the ABL menu; current docs say VOL- — see [release-history](release-history.md).

## Sources
- [S1] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/flashing-to-an-sd-card.md, preview-images.md, downloads/index.md
